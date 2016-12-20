

#import "P2PClient.h"
#import "P2PCInterface.h"
#import "Utils.h"
#import "Constants.h"
#import "config.h"
#import "PAIOUnit.H"

#import "FListManager.h"
#import "mesg.h"
#import "des2.h"
#import "CameraManager.h"

#import "Alarm.h"
#import "AlarmDAO.h"
#import "UDPManager.h"
#import "LocalDevice.h"
#import "MP4Recorder.h"
#import "MD5Manager.h"

static sRecFilenameType playbackFiles[1024];//视频回放修复
static int playbackFilesLength  = 0;
static int playbackCurrentFileIndex = -1;

@implementation P2PClient

int Get3cidByIp(int dwIp)
{
    if (dwIp<256) {
        NSArray* deviceList = [[UDPManager sharedDefault] getLanDevices];
        for (int i=0; i<[deviceList count]; i++)
        {
            LocalDevice *localDevice = [deviceList objectAtIndex:i];
            NSString* address = localDevice.address;
            NSArray *array = [address componentsSeparatedByString:@"."];
            NSString* sID = [array objectAtIndex:3];
            if (sID.intValue == dwIp) {
                return localDevice.contactId.intValue;
            }
        }
    }
    return dwIp;
}
//contactId   对方(接收方)ID
int GetIpBy3CID(int contactId)
{
    NSArray* deviceList = [[UDPManager sharedDefault] getLanDevices];
    
    for (int i=0; i<[deviceList count]; i++)
    {
        LocalDevice *localDevice = [deviceList objectAtIndex:i];
        if (localDevice.contactId.intValue == contactId)
        {
            NSString* address = localDevice.address;
            NSArray *array = [address componentsSeparatedByString:@"."];
            NSString* sID = [array objectAtIndex:3];
            return sID.intValue;
        }
    }
    return contactId;
}


-(void)dealloc{
    [self.callId release];
    [self.callPassword release];
    [self.loadedplaybackFiles release];//视频回放修复
    [super dealloc];
}

+ (P2PClient*)sharedClient
{
    
    static P2PClient *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[P2PClient alloc] init];
        manager.isSendProcRunning = NO;
        manager.callPassword = @"";
        manager.loadedplaybackFiles = [NSMutableArray arrayWithCapacity:0];//视频回放修复add
    });
    return manager;
}

-(BOOL)p2pConnectWithId:(NSString *)contactId codeStr1:(NSString *)codeStr1 codeStr2:(NSString *)codeStr2{
    if(![contactId isValidateNumber]){
        return NO;
    }
    
    if(![codeStr1 isValidateNumber]){
        return NO;
    }
    
    if(![codeStr2 isValidateNumber]){
        return NO;
    }
    sP2PInitPrm mP2Pprm;
    mP2Pprm.dw3CID = contactId.intValue;
    mP2Pprm.dw3CID |= 0x80000000 ;
    mP2Pprm.dwCode1 = codeStr1.intValue;
    mP2Pprm.dwCode2 = codeStr2.intValue;
    
    mP2Pprm.pHostName ="|p2p1.cloudlinks.cn|p2p2.cloudlinks.cn|p2p3.cloud-links.net|p2p4.cloud-links.net|p2p5.cloudlinks.cn|p2p6.cloudlinks.cn|p2p7.cloudlinks.cn|  p2p8.cloudlinks.cn|p2p9.cloudlinks.cn|p2p10.cloudlinks.cn";

    mP2Pprm.dwChNs         = 1;
    mP2Pprm.dwChBufSize[0] = 1024*512;
    mP2Pprm.dwChBufSize[1] = 1024*512;
    mP2Pprm.dwChBufSize[2] = 1024*512;
    mP2Pprm.dwChBufSize[3] = 1024*512;
    mP2Pprm.dwPassword     = 1792802871;
    

    mP2Pprm.dwCustomerID[0] = 10;//设备加密_索普达---10
    mP2Pprm.dwCustomerID[1] = 34;//设备加密_黑猫---34
    mP2Pprm.dwCustomerID[2] = 101;//设备加密_Don Don---101
    mP2Pprm.dwCustomerID[3] = 0;
    mP2Pprm.dwCustomerID[4] = 0;
    mP2Pprm.dwCustomerID[5] = 0;
    mP2Pprm.dwCustomerID[6] = 0;
    mP2Pprm.dwCustomerID[7] = 0;
    mP2Pprm.dwCustomerID[8] = 0;
    mP2Pprm.dwCustomerID[9] = 0;
    mP2Pprm.vCallingSignal = vCallingSignal;
    mP2Pprm.vRejectSignal  = vRejectSignal;
    mP2Pprm.vAcceptSignal  = vAcceptSignal;
    mP2Pprm.vP2PConnReady  = vP2PConnReady;
    mP2Pprm.vRecvRemoteMessage = vRecvRemoteMessage;
    mP2Pprm.vSendMessageAck=    vSendMessageAck;
    mP2Pprm.vFriendsStatusUpdate = vFriendsStatusUpdate;
    mP2Pprm.vFlagUpdate = NULL;
    _srecAndDecPrm.vRecvUserDataCallBack = commandSettingInAction;
    
    return fgP2PInit(&mP2Pprm);
    
}

void commandSettingInAction(DWORD dwCmd, DWORD  dwOption , DWORD * pdwData,  DWORD  dwDataLen)
{
    if (dwCmd == USR_CMD_AUDIO_ONLY) {
        if (dwOption == 1) {
            DLog(@"开启");
        }else{
            DLog(@"关闭");
        }
        
        NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_CHANGE_VIDEO_STATE];
        NSNumber *value  = [NSNumber numberWithBool:dwOption];
        NSDictionary *parameter = @{@"key": key,
                                    @"value" : value};
        [[P2PClient sharedClient] receivePlayingCommand:parameter];
        
    }
    
    if (dwCmd == USR_CMD_CURRENT_USERS_NS) {
        //NSLog(@"%i",dwOption);
        NSNumber *value  = [NSNumber numberWithInt:dwOption];
        NSDictionary *parameter = @{@"value" : value};
        [[P2PClient sharedClient] receivePlayingCommand:parameter];
    }
    
    if (dwCmd == USR_CMD_PLAY_CTL) {
        
        DLog(@"%i",dwOption);
        switch (dwOption) {
            case USR_CMD_OPTION_FILE_INFO:
            {
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PLAYING];
                vSetSupperDrop(FALSE);
                
                [[P2PClient sharedClient] setPlayback_startTime:(((uint64_t)pdwData[0]<<32)|pdwData[1])];
                [[P2PClient sharedClient] setPlayback_endTime:(((uint64_t)pdwData[2]<<32)|pdwData[3])];
                
                UINT64 totalTime = [[P2PClient sharedClient] playback_endTime] - [[P2PClient sharedClient] playback_startTime];
                [[P2PClient sharedClient] setPlayback_totalTime:totalTime];
            }
                break;
            case USR_CMD_OPTION_FILE_END:
            {
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_STOP];
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_STOP];
                
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
            }
                break;
            case USR_CMD_OPTION_STOP_RET:
            {
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_STOP];
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_STOP];
                
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
            }
                break;
            case USR_CMD_OPTION_PLAY_RET:
            {
                vSetSupperDrop(FALSE);
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PLAYING];
                
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_START];
                
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
            }
                break;
            case USR_CMD_OPTION_JUMP_RET:{
                vSetSupperDrop(FALSE);
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PLAYING];
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_START];
                
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
                break;
            }
            case USR_CMD_OPTION_NEXT_FILE_RET:{
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PLAYING];
                vSetSupperDrop(FALSE);
                NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_START];
                NSDictionary *parameter = @{@"key": key};
                [[P2PClient sharedClient] receivePlayingCommand:parameter];
                break;
            }
            default:
                break;
        }
    }
    return;
}

- (void)receivePlayingCommand:(NSDictionary *)dictionary
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_PLAYING_CMD
                                                        object:self
                                                      userInfo:dictionary];
}

-(NSInteger)getPlaybackCurrentFileIndex{
    return playbackCurrentFileIndex;
}

-(NSInteger)getPlaybackFilesLength{
    return playbackFilesLength;
}

-(void)previous{
    if(playbackCurrentFileIndex==0){
        return;
    }
    
    [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_STOP];
    NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_STOP];
    NSDictionary *parameter = @{@"key": key};
    [[P2PClient sharedClient] receivePlayingCommand:parameter];
    BYTE prm[8];
    playbackCurrentFileIndex -= 1;
    memcpy(prm, &(playbackFiles[playbackCurrentFileIndex]), sizeof(sRecFilenameType));
    fgSendUserData(USR_CMD_PLAY_CTL, USR_CMD_OPTION_NEXT_FILE, prm, sizeof(sRecFilenameType));
    
}

-(void)next{
    if(playbackCurrentFileIndex>=(playbackFilesLength-1)){
        return;
    }
    
    [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_STOP];
    NSNumber *key = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_PLAYBACK_STOP];
    NSDictionary *parameter = @{@"key": key};
    [[P2PClient sharedClient] receivePlayingCommand:parameter];
    
    BYTE prm[8];
    playbackCurrentFileIndex += 1;
    memcpy(prm, &(playbackFiles[playbackCurrentFileIndex]), sizeof(sRecFilenameType));
    fgSendUserData(USR_CMD_PLAY_CTL, USR_CMD_OPTION_NEXT_FILE, prm, sizeof(sRecFilenameType));
    vSetSupperDrop(TRUE);
}

-(void)jump:(UInt64)value{
    UInt64 jumpValue = (self.playback_startTime+value*1000000);
    
    
    fgSendUserData(USR_CMD_PLAY_CTL, USR_CMD_OPTION_JUMP, (BYTE*)(&jumpValue), sizeof(UInt64));
    vSetSupperDrop(TRUE);
}

-(void)p2pDisconnect{
    // 网络库退出并释放资源
    vP2PExit();
}

#define  FLAG_VIDEO_TRANS_QVGA 	 (0)  //
#define  FLAG_VIDEO_TRANS_HD     (1)  //
#define  FLAG_VIDEO_TRANS_VGA   (2)  //
-(void)p2pCallWithId:(NSString *)contactId password:(NSString*)password callType:(P2PCallType)type{
    self.p2pCallType = type;
    self.callId = contactId;
    if(!password){
        password = @"";
    }
    if (contactId)
    {
        UINT64 iCallId = [contactId intValue];
        if ([contactId hasPrefix:@"0"]){
            iCallId |= 0x80000000;
        }
#pragma mark -  用IP来监控  如果要在没有外网的情况下，不要让客户使用 注释掉
//        int iTargetID = GetIpBy3CID(contactId.intValue);
//        if (iTargetID != contactId.intValue) {
//            iCallId = iTargetID;
//        }
        
        NSString *callMsg = @"test callMsg";
        DWORD dwCallPrm[4];
        switch (type) {
            case P2PCALL_TYPE_MONITOR:{
                dwCallPrm[0] = CONN_TYPE_MONITOR;
                dwCallPrm[1] = LOCAL_VIDEO_ABILITY ;
                dwCallPrm[2] = FLAG_VIDEO_TRANS_VGA ;
                dwCallPrm[3] = 0 ;
                
                if(fgP2PCall(iCallId, 1, [password intValue], dwCallPrm, (char *)[callMsg UTF8String])){
                    DLog(@"call success.");
                }else{
                    DLog(@"call failure.");
                }
                break;
            }
            case P2PCALL_TYPE_VIDEO:{
                
                dwCallPrm[0] = CONN_TYPE_VIDEO_CALL;
                dwCallPrm[1] = LOCAL_VIDEO_ABILITY ;
                dwCallPrm[2] = 0 ;
                dwCallPrm[3] = 0 ;
                
                fgP2PCall(iCallId, 0, 0, dwCallPrm, (char *)[callMsg UTF8String]);
                break;
            }
                
            default:
                break;
        }
        
    }
    
}

-(void)p2pPlaybackCallWithId:(NSString *)contactId password:(NSString *)password index:(NSInteger)index{
    if(index>=playbackFilesLength){
        return;
    }
    playbackCurrentFileIndex = (int)index;
    self.p2pCallType = P2PCALL_TYPE_PLAYBACK;
    self.callId = contactId;
    if(!password){
        password = @"";
    }
    
    
    if (contactId)
    {
        UINT64 iCallId = [contactId intValue];
        if ([contactId hasPrefix:@"0"]){
            iCallId |= 0x80000000;
        }
        int iTargetID = GetIpBy3CID(contactId.intValue);
        if (iTargetID != contactId.intValue) {
            iCallId = iTargetID;
        }
        
        NSString *callMsg = @"";
        DWORD dwCallPrm[4];
        dwCallPrm[0] = CONN_TYPE_FILE_TRANS;
        dwCallPrm[1] = LOCAL_VIDEO_ABILITY ;
        dwCallPrm[2] = ((DWORD*)(&playbackFiles[index]))[0];
        dwCallPrm[3] = ((DWORD*)(&playbackFiles[index]))[1];
        
        fgP2PCall(iCallId, 1, [password intValue], dwCallPrm, (char *)[callMsg UTF8String]);
    }
}

- (void)p2pAccept {
    DWORD dwCallPrm[4];
    dwCallPrm[0] = CONN_TYPE_VIDEO_CALL;
    dwCallPrm[1] = LOCAL_VIDEO_ABILITY ;
    dwCallPrm[2] = 0 ;
    dwCallPrm[3] = 0 ;
    vP2PAccept(dwCallPrm);
}

- (void)p2pHungUp
{
    if (self.isFromVideoController)
    {
        self.isFromVideoController = NO;
        [[CameraManager sharedManager] stopCamera];//用于视频通话,所以监控、回放挂断时，不应调用
    }
    [[MP4Recorder sharedDefault]stopRecord];
    [[MP4Recorder sharedDefault] resetVideoSize];
    vStopRecvAndDec();
    vStopAVEncAndSend();
    vP2PHungup(FALSE);
}

- (void)sendCommandType:(int)type andOption:(int)option
{
    fgSendUserData(type, option, NULL, 0);
}

- (void)startCall
{
    DLog(@"startCall.");
    [UIView animateWithDuration:0.1 animations:^{
        
        
    } completion:^(BOOL finished) {
        
        //srecAndDecPrm.dwConnectType = self.chattingCallType;
        //        srecAndDecPrm.dwConnectType = 1;
        
        _srecAndDecPrm.dwConnectType = self.p2pCallType;
        _srecAndDecPrm.vRecvAVData = vRecvAVData1;
        _srecAndDecPrm.vRecvAVHeader = vRecvAVHeader1;
        _srecAndDecPrm.vRecvUserDataCallBack = commandSettingInAction;
        if(fgStartRecvAndDec(&(_srecAndDecPrm))){
            DLog(@"fgStartRecvAndDec success.");
        }
        if (self.p2pCallType == P2PCALL_TYPE_VIDEO || self.p2pCallType == P2PCALL_TYPE_MONITOR) {
            fgStartAVEncAndSend(VIDEO_FRAME_RATE);
        }
    }];
    
}

#pragma mark - p2p call back

void vCallingSignal(sCallingPrmType *sCallPrm) {
    NSLog(@"vCallingSingal");
    unsigned int fgBCalled;
    unsigned int dwHisID;
    unsigned int dwDevType;
    unsigned int fgInSameDomain;
    unsigned int fgMonitorOnly;
    unsigned int dwRemoteChNs;
    
    fgBCalled = sCallPrm->fgBCalled;
    dwHisID = sCallPrm->dwHisID;
    dwDevType = sCallPrm->dwHisDevType;
    fgInSameDomain = sCallPrm->fgInSameDomain;
    fgMonitorOnly = sCallPrm->fgSuperCall;
    dwRemoteChNs = sCallPrm->dwRemoteChNs;
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    
    if(fgBCalled==1){
        [info setObject:[NSString stringWithFormat:@"%i",dwHisID&0x7fffffff] forKey:@"callId"];
        [info setObject:@"YES" forKey:@"isBCalled"];
    }else{
        //[info setObject:@"0" forKey:@"callId"];
        [info setObject:@"NO" forKey:@"isBCalled"];
    }
    
    [[P2PClient sharedClient] performSelectorOnMainThread:@selector(delegateCalling:) withObject:info waitUntilDone:YES];
}

