//
//  QRCodeNextController.m
//  Yoosee
//
//  Created by guojunyi on 14-9-18.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "QRCodeNextController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "QRCodeGenerator.h"
#import "YProgressView.h"
#import "FListManager.h"
#import "CreateInitPasswordController.h"
#import "AddContactNextController.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#import "elian.h"
#import "WaitingPageView.h"
#import "QRCodeController.h"
#import "LSemTMFSet.h"
@interface QRCodeNextController () <LSemTMFSetDelegate>

{
    void *_context;
}
@property (nonatomic,copy) NSString *contactID;
@property (nonatomic,assign) NSInteger flag;
@property (nonatomic,assign) NSInteger type;
@property (strong,nonatomic) NSMutableDictionary *addresses;

@property (nonatomic,copy) NSString *address;

@end

@implementation QRCodeNextController
#pragma mark - 声波SDK初始化
-(void)soundInit{
    
    int soundCode=[[LSemTMFSet sharedInstance]initSDK:@"gwelltimes"
                                               client:@"gwelltimes"
                                         productModel:@"gm8135s-8136"
                                              license:@"11625ae8060111e6b5123e1d05defe78"];
    NSLog(@"声波初始化的结果码:%d",soundCode);
    [[LSemTMFSet sharedInstance] setDelegate:self];
    
}

#pragma mark - 声波开始发送
-(void)soundSendStart{
    NSLog(@"开始发送声波");
    
    [[LSemTMFSet sharedInstance] sendWiFiSet:self.uuidString password:self.wifiPwd];
    NSLog(@"要发送的WiFi是:%@,其密码是:%@",self.uuidString,self.wifiPwd);
    
}
#pragma mark - 声波停止发送
-(void)soundSendStop{
    NSLog(@"停止发送声波");
    [[LSemTMFSet sharedInstance] stopSend];
    [[LSemTMFSet sharedInstance] cancleConnectTimer];
}
#pragma mark - 声波SDK退出和释放
-(void)soundExit{
    NSLog(@"退出声波SDK");
    [self soundSendStop];
    [[LSemTMFSet sharedInstance] exitEMTMFSDK];
}
#pragma mark - 声波的几个协议
- (void)didSetWifiResultErrcode:(EMTMFErrcodeType*)errcode content:(NSString*)content{
    if (errcode==(EMTMFErrcodeType*)EMTMFErrcodeType_SUCESS){
        NSLog(@"声波配对成功");
        self.isWaiting = NO;
        
    }else{
        NSLog(@"声波配对失败,重新发送");
        [self soundSendStart];
    }
}
- (void)didFSKSendingComplete{
    [[LSemTMFSet sharedInstance] startConnectTimeOutListener:1];//暂停1秒,然后继续发送声波
}

-(void)didSDKErrcode:(int) errCode errMsg:(NSString*)errMsg{
    NSLog(@"声波初始化结果码:%d,结果码解释:%@",errCode,errMsg);
}
-(void)dealloc{
    [self.uuidString release];
    [self.wifiPwd release];
    [self.smartKeyPromptView release];
    [self.qrcodeImageView release];
    [self.addresses release];
    [self.promptButton release];//set wifi to add device by qr
    [self.topBar release];//set wifi to add device by qr
    
    [super dealloc];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self soundExit];
    });
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.conectType == conectType_Intelligent){//startSetWifiLoop
//        配置Wi-Fi
        if (_context){
            elianStop(_context);
            elianDestroy(_context);
            _context = NULL;

        }
    }
    
    self.isWaiting = NO;//isWaiting is NO
    self.isFinish = YES;
    self.isRun = NO;
    if(self.socket){
        [self.socket close];
        self.socket=nil;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    isButtonSend 是点击上个界面的按钮的点击状态

#pragma mark -  扫描二维码
//    if (self.conectType == conectType_qrcode) {
//        self.qrcodeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"EnCtYpE_ePyTcNeEsSiD%@dIsSeCoDe%@eDoC",self.uuidString,self.wifiPwd] imageSize:self.qrcodeImageView.frame.size.width];
//    }
// #pragma mark -  智能连接
//    else if (self.conectType == conectType_Intelligent)
//    {
//        self.qrcodeImageView.image = [UIImage imageNamed:@"Qcord0"];
////        [self startSetWifiLoop];//给设备设置wifi
//        [self soundSendStart];
//
//        [self onBottomButtom1Press];//直接调用，不用点击“听到了”按钮
//        
////        [self startTiming];
//
//    }
//    self.isFinish = NO;

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.conectType == conectType_qrcode) {
                self.qrcodeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"EnCtYpE_ePyTcNeEsSiD%@dIsSeCoDe%@eDoC",self.uuidString,self.wifiPwd] imageSize:self.qrcodeImageView.frame.size.width];
            }
            else if (self.conectType == conectType_Intelligent)
            {
                self.qrcodeImageView.image = [UIImage imageNamed:@"Qcord0"];
                [self startSetWifiLoop];//给设备设置wifi
                //发送声波
                [self soundSendStart];
                [self onBottomButtom1Press];//直接调用，不用点击“听到了”按钮
            }
            self.isFinish = NO;
        });
    });
    
    self.isRun = YES;
    self.isPrepared = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(self.isRun){//不断广播获取设置好WIFI的设备
            if(!self.isPrepared){
                [self prepareSocket];
            }
            usleep(1000000);
        }
    });
}