void vRejectSignal(unsigned int fgBCalled,  unsigned int dwErrorOption)
{
    NSLog(@"vRecjectSignal");
    NSString *rejectMsg = nil;
    switch((int)dwErrorOption)
    {
        case CALL_ERROR_NONE:
        {
            rejectMsg = NSLocalizedString(@"id_unknown_error", nil);
            break;
        }
        case CALL_ERROR_DESID_NOT_ENABLE:
        {
            rejectMsg = NSLocalizedString(@"id_disabled", nil);
            break;
        }
        case CALL_ERROR_DESID_OVERDATE:
        {
            rejectMsg = NSLocalizedString(@"id_overdate", nil);
            break;
        }
        case CALL_ERROR_DESID_NOT_ACTIVE:
        {
            rejectMsg = NSLocalizedString(@"id_inactived", nil);
            break;
        }
        case CALL_ERROR_DESID_OFFLINE:
        {
            rejectMsg = NSLocalizedString(@"id_offline", nil);
            break;
        }
        case CALL_ERROR_DESID_BUSY:
        {
            rejectMsg = NSLocalizedString(@"id_busy", nil);
            break;
        }
        case CALL_ERROR_DESID_POWERDOWN:
        {
            rejectMsg = NSLocalizedString(@"id_powerdown", nil);
            break;
        }
        case CALL_ERROR_NO_HELPER:
        {
            rejectMsg = NSLocalizedString(@"id_connect_failed", nil);
            break;
        }
        case CALL_ERROR_HANGUP:
        {
            rejectMsg = NSLocalizedString(@"id_hangup", nil);
            break;
        }
        case CALL_ERROR_TIMEOUT:
        {
            rejectMsg = NSLocalizedString(@"id_timeout", nil);
            break;
        }
        case CALL_ERROR_INTER_ERROR:
        {
            rejectMsg = NSLocalizedString(@"id_internal_error", nil);
            break;
        }
        case CALL_ERROR_RING_TIMEOUT:
        {
            rejectMsg = NSLocalizedString(@"id_no_accept", nil);
            break;
        }
        case CALL_ERROR_PW_WRONG:
        {
            rejectMsg = NSLocalizedString(@"id_password_error", nil);
            break;
        }
        case CALL_ERROR_CONN_FAIL:
        {
            rejectMsg = NSLocalizedString(@"id_connect_failed", nil);
            break;
        }
        case CALL_ERROR_NOT_SUPPORT:
        {
            rejectMsg = NSLocalizedString(@"id_not_support", nil);
        }
        default:
            rejectMsg = NSLocalizedString(@"id_unknown_error", nil);
            break;
    }
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setObject:rejectMsg forKey:@"rejectMsg"];
    [[P2PClient sharedClient] performSelectorOnMainThread:@selector(delegateReject:) withObject:info waitUntilDone:YES];
    
}
#define       VIDEO_ABILITY_16_9        (1<<7)
void vAcceptSignal(unsigned int fgBCalled, unsigned int  *pdwPrm)
{
    
    BOOL is16b9 = NO;
    if(pdwPrm[0]==CONN_TYPE_MONITOR||pdwPrm[0]==CONN_TYPE_FILE_TRANS||pdwPrm[0]==CONN_TYPE_VIDEO_CALL){
        if(((pdwPrm[1] >> 24)& VIDEO_ABILITY_16_9 )||((pdwPrm[1] >> 16)& VIDEO_ABILITY_16_9 ))
        {
            is16b9 = YES;
        }
    }
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setObject:[NSNumber numberWithBool:is16b9] forKey:@"is16b9"];
//    接受委托
    [[P2PClient sharedClient] performSelectorOnMainThread:@selector(delegateAccept:) withObject:info waitUntilDone:YES];
}

void vP2PConnReady(void)
{
    NSLog(@"vP2PConnReady");
//    准备委托
    [[P2PClient sharedClient] performSelectorOnMainThread:@selector(delegateReady:) withObject:nil waitUntilDone:YES];
}





-(void)getContactsStates:(NSArray *)contacts{
    if(!contacts||[contacts count]==0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateContactState" object:nil];
    }
    unsigned int tables[[contacts count]];
    for(int i=0;i<[contacts count];i++){
        
        NSString *contactId = [contacts objectAtIndex:i];
        if([contactId characterAtIndex:0]=='0'){
            tables[i] = contactId.intValue|0x80000000;
        }else{
            tables[i] = contactId.intValue;
        }
    }
    fgP2PGetFriendsStatus(tables, (unsigned int)[contacts count]);
}

void   vFriendsStatusUpdate(sFriendsType * pFriends )
{
    int count = pFriends->dwFriendsCount;
    
    
    for(int i=0;i<count;i++){
        unsigned int state = (unsigned int)pFriends->bStatus[i]&0xf;
        unsigned int type = (unsigned int)pFriends->bType[i]&0xf;
        unsigned int iContactId = (unsigned int)pFriends->dwFriends[i]&0x7fffffff;
        NSString *contactId = nil;
        
        if(((unsigned int)pFriends->dwFriends[i]&0x80000000)!=0){
            contactId = [NSString stringWithFormat:@"0%d",iContactId];
        }else{
            contactId = [NSString stringWithFormat:@"%d",iContactId];
        }
        DLog("contactId:%@  onlineState:%i",contactId,state);
        FListManager *manager = [FListManager sharedFList];
        [manager setStateWithId:contactId state:state];
        
        if(state==1){
            [manager setTypeWithId:contactId type:type];
        }
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateContactState" object:nil];
    DLog(@"vFriendsStatusUpdate");
}

- (void)setDelegate:(id<P2PClientDelegate>)delegate
{
    _delegate = delegate;
}

- (void)setPlaybackDelegate:(id<P2PPlaybackDelegate>)delegate{
    _playbackDelegate = delegate;
}

#pragma mark delegate method

//The selectors performed on main thread for delegate
- (void)delegateCalling:(NSDictionary*)info {
    NSString *isBCalled = [info objectForKey:@"isBCalled"];
    
    
    if([isBCalled isEqualToString:@"YES"]){
        NSString *callId = [info objectForKey:@"callId"];
        self.callId = callId;
        self.isBCalled = YES;
    }else{
        self.isBCalled = NO;
    }
    
    self.p2pCallState = P2PCALL_STATE_CALLING;
    if(self.isBCalled){
        self.p2pCallType = P2PCALL_TYPE_VIDEO;
    }
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if (self.delegate && [self.delegate respondsToSelector:@selector(P2PClientCalling:)]) {
            [self.delegate P2PClientCalling:info];
        }
    }else{
        if (self.playbackDelegate && [self.playbackDelegate respondsToSelector:@selector(P2PPlaybackCalling:)]) {
            [self.playbackDelegate P2PPlaybackCalling:info];
        }
    }
}
- (void)delegateReject:(NSDictionary*)info {
    NSLog(@"delegateReject");
    if (self.p2pCallState == P2PCALL_STET_READY) {
        
        [[PAIOUnit sharedUnit] stopAudio];
        [self p2pHungUp];
    }
    
    self.p2pCallState = P2PCALL_STATE_NONE;
    
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if (self.delegate && [self.delegate respondsToSelector:@selector(P2PClientReject:)]) {
            [self.delegate P2PClientReject:info];
        }
    }else{
        if (self.playbackDelegate && [self.playbackDelegate respondsToSelector:@selector(P2PPlaybackReject:)]) {
            [self.playbackDelegate P2PPlaybackReject:info];
        }
    }
}
- (void)delegateAccept:(NSDictionary*)info {
    
    self.is16B9 = [[info valueForKey:@"is16b9"] intValue];
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if (self.delegate && [self.delegate respondsToSelector:@selector(P2PClientAccept:)]) {
            [self.delegate P2PClientAccept:info];
        }
    }else{
        if (self.playbackDelegate && [self.playbackDelegate respondsToSelector:@selector(P2PPlaybackAccept:)]) {
            [self.playbackDelegate P2PPlaybackAccept:info];
        }
    }
}

- (void)delegateReady:(NSDictionary*)info {
    NSLog(@"delegateReady");
    self.p2pCallState = P2PCALL_STET_READY;
    [[PAIOUnit sharedUnit] startAudioWithCallType:self.p2pCallType];
    [self performSelectorOnMainThread:@selector(startCall) withObject:nil waitUntilDone:YES];
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if (self.delegate && [self.delegate respondsToSelector:@selector(P2PClientReady:)]) {
            [self.delegate P2PClientReady:info];
        }
    }else{
        if (self.playbackDelegate && [self.playbackDelegate respondsToSelector:@selector(P2PPlaybackReady:)]) {
            [self.playbackDelegate P2PPlaybackReady:info];
        }
    }
}

/*********************************************************/
#define MESG_ID_GET_PLAYBACK_FILES 2000
#define MESG_ID_GET_PLAYBACK_FILES_BY_DATE 3000
#define MESG_ID_GET_DEVICE_TIME 4000
#define MESG_ID_SET_DEVICE_TIME 5000
#define MESG_ID_GET_NPC_SETTINGS 6000
#define MESG_ID_SET_VIDEO_FORMAT 7000
#define MESG_ID_SET_VIDEO_VOLUME 8000
#define MESG_ID_SET_DEVICE_PASSWORD 9000
#define MESG_ID_SET_BUZZER 10000
#define MESG_ID_SET_MOTION 11000
#define MESG_ID_GET_ALARM_EMAIL 12000
#define MESG_ID_SET_ALARM_EMAIL 13000
#define MESG_ID_GET_BIND_ACCOUNT 14000
#define MESG_ID_SET_BIND_ACCOUNT 15000
#define MESG_ID_SET_REMOTE_DEFENCE 16000
#define MESG_ID_SET_REMOTE_RECORD 17000
#define MESG_ID_SET_RECORD_TYPE 18000
#define MESG_ID_SET_RECORD_TIME 19000
#define MESG_ID_SET_RECORD_PLAN_TIME 20000
#define MESG_ID_SET_NET_TYPE 21000
#define MESG_ID_GET_WIFI_LIST 22000
#define MESG_ID_SET_WIFI 23000
#define MESG_ID_GET_DEFENCE_AREA_STATE 24000
#define MESG_ID_SET_DEFENCE_AREA_STATE 25000
#define MESG_ID_SET_INIT_PASSWORD 26000
#define MESG_ID_CHECK_DEVICE_UPDATE 27000
#define MESG_ID_SEND_MESSAGE 28000
#define MESG_ID_GET_DEFENCE_STATE 29000
#define MESG_ID_CANCEL_DEVICE_UPDATE 30000
#define MESG_ID_DO_DEVICE_UPDATE 31000
#define MESG_ID_GET_DEVICE_INFO 32000
#define MESG_ID_SEND_CUSTOM_CMD 33000
#define MESG_ID_SET_IMAGE_INVERSION 34000
#define MESG_ID_SET_AUTO_UPDATE 35000
#define MESG_ID_SET_HUMAN_INFRARED 36000
#define MESG_ID_SET_WIRED_ALARM_INPUT 37000
#define MESG_ID_SET_WIRED_ALARM_OUTPUT 38000
#define MESG_ID_SET_VISITOR_PASSWORD 39000
#define MESG_ID_SET_DEVICE_TIME_ZONE 40000
#define MESG_ID_GET_SDCARD_INFO 41000
#define MESG_ID_SET_SDCARD_INFO 42000
#define MESG_ID_GET_DEFENCE_SWITCH_STATE 43000
#define MESG_ID_SET_DEFENCE_SWITCH_STATE 44000
#define MESG_ID_SET_SEARCH_PRESET 45000
#define MESG_ID_GET_SEARCH_PRESET 64000

#define MESG_ID_GET_ALARM_PRESET_MOTOR_POS 46000
#define MESG_ID_SET_ALARM_PRESET_MOTOR_POS 47000

#define MESG_ID_GET_IP_CONFIG 48000
#define MESG_ID_SET_IP_CONFIG 48000
#define MESG_ID_GET_TH_DATA 49000      //温湿度
#define MESG_ID_SET_TH_DATA 50000      //设置上下限
#define MESG_ID_RET_TH_DATA 51000      //receive
#define MESG_ID_SET_THALERT_STATE 52000  //温湿度上下限开关
#define MESG_ID_REMOTE_RESET 53000  //恢复出厂
#define MESG_ID_SET_INDIA_TIMEZONE 54000 //印度时区
#define MESG_ID_SET_PRESET 55000   //设置预置位
#define MESG_ID_SET_SOUND_ALARM 56000   //声音报警
#define MESG_ID_SET_GPIO_CTL 57000
#define MESG_ID_SET_MOTION_LEVEL 58000  //移动侦测灵敏度

#define MESG_ID_SET_REMOTE_REBOOT 59000 //设备重启
#define MESG_ID_RET_REMOTE_REBOOT 60000

#define MESG_ID_GET_FTP 61000 //FTP
#define MESG_ID_SET_FTP 62000
#define MESG_ID_RET_TFP 63000

void  vSendMessageAck(DWORD dwDesID,DWORD dwMesgID, DWORD  dwError)
{
    if (dwDesID<256) {
        dwDesID = Get3cidByIp(dwDesID);
    }
    
    NSNumber *result = [NSNumber numberWithInt:dwError];
    NSNumber *mesgId = [NSNumber numberWithInt:dwMesgID];
    if(dwMesgID<MESG_ID_GET_PLAYBACK_FILES&&dwMesgID>=(MESG_ID_GET_PLAYBACK_FILES-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_PLAYBACK_FILES];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_PLAYBACK_FILES_BY_DATE&&dwMesgID>=(MESG_ID_GET_PLAYBACK_FILES_BY_DATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_PLAYBACK_FILES];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEVICE_TIME&&dwMesgID>=(MESG_ID_GET_DEVICE_TIME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEVICE_TIME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEVICE_TIME&&dwMesgID>=(MESG_ID_SET_DEVICE_TIME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_DEVICE_TIME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_NPC_SETTINGS&&dwMesgID>=(MESG_ID_GET_NPC_SETTINGS-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_NPC_SETTINGS];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_VIDEO_FORMAT&&dwMesgID>=(MESG_ID_SET_VIDEO_FORMAT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_VIDEO_FORMAT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_VIDEO_VOLUME&&dwMesgID>=(MESG_ID_SET_VIDEO_VOLUME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_VIDEO_VOLUME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEVICE_PASSWORD&&dwMesgID>=(MESG_ID_SET_DEVICE_PASSWORD-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_DEVICE_PASSWORD];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_BUZZER&&dwMesgID>=(MESG_ID_SET_BUZZER-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_BUZZER];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_MOTION&&dwMesgID>=(MESG_ID_SET_MOTION-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_MOTION];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_ALARM_EMAIL&&dwMesgID>=(MESG_ID_GET_ALARM_EMAIL-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_ALARM_EMAIL];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }
    else if(dwMesgID<MESG_ID_SET_ALARM_EMAIL&&dwMesgID>=(MESG_ID_SET_ALARM_EMAIL-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_ALARM_EMAIL];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if (dwMesgID<MESG_ID_GET_FTP&&dwMesgID>=(MESG_ID_GET_FTP-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_FTP];//FTP
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if (dwMesgID<MESG_ID_SET_FTP&&dwMesgID>=(MESG_ID_SET_FTP-1000)){//FTP
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_FTP];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_BIND_ACCOUNT&&dwMesgID>=(MESG_ID_GET_BIND_ACCOUNT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_BIND_ACCOUNT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_BIND_ACCOUNT&&dwMesgID>=(MESG_ID_SET_BIND_ACCOUNT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_BIND_ACCOUNT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_REMOTE_DEFENCE&&dwMesgID>=(MESG_ID_SET_REMOTE_DEFENCE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_REMOTE_DEFENCE];
        NSString *contactId = [NSString stringWithFormat:@"%i",dwDesID];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result,@"contactId":contactId};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_REMOTE_RECORD&&dwMesgID>=(MESG_ID_SET_REMOTE_RECORD-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_REMOTE_RECORD];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_RECORD_TYPE&&dwMesgID>=(MESG_ID_SET_RECORD_TYPE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_RECORD_TYPE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_RECORD_TIME&&dwMesgID>=(MESG_ID_SET_RECORD_TIME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_RECORD_TIME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_RECORD_PLAN_TIME&&dwMesgID>=(MESG_ID_SET_RECORD_PLAN_TIME-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_RECORD_PLAN_TIME];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_NET_TYPE&&dwMesgID>=(MESG_ID_SET_NET_TYPE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_NET_TYPE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_WIFI_LIST&&dwMesgID>=(MESG_ID_GET_WIFI_LIST-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_WIFI_LIST];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_WIFI&&dwMesgID>=(MESG_ID_SET_WIFI-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_WIFI];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEFENCE_AREA_STATE&&dwMesgID>=(MESG_ID_GET_DEFENCE_AREA_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEFENCE_AREA_STATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEFENCE_AREA_STATE&&dwMesgID>=(MESG_ID_SET_DEFENCE_AREA_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_DEFENCE_AREA_STATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_INIT_PASSWORD&&dwMesgID>=(MESG_ID_SET_INIT_PASSWORD-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_INIT_PASSWORD];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_CHECK_DEVICE_UPDATE&&dwMesgID>=(MESG_ID_CHECK_DEVICE_UPDATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_CHECK_DEVICE_UPDATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SEND_MESSAGE&&dwMesgID>=(MESG_ID_SEND_MESSAGE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SEND_MESSAGE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result,@"flag":mesgId};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEFENCE_STATE&&dwMesgID>=(MESG_ID_GET_DEFENCE_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEFENCE_STATE];
        NSString *contactId = [NSString stringWithFormat:@"%i",dwDesID];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result,@"contactId":contactId};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_DO_DEVICE_UPDATE&&dwMesgID>=(MESG_ID_DO_DEVICE_UPDATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_DO_DEVICE_UPDATE];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEVICE_INFO&&dwMesgID>=(MESG_ID_GET_DEVICE_INFO-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEVICE_INFO];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SEND_CUSTOM_CMD&&dwMesgID>=(MESG_ID_SEND_CUSTOM_CMD-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_CUSTOM_CMD];
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_IMAGE_INVERSION&&dwMesgID>=(MESG_ID_SET_IMAGE_INVERSION-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_IMAGE_INVERSION];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_AUTO_UPDATE&&dwMesgID>=(MESG_ID_SET_AUTO_UPDATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_AUTO_UPDATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_HUMAN_INFRARED&&dwMesgID>=(MESG_ID_SET_HUMAN_INFRARED-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_HUMAN_INFRARED];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_WIRED_ALARM_INPUT&&dwMesgID>=(MESG_ID_SET_WIRED_ALARM_INPUT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_WIRED_ALARM_OUTPUT&&dwMesgID>=(MESG_ID_SET_WIRED_ALARM_OUTPUT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_VISITOR_PASSWORD&&dwMesgID>=(MESG_ID_SET_VISITOR_PASSWORD-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_VISITOR_PASSWORD];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEVICE_TIME_ZONE&&dwMesgID>=(MESG_ID_SET_DEVICE_TIME_ZONE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_TIME_ZONE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_SDCARD_INFO&&dwMesgID>=(MESG_ID_GET_SDCARD_INFO-1000)){//发送命令状态回调
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_SDCARD_INFO];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_SDCARD_INFO&&dwMesgID>=(MESG_ID_SET_SDCARD_INFO-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_SDCARD_INFO];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_DEFENCE_SWITCH_STATE&&dwMesgID>=(MESG_ID_GET_DEFENCE_SWITCH_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_DEFENCE_SWITCH_STATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_DEFENCE_SWITCH_STATE&&dwMesgID>=(MESG_ID_SET_DEFENCE_SWITCH_STATE-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_DEFENCE_SWITCH_STATE];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if (dwMesgID<MESG_ID_GET_IP_CONFIG&&dwMesgID>=(MESG_ID_GET_IP_CONFIG-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_IPCONFIG];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if (dwMesgID<MESG_ID_SET_IP_CONFIG&&dwMesgID>=(MESG_ID_SET_IP_CONFIG-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_IPCONFIG];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_GET_TH_DATA&&dwMesgID>=(MESG_ID_GET_TH_DATA-1000)){//获取温湿度
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_TH_DATA];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }
   
    else if(dwMesgID<MESG_ID_SET_TH_DATA&&dwMesgID>=(MESG_ID_SET_TH_DATA-1000)){//温湿度上下限
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_TH_DATA];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }
    
    //报警预置位
    else if (dwDesID<MESG_ID_GET_ALARM_PRESET_MOTOR_POS && dwDesID >= MESG_ID_GET_ALARM_PRESET_MOTOR_POS - 1000 ){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_GET_PRESET_MOTOR_POS];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    } else if (dwDesID<MESG_ID_SET_ALARM_PRESET_MOTOR_POS && dwDesID >= MESG_ID_SET_ALARM_PRESET_MOTOR_POS - 1000 ){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_PRESET_MOTOR_POS];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }
    
    
    else if (dwMesgID<MESG_ID_SET_REMOTE_REBOOT&&dwMesgID >=(MESG_ID_SET_REMOTE_REBOOT-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_REMOTE_REBOOT];//设备重启 　
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
        
    }else if (dwMesgID<MESG_ID_SET_PRESET&&dwMesgID>=(MESG_ID_SET_PRESET-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_SEARCH_PRESET];
        NSDictionary *parameter = @{@"key": key,
                                    @"result": result
                                        };
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }
    else if (dwMesgID<MESG_ID_SET_SOUND_ALARM&&dwMesgID>=(MESG_ID_SET_SOUND_ALARM-1000)){//声音报警
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_NPCSETTINGS_SOUNDALARM];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }else if(dwMesgID<MESG_ID_SET_GPIO_CTL&&dwMesgID>=(MESG_ID_SET_GPIO_CTL-1000)){
        NSNumber *key = [NSNumber numberWithInt:ACK_RET_SET_GPIO_CTL];
        
        NSDictionary *parameter = @{@"key":key,
                                    @"result":result};
        
        [[P2PClient sharedClient] ack_receiveReceiveRemoteMessage:parameter];
    }
    
}

void  vRecvRemoteMessage(DWORD dwSrcID,  unsigned int fgHasCheckdPassword, void *pMesg, DWORD dwMesgSize)
{
    if (dwSrcID<256) {
        dwSrcID = Get3cidByIp(dwSrcID);
    }
    
    BYTE *pMesgBuffer = (BYTE *)pMesg;
    
    if(pMesgBuffer[0] == MESG_TYPE_RET_REC_LIST)
    {
        sMesgRetRecListType *sRetRec = (sMesgRetRecListType*)pMesg;
        
        if(sRetRec->bFileNs>128)
        {
            return;
        }
        //防止此类问题的出现：最近1个月界面，上拉加载更多，但是未得到及时的数据返回
        //同时，点击最近3天，获取最近3天的数据；此时，设备端返回了1个月上拉加载的数据和最近3天的数据
        //此现象是不正常，所以书写以下代码避免
        if ([[P2PClient sharedClient] currentLabel] == 1) {
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForThreeDay]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForThreeDay:NO];
                return;
            }
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForOneMon]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneMon:NO];
                return;
            }
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForCustom]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForCustom:NO];
                return;
            }
            
            [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneDay:NO];
        }else if ([[P2PClient sharedClient] currentLabel] == 2){
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForOneDay]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneDay:NO];
                return;
            }
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForOneMon]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneMon:NO];
                return;
            }
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForCustom]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForCustom:NO];
                return;
            }
            
            [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForThreeDay:NO];
        }else if ([[P2PClient sharedClient] currentLabel] == 3){
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForOneDay]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneDay:NO];
                return;
            }
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForThreeDay]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForThreeDay:NO];
                return;
            }
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForCustom]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForCustom:NO];
                return;
            }
            
            [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneMon:NO];
        }else if ([[P2PClient sharedClient] currentLabel] == 4){
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForOneDay]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneDay:NO];
                return;
            }
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForThreeDay]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForThreeDay:NO];
                return;
            }
            if ([[P2PClient sharedClient] isLoadMorePlaybackFilesForOneMon]) {
                [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneMon:NO];
                return;
            }
            
            [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForCustom:NO];
        }
        
        
        if(sRetRec->bFileNs==0){
//            获得播放文件
            NSNumber *key = [NSNumber numberWithInt:RET_GET_PLAYBACK_FILES];
            NSArray *files = [NSArray arrayWithObjects:nil];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:files forKey:@"files"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
            
        }else{
            NSMutableArray *files = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *times = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *sizes = [NSMutableArray arrayWithCapacity:0];
            
            
            
            //每次在最近一天、最近三天...之间切换时，记录文件数量的变量清0，保存已获取回放文件的数组清空
            if ([[P2PClient sharedClient] isClearPlaybackFilesLength]) {
                playbackFilesLength = 0;
                [[P2PClient sharedClient] setIsClearPlaybackFilesLength:NO];
                [[[P2PClient sharedClient] loadedplaybackFiles] removeAllObjects];
            }
            
            
            
            //sRetRec->bFileNs录像文件的个数，最大值为64
            for(int i=0;i<sRetRec->bFileNs;i++){
                char buffer[64];
                memset(buffer, 0, 64);
                sprintf(buffer, "disc%d/%04d-%02d-%02d_%02d:%02d:%02d_%c.av",
                        sRetRec->sFileName[i].bMon>>4,
                        sRetRec->sFileName[i].wYear,
                        sRetRec->sFileName[i].bMon&0xf,
                        sRetRec->sFileName[i].bDay,
                        sRetRec->sFileName[i].bHour,
                        sRetRec->sFileName[i].bMin,
                        sRetRec->sFileName[i].bSec,
                        sRetRec->sFileName[i].cType);
                
                NSString *file = [NSString stringWithUTF8String:buffer];
                
                BOOL isNewPlaybackFile = NO;
                int loadedFileCount = [[[P2PClient sharedClient] loadedplaybackFiles] count];//已经加载的回放文件个数
                NSArray *loadedplaybackFiles = [[P2PClient sharedClient] loadedplaybackFiles];//已经加载的回放文件
                
                //判断file是否已经加载过
                if (loadedFileCount > 0) {
                    for (NSString *loadedFile in loadedplaybackFiles) {
                        if ([file isEqualToString:loadedFile]) {
                            isNewPlaybackFile = NO;
                            break;
                        }
                        isNewPlaybackFile = YES;
                    }
                }else{
                    isNewPlaybackFile = YES;
                }
                
                //保存未加载过的file
                if (isNewPlaybackFile) {
                    
                    //回放文件的名称，用于界面显示
                    [files addObject:file];
                    
                    //回放文件的播放时长
                    if ((sRetRec->bOption0 & 0x01) != 0) {//支持返回播放时长
                        WORD* pSize = (WORD*)&(sRetRec->sFileName[sRetRec->bFileNs]);
                        NSNumber* number = [NSNumber numberWithInt:pSize[i]];
                        [sizes addObject:number];
                    }
                    
                    //playbackFiles用于点击播放（要注意的是，与files保持一一对应）
                    memcpy(playbackFiles+loadedFileCount, sRetRec->sFileName+i, sizeof(sRecFilenameType)*(sRetRec->bFileNs-i));
                    
                    //回放文件的名称，用于记录用户已加载的回放文件和文件的数量
                    [[[P2PClient sharedClient] loadedplaybackFiles] addObject:file];
                }
                
            }
            //已经加载的回放文件个数
            playbackFilesLength = [[[P2PClient sharedClient] loadedplaybackFiles] count];
            
            
            for(int i=0;i<sRetRec->bFileNs;i++){
                char buffer[64];
                memset(buffer, 0, 64);
                sprintf(buffer, "%04d-%02d-%02d %02d:%02d",
                        sRetRec->sFileName[i].wYear,
                        sRetRec->sFileName[i].bMon&0xf,
                        sRetRec->sFileName[i].bDay,
                        sRetRec->sFileName[i].bHour,
                        sRetRec->sFileName[i].bMin);
                
                
                NSString *time = [NSString stringWithUTF8String:buffer];
                [times addObject:time];//重复添加
            }
            
            NSNumber *key = [NSNumber numberWithInt:RET_GET_PLAYBACK_FILES];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:files forKey:@"files"];
            [parameter setValue:times forKey:@"times"];
            [parameter setValue:sizes forKey:@"sizes"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
        
        
    }else if(pMesgBuffer[0]==MESG_TYPE_RET_DATETIME){
        sMesgDateTimeType *pDate = (sMesgDateTimeType*)pMesg;
        if(pDate->bOption==1){
            
            
            NSNumber *key = [NSNumber numberWithInt:RET_GET_DEVICE_TIME];
            NSString *time = [Utils getDeviceTimeByIntValue:pDate->sMesgSysTime.wYear month:pDate->sMesgSysTime.bMon day:pDate->sMesgSysTime.bDay hour:pDate->sMesgSysTime.bHour minute:pDate->sMesgSysTime.bMin];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            //DLog(@"%@",time);
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:time forKey:@"time"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else{
            NSNumber *key = [NSNumber numberWithInt:RET_SET_DEVICE_TIME];
            NSNumber *result = [NSNumber numberWithInt:pDate->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }else if(pMesgBuffer[0]==MESG_TYPE_RET_SETTING){
        sMessageSettingsType *pSetting = (sMessageSettingsType*)pMesg;
        pSetting->wSettingCount &= 0xff;
        if(pSetting->wSettingCount<=0){
            return;
        }
        for(int i = 0; i < pSetting->wSettingCount; i++)
        {
            if((pSetting->bOption&0xff)==1){
                if(pSetting->sSettings[i].dwSettingID==0){
                    
                }
                switch(pSetting->sSettings[i].dwSettingID){
                    case 0:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_REMOTE_DEFENCE];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        NSString *contactId = [NSString stringWithFormat:@"%i",dwSrcID];
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        [parameter setValue:contactId forKey:@"contactId"];
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 1:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_BUZZER];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 2:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_MOTION];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 3:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_RECORD_TYPE];
                        
                        NSNumber *type = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:type forKey:@"type"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 4:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_REMOTE_RECORD];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 5:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_RECORD_PLAN_TIME];
                        
                        NSNumber *time = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:time forKey:@"time"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 8:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_VIDEO_FORMAT];
                        
                        NSNumber *type = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:type forKey:@"type"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 11:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_RECORD_TIME];
                        
                        NSNumber *time = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:time forKey:@"time"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 13:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_NET_TYPE];
                        
                        NSNumber *type = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue&0xffff];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:type forKey:@"type"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 14:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_VIDEO_VOLUME];
                        
                        NSNumber *value = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:value forKey:@"value"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                        
                    case 16:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_AUTO_UPDATE];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 17:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_HUMAN_INFRARED];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 18:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_WIRED_ALARM_INPUT];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 19:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_WIRED_ALARM_OUTPUT];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 20:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_TIME_ZONE];
                        
                        NSNumber *value = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:value forKey:@"value"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 24:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_IMAGE_INVERSION];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 28://移动侦测灵敏度
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_MOTIONLEVEL];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 29:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_TH_DATA];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                        
                    }
                        break;
                    case 35://声音报警
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_NPCSETTINGS_SOUNDALARM];
                        
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                        
                    }
                        break;
                        
                    case 36:
                    {
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        // RET_GET_PRESET_POS_SUPPORT 这个保证唯一就行
                        NSNumber *key = [NSNumber numberWithInt:RET_GET_PRESET_POS_SUPPORT];
                        NSString *contactId = [NSString stringWithFormat:@"%i",dwSrcID];
                        NSNumber *presetPosFlag = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:presetPosFlag forKey:@"presetPosFlag"];
                        [parameter setValue:contactId forKey:@"contactId"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    default:
                        break;
                }
            }
            else{
                switch(pSetting->sSettings[i].dwSettingID){
                    case 0:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_REMOTE_DEFENCE];
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSString *contactId = [NSString stringWithFormat:@"%i",dwSrcID];
                        NSNumber *state = [NSNumber numberWithInt:pSetting->sSettings[i].dwSettingValue];
                        
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        [parameter setValue:contactId forKey:@"contactId"];
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        [parameter setValue:state forKey:@"state"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 1:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_BUZZER];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 2:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_MOTION];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 3:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_RECORD_TYPE];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 4:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_REMOTE_RECORD];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 5:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_RECORD_PLAN_TIME];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 8:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_VIDEO_FORMAT];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 9:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_DEVICE_PASSWORD];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 11:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_RECORD_TIME];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 13:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_NET_TYPE];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 14:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_VIDEO_VOLUME];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                        
                    case 16:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_AUTO_UPDATE];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 17:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_HUMAN_INFRARED];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 18:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 19:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 20:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_TIME_ZONE];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 21:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_VISITOR_PASSWORD];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 24:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_IMAGE_INVERSION];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 28:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_MOTIONLEVEL];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                    case 29:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_TH_DATA];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                        case 35:
                    {
                        NSNumber *key = [NSNumber numberWithInt:RET_SET_NPCSETTINGS_SOUNDALARM];
                        
                        NSNumber *result = [NSNumber numberWithInt:pSetting->bOption];
                        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
                        
                        [parameter setValue:key forKey:@"key"];
                        [parameter setValue:result forKey:@"result"];
                        
                        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
                    }
                        break;
                        
                    
                }
            }
        }
    }
    else if (pMesgBuffer[0] == MESG_TYPE_RET_FTP){
        sMesgFtpConfig *setFtp = (sMesgFtpConfig *)pMesg;
        if (setFtp -> bOption == MESG_GET_OK) {
            NSNumber *key = [NSNumber numberWithInt:RET_GET_FTP];
            NSNumber *result = [NSNumber numberWithInt:setFtp -> bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary  dictionaryWithCapacity:0];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            NSString *hostname = [NSString stringWithUTF8String:setFtp->svrInfo.hostname];
            
            NSString *usrname = [NSString stringWithUTF8String:setFtp ->svrInfo.usrname];
            NSString *passwd = [NSString stringWithUTF8String:setFtp ->svrInfo.passwd];
            NSNumber *svrport = [NSNumber numberWithInt:setFtp ->svrInfo.svrport];
            NSNumber *usrflag = [NSNumber numberWithBool:setFtp ->svrInfo.usrflag];
            
            [parameter setObject:hostname forKey:@"hostname"];
            [parameter setObject:usrname forKey:@"usrname"];
            [parameter setObject:passwd forKey:@"passwd"];
            [parameter setObject:svrport forKey:@"svrport"];
            [parameter setObject:usrflag forKey:@"usrflag"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
            
        }else if (setFtp -> bOption == MESG_SET_OK){
            NSNumber *key = [NSNumber numberWithInt:RET_SET_FTP];
            NSNumber *result = [NSNumber numberWithInt:setFtp ->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else if (setFtp -> bOption == MESG_SET_FTP_ERR){
            NSLog(@"设置网络信息的方式错误,有可能是用户名,密码,域 名超过最大字符限度。");
        }else if (setFtp -> bOption == MESG_GET_FTP_ERR){
            NSLog(@"设置网络信息的方式错误,有可能是网络故障。");

        }
        
    }
    else if(pMesgBuffer[0]==MESG_TYPE_RET_EMIAL){
        sMesgEmailType *pEmail = (sMesgEmailType*)pMesg;
        /*
         bOption值（8位）
         isGetOrSet最后1位，0时表示set的回调；1时表示get的回调
         isSMTP倒数第2位，0时表示不支持SMTP；1时表示支持SMTP
         isRightPwd倒数第3位，0时表示SMTP邮箱密码错误；1时表示SMTP邮箱密码正确
         isEmailVerified倒数第5位，0时表示SMTP邮箱已验证；1时表示SMTP邮箱未验证
         */
        int isGetOrSet = (pEmail->bOption>>0)&1;
        int isSMTP = (pEmail->bOption>>1)&1;
        int isRightPwd = (pEmail->bOption>>2)&1;
        int isEmailVerified = (pEmail->bOption>>4)&1;
        if(isGetOrSet==1 && pEmail->bOption != 15){//get
            
            
            NSNumber *key = [NSNumber numberWithInt:RET_GET_ALARM_EMAIL];
            NSNumber *isSMTP_N = [NSNumber numberWithInt:isSMTP];
            NSNumber *isRightPwd_N = [NSNumber numberWithInt:isRightPwd];
            NSNumber *isEmailVerified_N = [NSNumber numberWithInt:isEmailVerified];
            NSString *email = [NSString stringWithUTF8String:pEmail->cString];
            //Smtp地址
            pEmail->cSmtpServer[63] = '\0';//强制添加结束符，避免数据错乱
            NSString *smtpServer = [NSString stringWithUTF8String:pEmail->cSmtpServer];
            NSNumber *smtpPort = [NSNumber numberWithInt:pEmail->dwSmtpPort];
            NSString *smtpUser = [NSString stringWithUTF8String:pEmail->cSmtpUser];
            //解密
            unsigned char decodeKey[8] = {0x9c, 0xae, 0x6a, 0x5a, 0xe1,0xfc,0xb0, 0x82};
            unsigned char encodePwd[64] = {0};//密文
            
            for(int j=0; j<pEmail->wLen; j++){
                encodePwd[j] = pEmail->cSmtpPwd[j];
                
            }
            
            int encryCount = 0;//表示密码加密多少次才完成
            if(pEmail->wLen%8 == 0){
                encryCount = pEmail->wLen/8;
            }else{
                encryCount = pEmail->wLen/8 + 1;
            }
            
            unsigned char decodePwd[pEmail->wLen];//存放明文
            unsigned char decodePwdTemp[8];
            unsigned char pwdTemp[8];
            for(int i=0; i<encryCount; i++){
                memset(pwdTemp, 0, sizeof(pwdTemp));
                memcpy(pwdTemp, encodePwd + i * 8, 8);
                
                memset(decodePwdTemp, 0, sizeof(decodePwdTemp));
                des(pwdTemp, decodePwdTemp, decodeKey, 0);//对密文进行解密
                
                memcpy(decodePwd + i * 8, decodePwdTemp, 8);
            }
            NSMutableString *decodeString = [NSMutableString stringWithCapacity:0];
            for(int i=0; i<encryCount*8; i++){
                [decodeString appendFormat:@"%c",decodePwd[i]];//明文字符串
            }
            NSArray *smtpPwdArr = [decodeString componentsSeparatedByString:@"##"];
            //有效的明文密码smtpPwd
            NSString *smtpPwd = [NSString stringWithFormat:@"%@",smtpPwdArr[0]];
            //加密类型
            NSNumber *encryptType = [NSNumber numberWithInt:pEmail->bEncryptType];
            //bReserve =0x01则显示手工设置(固件新版本一律回0x01),  否则不显示
            NSNumber *reserve = [NSNumber numberWithInt:pEmail->bReserve];
            
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            //DLog(@"%@",time);
            [parameter setValue:isSMTP_N forKey:@"isSMTP"];
            [parameter setValue:isRightPwd_N forKey:@"isRightPwd"];
            [parameter setValue:isEmailVerified_N forKey:@"isEmailVerified"];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:email forKey:@"email"];
            [parameter setValue:smtpServer forKey:@"smtpServer"];
            [parameter setValue:smtpPort forKey:@"smtpPort"];
            [parameter setValue:smtpUser forKey:@"smtpUser"];
            [parameter setValue:smtpPwd forKey:@"smtpPwd"];
            [parameter setValue:encryptType forKey:@"encryptType"];
            [parameter setValue:reserve forKey:@"reserve"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else{//set
            NSNumber *key = [NSNumber numberWithInt:RET_SET_ALARM_EMAIL];
            NSNumber *result = [NSNumber numberWithInt:isGetOrSet];
            if (pEmail->bOption == 15) {//邮箱格式错误
                result = [NSNumber numberWithInt:pEmail->bOption];
            }
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }else if(pMesgBuffer[0] == MESG_TYPE_RET_APPID){
        sMesgGSetAppIdType *pAppId = (sMesgGSetAppIdType*)pMesg;
        if(pAppId->bOption==1){
            
            
            NSNumber *key = [NSNumber numberWithInt:RET_GET_BIND_ACCOUNT];
            NSNumber *count = [NSNumber numberWithInt:pAppId->bAppIdCount];
            NSNumber *maxCount = [NSNumber numberWithInt:pAppId->bAppIdMAXCount];
            NSMutableArray *datas = [NSMutableArray arrayWithCapacity:0];
            if([count intValue]==1&&pAppId->dwAppId[0]==0){
                
            }else{
                for(int i=0;i<pAppId->bAppIdCount;i++){
                    [datas addObject:[NSNumber numberWithInt:pAppId->dwAppId[i]]];
                }
            }
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            //DLog(@"%@",time);
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:count forKey:@"count"];
            [parameter setValue:maxCount forKey:@"maxCount"];
            [parameter setValue:datas forKey:@"datas"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else{
            NSNumber *key = [NSNumber numberWithInt:RET_SET_BIND_ACCOUNT];
            NSNumber *result = [NSNumber numberWithInt:pAppId->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }else if(pMesgBuffer[0]==MESG_TYPE_RET_WIFILIST){
        sMesgGetWifiListType *pWifi = (sMesgGetWifiListType*)pMesg;
        sNpcWifiListType *sList = &(pWifi->sNpcWifiList);
        
        
        if(pWifi->bOption==1){
            NSNumber *key = [NSNumber numberWithInt:RET_GET_WIFI_LIST];
            NSMutableArray *types = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *names = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *strengths = [NSMutableArray arrayWithCapacity:0];
            NSNumber *count = [NSNumber numberWithInt:sList->bWifiApNs];
            NSNumber *currentIndex = [NSNumber numberWithInt:sList->wCurrentConnSSIDIndex];
            for(int i=0;i<sList->bWifiApNs;i++){
                BYTE data = sList->bEncTpSigLev[i];
                
                [types addObject:[NSNumber numberWithInt:(int)data>>4]];
                [strengths addObject:[NSNumber numberWithInt:(int)((data&0xf)&0xff)]];
                
            }
            
            
            
            char buffer[128];
            int n = 0;
            for(int i=0;i<pWifi->wLen;i++){
                if(sList->cAllESSID[i]!='\0'){
                    buffer[n] = sList->cAllESSID[i];
                    n++;
                }else{
                    buffer[n] = '\0';
                    if([NSString stringWithUTF8String:buffer]){
                        [names addObject:[NSString stringWithUTF8String:buffer]];
                    }else{
                        [names addObject:@"Error Name"];
                    }
                    
                    n = 0;
                }
            }
            
            
            
            
            if([names count]!=sList->bWifiApNs){
                DLog(@"WIFI LIST ERROR");
                return;
            }
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            //DLog(@"%@",time);
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:types forKey:@"types"];
            [parameter setValue:names forKey:@"names"];
            [parameter setValue:strengths forKey:@"strengths"];
            [parameter setValue:count forKey:@"count"];
            [parameter setValue:currentIndex forKey:@"currentIndex"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else{
            NSNumber *key = [NSNumber numberWithInt:RET_SET_WIFI];
            NSNumber *result = [NSNumber numberWithInt:pWifi->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }else if (pMesgBuffer[0]==MESG_TYPE_RET_IP_CONFIG){
        sMesgIPConfig * pIP = (sMesgIPConfig *)pMesg;
        //获取网络信息配置
        if (pIP->bOption == MESG_GET_OK) {
            NSNumber * key = [NSNumber numberWithInt:RET_GET_IPCONFIG];
            NSNumber * result = [NSNumber numberWithInt:pIP->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            DWORD ip = (DWORD)pIP->dwIP;
            DWORD netmask = (DWORD)pIP->dwSubNetMask;
            DWORD getway = (DWORD)pIP->dwGetWay;
            DWORD dns = (DWORD)pIP->dwDNS;
            int d = ip&0xff;
            int c = (ip>>8)&0xff;
            int b = (ip>>16)&0xff;
            int a = (ip>>24)&0xff;
            NSString * ipstr = [NSString stringWithFormat:@"%i.%i.%i.%i",a,b,c,d];
            
            d = netmask&0xff;
            c = (netmask>>8)&0xff;
            b = (netmask>>16)&0xff;
            a = (netmask>>24)&0xff;
            NSString * netmaskstr = [NSString stringWithFormat:@"%i.%i.%i.%i",a,b,c,d];
            
            d = getway&0xff;
            c = (getway>>8)&0xff;
            b = (getway>>16)&0xff;
            a = (getway>>24)&0xff;
            NSString * getwaykstr = [NSString stringWithFormat:@"%i.%i.%i.%i",a,b,c,d];
            
            d = dns&0xff;
            c = (dns>>8)&0xff;
            b = (dns>>16)&0xff;
            a = (dns>>24)&0xff;
            NSString * dnsstr = [NSString stringWithFormat:@"%i.%i.%i.%i",a,b,c,d];//服务器域名
            
            [parameter setValue:ipstr forKey:@"ip"];
            [parameter setValue:netmaskstr forKey:@"subnetmask"];
            [parameter setValue:getwaykstr forKey:@"getway"];
            [parameter setValue:dnsstr forKey:@"dns"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else if (pIP->bOption == MESG_SET_OK){
            NSNumber * key = [NSNumber numberWithInt:RET_SET_IPCONFIG];
            NSNumber * result = [NSNumber numberWithInt:pIP->bOption];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else if (pIP->bOption == MESG_SET_IP_VALUE_ERROR){
            //设置网络信息的方式错误
        }else if (pIP->bOption == MESG_SET_GW_IP_VALUE_ERROR){
            //网关和IP地址不在同一网段
        }
    }else if(pMesgBuffer[0]==MESG_TYPE_RET_ALARMCODE_STATUS){
        sMesgGetAlarmCodeType *pCode = (sMesgGetAlarmCodeType*)pMesg;
        
        
        
        if(pCode->bOption==1){
            NSNumber *key = [NSNumber numberWithInt:RET_GET_DEFENCE_AREA_STATE];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableArray *status = [NSMutableArray arrayWithCapacity:0];
            
            NSMutableArray *keyGroup = [NSMutableArray arrayWithCapacity:0];
            int keyValue = pCode->bAlarmKeySta;
            
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>0)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>1)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>2)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>3)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>4)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>5)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>6)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>7)&0x1)]];
            [status addObject:keyGroup];
            for(int i=0;i<pCode->bAlarmCodeCount;i++){
                NSMutableArray *group = [NSMutableArray arrayWithCapacity:0];
                int value = pCode->bAlarmCodeSta[i];
                
                [group addObject:[NSNumber numberWithInt:((value>>0)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>1)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>2)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>3)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>4)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>5)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>6)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>7)&0x1)]];
                [status addObject:group];
            }
            NSNumber *result = [NSNumber numberWithInt:pCode->bOption];
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            [parameter setValue:status forKey:@"status"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
        else if(pCode->bOption == MESG_SET_ID_ALARMCODE_UBOOT_VERSION_ERR ||
                pCode->bOption == MESG_SET_DEVICE_NOT_SUPPORT)
        {
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            NSNumber *key = [NSNumber numberWithInt:RET_GET_DEFENCE_AREA_STATE];
            NSNumber *result = [NSNumber numberWithInt:pCode->bOption];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
        else
        {
            NSNumber *key = [NSNumber numberWithInt:RET_SET_DEFENCE_AREA_STATE];
            NSNumber *result = [NSNumber numberWithInt:pCode->bOption];
            NSNumber *group = [NSNumber numberWithInt:(int)pCode->bAlarmCodeSta[0]];
            NSNumber *item = [NSNumber numberWithInt:(int)pCode->bAlarmCodeSta[4]];
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            [parameter setValue:group forKey:@"group"];
            [parameter setValue:item forKey:@"item"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }else if(pMesgBuffer[0]==MESG_TYPE_RET_DEFENCE_SWITCH_STATE){
        sMesgGetDefenceSwitchType * pSwitchState = (sMesgGetDefenceSwitchType *)pMesg;
        
        if(pSwitchState->bOption==1){//表示获取成功
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            NSNumber *key = [NSNumber numberWithInt:RET_GET_DEFENCE_SWITCH_STATE];
            NSMutableArray *switchStatus = [NSMutableArray arrayWithCapacity:0];
            
            NSMutableArray *keyGroup = [NSMutableArray arrayWithCapacity:0];
            int keyValue = pSwitchState->bReserve;
            
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>0)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>1)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>2)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>3)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>4)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>5)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>6)&0x1)]];
            [keyGroup addObject:[NSNumber numberWithInt:((keyValue>>7)&0x1)]];
            
            [switchStatus addObject:keyGroup];
            for(int i=0;i<pSwitchState->bDefenceSetSwitchCount;i++){
                NSMutableArray *group = [NSMutableArray arrayWithCapacity:0];
                int value = pSwitchState->bDefenceSetSwitch[i];
                
                [group addObject:[NSNumber numberWithInt:((value>>0)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>1)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>2)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>3)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>4)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>5)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>6)&0x1)]];
                [group addObject:[NSNumber numberWithInt:((value>>7)&0x1)]];
                
                [switchStatus addObject:group];
                
            }
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:switchStatus forKey:@"switchStatus"];
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }else if (pSwitchState->bOption==0){//表示设置成功
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            NSNumber *key = [NSNumber numberWithInt:RET_SET_DEFENCE_SWITCH_STATE];
            NSNumber *result = [NSNumber numberWithInt:pSwitchState->bOption];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        }
    }else if(pMesgBuffer[0]==MESG_TYPE_RET_INIT_PASSWD){
        sMesgSetInitPasswdType *pPassword = (sMesgSetInitPasswdType*)pMesg;
        
        NSNumber *key = [NSNumber numberWithInt:RET_SET_INIT_PASSWORD];
        NSNumber *result = [NSNumber numberWithInt:pPassword->bOption];
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:result forKey:@"result"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }else if(pMesgBuffer[0]==MESG_TYPE_UPG_CHEK_VERSION_RET){
        sMesgUpgType *pUpg = (sMesgUpgType*)pMesg;
        
        int iCurVersion = pUpg->sRemoteUpgMesg.dwUpgID;
        int iUpgVersion = pUpg->sRemoteUpgMesg.dwUpgVal;
        
        int a = iCurVersion&0xff;
        int b = (iCurVersion>>8)&0xff;
        int c = (iCurVersion>>16)&0xff;
        int d = (iCurVersion>>24)&0xff;
        
        int e = iUpgVersion&0xff;
        int f = (iUpgVersion>>8)&0xff;
        int g = (iUpgVersion>>16)&0xff;
        int h = (iUpgVersion>>24)&0xff;
        
        NSNumber *key = [NSNumber numberWithInt:RET_CHECK_DEVICE_UPDATE];
        NSNumber *result = [NSNumber numberWithInt:pUpg->bOption];
        NSString *curVersion = [NSString stringWithFormat:@"%i.%i.%i.%i",d,c,b,a];
        NSString *upgVersion = [NSString stringWithFormat:@"%i.%i.%i.%i",h,g,f,e];
        NSString *contactId = [NSString stringWithFormat:@"%i",dwSrcID];//设备检查更新
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:curVersion forKey:@"curVersion"];
        [parameter setValue:upgVersion forKey:@"upgVersion"];
        [parameter setValue:result forKey:@"result"];
        [parameter setValue:contactId forKey:@"contactId"];//设备检查更新

        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }else if(pMesgBuffer[0]==MESG_TYPE_UPG_FILE_TO_DOWNLOAD_RET){
        sMesgUpgType *pUpg = (sMesgUpgType*)pMesg;
        
        
        NSNumber *key = [NSNumber numberWithInt:RET_DO_DEVICE_UPDATE];
        NSNumber *result = [NSNumber numberWithInt:pUpg->bOption];
        NSNumber *value = [NSNumber numberWithInt:pUpg->sRemoteUpgMesg.dwUpgVal];
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:value forKey:@"value"];
        [parameter setValue:result forKey:@"result"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }else if(pMesgBuffer[0]==MESG_TYPE_DEVICE_NOT_SUPPORT_RET){
        
        NSNumber *key = [NSNumber numberWithInt:RET_DEVICE_NOT_SUPPORT];
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }else if(pMesgBuffer[0]==MESG_TYPE_MESSAGE){
        NSNumber *key = [NSNumber numberWithInt:RET_RECEIVE_MESSAGE];
        
        sMesgStringMesgType *pMessage = (sMesgStringMesgType*)pMesg;
        
        if(pMessage->wLen<=0) return;
        
        pMessage->cString[pMessage->wLen] = 0;
        NSString *message = [NSString stringWithUTF8String:pMessage->cString];
        NSString *contactId = [NSString stringWithFormat:@"0%d",dwSrcID&0x7fffffff];
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:message forKey:@"message"];
        [parameter setValue:contactId forKey:@"contactId"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        
    }else if(pMesgBuffer[0]==MESG_TYPE_ALARM_CALL){
        sMesgAlarmInfoType *pAlarm = (sMesgAlarmInfoType*)pMesg;
        
        int isSupport = 0;
        if((pMesgBuffer[2]&0x1)==1){
            isSupport = 1;
        }else{
            isSupport = 0;
        }
        NSString *contactId = [NSString stringWithFormat:@"%i",dwSrcID];
        NSNumber *type = [NSNumber numberWithInt:pMesgBuffer[1]];
        NSNumber *isSupportExternAlarm = [NSNumber numberWithInt:isSupport];
        NSNumber *group = [NSNumber numberWithInt:pAlarm->sAlarmCodes.dwAlarmCodeID];
        NSNumber *item = [NSNumber numberWithInt:pAlarm->sAlarmCodes.dwAlarmCodeIndex];
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:contactId forKey:@"contactId"];
        [parameter setValue:type forKey:@"type"];
        [parameter setValue:isSupportExternAlarm forKey:@"isSupportExternAlarm"];
        [parameter setValue:group forKey:@"group"];
        [parameter setValue:item forKey:@"item"];
        [[P2PClient sharedClient] receiveReceiveAlarmMessage:parameter];
        
        NSString *deviceId   = [parameter valueForKey:@"contactId"];
        int alarmType   = [[parameter valueForKey:@"type"] intValue];
        int alarmGroup   = [[parameter valueForKey:@"group"] intValue];
        int alarmItem   = [[parameter valueForKey:@"item"] intValue];
        
        Alarm * alarm = [[Alarm alloc]init];
        AlarmDAO * alarmDAO = [[AlarmDAO alloc]init];
        alarm.deviceId = deviceId;
        alarm.alarmTime = [NSString stringWithFormat:@"%ld",[Utils getCurrentTimeInterval]];
        alarm.alarmType = alarmType;
        alarm.alarmGroup = alarmGroup;
        alarm.alarmItem = alarmItem;
        
        NSString * plist = [[NSBundle mainBundle] pathForResource:@"Alarm-Record" ofType:@"plist"];
        NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
        BOOL isLocalAlarmRecord = [dic[@"isLocalAlarmRecord"] boolValue];
        if (isLocalAlarmRecord) {//YES则保存到本地
            [alarmDAO insert:alarm];
        }
        [alarm release];
        [alarmDAO release];
        
        
    }else if(pMesgBuffer[0]==MESG_TYPE_GET_SYS_VERSION_RET){
        sMesgSysVersionType *pVersion = (sMesgSysVersionType*)pMesg;
        int iCurVersion = pVersion->dwCurAppVersion;
        int iKernelVersion = pVersion->dwKernelVersion;
        int iRootfsVersion = pVersion->dwRootfsVersion;
        int iUbootVersion = pVersion->dwUbootVersion;
        int a = iCurVersion&0xff;
        int b = (iCurVersion>>8)&0xff;
        int c = (iCurVersion>>16)&0xff;
        int d = (iCurVersion>>24)&0xff;
        
        NSNumber *key = [NSNumber numberWithInt:RET_GET_DEVICE_INFO];
        NSNumber *result = [NSNumber numberWithInt:pVersion->bOption];
        NSString *curVersion = [NSString stringWithFormat:@"%i.%i.%i.%i",d,c,b,a];
        NSString *kernelVersion = [NSString stringWithFormat:@"%i",iKernelVersion];
        NSString *rootfsVersion = [NSString stringWithFormat:@"%i",iRootfsVersion];
        NSString *ubootVersion = [NSString stringWithFormat:@"%i",iUbootVersion];
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:curVersion forKey:@"curVersion"];
        [parameter setValue:ubootVersion forKey:@"ubootVersion"];
        [parameter setValue:kernelVersion forKey:@"kernelVersion"];
        [parameter setValue:rootfsVersion forKey:@"rootfsVersion"];
        [parameter setValue:result forKey:@"result"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }else if(pMesgBuffer[0]==MESG_TYPE_USER_CMD_RET){
        
        NSNumber *key = [NSNumber numberWithInt:RET_CUSTOM_CMD];
        
        sMesgStringMesgType *pMessage = (sMesgStringMesgType*)pMesg;
        
        if(pMessage->wLen<=0) return;
        
        pMessage->cString[pMessage->wLen] = 0;
        
        NSString *cmd = [NSString stringWithUTF8String:pMessage->cString];
        NSString *contactId = [NSString stringWithFormat:@"0%d",dwSrcID&0x7fffffff];
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:cmd forKey:@"cmd"];
        [parameter setValue:contactId forKey:@"contactId"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }else if(pMesgBuffer[0] == MESG_TYPE_GET_SDCARD_INFO){
        sMesgSDCardInfoType * sSDCardInfo = (sMesgSDCardInfoType *)pMesg;
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        NSNumber *key = [NSNumber numberWithInt:RET_GET_SDCARD_INFO];
        [parameter setValue:key forKey:@"key"];
        
        NSString * result = [NSString stringWithFormat:@"%d",sSDCardInfo->bOption];
        [parameter setValue:result forKey:@"result"];
        
        if (sSDCardInfo->bOption == 1) {
            NSString * storageCount = [NSString stringWithFormat:@"%d",sSDCardInfo->wSDCardCount];//存储设备的数量
            [parameter setValue:storageCount forKey:@"storageCount"];
            
            int storageID;
            storageID = sSDCardInfo->sSDCard[0].bSDCardID;
            int storageType = storageID & 16;
            [parameter setValue:[NSString stringWithFormat:@"%d",storageType] forKeyPath:@"storageType"];
            
            if (storageType == SDCARD) {
                
                [parameter setValue:[NSString stringWithFormat:@"%d",storageID] forKeyPath:@"sdCardID"];
                
                NSString * sdTotalStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDTotalSpace/(1024*1024)];
                [parameter setValue:sdTotalStorage forKey:@"sdTotalStorage"];
                NSString * sdFreeStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDCardFreeSpace/(1024*1024)];
                [parameter setValue:sdFreeStorage forKey:@"sdFreeStorage"];
            }else{
                NSString * usbTotalStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDTotalSpace/(1024*1024)];
                [parameter setValue:usbTotalStorage forKey:@"usbTotalStorage"];
                NSString * usbFreeStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDCardFreeSpace/(1024*1024)];
                [parameter setValue:usbFreeStorage forKey:@"usbFreeStorage"];
            }
            
            if (sSDCardInfo->wSDCardCount > 1) {
                if (storageType == SDCARD) {
                    NSString * usbTotalStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[1].u64SDTotalSpace/(1024*1024)];
                    [parameter setValue:usbTotalStorage forKey:@"usbTotalStorage"];
                    NSString * usbFreeStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[1].u64SDCardFreeSpace/(1024*1024)];
                    [parameter setValue:usbFreeStorage forKey:@"usbFreeStorage"];
                }else{
                    NSString * sdTotalStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDTotalSpace/(1024*1024)];
                    [parameter setValue:sdTotalStorage forKey:@"sdTotalStorage"];
                    NSString * sdFreeStorage = [NSString stringWithFormat:@"%llu",sSDCardInfo->sSDCard[0].u64SDCardFreeSpace/(1024*1024)];
                    [parameter setValue:sdFreeStorage forKey:@"sdFreeStorage"];
                }
            }
        }else{//MESG_SDCARD_NO_EXIST
            //sd卡不存在
        }
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }else if(pMesgBuffer[0] == MESG_TYPE_SET_FORMAT_SDCARD){
        sMesgSDCardFormatType * sSDCardFormat = (sMesgSDCardFormatType *)pMesg;
        
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        NSNumber *key = [NSNumber numberWithInt:RET_SET_SDCARD_FORMAT];
        [parameter setValue:key forKey:@"key"];
        NSNumber * result = [NSNumber numberWithInt:sSDCardFormat->bOption];
        [parameter setValue:result forKey:@"result"];
        
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
    else if(pMesgBuffer[0] == MESG_TYPE_RET_MOTOR_PRESET_POS){
        sMesgPresetMotorPos * sPresetMotor = (sMesgPresetMotorPos *)pMesg;
        
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            NSNumber *key = [NSNumber numberWithInt:RET_SET_SEARCH_PRESET];
            NSNumber * result = [NSNumber numberWithInt:sPresetMotor->bOption];
        
            NSNumber *bOperation = [NSNumber numberWithInt:sPresetMotor ->bOperation];
            NSNumber *bPresetNum = [NSNumber numberWithInt:sPresetMotor ->bPresetNum];
        
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            [parameter setObject:bOperation forKey:@"bOperation"];
            [parameter setObject:bPresetNum forKey:@"bPresetNum"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
        
}
    
    else if(pMesgBuffer[0] == MESG_TYPE_RET_ALARM_TYPE_MOTOR_PRESET_POS){
        sMesgAlarmTypePresetMotorPos * sAlarmPresetMotor = (sMesgAlarmTypePresetMotorPos *)pMesg;
        //sAlarmPresetMotor->bAlarmOrDefence == 0;
        //获取到报警类型的信息
        
        //sAlarmPresetMotor->bAlarmOrDefence == 1;
        //获取到布防类型的信息
        

        if (sAlarmPresetMotor->bOption == 1) {
            //获取数据返回，进入这里
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            
            NSNumber *key = [NSNumber numberWithInt:RET_GET_PRESET_MOTOR_POS];
            NSNumber * result = [NSNumber numberWithInt:sAlarmPresetMotor->bOption];
            NSNumber *bAlarmOrDefence = [NSNumber numberWithInt:sAlarmPresetMotor ->bAlarmOrDefence];
            NSNumber *bAlarmType = [NSNumber numberWithInt:sAlarmPresetMotor ->bAlarmType];
            NSNumber *group = [NSNumber numberWithInt:sAlarmPresetMotor ->bDefenceArea];
            NSNumber *item = [NSNumber numberWithInt:sAlarmPresetMotor ->bChannel];
            NSNumber *bPresetNum = [NSNumber numberWithInt:sAlarmPresetMotor ->bPresetNum];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            [parameter setObject:bAlarmOrDefence forKey:@"bAlarmOrDefence"];
            [parameter setObject:bAlarmType forKey:@"bAlarmType"];
            [parameter setObject:group forKey:@"group"];
            [parameter setObject:item forKey:@"item"];
            [parameter setObject:bPresetNum forKey:@"bPresetNum"];
            //还没实现接收函数
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
            
        }else{
            //设置数据返回，进入这里
            NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
            NSNumber *key = [NSNumber numberWithInt:RET_SET_PRESET_MOTOR_POS];
            NSNumber * result = [NSNumber numberWithInt:sAlarmPresetMotor->bOption];
            
            [parameter setValue:key forKey:@"key"];
            [parameter setValue:result forKey:@"result"];
            
            [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];

        }

        
    }
    
    else if(pMesgBuffer[0] == MESG_TYPE_RET_TH_DATA){//获取温湿度数据
        sMesgTHData * sTHData = (sMesgTHData *)pMesg;
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        NSNumber *key = [NSNumber numberWithInt:RET_GET_TH_DATA];
        [parameter setValue:key forKey:@"key"];
        
        NSString * result = [NSString stringWithFormat:@"%d",sTHData->bOption];
        [parameter setValue:result forKey:@"result"];
        
        if (sTHData->bOption == 1)//get成功
        {
            NSString *nowTemperature = [NSString stringWithFormat:@"%f",sTHData->fTemperature];
            [parameter setValue:nowTemperature forKey:@"nowTemperature"];
            
            NSString *nowHumidity = [NSString stringWithFormat:@"%d",sTHData->dwHumidity];
            [parameter setValue:nowHumidity forKey:@"nowHumidity"];
            
            NSString *temperatureMin = [NSString stringWithFormat:@"%f", sTHData->fTempLmt[0]];//温度下限
            [parameter setValue:temperatureMin forKey:@"temperatureMin"];
            
            NSString *temperatureMax = [NSString stringWithFormat:@"%f", sTHData->fTempLmt[1]];//温度上限
            [parameter setValue:temperatureMax forKey:@"temperatureMax"];
            
            NSString *hunmidityMin = [NSString stringWithFormat:@"%u", sTHData->dwHumiLmt[0]];//湿度下限;
            [parameter setValue:hunmidityMin forKey:@"humidityMin"];
            
            NSString *hunmidityMax = [NSString stringWithFormat:@"%u", sTHData->dwHumiLmt[1]];//湿度上限;
            [parameter setValue:hunmidityMax forKey:@"humidityMax"];
            
        }
        else if(sTHData->bOption == 0)//set
        {
            //            NSString *nowTemperature = [NSString stringWithFormat:@"%f",sTHData->fTemperature];
            //            [parameter setValue:nowTemperature forKey:@"nowTemperature"];
            //
            //            NSString *nowHumidity = [NSString stringWithFormat:@"%d",sTHData->dwHumidity];
            //            [parameter setValue:nowHumidity forKey:@"nowHumidity"];
            //
            //            NSString *temperatureMin = [NSString stringWithFormat:@"%f", sTHData->fTempLmt[0]];//温度下限
            //            [parameter setValue:temperatureMin forKey:@"temperatureMin"];
            //
            //            NSString *temperatureMax = [NSString stringWithFormat:@"%f", sTHData->fTempLmt[1]];//温度上限
            //            [parameter setValue:temperatureMax forKey:@"temperatureMax"];
        }
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }else if(pMesgBuffer[0] == MESG_TYPE_RET_GPIO_CTL){
        sMesgSetGpioCtrl * sSetGpioCtrl = (sMesgSetGpioCtrl *)pMesg;
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        NSNumber *key = [NSNumber numberWithInt:RET_SET_GPIO_CTL];
        [parameter setValue:key forKey:@"key"];
        
        NSNumber * result = [NSNumber numberWithInt:sSetGpioCtrl->bOption];
        [parameter setValue:result forKey:@"result"];
        //还没实现接收函数
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }else if (pMesgBuffer[0] == MESG_TYPE_RET_REMOTE_REBOOT){//设备重启
        sMesgRemoteReboot *sRemotteReboot = (sMesgRemoteReboot *)pMesg;
        NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
        NSNumber *key = [NSNumber numberWithBool:RET_SET_REMOTE_REBOOT];
        NSNumber *result = [NSNumber numberWithInt:sRemotteReboot ->bOption];
        [parameter setValue:key forKey:@"key"];
        [parameter setValue:result forKey:@"result"];
        [[P2PClient sharedClient] receiveReceiveRemoteMessage:parameter];
    }
}


- (void)receiveReceiveAlarmMessage:(NSDictionary *)dictionary{
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_ALARM_MESSAGE
                                                        object:self
                                                      userInfo:dictionary];
}