-(BOOL)prepareSocket{
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    
    if (![socket bindToPort:9988 error:&error])
    {
        //NSLog(@"Error binding: %@", [error localizedDescription]);
        return NO;
    }
    if (![socket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", [error localizedDescription]);
        return NO;
    }
    
    if (![socket enableBroadcast:YES error:&error])
    {
        NSLog(@"Error enableBroadcast: %@", [error localizedDescription]);
        return NO;
    }
    
    self.socket = socket;
    self.isPrepared = YES;
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self soundInit]; //声波配网

    self.addresses = [[NSMutableDictionary alloc] initWithCapacity:1];
    [self initComponent];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#define QRCODE_IMAGE_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 450:250)
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH 100
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT 32
#define WAITING_CONTENT_VIEW_WIDTH 288
#define WAITING_CONTENT_VIEW_HEIGHT 300


-(void)connectOnceAgainButtonClick{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)connectFailurePromptViewSetWifiToAddDeviceByQR{//set wifi to add device by qr

    [self.navigationController popViewControllerAnimated:YES];
//    self.qrCodeController.SetWifiToAddDeviceByQR = @"SetWifiToAddDeviceByQR";
}


-(void)onHelpPress{//set wifi to add device by qr
    [self.promptButton setHidden:NO];
}

-(void)dismissView{//set wifi to add device by qr
    [self.promptButton setHidden:YES];
}

-(void)onBackPress{
    if (self.conectType == conectType_qrcode){//set wifi to add device by qr
        self.qrCodeController.isSetWifiToAddDeviceByQR = YES;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 使用90秒来进行空中发包，给设备设置wifi
-(void)onBottomButtom1Press{
    [self.smartKeyPromptView setHidden:NO];
    if (self.conectType == conectType_qrcode) {//set wifi to add device by qr
        [self.topBar setRightButtonHidden:YES];
    }
    
    self.isWaiting = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int index = 0;
        while(self.isWaiting){
            DLog(@"%i",index);
            index++;
            if (self.conectType == conectType_Intelligent){//startSetWifiLoop
                if (index >= 21 && index <= 30) {
                    if (index == 21) {
                        elianStop(_context);
                    }
                    
                }else if (index >= 51 && index <= 60){
                    if (index == 51) {
                        elianStop(_context);
                    }
                    
                }else if (index >= 81){
                    if (index == 81) {
                        elianStop(_context);

                    }
                    
                }else{
                    if (index==31 || index==61) {
                        elianStart(_context);
                    }
                }
                if(index>=90){//90
                    break;
                }
            }else{
                if(index>=60){//60
                    break;
                }
            }
            sleep(1.0);
        }
        [self soundSendStop];

        if(!self.isFinish){
            if (self.conectType == conectType_Intelligent){//startSetWifiLoop
                if (_context){
                    elianStop(_context);
                    elianDestroy(_context);
                    _context = NULL;
                }//设置WIFI失败，停止

            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.smartKeyPromptView setHidden:NO];
                
                [self.connectFailurePromptView setHidden:NO];
                self.isWaiting = NO;//isWaiting is NO

            });
        }
    });
}


#pragma mark - 搜索到设备，弹出添加设备提示
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (alertView.tag==ALERT_TAG_SET_FAILED) {
        if(buttonIndex==0){
            
        }
    }else if(alertView.tag==ALERT_TAG_SET_SUCCESS){
        if(buttonIndex==0){
            [[FListManager sharedFList] searchLocalDevices];
            self.address = [self.addresses objectForKey:self.contactID];
            NSArray *stringArray = [self.address componentsSeparatedByString:@"."];
            NSString *targetAdress = [NSString stringWithFormat:@"%@",[stringArray lastObject]];
            
            if (self.flag == 0) {//设备未初始化过密码
                CreateInitPasswordController *createInitPasswordController = [[CreateInitPasswordController alloc] init];
                [createInitPasswordController setContactId:self.contactID];
                createInitPasswordController.isPopRoot = YES;
                createInitPasswordController.contactIp = targetAdress;
                [createInitPasswordController setAddress:self.address];
                [self.navigationController pushViewController:createInitPasswordController animated:YES];
                [createInitPasswordController release];
                
            }else{
                AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
                [addContactNextController setContactId:self.contactID];
                addContactNextController.isPopRoot = YES;
                addContactNextController.isInFromQRCodeNextController = YES;
                addContactNextController.inType = 0;
                [self.navigationController pushViewController:addContactNextController animated:YES];
                addContactNextController.hideDeleteBtn = @"hideDeleteBtn";
                [addContactNextController release];
            }
        }
    }
}

#pragma mark - GCDAsyncUdpSocket
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"did send");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"error:== %@", error);
}

#pragma mark 搜索设备
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    if (data) {
        Byte receiveBuffer[1024];
        [data getBytes:receiveBuffer length:1024];
        
        if(receiveBuffer[0]==1){
            NSString *host = nil;
            uint16_t port = 0;
            [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
            
            int contactId = *(int*)(&receiveBuffer[16]);
            int type = *(int*)(&receiveBuffer[20]);
            int flag = *(int*)(&receiveBuffer[24]);
            
            self.contactID = [NSString stringWithFormat:@"%d",contactId];
            self.type = type;
            self.flag = flag;
            [self.addresses setObject:host forKey:[NSString stringWithFormat:@"%i",contactId]];
            
            if(self.isShowSuccessAlert){
                return;
            }
            
            if(self.isWaiting){
                self.isWaiting = NO;//isWaiting is NO
                self.isShowSuccessAlert = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isFinish = YES;
                    [self.smartKeyPromptView setHidden:NO];
                    if (!self.isNotFirst) {
                        if (self.conectType == conectType_Intelligent){//startSetWifiLoop
                            if (_context){
                                elianStop(_context);
                                elianDestroy(_context);
                                _context = NULL;
                            }//设置WIFI成功，停止
                            
                        }
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"set_wifi_success_title", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil,nil];
                        alert.tag = ALERT_TAG_SET_SUCCESS;
                        [alert show];
                        [alert release];
                        self.isNotFirst = YES;
                    }
                });
                
            }
        }
    }
}