- (void)receiveReceiveRemoteMessage:(NSDictionary *)dictionary{
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_REMOTE_MESSAGE
                                                        object:self
                                                      userInfo:dictionary];
}

- (void)ack_receiveReceiveRemoteMessage:(NSDictionary *)dictionary{
    [[NSNotificationCenter defaultCenter] postNotificationName:ACK_RECEIVE_REMOTE_MESSAGE
                                                        object:self
                                                      userInfo:dictionary];
}

-(void)getPlaybackFilesWithId:(NSString *)contactId password:(NSString *)password timeInterval:(NSInteger)interval{
    static int mesg_id = MESG_ID_GET_PLAYBACK_FILES-1000;
    if(mesg_id>=MESG_ID_GET_PLAYBACK_FILES){
        mesg_id = MESG_ID_GET_PLAYBACK_FILES-1000;
    }
    
    NSDateComponents *dateComponents = [Utils getNowDateComponents];
    
    int year = (int)[dateComponents year];
    int month = (int)[dateComponents month];
    int day = (int)[dateComponents day];
    int hour = (int)[dateComponents hour];
    int minute = (int)[dateComponents minute];
    
    DLog(@"%i",mesg_id);
    
    
    sMesgGetRecListType sGetRec;
    if(day<interval){
        sGetRec.bCmd = MESG_TYPE_GET_REC_LIST;
        sGetRec.bOption = 0;
        sGetRec.wOption = 0;
        sGetRec.sBeginTime.wYear = year;
        sGetRec.sBeginTime.bMon = month-1;
        sGetRec.sBeginTime.bDay = interval-day;
        sGetRec.sBeginTime.bHour = hour;
        sGetRec.sBeginTime.bMin = minute;
    }else{
        sGetRec.bCmd = MESG_TYPE_GET_REC_LIST;
        sGetRec.bOption = 0;
        sGetRec.wOption = 0;
        sGetRec.sBeginTime.wYear = year;
        sGetRec.sBeginTime.bMon = month;
        sGetRec.sBeginTime.bDay = day-interval;
        sGetRec.sBeginTime.bHour = hour;
        sGetRec.sBeginTime.bMin = minute;
    }
    
    
    sGetRec.sEndTime.wYear = year;
    sGetRec.sEndTime.bMon = month;
    sGetRec.sEndTime.bDay = day;
    sGetRec.sEndTime.bHour = hour;
    sGetRec.sEndTime.bMin = minute;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sGetRec, sizeof(sMesgGetRecListType), NULL, 0, 0);
    mesg_id++;
    
}

#define GET_REC_LIST_OPTION_WITH_FILE_SIZE (1<<0)
//按日期得到回放文件
-(void)getPlaybackFilesWithIdByDate:(NSString *)contactId password:(NSString *)password startDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    static int mesg_id = MESG_ID_GET_PLAYBACK_FILES_BY_DATE-1000;
    if(mesg_id>=MESG_ID_GET_PLAYBACK_FILES_BY_DATE){
        mesg_id = MESG_ID_GET_PLAYBACK_FILES_BY_DATE-1000;
    }
    
    NSDateComponents *startdateComponents = [Utils getDateComponentsByDate:startDate];
    
    int start_year = [startdateComponents year];
    int start_month = [startdateComponents month];
    int start_day = [startdateComponents day];
    int start_hour = [startdateComponents hour];
    int start_minute = [startdateComponents minute];
    
    NSDateComponents *enddateComponents = [Utils getDateComponentsByDate:endDate];
    
    int end_year = [enddateComponents year];
    int end_month = [enddateComponents month];
    int end_day = [enddateComponents day];
    int end_hour = [enddateComponents hour];
    int end_minute = [enddateComponents minute];
    
    
    sMesgGetRecListType sGetRec;
    sGetRec.bCmd = MESG_TYPE_GET_REC_LIST;
    sGetRec.bOption |= GET_REC_LIST_OPTION_WITH_FILE_SIZE;
    sGetRec.wOption = 0;
    sGetRec.sBeginTime.wYear = start_year;
    sGetRec.sBeginTime.bMon = start_month;
    sGetRec.sBeginTime.bDay = start_day;
    sGetRec.sBeginTime.bHour = start_hour;
    sGetRec.sBeginTime.bMin = start_minute;
    
    
    sGetRec.sEndTime.wYear = end_year;
    sGetRec.sEndTime.bMon = end_month;
    sGetRec.sEndTime.bDay = end_day;
    sGetRec.sEndTime.bHour = end_hour;
    sGetRec.sEndTime.bMin = end_minute;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sGetRec, sizeof(sMesgGetRecListType), NULL, 0, 0);
    mesg_id++;
    
}