#pragma mark - 空中发包，给设备设置wifi
- (void)startSetWifiLoop
{
    //ssid
    const char *ssid = [self.uuidString cStringUsingEncoding:NSASCIIStringEncoding];
    //authmode
    int authmode = 9;//delete
    //pwd
    const char *password = [self.wifiPwd cStringUsingEncoding:NSUTF8StringEncoding];//NSASCIIStringEncoding
    //target
    unsigned char target[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    
    
    _context = elianNew(NULL, 0, target, ELIAN_SEND_V1 | ELIAN_SEND_V4);
    elianPut(_context, TYPE_ID_AM, (char *)&authmode, 1);//delete
    elianPut(_context, TYPE_ID_SSID, (char *)ssid, strlen(ssid));
    elianPut(_context, TYPE_ID_PWD, (char *)password, strlen(password));

    elianStart(_context);
}
-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    if (self.conectType == conectType_qrcode) {//set wifi to add device by qr
        [topBar setRightButtonHidden:NO];
        [topBar setRightButtonText:NSLocalizedString(@"help", nil)];
        [topBar.rightButton addTarget:self action:@selector(onHelpPress) forControlEvents:UIControlEventTouchUpInside];
    }
    [topBar setTitle:NSLocalizedString(@"add_new_device",nil)];
    [self.view addSubview:topBar];
    self.topBar = topBar;
    [topBar release];
    
    [self.view setBackgroundColor:XBgColor];
    
    UIImageView *qrcodeImage = [[UIImageView alloc] initWithFrame:CGRectMake((width-QRCODE_IMAGE_WIDTH_HEIGHT)/2, 20+NAVIGATION_BAR_HEIGHT, QRCODE_IMAGE_WIDTH_HEIGHT, QRCODE_IMAGE_WIDTH_HEIGHT)];
    if (self.conectType == conectType_qrcode) {
        qrcodeImage.layer.cornerRadius = 5.0;
        qrcodeImage.layer.borderColor = [XBlack CGColor];
        qrcodeImage.layer.borderWidth = 1.0;
        qrcodeImage.backgroundColor = XWhite;
        [self.view addSubview:qrcodeImage];//set wifi to add device by qr
    }
    self.qrcodeImageView = qrcodeImage;
    [qrcodeImage release];
    
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, self.qrcodeImageView.frame.origin.y+self.qrcodeImageView.frame.size.height+20, width-40, (height-(self.qrcodeImageView.frame.origin.y+self.qrcodeImageView.frame.size.height+20))/2);
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = XBlack;
    label.font = XFontBold_16;
    label.backgroundColor = [UIColor clearColor];
    if (self.conectType == conectType_qrcode) {
        label.text = NSLocalizedString(@"qrcode_prompt", nil);
        [self.view addSubview:label];//set wifi to add device by qr
    }
    else
    {
        label.text = NSLocalizedString(@"qrcode_prompt01", nil);
    }
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, label.frame.origin.y+label.frame.size.height, width, height-(label.frame.origin.y+label.frame.size.height))];
    
    UIButton *bottomButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton1 addTarget:self action:@selector(onBottomButtom1Press) forControlEvents:UIControlEventTouchUpInside];
    bottomButton1.frame = CGRectMake((bottomView.frame.size.width-SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH)/2, (bottomView.frame.size.height-SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT)/2, SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH, SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT);
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [bottomButton1 setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [bottomButton1 setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [bottomButton1 setTitle:NSLocalizedString(@"heard", nil) forState:UIControlStateNormal];
    
    [bottomView addSubview:bottomButton1];
    
    if (self.conectType == conectType_qrcode) {
        [self.view addSubview:bottomView];//set wifi to add device by qr
    }
    
    [label release];
    [bottomView release];
    
    UIView *smartKeyPromptView = [[WaitingPageView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    [self.view addSubview:smartKeyPromptView];
    self.smartKeyPromptView = smartKeyPromptView;
    [smartKeyPromptView release];
    
    if (self.conectType == conectType_qrcode) {
        [self.smartKeyPromptView setHidden:YES];//set wifi to add device by qr
    }else{
        [self.smartKeyPromptView setHidden:NO];//直接显示“正在连接WIFI”界面
    }
    
    //二维码帮助引导视图
    //set wifi to add device by qr
    UIButton * promptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    promptButton.frame = CGRectMake(0, 0, width, height);
    promptButton.backgroundColor = XBlack_128;
    [promptButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *helpContent = [[UIImageView alloc] initWithFrame:CGRectMake((smartKeyPromptView.frame.size.width-WAITING_CONTENT_VIEW_WIDTH)/2, (smartKeyPromptView.frame.size.height-WAITING_CONTENT_VIEW_HEIGHT)/2+NAVIGATION_BAR_HEIGHT, WAITING_CONTENT_VIEW_WIDTH, WAITING_CONTENT_VIEW_HEIGHT)];
    UIImage *helpContentImage = [UIImage imageNamed:@"bg_smart_key_prompt.png"];
    helpContentImage = [helpContentImage stretchableImageWithLeftCapWidth:helpContentImage.size.width*0.5 topCapHeight:helpContentImage.size.height*0.5];
    helpContent.image = helpContentImage;
    [promptButton addSubview:helpContent];
    
    UIImageView *helpContentTop = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, WAITING_CONTENT_VIEW_WIDTH-20*2, WAITING_CONTENT_VIEW_HEIGHT/2)];
    helpContentTop.contentMode = UIViewContentModeScaleAspectFit;
    helpContentTop.image = [UIImage imageNamed:@"img_scanning_code.png"];
    [helpContent addSubview:helpContentTop];
    [helpContentTop release];
    
    UILabel *helpContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, helpContentTop.frame.origin.y+helpContentTop.frame.size.height+10, WAITING_CONTENT_VIEW_WIDTH-20*2, 50)];
    helpContentLabel.backgroundColor = [UIColor clearColor];
    helpContentLabel.numberOfLines = 0;
    helpContentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    helpContentLabel.textColor = XBlack;
    helpContentLabel.textAlignment = NSTextAlignmentCenter;
    helpContentLabel.text = NSLocalizedString(@"set_scanning_code_prompt", nil);
    helpContentLabel.font = XFontBold_14;
    [helpContent addSubview:helpContentLabel];
    [helpContentLabel release];
    [helpContent release];
    
    [self.view addSubview:promptButton];
    self.promptButton = promptButton;
    [self.promptButton setHidden:YES];
    
    self.isShowSuccessAlert = NO;
    ConnectFailurePromptView *connectFailurePromptView = [[ConnectFailurePromptView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    connectFailurePromptView.delegate = self;
    [self.view addSubview:connectFailurePromptView];
    [connectFailurePromptView setHidden:YES];
    self.connectFailurePromptView = connectFailurePromptView;
    [connectFailurePromptView release];
    
}

#pragma mark - 无用
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


#pragma mark - 屏幕
-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationPortrait );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end