-(void)getDeviceTimeWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_DEVICE_TIME-1000;
    if(mesg_id>=MESG_ID_GET_DEVICE_TIME){
        mesg_id = MESG_ID_GET_DEVICE_TIME-1000;
    }
    sMesgDateTimeType sDate;
    sDate.bCmd = MESG_TYPE_GET_DATETIME;
    sDate.bOption = 0;
    sDate.wOption = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sDate, sizeof(sMesgDateTimeType), NULL, 0, 0);
    mesg_id++;
}

-(void)setDeviceTimeWithId:(NSString *)contactId password:(NSString *)password year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute{
    static int mesg_id = MESG_ID_SET_DEVICE_TIME-1000;
    if(mesg_id>=MESG_ID_SET_DEVICE_TIME){
        mesg_id = MESG_ID_SET_DEVICE_TIME-1000;
    }
    sMesgDateTimeType sDate;
    sDate.bCmd = MESG_TYPE_SET_DATETIME;
    sDate.bOption = 0;
    sDate.wOption = 0;
    
    sDate.sMesgSysTime.wYear = year;
    sDate.sMesgSysTime.bMon = month;
    sDate.sMesgSysTime.bDay = day;
    sDate.sMesgSysTime.bHour = hour;
    sDate.sMesgSysTime.bMin = minute;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sDate, sizeof(sMesgDateTimeType), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 获取SD卡的信息
-(void)getSDCardInfoWithId:(NSString *)contactId password:(NSString *)password
{
    static int mesg_id = MESG_ID_GET_SDCARD_INFO - 1000;
    if (mesg_id >= MESG_ID_GET_SDCARD_INFO) {
        mesg_id = MESG_ID_GET_SDCARD_INFO - 1000;
    }
    
    sMesgSDCardInfoType sSDCardInfo;
    sSDCardInfo.bCommandType = MESG_TYPE_GET_SDCARD_INFO;
    sSDCardInfo.bOption = 0;
    sSDCardInfo.wSDCardCount = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSDCardInfo, sizeof(sMesgSDCardInfoType), NULL, 0, 0);
    mesg_id++;
}

-(void)setSDCardInfoWithId:(NSString *)contactId password:(NSString *)password sdcardID:(int)sdcardID
{
    static int mesg_id = MESG_ID_SET_SDCARD_INFO - 1000;
    if (mesg_id >= MESG_ID_SET_SDCARD_INFO) {
        mesg_id = MESG_ID_SET_SDCARD_INFO - 1000;
    }
    
    sMesgSDCardFormatType sSDCardFormat;
    sSDCardFormat.bCommandType = MESG_TYPE_SET_FORMAT_SDCARD;
    sSDCardFormat.bOption = 0;
    sSDCardFormat.wRemainByte = 0;
    sSDCardFormat.bSDCardID = sdcardID;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSDCardFormat, sizeof(sMesgSDCardFormatType), NULL, 0, 0);
    mesg_id++;
}

-(void)getNpcSettingsWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_NPC_SETTINGS-1000;
    if(mesg_id>=MESG_ID_GET_NPC_SETTINGS){
        mesg_id = MESG_ID_GET_DEVICE_TIME-1000;
    }
    BYTE pMessageBody[4];
    pMessageBody[0] = MESG_TYPE_GET_SETTING;
    pMessageBody[1] = 0;
    pMessageBody[2] = 0;
    pMessageBody[3] = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, pMessageBody, 4, NULL, 0, 0);
    mesg_id++;
}

-(void)getDefenceState:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_DEFENCE_STATE-1000;
    if(mesg_id>=MESG_ID_GET_DEFENCE_STATE){
        mesg_id = MESG_ID_GET_DEFENCE_STATE-1000;
    }
    BYTE pMessageBody[4];
    pMessageBody[0] = MESG_TYPE_GET_SETTING;
    pMessageBody[1] = 0;
    pMessageBody[2] = 0;
    pMessageBody[3] = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, pMessageBody, 4, NULL, 0, 0);
    mesg_id++;
}

-(void)setVideoFormatWithId:(NSString *)contactId password:(NSString *)password type:(NSInteger)type{
    static int mesg_id = MESG_ID_SET_VIDEO_FORMAT-1000;
    if(mesg_id>=MESG_ID_SET_VIDEO_FORMAT){
        mesg_id = MESG_ID_SET_VIDEO_FORMAT-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 8;
    sSetting.sSettings[0].dwSettingValue = type;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 媒体音量设置
-(void)setVideoVolumeWithId:(NSString *)contactId password:(NSString *)password value:(NSInteger)value{
    static int mesg_id = MESG_ID_SET_VIDEO_VOLUME-1000;
    if(mesg_id>=MESG_ID_SET_VIDEO_VOLUME){
        mesg_id = MESG_ID_SET_VIDEO_VOLUME-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 14;
    sSetting.sSettings[0].dwSettingValue = value;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 移动侦测灵敏度
-(void)setMotionLevelWithId:(NSString *)contactId password:(NSString *)password level:(NSInteger)level{
    static int mesg_id = MESG_ID_SET_MOTION_LEVEL-1000;
    if(mesg_id>=MESG_ID_SET_MOTION_LEVEL){
        mesg_id = MESG_ID_SET_MOTION_LEVEL-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 28;
    sSetting.sSettings[0].dwSettingValue = level;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setDevicePasswordWithId:(NSString *)contactId password:(NSString *)password newPassword:(NSString *)newPassword{
    
    static int mesg_id = MESG_ID_SET_DEVICE_PASSWORD-1000;
    if(mesg_id>=MESG_ID_SET_DEVICE_PASSWORD){
        mesg_id = MESG_ID_SET_DEVICE_PASSWORD-1000;
    }
    //从sMessageSettingsType改为 sMessageSettingsExtOptType，在设置p2p的密码时，同时设置rtsp的密码
    sMessageSettingsExtOptType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 9;
    sSetting.sSettings[0].dwSettingValue = [[Utils GetTreatedPassword:newPassword] intValue];
    
    NSString* sPwdRtsp = [NSString stringWithFormat:@"admin:HIipCamera:%@", newPassword];
    [MD5Manager GetMD5PasswordWithSrc:[sPwdRtsp UTF8String] Dst:sSetting.cRtspPasswdVerification];
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, [[Utils GetTreatedPassword:password] intValue], mesg_id, &sSetting, sizeof(sMessageSettingsExtOptType), NULL, 0, 0);
    mesg_id++;
}

-(void)setVisitorPasswordWithId:(NSString *)contactId password:(NSString *)password newPassword:(NSString *)newPassword{
    static int mesg_id = MESG_ID_SET_VISITOR_PASSWORD-1000;
    if(mesg_id>=MESG_ID_SET_VISITOR_PASSWORD){
        mesg_id = MESG_ID_SET_VISITOR_PASSWORD-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 21;
    sSetting.sSettings[0].dwSettingValue = newPassword.intValue;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setBuzzerWithId:(NSString *)contactId password:(NSString *)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_BUZZER-1000;
    if(mesg_id>=MESG_ID_SET_BUZZER){
        mesg_id = MESG_ID_SET_BUZZER-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 1;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setMotionWithId:(NSString *)contactId password:(NSString *)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_MOTION-1000;
    if(mesg_id>=MESG_ID_SET_MOTION){
        mesg_id = MESG_ID_SET_MOTION-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 2;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setImageInversionWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_IMAGE_INVERSION-1000;
    if(mesg_id>=MESG_ID_SET_IMAGE_INVERSION){
        mesg_id = MESG_ID_SET_IMAGE_INVERSION-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 24;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}


-(void)setAutoUpdateWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_AUTO_UPDATE-1000;
    if(mesg_id>=MESG_ID_SET_AUTO_UPDATE){
        mesg_id = MESG_ID_SET_AUTO_UPDATE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 16;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setHumanInfraredWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_HUMAN_INFRARED-1000;
    if(mesg_id>=MESG_ID_SET_HUMAN_INFRARED){
        mesg_id = MESG_ID_SET_HUMAN_INFRARED-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 17;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setWiredAlarmInputWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_WIRED_ALARM_INPUT-1000;
    if(mesg_id>=MESG_ID_SET_WIRED_ALARM_INPUT){
        mesg_id = MESG_ID_SET_WIRED_ALARM_INPUT-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 18;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setWiredAlarmOutputWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_WIRED_ALARM_OUTPUT-1000;
    if(mesg_id>=MESG_ID_SET_WIRED_ALARM_OUTPUT){
        mesg_id = MESG_ID_SET_WIRED_ALARM_OUTPUT-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 19;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setDeviceTimezoneWithId:(NSString *)contactId password:(NSString *)password value:(NSInteger)value{
    static int mesg_id = MESG_ID_SET_DEVICE_TIME_ZONE-1000;
    if(mesg_id>=MESG_ID_SET_DEVICE_TIME_ZONE){
        mesg_id = MESG_ID_SET_DEVICE_TIME_ZONE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 20;
    sSetting.sSettings[0].dwSettingValue = value;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}
//声音报警
-(void)setSoundAlarmWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state
{
    static int mesg_id = MESG_ID_SET_SOUND_ALARM-1000;
    if(mesg_id>=MESG_ID_SET_SOUND_ALARM){
        mesg_id = MESG_ID_SET_SOUND_ALARM-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 35;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}
#pragma mark - 获取FTP的信息
- (void)getFTPWithId: (NSString *)contactId password: (NSString *)password{
    static int mesg_id = MESG_ID_GET_FTP - 1000;
    if (mesg_id >= MESG_ID_GET_FTP) {
        mesg_id = MESG_ID_GET_FTP - 1000;
    }
    sMesgFtpConfig setFtp;
    setFtp.bCmd = MESG_TYPE_GET_FTP;
    setFtp.bOption = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &setFtp, sizeof(sMesgFtpConfig), NULL, 0, 0);
    mesg_id++;
}
-(void)setFTPWithId:(NSString *)contactId password:(NSString *)password  hostname:(NSString *)hostname usrname:(NSString *)usrname FTPPassword:(NSString *)FTPPassword svrport: (int)svrport usrflagtaye:(BOOL)usrflagtaye{
    static int mesg_id = MESG_ID_SET_FTP-1000;
    if(mesg_id>=MESG_ID_SET_FTP){
        mesg_id = MESG_ID_SET_FTP-1000;
    }
    sMesgFtpConfig setFtp;
    setFtp.bCmd = MESG_TYPE_SET_FTP;
    setFtp.bOption = 0;
    
    memcpy(setFtp.svrInfo.hostname, [hostname UTF8String], [hostname length]);
    memcpy(setFtp.svrInfo.usrname, [usrname UTF8String], [usrname length]);
    memcpy(setFtp.svrInfo.passwd, [FTPPassword UTF8String], [FTPPassword length]);
    setFtp.svrInfo.hostname[[hostname length]] = 0;
    setFtp.svrInfo.usrname[[usrname length]] = 0;
    setFtp.svrInfo.passwd[[FTPPassword length]] = 0;
    setFtp.svrInfo.svrport =svrport;
    setFtp.svrInfo.usrflag = usrflagtaye;
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &setFtp, sizeof(sMesgFtpConfig), NULL, 0, 0);
    mesg_id++;
    
}
#pragma mark - 获取报警邮箱地址信息
-(void)getAlarmEmailWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_ALARM_EMAIL-1000;
    if(mesg_id>=MESG_ID_GET_ALARM_EMAIL){
        mesg_id = MESG_ID_GET_ALARM_EMAIL-1000;
    }
    sMesgEmailType sEmail;
    sEmail.bCmd = MESG_TYPE_GET_EMIAL;
    sEmail.bOption = 0x03;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sEmail, sizeof(sMesgEmailType), NULL, 0, 0);
    mesg_id++;
}


#pragma mark - 设置报警邮箱地址信息
-(void)setAlarmEmailWithId:(NSString *)contactId password:(NSString *)password email:(NSString *)email smtpServer:(NSString *)smtpServer smtpPort:(int)smtpPort smtpUser:(NSString *)smtpUser smtpPwd:(NSString *)smtpPwd encryptType:(int)encryptType subject:(NSString *)subject content:(NSString *)content isSupportSMTP:(BOOL)isSupportSMTP{
    static int mesg_id = MESG_ID_SET_ALARM_EMAIL-1000;
    if(mesg_id>=MESG_ID_SET_ALARM_EMAIL){
        mesg_id = MESG_ID_SET_ALARM_EMAIL-1000;
    }
    sMesgEmailType sEmail;
    
    sEmail.bCmd = MESG_TYPE_SET_EMIAL;
    
    sEmail.bOption = 0x03;//参数bOption只需传0x03（0x03兼容了0x00和0x01，0表示系统默认邮箱）
    
    //sEmail.wLen = email.length;
    
    //邮件地址
    char *tempStr = (char *)[email UTF8String];
    memcpy(sEmail.cString,tempStr,strlen(tempStr));
    sEmail.cString[strlen(tempStr)] = 0;//结束位
    
    if(isSupportSMTP){//新设备
        //SMTP服务器
        char *tempStr2 = (char *)[smtpServer UTF8String];
        memcpy(sEmail.cSmtpServer,tempStr2,strlen(tempStr2));
        sEmail.cSmtpServer[strlen(tempStr2)] = 0;//结束位
        
        //SMTP端口
        sEmail.dwSmtpPort = smtpPort;
        
        //Smtp账号
        char *tempStr3 = (char *)[smtpUser UTF8String];
        memcpy(sEmail.cSmtpUser,tempStr3,strlen(tempStr3));
        sEmail.cSmtpUser[strlen(tempStr3)] = 0;//结束位
        
        //Smtp密码
        unsigned char key[8] = {0x9c, 0xae, 0x6a, 0x5a, 0xe1,0xfc,0xb0, 0x82};
        NSString *newPwdString = [NSString stringWithFormat:@"%@##",smtpPwd];
        unsigned char *pwd  = (unsigned char *)[newPwdString UTF8String];
        int len = (int)[newPwdString length];//密码长度
        
        //要加密的密码bSrcPwd
        unsigned char bSrcPwd[64]  = {0};
        for(int i=0; i<64; i++){//初始化为'0'
            bSrcPwd[i] = '0';
        }
        memcpy(bSrcPwd, pwd, len);
        
        int encryCount = 0;//表示密码加密多少次才完成
        if(len%8 == 0){
            encryCount = len/8;
        }else{
            encryCount = len/8 + 1;
        }
        sEmail.wLen = encryCount*8;
        
        //加密后的字符串
        unsigned char encodePwd[len];
        unsigned char encodePwdTemp[8];
        unsigned char pwdTemp[8];
        for(int i=0; i<encryCount; i++){
            memset(pwdTemp, 0, sizeof(pwdTemp));
            memcpy(pwdTemp, bSrcPwd + i * 8, 8);
            
            memset(encodePwdTemp, 0, sizeof(encodePwdTemp));
            des(pwdTemp, encodePwdTemp, key, 1);
            
            memcpy(encodePwd + i * 8, encodePwdTemp, 8);
        }
        
        
        for(int i=0; i<encryCount*8; i++){
            sEmail.cSmtpPwd[i] = encodePwd[i];
        }
        sEmail.cSmtpPwd[encryCount*8] = 0;//结束位
        
        //加密类型
        sEmail.bEncryptType = encryptType;
        
        
        //主题内容的UI没有实现，只在此传参测试
        //主题 格式通常是Attention:XXXX:xxxx alarm!
        //XXXX：xxxx是加入3CID号和告警类型的信息
        char *subjectTemp = (char *)[subject UTF8String];
        memcpy(sEmail.cEmailSubject,subjectTemp,strlen(subjectTemp));
        sEmail.cEmailSubject[strlen(subjectTemp)] = 0;//结束位
        //内容
        //长度小于100字符,英文
        char *contentTemp = (char *)[content UTF8String];
        memcpy(sEmail.cEmailContent,contentTemp,strlen(contentTemp));
        sEmail.cEmailContent[strlen(contentTemp)] = 0;//结束位
        
        //针对新设备，结构体长度sizeof(sMesgEmailType)
        int iTargetID = GetIpBy3CID(contactId.intValue);
        fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sEmail, sizeof(sMesgEmailType), NULL, 0, 0);
    }else{
        //针对旧设备，结构体长度36
        int iTargetID = GetIpBy3CID(contactId.intValue);
        fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sEmail, 36, NULL, 0, 0);
    }
    mesg_id++;
}


-(void)getBindAccountWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_BIND_ACCOUNT-1000;
    if(mesg_id>=MESG_ID_GET_BIND_ACCOUNT){
        mesg_id = MESG_ID_GET_BIND_ACCOUNT-1000;
    }
    sMesgGSetAppIdType sAppId;
    sAppId.bCmd = MESG_TYPE_GET_APPID;
    sAppId.bOption = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sAppId, sizeof(sMesgGSetAppIdType), NULL, 0, 0);
    mesg_id++;
}

-(void)setBindAccountWithId:(NSString *)contactId password:(NSString *)password datas:(NSMutableArray *)datas{
    static int mesg_id = MESG_ID_SET_BIND_ACCOUNT-1000;
    if(mesg_id>=MESG_ID_SET_BIND_ACCOUNT){
        mesg_id = MESG_ID_SET_BIND_ACCOUNT-1000;
    }
    
    NSMutableArray *setDatas = [NSMutableArray arrayWithArray:datas];
    int count = [setDatas count];
    if(count==0){
        [setDatas addObject:[NSNumber numberWithInt:0]];
        count = 1;
    }
    int ids[count];
    
    for(int i=0;i<count;i++){
        NSNumber *bindId = [setDatas objectAtIndex:i];
        ids[i] = [bindId intValue];
    }
    BYTE buffer[256];
    sMesgGSetAppIdType *sAppId = (sMesgGSetAppIdType*)buffer;
    sAppId->bCmd = MESG_TYPE_SET_APPID;
    sAppId->bAppIdCount = count;
    memcpy(sAppId->dwAppId, ids, count*sizeof(int));
    int length = sizeof(sMesgGSetAppIdType)+(count-1)*sizeof(int);
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, sAppId, length, NULL, 0, 0);
    mesg_id++;
}

-(void)setRemoteDefenceWithId:(NSString *)contactId password:(NSString *)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_REMOTE_DEFENCE-1000;
    if(mesg_id>=MESG_ID_SET_REMOTE_DEFENCE){
        mesg_id = MESG_ID_SET_REMOTE_DEFENCE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 0;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}
#pragma mark 获取ip
-(void)GetIpConfigWithId:(NSString * )contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_IP_CONFIG-1000;
    if(mesg_id>=MESG_ID_GET_IP_CONFIG){
        mesg_id = MESG_ID_GET_IP_CONFIG-1000;
    }
    sMesgIPConfig sSetting;
    memset(&sSetting, 0, sizeof(sSetting));
    sSetting.bCmd = MESG_TYPE_GET_IP_CONFIG;
    sSetting.bOption = 1;
    sSetting.bType = 1;
    sSetting.fgIsAuto = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sSetting, sizeof(sMesgIPConfig), NULL, 0, 0);
    mesg_id++;
}


#pragma mark 设置ip
-(void)setFtpConfigWithId:(NSString *)contactId password:(NSString *)password isAuto:(int)isAuto ip:(int)ip subnetmask:(int)subnetmask getway:(int)getway dns:(int)dns{
    static int mesg_id = MESG_ID_SET_IP_CONFIG-1000;
    if(mesg_id>=MESG_ID_SET_IP_CONFIG){
        mesg_id = MESG_ID_SET_IP_CONFIG-1000;
    }
    sMesgIPConfig sSetting;
    memset(&sSetting, 0, sizeof(sSetting));
    sSetting.bCmd = MESG_TYPE_SET_IP_CONFIG;
    sSetting.bOption = 1;
    sSetting.bType = 0;
    sSetting.fgIsAuto = isAuto;
    sSetting.dwIP =ip;
    sSetting.dwSubNetMask = subnetmask;
    sSetting.dwGetWay = getway;
    sSetting.dwDNS = dns;
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMesgIPConfig), NULL, 0, 0);
    mesg_id++;
}


-(void)setRemoteRecordWithId:(NSString *)contactId password:(NSString *)password state:(NSInteger)state{
    static int mesg_id = MESG_ID_SET_REMOTE_RECORD-1000;
    if(mesg_id>=MESG_ID_SET_REMOTE_RECORD){
        mesg_id = MESG_ID_SET_REMOTE_RECORD-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 4;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setRecordTypeWithId:(NSString *)contactId password:(NSString *)password type:(NSInteger)type{
    static int mesg_id = MESG_ID_SET_RECORD_TYPE-1000;
    if(mesg_id>=MESG_ID_SET_RECORD_TYPE){
        mesg_id = MESG_ID_SET_RECORD_TYPE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 3;
    sSetting.sSettings[0].dwSettingValue = type;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setRecordTimeWithId:(NSString *)contactId password:(NSString *)password value:(NSInteger)value{
    static int mesg_id = MESG_ID_SET_RECORD_TIME-1000;
    if(mesg_id>=MESG_ID_SET_RECORD_TIME){
        mesg_id = MESG_ID_SET_RECORD_TIME-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 11;
    sSetting.sSettings[0].dwSettingValue = value;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setRecordPlanTimeWithId:(NSString *)contactId password:(NSString *)password time:(NSInteger)time{
    static int mesg_id = MESG_ID_SET_RECORD_PLAN_TIME-1000;
    if(mesg_id>=MESG_ID_SET_RECORD_PLAN_TIME){
        mesg_id = MESG_ID_SET_RECORD_PLAN_TIME-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 5;
    sSetting.sSettings[0].dwSettingValue = time;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

-(void)setNetTypeWithId:(NSString *)contactId password:(NSString *)password type:(NSInteger)type{
    static int mesg_id = MESG_ID_SET_NET_TYPE-1000;
    if(mesg_id>=MESG_ID_SET_NET_TYPE){
        mesg_id = MESG_ID_SET_NET_TYPE-1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 13;
    sSetting.sSettings[0].dwSettingValue = type;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 温湿度上下限报警开关
-(void)setTHAlertWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state
{
    static int mesg_id = MESG_ID_SET_THALERT_STATE - 1000;
    if(mesg_id >= MESG_ID_SET_THALERT_STATE){
        mesg_id = MESG_ID_SET_THALERT_STATE - 1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 29;
    sSetting.sSettings[0].dwSettingValue = state;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 恢复出厂设置
-(void)remoteResetWithId:(NSString*)contactId password:(NSString*)password state:(NSInteger)state
{
    static int mesg_id = MESG_ID_REMOTE_RESET - 1000;
    if(mesg_id >= MESG_ID_REMOTE_RESET){
        mesg_id = MESG_ID_REMOTE_RESET - 1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 33;
    sSetting.sSettings[0].dwSettingValue = FUCTION_TEST_ID_RESET << 16;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
    
}

#pragma mark - 印度时区专用
-(void)setIndiaTimezoneWithId:(NSString*)contactId password:(NSString*)password value:(NSInteger)value
{
    static int mesg_id = MESG_ID_SET_INDIA_TIMEZONE - 1000;
    if(mesg_id >= MESG_ID_SET_INDIA_TIMEZONE){
        mesg_id = MESG_ID_SET_INDIA_TIMEZONE - 1000;
    }
    sMessageSettingsType sSetting;
    sSetting.bCmd = MESG_TYPE_SET_SETTING;
    sSetting.bOption = 0;
    sSetting.wSettingCount = 1;
    sSetting.sSettings[0].dwSettingID = 20;
    sSetting.sSettings[0].dwSettingValue = value;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetting, sizeof(sMessageSettingsType), NULL, 0, 0);
    mesg_id++;
}


-(void)getWifiListWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_WIFI_LIST-1000;
    if(mesg_id>=MESG_ID_GET_WIFI_LIST){
        mesg_id = MESG_ID_GET_WIFI_LIST-1000;
    }
    sMesgGetWifiListType sWifi;
    sWifi.bCmd = MESG_TYPE_GET_WIFILIST;
    sWifi.bOption = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sWifi, sizeof(sMesgGetWifiListType), NULL, 0, 0);
    mesg_id++;
}

-(void)setWifiWithId:(NSString *)contactId password:(NSString *)password type:(NSInteger)type name:(NSString *)name wifiPassword:(NSString *)wifiPassword{
    static int mesg_id = MESG_ID_SET_WIFI-1000;
    if(mesg_id>=MESG_ID_SET_WIFI){
        mesg_id = MESG_ID_SET_WIFI-1000;
    }
    sMesgSetWifiListType sWifi;
    sWifi.bCmd = MESG_TYPE_SET_WIFILIST;
    sWifi.bOption = 0;
    
    sWifi.sPhoneWifiInfo.dwEncType = type;
    memcpy(sWifi.sPhoneWifiInfo.cESSID, [name UTF8String], [name length]);
    memcpy(sWifi.sPhoneWifiInfo.cPassword, [wifiPassword UTF8String], [wifiPassword length]);
    
    sWifi.sPhoneWifiInfo.cESSID[[name length]] = 0;
    sWifi.sPhoneWifiInfo.cPassword[[wifiPassword length]] = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sWifi, sizeof(sMesgSetWifiListType), NULL, 0, 0);
    mesg_id++;
}

-(void)getDefenceAreaState:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_DEFENCE_AREA_STATE-1000;
    if(mesg_id>=MESG_ID_GET_DEFENCE_AREA_STATE){
        mesg_id = MESG_ID_GET_DEFENCE_AREA_STATE-1000;
    }
    sMesgGetAlarmCodeType sCode;
    sCode.bCmd = MESG_TYPE_GET_ALARMCODE_STATUS;
    sCode.bOption = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sCode, sizeof(sMesgGetAlarmCodeType), NULL, 0, 0);
    mesg_id++;
}

-(void)setDefenceAreaState:(NSString *)contactId password:(NSString *)password group:(NSInteger)group item:(NSInteger)item type:(NSInteger)type{
    static int mesg_id = MESG_ID_SET_DEFENCE_AREA_STATE-1000;
    if(mesg_id>=MESG_ID_SET_DEFENCE_AREA_STATE){
        mesg_id = MESG_ID_SET_DEFENCE_AREA_STATE-1000;
    }
    sMesgSetAlarmCodeType sCode;
    sCode.bCmd = MESG_TYPE_SET_ALARMCODE_STATUS;
    sCode.bOption = 0;
    sCode.bSetAlarmCodeId = type;
    sCode.bAlarmCodeCount = 1;
    sCode.sAlarmCodes[0].dwAlarmCodeID = group;
    sCode.sAlarmCodes[0].dwAlarmCodeIndex = item;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sCode, sizeof(sMesgSetAlarmCodeType), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 设置 报警类型的预置位置

-(void)setAlarmTypeMotorPresetPosWithId:(NSString *)contactId password:(NSString *)password alarmType:(int)alarmType group:(NSInteger)group item:(NSInteger)item presetNumber:(int)presetNumber{
    static int mesg_id = MESG_ID_SET_ALARM_PRESET_MOTOR_POS - 1000;
    if (mesg_id >= MESG_ID_SET_ALARM_PRESET_MOTOR_POS) {
        mesg_id = MESG_ID_SET_ALARM_PRESET_MOTOR_POS - 1000;
    }
    
    sMesgAlarmTypePresetMotorPos sAlarmTypePresetMotorPos;
    sAlarmTypePresetMotorPos.bCmd = MESG_TYPE_SET_ALARM_TYPE_MOTOR_PRESET_POS;
    sAlarmTypePresetMotorPos.bOption = 0;
    sAlarmTypePresetMotorPos.bAlarmOrDefence = 0;
    sAlarmTypePresetMotorPos.bAlarmType = alarmType;
    sAlarmTypePresetMotorPos.bPresetNum = presetNumber;
    sAlarmTypePresetMotorPos.bDefenceArea = group;
    sAlarmTypePresetMotorPos.bChannel = item;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sAlarmTypePresetMotorPos, sizeof(sMesgAlarmTypePresetMotorPos), NULL, 0, 0);
    mesg_id++;
}





//-(void)setAlarmTypeMotorPresetPosWithId:(NSString *)contactId password:(NSString *)password alarmType:(int)alarmType presetNumber:(int)presetNumber{
//    static int mesg_id = MESG_ID_SET_ALARM_PRESET_MOTOR_POS - 1000;
//    if (mesg_id >= MESG_ID_SET_ALARM_PRESET_MOTOR_POS) {
//        mesg_id = MESG_ID_SET_ALARM_PRESET_MOTOR_POS - 1000;
//    }
//    
//    sMesgAlarmTypePresetMotorPos sAlarmTypePresetMotorPos;
//    sAlarmTypePresetMotorPos.bCmd = MESG_TYPE_SET_ALARM_TYPE_MOTOR_PRESET_POS;
//    sAlarmTypePresetMotorPos.bOption = 0;
//    sAlarmTypePresetMotorPos.bAlarmOrDefence = 0;
//    sAlarmTypePresetMotorPos.bAlarmType = alarmType;
//    sAlarmTypePresetMotorPos.bPresetNum = presetNumber;
//    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sAlarmTypePresetMotorPos, sizeof(sMesgAlarmTypePresetMotorPos), NULL, 0, 0);
//    mesg_id++;
//}
#pragma mark - 获取 报警类型的预置位置

- (void)getAlarmTypeMotorPresetPosWithId:(NSString *)contactId password:(NSString *)password alarmType:(int)alarmType group:(NSInteger)group item:(NSInteger)item presetNumber:(int)presetNumber{
    static int mesg_id = MESG_ID_GET_ALARM_PRESET_MOTOR_POS - 1000;
    if (mesg_id >= MESG_ID_GET_ALARM_PRESET_MOTOR_POS) {
        mesg_id = MESG_ID_GET_ALARM_PRESET_MOTOR_POS - 1000;
    }
    
    sMesgAlarmTypePresetMotorPos sAlarmTypePresetMotorPos;
    sAlarmTypePresetMotorPos.bCmd = MESG_TYPE_GET_ALARM_TYPE_MOTOR_PRESET_POS;
    sAlarmTypePresetMotorPos.bOption = 0;
    sAlarmTypePresetMotorPos.bAlarmOrDefence = 0;
    sAlarmTypePresetMotorPos.bAlarmType = alarmType;
    sAlarmTypePresetMotorPos.bPresetNum = presetNumber;
    sAlarmTypePresetMotorPos.bDefenceArea = group;
    sAlarmTypePresetMotorPos.bChannel = item;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sAlarmTypePresetMotorPos, sizeof(sMesgAlarmTypePresetMotorPos), NULL, 0, 0);
    mesg_id++;
}


//- (void)getAlarmTypeMotorPresetPosWithId:(NSString *)contactId password:(NSString *)password alarmType:(int)alarmType{
//    static int mesg_id = MESG_ID_GET_ALARM_PRESET_MOTOR_POS - 1000;
//    if (mesg_id >= MESG_ID_GET_ALARM_PRESET_MOTOR_POS) {
//        mesg_id = MESG_ID_GET_ALARM_PRESET_MOTOR_POS - 1000;
//    }
//    
//    sMesgAlarmTypePresetMotorPos sAlarmTypePresetMotorPos;
//    sAlarmTypePresetMotorPos.bCmd = MESG_TYPE_GET_ALARM_TYPE_MOTOR_PRESET_POS;
//    sAlarmTypePresetMotorPos.bOption = 0;
//    sAlarmTypePresetMotorPos.bAlarmOrDefence = 0;
//    sAlarmTypePresetMotorPos.bAlarmType = alarmType;
//    sAlarmTypePresetMotorPos.bPresetNum = 0xFF;
//    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sAlarmTypePresetMotorPos, sizeof(sMesgAlarmTypePresetMotorPos), NULL, 0, 0);
//    mesg_id++;
//}

#pragma mark - 设置 布防类型的预置位置
-(void)setDefenceTypeMotorPresetPosWithId:(NSString *)contactId password:(NSString *)password defenceArea:(int)defenceArea channel:(int)channel presetNumber:(int)presetNumber {
    static int mesg_id = MESG_ID_SET_ALARM_PRESET_MOTOR_POS - 1000;
    if (mesg_id >= MESG_ID_SET_ALARM_PRESET_MOTOR_POS) {
        mesg_id = MESG_ID_SET_ALARM_PRESET_MOTOR_POS - 1000;
    }
    
    sMesgAlarmTypePresetMotorPos sAlarmTypePresetMotorPos;
    sAlarmTypePresetMotorPos.bCmd = MESG_TYPE_SET_ALARM_TYPE_MOTOR_PRESET_POS;
    sAlarmTypePresetMotorPos.bOption = 0;
    sAlarmTypePresetMotorPos.bAlarmOrDefence = 1;
    sAlarmTypePresetMotorPos.bDefenceArea = defenceArea;
    sAlarmTypePresetMotorPos.bChannel = channel;
    sAlarmTypePresetMotorPos.bPresetNum = presetNumber;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sAlarmTypePresetMotorPos, sizeof(sMesgAlarmTypePresetMotorPos), NULL, 0, 0);
    mesg_id++;
}


-(void)getDefenceTypeMotorPresetPosWithId:(NSString *)contactId password:(NSString *)password channel:(int)channel{
    static int mesg_id = MESG_ID_GET_ALARM_PRESET_MOTOR_POS - 1000;
    if (mesg_id >= MESG_ID_GET_ALARM_PRESET_MOTOR_POS) {
        mesg_id = MESG_ID_GET_ALARM_PRESET_MOTOR_POS - 1000;
    }
    
    sMesgAlarmTypePresetMotorPos sAlarmTypePresetMotorPos;
    sAlarmTypePresetMotorPos.bCmd = MESG_TYPE_GET_ALARM_TYPE_MOTOR_PRESET_POS;
    sAlarmTypePresetMotorPos.bOption = 0;
    sAlarmTypePresetMotorPos.bAlarmOrDefence = 1;
    sAlarmTypePresetMotorPos.bDefenceArea = 0;
    sAlarmTypePresetMotorPos.bChannel = channel;
    sAlarmTypePresetMotorPos.bPresetNum = 0xFF;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sAlarmTypePresetMotorPos, sizeof(sMesgAlarmTypePresetMotorPos), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 获取 布防类型的预置位置
-(void)getDefenceTypeMotorPresetPosWithId:(NSString *)contactId password:(NSString *)password defenceArea:(int)defenceArea channel:(int)channel{
    static int mesg_id = MESG_ID_GET_ALARM_PRESET_MOTOR_POS - 1000;
    if (mesg_id >= MESG_ID_GET_ALARM_PRESET_MOTOR_POS) {
        mesg_id = MESG_ID_GET_ALARM_PRESET_MOTOR_POS - 1000;
    }
    
    sMesgAlarmTypePresetMotorPos sAlarmTypePresetMotorPos;
    sAlarmTypePresetMotorPos.bCmd = MESG_TYPE_GET_ALARM_TYPE_MOTOR_PRESET_POS;
    sAlarmTypePresetMotorPos.bOption = 0;
    sAlarmTypePresetMotorPos.bAlarmOrDefence = 1;
    sAlarmTypePresetMotorPos.bDefenceArea = defenceArea;
    sAlarmTypePresetMotorPos.bChannel = channel;
    sAlarmTypePresetMotorPos.bPresetNum = 0xFF;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sAlarmTypePresetMotorPos, sizeof(sMesgAlarmTypePresetMotorPos), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 设置预置位
-(void)setDevicePresetWithId:(NSString *)contactId password:(NSString *)password type:(int)type presetNum:(int)presetNum
{
    static int mesg_id = MESG_ID_SET_PRESET - 1000;
    if(mesg_id>=MESG_ID_SET_PRESET){
        mesg_id = MESG_ID_SET_PRESET - 1000;
    }
    sMesgPresetMotorPos sSetPreset;
    sSetPreset.bCmd = MESG_TYPE_SET_MOTOR_PRESET_POS;
    sSetPreset.bOption = 0;
    sSetPreset.bOperation = type;
    sSetPreset.bPresetNum = presetNum;
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetPreset, sizeof(sMesgPresetMotorPos), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 获取预置位
- (void)getPressetInfo:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_SEARCH_PRESET - 1000;
    if (mesg_id >= MESG_ID_GET_SEARCH_PRESET) {
        mesg_id = MESG_ID_GET_SEARCH_PRESET - 1000;
    }
    
    sMesgPresetMotorPos sPresetMotor;
    sPresetMotor.bCmd = MESG_TYPE_SET_MOTOR_PRESET_POS;
    sPresetMotor.bOption = 0;
    sPresetMotor.bOperation = 2;
    sPresetMotor.bPresetNum = 0;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sPresetMotor, sizeof(sMesgPresetMotorPos), NULL, 0, 0);
    mesg_id++;
    
}


#pragma mark - 预置位设置和查看
-(void)setAndSearchPresetWithId:(NSString *)contactId password:(NSString *)password operation:(int)operation presetNumber:(int)presetNumber{
    static int mesg_id = MESG_ID_SET_SEARCH_PRESET - 1000;
    if (mesg_id >= MESG_ID_SET_SEARCH_PRESET) {
        mesg_id = MESG_ID_SET_SEARCH_PRESET - 1000;
    }
    
    sMesgPresetMotorPos sPresetMotor;
    sPresetMotor.bCmd = MESG_TYPE_SET_MOTOR_PRESET_POS;
    sPresetMotor.bOption = 0;
    sPresetMotor.bOperation = operation;
    sPresetMotor.bPresetNum = presetNumber;
    fgP2PSendRemoteMessage(contactId.intValue, password.intValue, mesg_id, &sPresetMotor, sizeof(sMesgPresetMotorPos), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 学习对码，添加启用或禁用开关
#pragma mark 获取启用或禁用开关
- (void) getDefenceSwitchStateWithId:(NSString *)contactId password:(NSString *)password
{
    static int mesg_id = MESG_ID_GET_DEFENCE_SWITCH_STATE - 1000;
    if (mesg_id >= MESG_ID_GET_DEFENCE_SWITCH_STATE) {
        mesg_id = MESG_ID_GET_DEFENCE_SWITCH_STATE - 1000;
    }
    
    sMesgGetDefenceSwitchType sGetDefenceSwitch;
    sGetDefenceSwitch.bCmd = MESG_TYPE_GET_DEFENCE_SWITCH_STATE;
    sGetDefenceSwitch.bOption = 0;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sGetDefenceSwitch, sizeof(sMesgGetDefenceSwitchType), NULL, 0, 0);
    mesg_id++;
}

#pragma mark 设置启用或禁用开关
- (void) setDefenceSwitchStateWithId:(NSString *)contactId password:(NSString *)password switchId:(int)switchId alarmCodeId:(int)alarmCodeId alarmCodeIndex:(int)alarmCodeIndex
{
    static int mesg_id = MESG_ID_SET_DEFENCE_SWITCH_STATE - 1000;
    if (mesg_id >= MESG_ID_SET_DEFENCE_SWITCH_STATE) {
        mesg_id = MESG_ID_SET_DEFENCE_SWITCH_STATE - 1000;
    }
    
    sMesgSetDefenceSwitchType sSetDefenceSwitch;
    sSetDefenceSwitch.bCmd = MESG_TYPE_SET_DEFENCE_SWITCH_STATE;
    sSetDefenceSwitch.bOption = 0;
    sSetDefenceSwitch.bSetDefenceSetSwitchId = switchId;          //1 开 0关
    sSetDefenceSwitch.sAlarmCodes[0].dwAlarmCodeID = alarmCodeId;  //要设置的防区编号0～7，遥控器不支持开关
    sSetDefenceSwitch.sAlarmCodes[0].dwAlarmCodeIndex = alarmCodeIndex;//要设置防区中的通道编号0～7
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetDefenceSwitch, sizeof(sMesgSetDefenceSwitchType), NULL, 0, 0);
    mesg_id++;
}

-(void)setInitPasswordWithId:(NSString *)contactId initPassword:(NSString *)initPassword{
    static int mesg_id = MESG_ID_SET_INIT_PASSWORD-1000;
    if(mesg_id>=MESG_ID_SET_INIT_PASSWORD){
        mesg_id = MESG_ID_SET_INIT_PASSWORD-1000;
    }
    //从sMesgSetInitPasswdType改为 sMesgSetInitPasswdExtOptType，在设置p2p的密码时，同时设置rtsp的密码
    sMesgSetInitPasswdExtOptType sPassword;
    sPassword.bCmd = MESG_TYPE_SET_INIT_PASSWD;
    BYTE souceBuf[8];
    BYTE desBuf[8];
    BYTE key[8] = {0x9c, 0xae, 0x6a, 0x5a, 0xe1,0xfc,0xb0, 0x82};
    DWORD password = [[Utils GetTreatedPassword:initPassword] intValue];
    memcpy(souceBuf, &password, sizeof(DWORD));
    
    des(souceBuf,desBuf,key,0);
    memcpy(sPassword.bPasswd, desBuf, 8);
    
    NSString* sPwdRtsp = [NSString stringWithFormat:@"admin:HIipCamera:%@", initPassword];
    [MD5Manager GetMD5PasswordWithSrc:[sPwdRtsp UTF8String] Dst:sPassword.cRtspPasswdVerification];
    
    int iTargetID = GetIpBy3CID(contactId.intValue);       //设置初始密码必须用ip地址，所以搜索设备的时候不判断密码标志位
    fgP2PSendRemoteMessage(iTargetID, 0, mesg_id, &sPassword, sizeof(sMesgSetInitPasswdExtOptType), NULL, 0, 0);
    mesg_id++;
}

-(void)checkDeviceUpdateWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_CHECK_DEVICE_UPDATE-1000;
    if(mesg_id>=MESG_ID_CHECK_DEVICE_UPDATE){
        mesg_id = MESG_ID_CHECK_DEVICE_UPDATE-1000;
    }
    sMesgUpgType sUpg;
    sUpg.bCmd = MESG_TYPE_UPG_CHEK_VERSION;
    sUpg.sRemoteUpgMesg.dwUpgVal = 1;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sUpg, sizeof(sMesgUpgType), NULL, 0, 0);
    mesg_id++;
}

-(void)doDeviceUpdateWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_DO_DEVICE_UPDATE-1000;
    if(mesg_id>=MESG_ID_DO_DEVICE_UPDATE){
        mesg_id = MESG_ID_DO_DEVICE_UPDATE-1000;
    }
    sMesgUpgType sUpg;
    sUpg.bCmd = MESG_TYPE_UPG_FILE_TO_DOWNLOAD;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sUpg, sizeof(sMesgUpgType), NULL, 0, 0);
    mesg_id++;
}

-(void)cancelDeviceUpdateWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_CANCEL_DEVICE_UPDATE-1000;
    if(mesg_id>=MESG_ID_CANCEL_DEVICE_UPDATE){
        mesg_id = MESG_ID_CANCEL_DEVICE_UPDATE-1000;
    }
    sMesgUpgType sUpg;
    sUpg.bCmd = MESG_TYPE_UPG_FILE_CANCEL_DOWNLOAD;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sUpg, sizeof(sMesgUpgType), NULL, 0, 0);
    mesg_id++;
}

-(NSInteger)sendMessageToFriend:(NSString *)contactId message:(NSString *)message{
    static int mesg_id = MESG_ID_SEND_MESSAGE-1000;
    if(mesg_id>=MESG_ID_SEND_MESSAGE){
        mesg_id = MESG_ID_SEND_MESSAGE-1000;
    }
    
    char *messageStr = (char*)[message UTF8String];
    int length = strlen(messageStr);
    
    if(!message||length<=0||length>1024){
        return -1;
    }
    
    sMesgStringMesgType sMessage;
    
    sMessage.bCmd = MESG_TYPE_MESSAGE;
    sMessage.bOption = 0;
    sMessage.wLen = length;
    
    memcpy(sMessage.cString, messageStr, length);
    mesg_id++;
    fgP2PSendRemoteMessage(contactId.intValue|0x80000000, 0, mesg_id, &sMessage, length+4, sMessage.cString, length, (DWORD)PUSH_MESG_FRIEND);
    return mesg_id;
}

-(void)getDeviceInfoWithId:(NSString *)contactId password:(NSString *)password{
    static int mesg_id = MESG_ID_GET_DEVICE_INFO-1000;
    if(mesg_id>=MESG_ID_GET_DEVICE_INFO){
        mesg_id = MESG_ID_GET_DEVICE_INFO-1000;
    }
    sMesgSysVersionType sVersion;
    sVersion.bCmd = MESG_TYPE_GET_SYS_VERSION;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sVersion, sizeof(sMesgSysVersionType), NULL, 0, 0);
    mesg_id++;
}

-(NSInteger)sendCustomCmdWithId:(NSString *)contactId password:(NSString *)password cmd:(NSString *)cmd{
    static int mesg_id = MESG_ID_SEND_CUSTOM_CMD-1000;
    if(mesg_id>=MESG_ID_SEND_CUSTOM_CMD){
        mesg_id = MESG_ID_SEND_CUSTOM_CMD-1000;
    }
    
    char *cmdStr = (char*)[cmd UTF8String];
    int length = strlen(cmdStr);
    
    if(length<=0||length>1024){
        return -1;
    }
    
    sMesgStringMesgType sMessage;
    
    sMessage.bCmd = MESG_TYPE_USER_CMD;
    sMessage.bOption = 0;
    sMessage.wLen = length;
    
    memcpy(sMessage.cString, cmdStr, length);
    mesg_id++;
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sMessage, length+4, sMessage.cString, length, (DWORD)PUSH_MESG_FRIEND);
    return mesg_id;
}

#pragma mark - 设置GPIO中值
-(void)setGpioCtrlWithId:(NSString *)contactId password:(NSString *)password group:(int)group pin:(int)pin value:(int)value time:(int [])time{
    static int mesg_id = MESG_ID_SET_GPIO_CTL-1000;
    if(mesg_id>=MESG_ID_SET_GPIO_CTL){
        mesg_id = MESG_ID_SET_GPIO_CTL-1000;
    }
    sMesgSetGpioCtrl sSetGpioCtrl;
    sSetGpioCtrl.bCmd = MESG_TYPE_SET_GPIO_CTL;
    sSetGpioCtrl.bOption = 0;
    sSetGpioCtrl.bGroup = group;
    sSetGpioCtrl.bPin = pin;
    sSetGpioCtrl.bValueNs = value;
    for (int i = 0; i < 8; i++) {
        sSetGpioCtrl.iTimer_ms[i] = time[i];
    }
    
    int iTargetID = GetIpBy3CID(contactId.intValue);
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetGpioCtrl, sizeof(sMesgSetGpioCtrl), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 设备重启
-(void)setDeviceRemoteRebootRWithId:(NSString *)contactId password:(NSString *)password value:(NSInteger)value bRebootType:(NSInteger)bRebootType
{
    static int mesg_id = MESG_ID_SET_REMOTE_REBOOT - 1000;
    if (mesg_id >= MESG_ID_SET_REMOTE_REBOOT) {
        mesg_id = MESG_ID_SET_REMOTE_REBOOT - 1000;
    }
    sMesgRemoteReboot sRemoteReboot;
    sRemoteReboot.bCmd = MESG_TYPE_SET_REMOTE_REBOOT;
    sRemoteReboot.bOption = 0;
    sRemoteReboot.bRebootType = bRebootType;
    sRemoteReboot.bReserve = 0;
    sRemoteReboot.dwTimer_s = value;
    int iTargetID = GetIpBy3CID(contactId.intValue);
    
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sRemoteReboot, sizeof(sRemoteReboot), NULL, 0, 0);
    
}

#pragma mark - 获取 温湿度数据
-(void)getDeviceTHWithId:(NSString *)contactId password:(NSString *)password
{
    static int mesg_id = MESG_ID_GET_TH_DATA - 1000;
    if (mesg_id >= MESG_ID_GET_TH_DATA) {
        mesg_id = MESG_ID_GET_TH_DATA - 1000;
    }
    sMesgTHData sTHData;
    sTHData.bCmd = MESG_TYPE_GET_TH_DATA;
    sTHData.bOption = 0;
    sTHData.bTempOrHumi = 0;
    sTHData.bLimiteType = 0;
    sTHData.fTemperature = 0;
    sTHData.dwHumidity = 0;
    int iTargetID = GetIpBy3CID(contactId.intValue);
    
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sTHData, sizeof(sMesgTHData), NULL, 0, 0);
    mesg_id++;
}

#pragma mark - 设置温湿度上下限
-(void)setDeviceTHWithId:(NSString*)contactId password:(NSString*)password value:(NSInteger)value type:(NSInteger)type bLimiteType:(NSInteger)bLimiteType
{
    static int mesg_id = MESG_ID_SET_TH_DATA - 1000;
    if(mesg_id>=MESG_ID_SET_TH_DATA){
        mesg_id = MESG_ID_SET_TH_DATA - 1000;
    }
    sMesgTHData sSetTHData;
    sSetTHData.bCmd = MESG_TYPE_SET_TH_DATA;
    sSetTHData.bOption = 0;
    sSetTHData.bTempOrHumi = type;//值 0 为温度,值 1为湿度
    sSetTHData.bLimiteType = bLimiteType;// 值0 为下限, 值1 为上限
    sSetTHData.fTempLmt[bLimiteType] = value;//fTempLmt[ 1 ] ：温度上限值。fTempLmt[ 0 ] ： 温度下限值
    sSetTHData.dwHumiLmt[bLimiteType] = value;//dwHumiLmt[ 1 ] ： 湿度上限值。dwHumiLmt[ 0 ] : 湿度下限值
    int iTargetID = GetIpBy3CID(contactId.intValue);
    
    fgP2PSendRemoteMessage(iTargetID, password.intValue, mesg_id, &sSetTHData, sizeof(sMesgTHData), NULL, 0, 0);
    mesg_id++;
    
}





-(void)startRecord
{
    [[MP4Recorder sharedDefault]startRecordWithID:_callId];
}

-(void)stopRecord
{
    [[MP4Recorder sharedDefault]stopRecord];
}

void vRecvAVHeader1(sAVInfoType * pAVInfo)
{
    [[MP4Recorder sharedDefault] vRecvAVHeader1WithVideoWidth:pAVInfo->VideoWidth VideoHeight:pAVInfo->VideoHeight];
}

void vRecvAVData1(BYTE *pAudioData, DWORD dwAudioDataLen, uint32_t dwFrames, UINT64 u64APTS, BYTE *pVideoData, DWORD dwVideoLen,  UINT64 u64VPTS)
{
    [[MP4Recorder sharedDefault]vRecvAVData1WithAudioType:AUDIO_TYPE_AMR pAudioData:pAudioData dwFrames:dwFrames pVideoData:pVideoData dwVideoLen:dwVideoLen];
}












@end





