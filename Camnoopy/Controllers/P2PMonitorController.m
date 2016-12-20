#import "P2PMonitorController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "P2PClient.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "PAIOUnit.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "Utils.h"
#import "TouchButton.h"
#import "FListManager.h"
#import "MBProgressHUD.h"
#import "YProgressView.h"
#import "DWBubbleMenuButton.h"
//#import "AlarmDeviceListCell.h"
#import "mesg.h"
#import "DefenceCell.h"
#import "DefenceMagneticCell.h"
#import "DefenceDao.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ASIHTTPRequest.h"
#import "DefenceMagnetic1Cell.h"
#import "DefenceMagnetic1Model.h"
#import "yizhiweiCell.h"
#import "yizhiweimodel.h"
#define CONTROLLER_BAR_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 62:38)
#define CONTROLLER_BAR_BUTTON_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 82:50)
#define CONTROLLER_BAR_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 70:40)
#define CONTROLLER_BUTTON_WIDTH ([UIScreen mainScreen].bounds.size.height <= 480 ? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100:50):(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 120:70))
#define CONTROLLER_BUTTON_WIDTH_BIG ([UIScreen mainScreen].bounds.size.height <= 480 ? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 150:80):(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 180:100))
#define SCREENSHOTVIEW_HIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 94:74)
#define REMOTEVIEW_HEIGHT ([UIScreen mainScreen].bounds.size.height <= 480 ? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 300:200):(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 400:240))
#define PAGECONTROL_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 40:20)
#define PAGECONTROL_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:40)
#define PAGECONTROL_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:40)
#define LOADINGPRESSVIEW_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:40)
#define YUZHIWEI_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 280:90)

#define PRESS_LAYOUT_WIDTH_AND_HEIGHT 38
#define NUMBER_VIEW_LABEL_WIDTH 140
#define NUMBER_VIEW_LABEL_HEIGHT 25
#define CONTROLLER_BTN_TAG_SOUND 1
#define CONTROLLER_BTN_TAG_SCREENSHOT 2
#define CONTROLLER_BTN_TAG_PRESS_TALK 3
#define CONTROLLER_BTN_TAG_HD 4
#define CONTROLLER_BTN_TAG_SD 5
#define CONTROLLER_BTN_TAG_LD 6
#define CONTROLLER_BTN_TAG_DEFENCE  7
#define CONTROLLER_BTN_TAG_RECORD 8
#define CONTROLLER_BTN_TAG_FOLDER 9
#define CONTROLLER_BTN_TAG_FULLSCREEN 10
#define CONTROLLER_BTN_TAG_HUNGUP 11
#define CONTROLLER_BTN_TAG_RESOLUTION 12
#define CONTROLLERMENU_TAG 13
#define CONTROLLER_MAIN_TAG 14
#define CONTROLLER_BTN_TAG_SENSOR 15
#define CONTROLLER_BTN_TAG_REMOTE 16
#define CONTROLLER_BTN_TAG_GPIO1_0 17  //lock
#define CONTROLLER_BTN_COUNT 7 //tool button count

@interface P2PMonitorController ()<UITableViewDelegate,UITableViewDataSource,DefenceCMagneticellDelegate>
{
    UIPageControl * _pageControl;
    CGRect _rectResoutionShow;
    CGRect _rectResoutionHide;
    BOOL _isShowResolutionView;
    
    UIButton* _btnVoiceMenu;
    UIButton* _btnVoiceFull;
    
    BOOL _flag;//单次点击可直接对讲
    //    UIPanGestureRecognizer *panGR;
    BOOL _isGetDefenceStatusData;
    BOOL _isGetDefenceSwitchData;
    SystemSoundID soundId;
    UITableView *oneTableView;
    UITableView *twoTableView;
    UIView *v1;
}
@end

@implementation P2PMonitorController

-(void)dealloc{
    [self.remoteView release];
    [self.talkingTipView release];
    [self.viewerCountLable release];
    [self.viewerCountLable1 release];
    [self.canvasView release];
    [self.resolutionViewFull release];
    [self.screenshotView release];
    [self.connectingTipView release];
    //[self.connectingTipLable release];
    [self.toolbarFull release];
    [self.fullShotimgScrollView release];
    [self.controllerMenu release];
    [self.nowShowfullScrollView release];
    [self.recordbtn release];
    [self.recordbtnFull release];
    
    [self.resolutionbtnFull release];
    [self.shottopLabel release];
    [self.contact release];
    [self.defenceStatusData release];
    [self.nameArray release];
    [self.switchStatusData release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self startConnect];
    [[P2PClient sharedClient] p2pCallWithId:self.contact.contactId password:self.contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
    
#pragma mark - 获取判断是否支持预置位
    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
    [[P2PClient sharedClient] getPressetInfo:self.contact.contactId password:self.contact.contactPassword];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePlayingCommand:) name:RECEIVE_PLAYING_CMD object:nil];
    
    //接收远程消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitorStartMessage:) name:MONITOR_START_MESSAGE object:nil];
//    _isdelete = NO;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.isLoadDefenceArea = YES;
    [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isRender = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MONITOR_START_MESSAGE object:nil];
    self.isReject = YES;
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO];//顶部状态栏隐藏
    [self.remoteView setCaptureFinishScreen:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_PLAYING_CMD object:nil];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
                                       withObject:(id)UIDeviceOrientationPortrait];
    }
}

#define MESG_SET_GPIO_PERMISSION_DENIED 86
#define MESG_GPIO_CTRL_QUEUE_IS_FULL 87
#define MESG_SET_DEVICE_NOT_SUPPORT 255
- (void)receiveRemoteMessage:(NSNotification *)notification{
    //    NSLog(@"进来了方法:receiveRemoteMessage");
    NSDictionary *parameter = [notification userInfo];
    int key = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_SET_SEARCH_PRESET:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            
            if (result == 0) {
                //设置成功
                int bOperation = [[parameter valueForKey:@"bOperation"] intValue];
                if (bOperation == 1) {
                    int bPresetNum = [[parameter valueForKey:@"bPresetNum"] intValue];
                    NSLog(@"%d bPresetNum bPresetNum ", bPresetNum);
                }
                
            }else if (result == 1){
                //操作获取成功
                int bOperation = [[parameter valueForKey:@"bOperation"] intValue];
                if (bOperation == 2) {
                    int bPresetNum = [[parameter valueForKey:@"bPresetNum"] intValue];
                                        NSLog(@"%d bPresetNum bPresetNum ", bPresetNum);
                    _Num = bPresetNum;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        int c = _Num & 0b0001;
                        int d = _Num & 0b0010;
                        int f = _Num & 0b0100;
                        int g = _Num & 0b1000;
                        int h = _Num & 0b10000;
                        //                        NSLog(@"%d,%d,%d,%d,%d",c,d,f,g,h);
                        if (c == 1) {
                            [_array addObject:@"1"];
                        }
                        if (d == 2){
                            [_array addObject:@"2"];
                        }
                        if (f == 4){
                            [_array addObject:@"3"];
                        }
                        if (g == 8){
                            [_array addObject:@"4"];
                        }
                        if (h == 16){
                            [_array addObject:@"5"];
                        }
                        //                        NSLog(@"===array====%d",_array.count);
                        //                        for (NSString *c in _array) {
                        //                            NSLog(@"%@",c);
                        //                        }
                        [self.tableView reloadData];
                    });
                }
                
            }else if (result == 84 ){
                //为无此设置选项
            }else if (result == 254){
                //表示填入参数有误
            }else if (result == 255){
                //设备不支持预置位
            }
        }
            break;

#pragma mark - 获取是否支持预置位的值
        case RET_GET_PRESET_POS_SUPPORT:
        {
            NSInteger presetPosFlag = [[parameter valueForKey:@"presetPosFlag"] intValue];
            if (presetPosFlag) {
                self.isyuzhiwei= YES;
            }else{
                self.isyuzhiwei= NO;
            }
        }
            break;
            
        case RET_SET_GPIO_CTL:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            if (result == 0)
            {
                //设置成功
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
            }else if (result == MESG_SET_GPIO_PERMISSION_DENIED){
                //该GPIO未开放
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.view makeToast:NSLocalizedString(@"not_open", nil)];
                });
            }else if (result == MESG_GPIO_CTRL_QUEUE_IS_FULL){
                //操作过于频繁，之前的操作未执行完
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.view makeToast:NSLocalizedString(@"too_frequent", nil)];
                });
            }
            else if(result == MESG_SET_DEVICE_NOT_SUPPORT)
            {
                //设备不支持此操作
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.view makeToast:NSLocalizedString(@"not_support_operation", nil)];
                });
            }
        }
            break;
            
        case RET_DEVICE_NOT_SUPPORT://不支持禁用、启用开关
        {
            NSLog(@"进入case RET_DEVICE_NOT_SUPPORT");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressAlert hide:YES];
            });
            
            //作此判断是因为，2代npc支持防区加减，却不支持防区开关
            if (!_isGetDefenceStatusData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"device_not_support", nil)];
                });
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    usleep(800000);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:nil];
                    });
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [oneTableView reloadData];
                });
            }
        }
            break;
            
//        case RET_GET_DEFENCE_SWITCH_STATE:
//        {
//            NSLog(@"进入case RET_GET_DEFENCE_SWITCH_STATE");
//            NSMutableArray *switchStatus = [parameter valueForKey:@"switchStatus"];
//            self.switchStatusData = [switchStatus objectAtIndex:self.dwCurGroup];
//            _isGetDefenceSwitchData = YES;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.progressAlert hide:YES];
//                if(self.isSetting){
//                    self.isSetting = NO;
//                    [self.view makeToast:NSLocalizedString(@"modify_success", nil)];
//                }
//                [self.progressAlert hide:YES];
//                [oneTableView reloadData];
//            });
//        }
//            break;
//        case RET_SET_DEFENCE_SWITCH_STATE:
//        {
//            NSLog(@"进入case RET_SET_DEFENCE_SWITCH_STATE");
//            NSInteger result = [[parameter valueForKey:@"result"] intValue];
//            if(result==0){
//                self.isSetting = YES;
//                [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
//                
//            }else if(result==41){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.view makeToast:NSLocalizedString(@"device_not_support", nil)];
//                    //                                [self onBackPress];
//                });
//            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.progressAlert hide:YES];
//                    [oneTableView reloadData];
//                    [self.view makeToast:NSLocalizedString(@"modify_failure", nil)];
//                });
//            }
//        }
//            break;
//            
//        case RET_GET_DEFENCE_AREA_STATE:
//        {
//            NSLog(@"进入case RET_GET_DEFENCE_AREA_STATE");
//            NSInteger result = [[parameter valueForKey:@"result"] intValue];
//            //            NSLog(@"😄😭😊：%d", result);
//            if(result==MESG_SET_ID_ALARMCODE_UBOOT_VERSION_ERR || result == MESG_SET_DEVICE_NOT_SUPPORT){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.progressAlert hide:YES];
//                    [self.view makeToast:NSLocalizedString(@"device_not_support_defence_area", nil)];
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        usleep(800000);
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            //                            [self onBackPress];
//                        });
//                    });
//                });
//                return;
//            }
//            else if (result == MESG_GET_OK)//come here
//            {
//                NSMutableArray *status = [parameter valueForKey:@"status"];
//                
//                //                self.defenceStatusData = [status objectAtIndex:self.dwCurGroup];
//                
//#pragma mark - 进行数据请求  开关状态为0的显示在cell上
//                self.statusData = [NSMutableArray arrayWithArray:status];
//                NSLog(@"===%d===",self.statusData.count);
//                NSNumber *intNumber = [NSNumber numberWithInteger:0];
//                _dataArray = [NSMutableArray array];
//                _dataArray1 = [NSMutableArray array];
//                _dataArraycount = [NSMutableArray array];
//                for (int i = 0; i < self.statusData.count; i++) {
//#pragma mark - 传感器
//                    if (i != 0) {
//                        for (NSNumber * b in self.statusData[i]) {
//                            if ([b isEqualToNumber:intNumber]) {
//                                [_dataArray1 addObject:b];
//                            }
//                        }
//                    }
//#pragma mark - 遥控器
//                    else if (i==0){
//                        for (NSNumber *a  in self.statusData[0]) {
//                            if ([a isEqualToNumber:intNumber]) {
//                                [_dataArray addObject:a ];
//                            }
//                        }
//                        
//                    }
//                }
//                [_dataArraycount addObject:_dataArray];
//                [_dataArraycount addObject:_dataArray1];
//                
//                NSLog(@"%d==%d==",self.dataArray.count,self.dataArray1.count);
//                
//                if (_dataArray.count > 0 || _dataArray1.count > 0) {
//#pragma mark - 显示已经学习的tableview
//                    oneTableView = [[UITableView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width +10, 40, [UIScreen mainScreen].bounds.size.width-20, [UIScreen mainScreen].bounds.size.height/2-40) style:UITableViewStylePlain];
//                    //    tableView.backgroundColor = XBlack;
//                    oneTableView.backgroundColor = [UIColor redColor];
//                    
//                    oneTableView.delegate = self;
//                    oneTableView.dataSource = self;
//                    oneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;  //隐藏空白的cell
//                    [self.mainScrollView addSubview:oneTableView];
//                    
//                }
//                
//                self.isLoadDefenceArea = NO;
//                _isGetDefenceStatusData = YES;
//                if (!self.isSetting) {
//                    [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
//                }
//                else
//                {
//                    [self addviewcontroller];
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        self.isSetting = NO;
//                        
//                        [self.view makeToast:NSLocalizedString(@"modify_success", nil)];
//                        [self.progressAlert hide:YES];
//#pragma mark - 学习对码成功以后
//                        [oneTableView reloadData];
//                    });
//                }
//            }
//        }
//            
//            break;
//        case RET_SET_DEFENCE_AREA_STATE:
//        {
//            NSLog(@"进入case RET_SET_DEFENCE_AREA_STATE");
//            NSInteger result = [[parameter valueForKey:@"result"] intValue];
//            
//            if(result==MESG_SET_OK){
//                self.isSetting = YES;
//                [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
//                
//            }else if(result==32){
//                int group = [[parameter valueForKey:@"group"] intValue];
//                int item = [[parameter valueForKey:@"item"] intValue];
//                
//                DLog(@"%i %i->already learned!",group,item);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.progressAlert hide:YES];
//                    self.isLoadDefenceArea = NO;
//                    //                    [oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.lastSetItem inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
//                    //[oneTableView reloadData];
//                    
//                    //                    已经学习的 再去学习会显示 group：通道i已被学习
//                    NSString *promptString = [NSString stringWithFormat:@"%@:%@ %i %@",[Utils defaultDefenceName:group],NSLocalizedString(@"defence_item",nil),item+1,NSLocalizedString(@"already_learn",nil)];
//                    [self.view makeToast:promptString];
//                });
//            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.progressAlert hide:YES];
//                    [oneTableView reloadData];
//                    [self.view makeToast:NSLocalizedString(@"modify_failure", nil)];
//                });
//            }
//        }
//            break;
            
            
    }
}
- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    //    NSLog(@"进来了方法:ack_receiveRemoteMessage");
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    NSLog(@"ack_receiveRemoteMessage key=0x%x, result=%d", key, result);
    
    switch (key)
    {

        case ACK_RET_SET_GPIO_CTL:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                }else if(result==2){
                    DLog(@"resend do device update");
                    NSString *contactId = [[P2PClient sharedClient] callId];
                    NSString *contactPassword = [[P2PClient sharedClient] callPassword];
                    
                    [[P2PClient sharedClient] setGpioCtrlWithId:contactId password:contactPassword group:self.lastGroup pin:self.lastPin value:self.lastValue time:self.lastTime];
                }
            });
        }
            break;
            
//        case ACK_RET_GET_DEFENCE_AREA_STATE:
//        {
//            NSLog(@"进入了：case ACK_RET_GET_DEFENCE_AREA_STATE");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(result==1){
//                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        usleep(800000);
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            //                            [self onBackPress];
//                        });
//                    });
//                }else if(result==2){
//                    DLog(@"resend get defence area state");
//                    [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
//                }
//            });
//            
//            DLog(@"ACK_RET_GET_DEFENCE_AREA_STATE:%i",result);
//        }
//            break;
//        case ACK_RET_SET_DEFENCE_AREA_STATE:
//        {
//            NSLog(@"进入了：case ACK_RET_SET_DEFENCE_AREA_STATE");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(result==1){
//                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        usleep(800000);
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            //                            [self onBackPress];
//                        });
//                    });
//                }
//                else if(result==2){
//                    DLog(@"resend set defence area state");
//                    
//                    [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.lastGroup item:self.dwCurItem type:self.dwlastOperation];
//                }
//            });
//            DLog(@"ACK_RET_SET_DEFENCE_AREA_STATE:%i",result);
//        }
//            break;
//        case ACK_RET_GET_DEFENCE_SWITCH_STATE:{
//            NSLog(@"进入了：case ACK_RET_GET_DEFENCE_SWITCH_STATE");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(result==1){
//                    [self.progressAlert hide:YES];
//                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
//                    
//                }else if(result==2){
//                    DLog(@"resend do device update");
//                    [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                            usleep(2000000);
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [self.view makeToast:NSLocalizedString(@"id_timeout",nil)];
//                                //                                            [self onBackPress];
//                            });
//                        });
//                    });
//                }
//            });
//            DLog(@"ACK_RET_GET_DEVICE_INFO:%i",result);
//        }
//            break;
//        case ACK_RET_SET_DEFENCE_SWITCH_STATE:{
//            NSLog(@"进入了：case ACK_RET_SET_DEFENCE_SWITCH_STATE");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(result==1){
//                    [self.progressAlert hide:YES];
//                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
//                    
//                }else if(result==2){
//                    DLog(@"resend do device update");
//                    //                    [[P2PClient sharedClient] setDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword switchId:self.dwlastOperation alarmCodeId:(self.dwCurGroup-1) alarmCodeIndex:self.dwCurItem];
//                }
//            });
//            
//            DLog(@"ACK_RET_GET_DEVICE_INFO:%i",result);
//        }
//            break;
            
        default:
            break;
    }
}
- (void)startConnect{
    [self.connectingTipView setHidden:NO];
    [self.connectingTipView start];
    //[self.connectingTipLable setHidden:NO];
}
- (void)monitorStartMessage:(NSNotification*)notification{
    [self.connectingTipView setHidden:YES];
    [self.connectingTipView stop];
    
    if (!self.isInitRender) {
        self.isInitRender = YES;
        BOOL is16B9 = [[P2PClient sharedClient] is16B9];
        //如果不符合条件，则不显示"高清"选项
        if (!is16B9) {
            CGFloat width = _rectResoutionShow.size.width;
            CGFloat height = _rectResoutionShow.size.height;
            CGRect rect = CGRectMake(_rectResoutionShow.origin.x, _rectResoutionShow.origin.y+height/3, width, height*2/3);
            _rectResoutionShow = rect;
        }
        
        CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        //    int itemCount = 2;
        //    if (is16B9) {
        //        itemCount = 3;
        //    }
        
        //初始化画布
        OpenGLView *glView = [[OpenGLView alloc] init];
        glView.frame = [self getRenderViewFrame];
        
        [glView setCaptureFinishScreen:YES];
        //    glView.width = (NSInteger)glView.frame.size.width;
        //    glView.height = (NSInteger)glView.frame.size.height;
        self.remoteView = glView;
        self.remoteView.delegate = self;
        [self.remoteView.layer setMasksToBounds:YES];
        [self.canvasView addSubview:self.remoteView];
        [glView release];
        
        //显示网速
        UILabel *viewerCountLable1 = [[UILabel alloc] initWithFrame:CGRectMake(width-NUMBER_VIEW_LABEL_WIDTH-100, -5, NUMBER_VIEW_LABEL_WIDTH, NUMBER_VIEW_LABEL_HEIGHT)];
        viewerCountLable1.backgroundColor = [UIColor clearColor];
        viewerCountLable1.textAlignment = NSTextAlignmentCenter;
        viewerCountLable1.textColor = XWhite;
        viewerCountLable1.font = XFontBold_14;
        [self.remoteView addSubview:viewerCountLable1];
        self.viewerCountLable1 = viewerCountLable1;
        self.viewerCountFrame1 = viewerCountLable1.frame;
        [viewerCountLable1 release];
        
        //显示当前观看人数
        UILabel *viewerCountLable = [[UILabel alloc] initWithFrame:CGRectMake(width-NUMBER_VIEW_LABEL_WIDTH, -5, NUMBER_VIEW_LABEL_WIDTH, NUMBER_VIEW_LABEL_HEIGHT)];
        viewerCountLable.backgroundColor = [UIColor clearColor];
        viewerCountLable.textAlignment = NSTextAlignmentRight;
        viewerCountLable.textColor = XWhite;
        viewerCountLable.font = XFontBold_14;
        [self.remoteView addSubview:viewerCountLable];
        self.viewerCountLable = viewerCountLable;
        self.viewerCountFrame = viewerCountLable.frame;
        [viewerCountLable release];
        
#pragma  mark - 预置位
        if (self.isyuzhiwei) {
            UILabel *homeLabel = [self createHomeButtonView];
            homeLabel = [self createHomeButtonView];
            
            DWBubbleMenuButton *upMenuView = [[DWBubbleMenuButton alloc] initWithFrame:CGRectMake(height - 43.f, width - YUZHIWEI_WIDTH_HEIGHT, 40.f, 40.f) expansionDirection:DirectionUp];
            upMenuView.homeButtonView = homeLabel;
            [upMenuView addButtons:[self createDemoButtonArray]];
            [self.remoteView addSubview:upMenuView];
            [upMenuView release];
        }
        
#pragma mark - 手势
        UITapGestureRecognizer *doubleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap)];
        doubleTapG.delegate = self;
        [doubleTapG setNumberOfTapsRequired:2];
        [self.remoteView addGestureRecognizer:doubleTapG];
        
        UITapGestureRecognizer *singleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
        singleTapG.delegate = self;
        [singleTapG setNumberOfTapsRequired:1];
        [singleTapG requireGestureRecognizerToFail:doubleTapG];
        [self.remoteView addGestureRecognizer:singleTapG];
        
        //缩放
        UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(onPinch:)];
        [self.remoteView addGestureRecognizer:pinchGR];
        
        UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
        [swipeGestureUp setDirection:UISwipeGestureRecognizerDirectionUp];
        [swipeGestureUp setCancelsTouchesInView:YES];
        [swipeGestureUp setDelaysTouchesEnded:YES];
        [_remoteView addGestureRecognizer:swipeGestureUp];
        
        UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
        [swipeGestureDown setDirection:UISwipeGestureRecognizerDirectionDown];
        
        [swipeGestureDown setCancelsTouchesInView:YES];
        [swipeGestureDown setDelaysTouchesEnded:YES];
        [_remoteView addGestureRecognizer:swipeGestureDown];
        
        UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
        [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [swipeGestureLeft setCancelsTouchesInView:YES];
        [swipeGestureLeft setDelaysTouchesEnded:YES];
        [_remoteView addGestureRecognizer:swipeGestureLeft];
        
        UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
        [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [swipeGestureRight setCancelsTouchesInView:YES];
        [swipeGestureRight setDelaysTouchesEnded:YES];
        [_remoteView addGestureRecognizer:swipeGestureRight];
        
        [doubleTapG release];
        [singleTapG release];
        [pinchGR release];
        [swipeGestureUp release];
        [swipeGestureDown release];
        [swipeGestureLeft release];
        [swipeGestureRight release];
    }
    
    //开始渲染
    self.isReject = NO;
    [NSThread detachNewThreadSelector:@selector(renderView) toTarget:self withObject:nil];
    
    [self doOperationsAfterMonitorStartRender];
}

#pragma mark - 监控开始渲染后，此处执行相关操作
-(void)doOperationsAfterMonitorStartRender{
    
    /*
     *1. 应该放在监控准备就绪之后（即渲染之后）
     */
    [[PAIOUnit sharedUnit] setMuteAudio:NO];
    [[PAIOUnit sharedUnit] setSpeckState:YES];
    if([AppDelegate sharedDefault].isDoorBellAlarm){//门铃推送,点按开关说话
        self.isTalking = YES;
        [self.talkingTipView setHidden:NO];//对讲提示视图
        [[PAIOUnit sharedUnit] setSpeckState:NO];
    }
}

#pragma mark - 显示当前多少人在看
- (void)receivePlayingCommand:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int value  = [[parameter valueForKey:@"value"] intValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //        显示当前多少人在看
        self.viewerCountLable.text = [NSString stringWithFormat:@"%@ %i",NSLocalizedString(@"number_viewer", nil),value];
    
    });
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.isShowToolbarFull = YES;
    //    self.isPinchGR = NO;
    self.isNoSound = NO;
    self.isSettingSensor = NO;
    self.isSettingRemote = NO;
    _array = [[NSMutableArray alloc] init];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[PAIOUnit sharedUnit] setMuteAudio:NO];
    [[PAIOUnit sharedUnit] setSpeckState:YES];
    
    //获取防区设置信息
    [[P2PClient sharedClient]getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
    
    [self initComponent];
    [self initFullControllerbar];
}

#pragma mark - 初始化
-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    CGFloat height = rect.size.height;
    if(CURRENT_VERSION<7.0){
        height +=20;
    }
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    topBar.backButton.tag = CONTROLLER_BTN_TAG_HUNGUP;
    [topBar.backButton addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"smart_cameras",nil)];
    [self.view addSubview:topBar];
    self.topbar = topBar;
    [topBar release];
    
    [self.view setBackgroundColor:XBlack];
    
    UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBar.frame), width, REMOTEVIEW_HEIGHT)];
    canvasView.backgroundColor = XBlack;
    [self.view addSubview:canvasView];
    self.canvasView = canvasView;
    self.canvasframe = canvasView.frame;
    [canvasView release];
    
    YProgressView *progressView = [[YProgressView alloc] initWithFrame:CGRectMake((width-LOADINGPRESSVIEW_WIDTH_HEIGHT)/2, (self.canvasView.frame.size.height-LOADINGPRESSVIEW_WIDTH_HEIGHT)/2, LOADINGPRESSVIEW_WIDTH_HEIGHT, LOADINGPRESSVIEW_WIDTH_HEIGHT)];
    progressView.backgroundView.image = [UIImage imageNamed:@"monitor_press.png"];
    self.connectingTipViewframe = progressView.frame;
    self.connectingTipView = progressView;
    [progressView release];
    [self.canvasView addSubview:self.connectingTipView];
#pragma mark - 全屏播放按钮
    UIButton* fullbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fullbtn.frame = CGRectMake(width-35, CGRectGetMaxY(self.canvasView.frame)-30, 30, 30);
    [fullbtn setBackgroundImage:[UIImage imageNamed:@"Max_play2.png"] forState:UIControlStateNormal];
    [fullbtn setBackgroundColor:[UIColor clearColor]];
    fullbtn.tag = CONTROLLER_BTN_TAG_FULLSCREEN;
    [fullbtn addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fullbtn];
    
    
#pragma mark - 创建一个主scrollView
    UIScrollView *mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, height/2 + 20, width, height/2 - 20)];
//    mainScrollView.contentSize = CGSizeMake(width*2, 0);
        mainScrollView.contentSize = CGSizeMake(width, 0);
    mainScrollView.backgroundColor = XBlack;
    mainScrollView.pagingEnabled = NO;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.delegate = self;
    mainScrollView.bounces = NO;
    mainScrollView.tag = CONTROLLER_MAIN_TAG;
    self.mainScrollView = mainScrollView;
    [self.view addSubview:mainScrollView];
    [mainScrollView release];
    
    //创建第一个View容器
    UIView *firstViewController = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, mainScrollView.frame.size.height - self.screenshotView.frame.size.height)];
    [mainScrollView addSubview:firstViewController];
    [firstViewController release];
    
    UIScrollView * screenshotview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, SCREENSHOTVIEW_HIGHT)];
    //    screenshotview.showsVerticalScrollIndicator = NO;
    screenshotview.contentSize = CGSizeMake(width, 0);
    screenshotview.bounces = NO;
    [firstViewController addSubview:screenshotview];
    self.screenshotView = screenshotview;
    [screenshotview release];
    [self reloadScreenshotView];
    
    
    UIScrollView * fullShotimgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    fullShotimgScrollView.showsHorizontalScrollIndicator = NO;
    fullShotimgScrollView.showsVerticalScrollIndicator = NO;
    fullShotimgScrollView.hidden = YES;
    fullShotimgScrollView.pagingEnabled = YES;
    fullShotimgScrollView.bounces = NO;
    fullShotimgScrollView.delegate = self;
    [self.view addSubview:fullShotimgScrollView];
    self.fullShotimgScrollView = fullShotimgScrollView;
    [fullShotimgScrollView release];
    
    UILabel * shottopLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, PAGECONTROL_WIDTH, width, PAGECONTROL_WIDTH)];
    shottopLabel.textAlignment= NSTextAlignmentCenter;
    shottopLabel.textColor = XWhite;
    [self.view addSubview:shottopLabel];
    self.shottopLabel = shottopLabel;
    self.shottopLabel.hidden = YES;
    [shottopLabel release];
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake((width-PAGECONTROL_WIDTH)/2, height-PAGECONTROL_HEIGHT-10, PAGECONTROL_WIDTH, PAGECONTROL_HEIGHT);
    pageControl.backgroundColor = [UIColor blackColor];
    pageControl.numberOfPages = 2;//页数
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:16.0/255.0 green:113.0/255.0 blue:112.0/255.0 alpha:1.0f];
    //关联方法
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    _pageControl = pageControl;
//    [self.view addSubview:pageControl];
    [pageControl release];
    
    UIView * controllerview1 = [[UIView alloc] initWithFrame:CGRectMake(0, screenshotview.frame.size.height, width, mainScrollView.frame.size.height - screenshotview.frame.size.height)];
    controllerview1.backgroundColor = XBlack;
    int barheight = controllerview1.frame.size.height;
    
#pragma mark - 半屏播放监控视频的工具条
    NSArray * imgarr = @[@"monitor_l_voice.png",@"monitor_l_talk_normal.png",@"monitor_l_screemshot.png"];
    NSArray * imgselectarr = @[@"monitor_voice_d.png",@"monitor_talk_d.png",@"monitor_shot.png"];
    for (NSInteger i = 0; i < 3; i++)
    {
        TouchButton *button = [self getControllerButton];
        button.frame = CGRectMake((width/6)*(2*i+1)-CONTROLLER_BUTTON_WIDTH/2,barheight/2-CONTROLLER_BUTTON_WIDTH/2 , CONTROLLER_BUTTON_WIDTH, CONTROLLER_BUTTON_WIDTH);
        button.clipsToBounds = YES;
        
        if (i==1)//对讲
        {
            _flag = YES;     //单次点击可直接对讲
            _flag = !_flag;  //单次点击可直接对讲
            button.frame = CGRectMake((width/6)*(2*i+1)-CONTROLLER_BUTTON_WIDTH_BIG/2,barheight/2-CONTROLLER_BUTTON_WIDTH_BIG/2 , CONTROLLER_BUTTON_WIDTH_BIG, CONTROLLER_BUTTON_WIDTH_BIG);
            button.delegate = self;
            button.tag = CONTROLLER_BTN_TAG_PRESS_TALK;
            if (_flag)//单次点击可直接对讲
            {
                button.selected = YES;
            }
            else//单次点击可直接对讲
            {
                button.selected = NO;
            }
        }
        else if (i==0)//声音
        {
            button.tag = CONTROLLER_BTN_TAG_SOUND;
            _btnVoiceMenu = button;
            BOOL isMute = [[PAIOUnit sharedUnit] muteAudio];
            if (isMute)
            {
                button.selected = YES;
            }
            else
            {
                button.selected = NO;
            }
        }
        else if (i==2)
        {
            button.tag = CONTROLLER_BTN_TAG_SCREENSHOT;//截图按钮(半屏)
        }
        button.layer.cornerRadius = button.frame.size.width/2;
        button.clipsToBounds = YES;
        
        [button setImage:[UIImage imageNamed:imgarr[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:imgselectarr[i]] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        [controllerview1 addSubview:button];
        //[button release];
#pragma mark - 按了门铃进入的，开启对讲
        if (i == 1 && [AppDelegate sharedDefault].isDoorBellAlarm)
        {
            /*
             button.selected = YES;
             //            self.talkingTipView.hidden = YES;
             [[PAIOUnit sharedUnit] setSpeckState:NO];
             NSLog(@"into doorBell alarm view😭~ ~");
             */
            button.selected = YES;
            //支持门铃,点按开关说话
            [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [firstViewController addSubview:controllerview1];
    [controllerview1 release];
#pragma mark - 传感器配对
    UIButton *sensorMate = [UIButton buttonWithType:UIButtonTypeCustom];
    sensorMate.tag = CONTROLLER_BTN_TAG_SENSOR;
    sensorMate.frame = CGRectMake(width + 10, 0, width/2 - 10, 34);
    [sensorMate setTitle:NSLocalizedString(@"sensor_mate", nil) forState:UIControlStateNormal];
    sensorMate.backgroundColor = [UIColor grayColor];
    [sensorMate addTarget:self action:@selector(clickedSensorMateBtn) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:sensorMate];
#pragma mark - 遥控器配对
    UIButton *remoteMate = [UIButton buttonWithType:UIButtonTypeCustom];
    remoteMate.tag = CONTROLLER_BTN_TAG_REMOTE;
    remoteMate.frame = CGRectMake(width*2 - width/2 + 10, 0, width/2 - 20, 34);
    [remoteMate setTitle:NSLocalizedString(@"remote_mate", nil) forState:UIControlStateNormal];
    remoteMate.backgroundColor = [UIColor grayColor];
    [remoteMate addTarget:self action:@selector(clickedRemoteMateBtn) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:remoteMate];
    
    
    
    
    
#pragma mark - 按压对讲按钮时，显示的试图
    UIView *pressView = [[UIView alloc] initWithFrame:CGRectMake(10, height-10-PRESS_LAYOUT_WIDTH_AND_HEIGHT, PRESS_LAYOUT_WIDTH_AND_HEIGHT/2, PRESS_LAYOUT_WIDTH_AND_HEIGHT)];
    
    UIImageView *pressLeftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PRESS_LAYOUT_WIDTH_AND_HEIGHT/2, PRESS_LAYOUT_WIDTH_AND_HEIGHT)];
    pressLeftView.image = [UIImage imageNamed:@"ic_voice.png"];
    [pressView addSubview:pressLeftView];
    
    UIImageView *pressRightView = [[UIImageView alloc] initWithFrame:CGRectMake(PRESS_LAYOUT_WIDTH_AND_HEIGHT/2, 0, PRESS_LAYOUT_WIDTH_AND_HEIGHT/2, PRESS_LAYOUT_WIDTH_AND_HEIGHT)];
    NSArray *imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"amp1.png"],[UIImage imageNamed:@"amp2.png"],[UIImage imageNamed:@"amp3.png"],[UIImage imageNamed:@"amp4.png"],[UIImage imageNamed:@"amp5.png"],[UIImage imageNamed:@"amp6.png"],[UIImage imageNamed:@"amp7.png"],[UIImage imageNamed:@"amp4.png"],[UIImage imageNamed:@"amp5.png"],[UIImage imageNamed:@"amp6.png"],[UIImage imageNamed:@"amp3.png"],[UIImage imageNamed:@"amp5.png"],[UIImage imageNamed:@"amp6.png"],[UIImage imageNamed:@"amp6.png"],[UIImage imageNamed:@"amp3.png"],[UIImage imageNamed:@"amp4.png"],[UIImage imageNamed:@"amp5.png"],[UIImage imageNamed:@"amp5.png"],nil];
    
    pressRightView.animationImages = imagesArray;
    pressRightView.animationDuration = ((CGFloat)[imagesArray count])*200.0f/1000.0f;
    pressRightView.animationRepeatCount = 0;
    [pressRightView startAnimating];
    
    [pressView addSubview:pressRightView];
    [self.view addSubview:pressView];
    [pressView setHidden:YES];
    self.talkingTipView = pressView;
    self.talkingTipframe = self.talkingTipView.frame;
    
    [pressView release];
    [pressLeftView release];
    [pressRightView release];
}

- (void)changePage:(UIPageControl *)pageControl
{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    if (pageControl.currentPage == 0) {
        [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (pageControl.currentPage == 1) {
        [self.mainScrollView setContentOffset:CGPointMake(rect.size.width, 0) animated:YES];
    }
    NSLog(@"changePage to page2");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==self.mainScrollView) {
        CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
        if (scrollView.tag == CONTROLLER_MAIN_TAG) {
            _pageControl.currentPage = scrollView.contentOffset.x /rect.size.width;
        }
    }else if (scrollView == self.fullShotimgScrollView){
        CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
        CGFloat width = rect.size.width;
        int offset = scrollView.contentOffset.x/width;
        self.nowShowfullScrollView = self.fullShotimgScrollView.subviews[offset];
        //LoginResult *loginResult = [UDManager getLoginInfo];
        NSArray *datas = [NSArray arrayWithArray:[Utils getScreenShotFilesWithContactId:self.contact.contactId]];
        self.shottopLabel.text = [NSString stringWithFormat:@"%d/%d",offset+1,datas.count];
        //self.shottopLabel.text = [NSString stringWithFormat:@"%d/%d",offset+1,datas.count];
        CGFloat x = scrollView.contentOffset.x;
        if(x==-333){
        }
        else{
            //            offset = x;
            for(UIScrollView *s in scrollView.subviews){
                if([s isKindOfClass:[UIScrollView class]]){
                    [s setZoomScale:1.0]; //scrollView每滑动一次将要出现的图片较正常时候图片的倍数（将要出现的图片显示的倍数）
                }
            }
        }
    }
}
- (void)renderView{
    self.isRender = YES;
    GAVFrame * m_pAVFrame ;
    while (!self.isReject)
    {
        //        得到视频帧并显示
        if(fgGetVideoFrameToDisplay(&m_pAVFrame))
        {
            [self.remoteView render:m_pAVFrame];
            vReleaseVideoFrame();
        }
        usleep(10000);
    }
}

#pragma mark 刷新缩略图
- (void)reloadScreenshotView{
    
    for (UIView * view in self.screenshotView.subviews) {
        [view removeFromSuperview];
    }
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    int imagewidth = width/4;
    NSArray *datas = [NSArray arrayWithArray:[Utils getScreenShotFilesWithContactId:self.contact.contactId]];
    
    self.screenshotView.contentSize = CGSizeMake(imagewidth*MAX([datas count], 4), 0);
    for (int i= 0; i<MAX([datas count], 4); i++)
    {
        UIImageView * imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imagewidth*i, 0, imagewidth-1, self.screenshotView.frame.size.height)];
        imageview.userInteractionEnabled = YES;
        
        if (i<[datas count]) {
            //有图片
            NSString *name = [datas objectAtIndex:i];
            NSString *filePath = [Utils getScreenshotFilePathWithName:name contactId:self.contact.contactId];
            imageview.image = [UIImage imageWithContentsOfFile:filePath];
            UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ShowfullShotimg:)];
            [imageview addGestureRecognizer:gesture];
            [gesture release];
            
            [self.screenshotView addSubview:imageview];
            [imageview release];
        }
        else
        {
            UILabel *screenshotLab = [[UILabel alloc] initWithFrame:CGRectMake(imagewidth*i, 0, width, self.screenshotView.frame.size.height)];
            [self.screenshotView addSubview:screenshotLab];
            [screenshotLab release];
            //没有图片
            if (i==0) {
                screenshotLab.text = NSLocalizedString(@"screenshot_list_empty",nil);
                screenshotLab.textAlignment = NSTextAlignmentCenter;
                screenshotLab.font = [UIFont systemFontOfSize:16];
                screenshotLab.textColor = [UIColor whiteColor];
                imageview.image = [UIImage imageNamed:@""];
                [self.screenshotView addSubview:imageview];
                [imageview release];
            }
        }
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 全屏播放时的工具条
-(void)initFullControllerbar{
    CGRect rect = [AppDelegate getScreenSize:NO isHorizontal:YES];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    int btnCount;
    
    if ([AppDelegate sharedDefault].isDoorBellAlarm) {
        btnCount = CONTROLLER_BTN_COUNT;
    }
    else{
        btnCount = CONTROLLER_BTN_COUNT - 1;
    }
    //工具条
    CGFloat edgeX = width/5;
    CGFloat edgeY = 30;
    CGFloat edgeBar = 10;
    CGFloat itemWidth = (width-2*edgeX-2*edgeBar)/btnCount;
    CGFloat itemHeight = itemWidth - 5;
    CGFloat yPos = height - itemHeight - edgeY + 30;
    
    
    UIView * toolbarFull = [[UIView alloc] initWithFrame:CGRectMake(edgeX, yPos, width-edgeX*2, itemHeight)];
    toolbarFull.backgroundColor = [UIColor blackColor];
    //toolbarFull.layer.cornerRadius = 15.0f;
    toolbarFull.layer.masksToBounds = YES;
    //白色边框
    toolbarFull.layer.borderColor = [[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] CGColor];
    toolbarFull.layer.borderWidth = 0;//改了
    toolbarFull.alpha = 0.5;
    toolbarFull.hidden = YES;
    [self.view addSubview:toolbarFull];
    self.toolbarFull = toolbarFull;
    [toolbarFull release];
    
    for (NSInteger i = 0; i < btnCount; i++)
    {
        CGFloat xPosBtn = edgeBar+i*itemWidth;
        CGRect btnRect = CGRectMake(xPosBtn+itemWidth/7, itemHeight/7, itemWidth*2/3, itemHeight*2/3);;
        
        TouchButton * buttonTouch = nil;
        UIButton* button = nil;
        if (i == 2) {
            buttonTouch = [self getControllerButtonFull];
            buttonTouch.frame = btnRect;
        }
        else
        {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = btnRect;
        }
        
        switch (i)
        {
            case 0: //分辨率
            {
                [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = CONTROLLER_BTN_TAG_RESOLUTION;
                button.titleLabel.font = XFontBold_16;
                [button setTitle:NSLocalizedString(@"SD", nil) forState:UIControlStateNormal];
                self.resolutionbtnFull = button;
            }
                break;
            case 1: //声音
            {
                [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = CONTROLLER_BTN_TAG_SOUND;
                _btnVoiceFull = button;
                BOOL isMute = [[PAIOUnit sharedUnit] muteAudio];
                if (isMute) {
                    button.selected = YES;
                }else{
                    button.selected = NO;
                }
                [button setImage:[UIImage imageNamed:@"monitor_voice_full2.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"monitor_voice_full_d2.png"] forState:UIControlStateSelected];
                
                
            }
                break;
            case 2: //对讲
            {
                buttonTouch.delegate = self;
                buttonTouch.tag = CONTROLLER_BTN_TAG_PRESS_TALK;
                
                [buttonTouch setImage:[UIImage imageNamed:@"monitor_talk_full2.png"] forState:UIControlStateNormal];
                [buttonTouch setImage:[UIImage imageNamed:@"monitor_talk_full_d.png"] forState:UIControlStateSelected];
            }
                break;
            case 3: //截图按钮(全屏)
            {
                [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = CONTROLLER_BTN_TAG_SCREENSHOT;
                [button setImage:[UIImage imageNamed:@"monitor_shot_full2.png"] forState:UIControlStateNormal];
            }
                break;
            case 4:
            {
                //录像
                [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = CONTROLLER_BTN_TAG_RECORD;
                [button setImage:[UIImage imageNamed:@"monitor_record_full.png"] forState:UIControlStateNormal];
                
                UIImageView *pressRightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
                NSArray *imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"monitor_record_full_d1.png"],[UIImage imageNamed:@"monitor_record_full_d2.png"],nil];
                pressRightView.animationImages = imagesArray;
                pressRightView.animationDuration = ((CGFloat)[imagesArray count])*200.0f/1000.0f;
                pressRightView.animationRepeatCount = 0;
                [pressRightView startAnimating];
                pressRightView.hidden = YES;
                [button addSubview:pressRightView];
                self.recordbtnFull = button;
                
            }
                break;
            case 5://竖屏
            {
                [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                [button setBackgroundImage:[UIImage imageNamed:@"Min_play2.png"] forState:UIControlStateNormal];
                button.tag = CONTROLLER_BTN_TAG_FULLSCREEN;
                
                
            }
                break;
            case 6://开锁
            {
                [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = CONTROLLER_BTN_TAG_GPIO1_0;
                [button setImage:[UIImage imageNamed:@"long_press_lock.png"] forState:UIControlStateNormal];
                
            }
                break;
            case 7:
            {
                /*
                 //布防
                 [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                 button.tag = CONTROLLER_BTN_TAG_DEFENCE;
                 [button setImage:[UIImage imageNamed:@"monitor_defence_full.png"] forState:UIControlStateNormal];
                 [button setImage:[UIImage imageNamed:@"monitor_defence_full_d.png"] forState:UIControlStateSelected];
                 if (self.contact.defenceState == DEFENCE_STATE_ON)
                 {
                 button.selected = NO;
                 }
                 else
                 {
                 button.selected = YES;
                 }
                 */
            }
                break;
            default:
                break;
        }
        if (button != nil) {
            [self.toolbarFull addSubview:button];
        }
        else
        {
            [self.toolbarFull addSubview:buttonTouch];
        }
    }
    
    //分辨率
    yPos = height-edgeY-itemHeight-itemHeight*2;
    CGFloat xPos = edgeBar+edgeX;
    itemHeight = itemHeight*2/3;
    _rectResoutionShow = CGRectMake(xPos, yPos + 30, itemWidth, itemHeight*3);   //保存rect，方便之后弹出来
    _rectResoutionHide = CGRectMake(xPos, yPos+itemHeight*3 + 30, itemWidth, 0);   //保存rect，方便之后缩回去
    UIView *resolutionView = [[UIView alloc] initWithFrame:_rectResoutionHide];//分辨率
    resolutionView.layer.cornerRadius = 5.0f;
    resolutionView.layer.masksToBounds = YES;
    resolutionView.layer.borderColor = [[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] CGColor];
    resolutionView.layer.borderWidth = 1;
    resolutionView.alpha = 0.5;
    self.resolutionViewFull = resolutionView;
    [self.view addSubview:resolutionView];
    [resolutionView release];
    
    //分辨率选项
    for(int i=0;i<3;i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, itemHeight*i, itemWidth, itemHeight);
        [button.titleLabel setFont:XFontBold_12];
        if(i==0){
            [button setTitle:NSLocalizedString(@"LD", nil) forState:UIControlStateNormal];
            button.backgroundColor = [UIColor blackColor];
            button.tag = CONTROLLER_BTN_TAG_LD;
        }else if(i==1){
            [button setTitle:NSLocalizedString(@"SD", nil) forState:UIControlStateNormal];
            [button setBackgroundColor:XBlue];
            button.tag = CONTROLLER_BTN_TAG_SD;
        }else if(i==2){
            [button setTitle:NSLocalizedString(@"HD", nil) forState:UIControlStateNormal];
            button.backgroundColor = [UIColor blackColor];
            button.tag = CONTROLLER_BTN_TAG_HD;
        }
        [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.resolutionViewFull addSubview:button];
    }
}

#pragma mark - 点击图片按钮，进入图片模式
-(void)ShowfullShotimg:(UIGestureRecognizer *)sender{
    for (UIView * view in self.fullShotimgScrollView.subviews)
    {
        [view removeFromSuperview];
    }
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    UIImageView * imageview = (UIImageView *)sender.view;
    int imagewidth = width/4;
    int offset = imageview.frame.origin.x/imagewidth;
    self.fullShotimgScrollView.contentOffset = CGPointMake(width*offset, 0);
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSArray *datas = [NSArray arrayWithArray:[Utils getScreenShotFilesWithContactId:self.contact.contactId]];
    if (datas.count!=0&&(offset<datas.count)) {
        for (UIView * view in self.view.subviews) {
            view.hidden = YES;
        }
    }
    for (NSInteger i = 0; i<datas.count; i++) {
        NSString *name = [datas objectAtIndex:i];
        NSString *filePath = [Utils getScreenshotFilePathWithName:name contactId:self.contact.contactId];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        
        UIScrollView * imgscrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(width*i, 0, width, height)];
        imgscrollView.showsVerticalScrollIndicator = NO;
        imgscrollView.contentSize = CGSizeMake(width, height);
        imgscrollView.bounces = NO;
        imgscrollView.delegate = self;
        imgscrollView.minimumZoomScale=1.0;
        imgscrollView.maximumZoomScale=3.0;
        [imgscrollView setZoomScale:1.0];
        if (i==offset) {
            self.nowShowfullScrollView = imgscrollView;
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (imgscrollView.frame.size.height-imgscrollView.frame.size.width)/2, imgscrollView.frame.size.width, imgscrollView.frame.size.width*3/4)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        imageView.image = image;
        imgscrollView.backgroundColor = XBlack;
        [imgscrollView addSubview:imageView];
        
        UITapGestureRecognizer*doubleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        UIPinchGestureRecognizer * pinchG = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [imageView addGestureRecognizer:doubleTap];
        [imageView addGestureRecognizer:pinchG];
        [pinchG release];//release
        
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidefullShotimg)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [imageView addGestureRecognizer:singleTap];
        imageView.userInteractionEnabled = YES;
        [imageView release];//release
        [doubleTap release];//release
        [singleTap release];//release
        
        [self.fullShotimgScrollView addSubview:imgscrollView];
        [imgscrollView release];//release
    }
    if (datas.count!=0&&(offset<datas.count)) {
        self.fullShotimgScrollView.contentSize = CGSizeMake(width*datas.count, 0);
        self.shottopLabel.text = [NSString stringWithFormat:@"%d/%d",offset+1,datas.count];
        self.shottopLabel.hidden = NO;
        //[self.view bringSubviewToFront:self.shottopLabel];
        self.fullShotimgScrollView.hidden = NO;
        //self.isShowDetail = YES;
        self.fullShotimgScrollView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        self.fullShotimgScrollView.alpha = 0.1;
        [UIView transitionWithView:self.fullShotimgScrollView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            self.fullShotimgScrollView.alpha = 1.0;
                            self.fullShotimgScrollView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                        }
                        completion:^(BOOL finished) {
                        }
         ];
    }
}

#pragma mark - 退出图片模式
-(void)hidefullShotimg{
    for (UIView * view in self.view.subviews) {
        view.hidden = NO;
    }
    self.toolbarFull.hidden = YES;
    self.talkingTipView.hidden = YES;
    self.shottopLabel.hidden = YES;
    [UIView transitionWithView:self.fullShotimgScrollView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.fullShotimgScrollView.alpha = 0.1;
                        self.fullShotimgScrollView.transform = CGAffineTransformMakeScale(0.3, 0.3);
                    }
                    completion:^(BOOL finished) {
                        self.fullShotimgScrollView.hidden = YES;
                    }
     ];
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (scrollView == self.nowShowfullScrollView) {
        for(UIView*v in scrollView.subviews){
            return v;
        }
    }else{
        return self.remoteView;
    }
    return nil;
}

-(void)handleDoubleTap:(UIGestureRecognizer*)gesture{
    float newScale = [(UIScrollView*)gesture.view.superview zoomScale] *1.5;//每次双击放大倍数
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [(UIScrollView*)gesture.view.superview zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height=self.view.frame.size.height/ scale;
    zoomRect.size.width=self.view.frame.size.width/ scale;
    zoomRect.origin.x= center.x- (zoomRect.size.width/2.0);
    zoomRect.origin.y= center.y- (zoomRect.size.height/2.0);
    return zoomRect;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (self.isfullScreen) {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
        self.remoteView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
    }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if(scale>1.0 && self.isShowToolbarFull)
    {
        self.isShowToolbarFull = !self.isShowToolbarFull;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView commitAnimations];
    }
}

-(void)onBegin:(TouchButton *)touchButton widthTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"onBegin");
    if (!self.isfullScreen)
    {
        if (touchButton.tag == CONTROLLER_BTN_TAG_PRESS_TALK)
        {
            [touchButton setBackgroundImage:[UIImage imageNamed:@"monitor_talk_d.png"] forState:UIControlStateNormal];
            [self.talkingTipView setHidden:NO];
        }
        [[PAIOUnit sharedUnit] setSpeckState:NO];
    }
    else
    {
        if (touchButton.tag == CONTROLLER_BTN_TAG_PRESS_TALK)//全屏时对讲
        {
            _flag = !_flag;
            if (_flag)
            {
                touchButton.selected = YES;
                [touchButton setBackgroundImage:[UIImage imageNamed:@"monitor_talk_full_d.png"] forState:UIControlStateSelected];
                [self.talkingTipView setHidden:NO];
                [[PAIOUnit sharedUnit] setSpeckState:NO];
            }
            else
            {
                touchButton.selected = NO;
                self.talkingTipView.hidden = YES;
                UIButton *touchButton = [[UIButton alloc]init];
                if (self.isfullScreen)
                {
                    [touchButton setBackgroundImage:[UIImage imageNamed:@"monitor_talk_full2.png"] forState:UIControlStateNormal];
                    [self.talkingTipView setHidden:YES];
                }
                [[PAIOUnit sharedUnit] setSpeckState:YES];
                [touchButton release];
            }
        }
    }
}

-(void)onCancelled:(TouchButton *)touchButton widthTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"onCancelled");
    if (self.isfullScreen) {
        if (touchButton.tag == CONTROLLER_BTN_TAG_PRESS_TALK) {
            [touchButton setBackgroundImage:[UIImage imageNamed:@"monitor_talk_full2.png"] forState:UIControlStateNormal];
            [self.talkingTipView setHidden:YES];
        }
    }else{
        if (touchButton.tag == CONTROLLER_BTN_TAG_PRESS_TALK) {
            [touchButton setBackgroundImage:[UIImage imageNamed:@"monitor_talk_d.png"] forState:UIControlStateNormal];
            [self.talkingTipView setHidden:YES];
        }
    }
    [[PAIOUnit sharedUnit] setSpeckState:YES];
}

//-(void)onEnded:(TouchButton *)touchButton widthTouches:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"onEnd...");
//    if (self.isfullScreen)
//    {
//        if (touchButton.tag == CONTROLLER_BTN_TAG_PRESS_TALK)
//        {
//            [touchButton setBackgroundImage:[UIImage imageNamed:@"monitor_talk_full2.png"] forState:UIControlStateNormal];
//            [self.talkingTipView setHidden:YES];
//        }
//    }
//    else
//    {
//        if (touchButton.tag == CONTROLLER_BTN_TAG_PRESS_TALK)
//        {
//            [touchButton setBackgroundImage:[UIImage imageNamed:@"monitor_talk_d.png"] forState:UIControlStateNormal];
//            [self.talkingTipView setHidden:YES];
//        }
//    }
//    [[PAIOUnit sharedUnit] setSpeckState:YES];
//}

-(void)onMoved:(TouchButton *)touchButton widthTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    DLog(@"onMoved");
}

-(void)saveheadimg{
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!del.isGoBack) {
        UIImage *image = [[UIImage alloc] initWithCGImage:[self.remoteView glToUIImage].CGImage];
        NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(image)];
        [Utils saveHeaderFileWithId:[[P2PClient sharedClient] callId] data:imgData];
        [image release];
    }
}

#pragma mark - 各个按钮的点击事件
-(void)onControllerBtnPress:(id)sender{
    UIButton *button = (UIButton*)sender;
    switch(button.tag){
        case CONTROLLER_BTN_TAG_RESOLUTION://分辨率
        {
            if (_isShowResolutionView)
            {
                [UIView animateWithDuration:0.2f animations:^{
                    self.resolutionViewFull.frame = _rectResoutionHide;
                }];
                _isShowResolutionView = NO;
            }
            else
            {
                _isShowResolutionView = YES;
                [UIView animateWithDuration:0.2f animations:^{
                    self.resolutionViewFull.frame = _rectResoutionShow;
                }];
            }
        }
            break;
        case CONTROLLER_BTN_TAG_HUNGUP:
        {
            if(!self.isReject){
                self.isReject = !self.isReject;
                if (self.isRender) {
                    [self saveheadimg];
                }
                [[P2PClient sharedClient] p2pHungUp];
                MainContainer *mainController = [AppDelegate sharedDefault].mainController;
                [mainController dismissP2PView];
            }
        }
            break;
        case CONTROLLER_BTN_TAG_SOUND:
        {
            _btnVoiceMenu.selected = !_btnVoiceMenu.selected;
            _btnVoiceFull.selected = !_btnVoiceFull.selected;
            
            BOOL isMute = [[PAIOUnit sharedUnit] muteAudio];
            if(isMute){
                [[PAIOUnit sharedUnit] setMuteAudio:NO];
            }else{
                [[PAIOUnit sharedUnit] setMuteAudio:YES];
            }
        }
            break;
        case CONTROLLER_BTN_TAG_HD:
        {
            if (self.isfullScreen) {
                [self.resolutionbtnFull setTitle:NSLocalizedString(@"HD", nil) forState:UIControlStateNormal];
            }
            [[P2PClient sharedClient] sendCommandType:USR_CMD_VIDEO_CTL andOption:7];
            [self updateRightButtonState:CONTROLLER_BTN_TAG_HD];
        }
            break;
        case CONTROLLER_BTN_TAG_SD:
        {
            if (self.isfullScreen) {
                [self.resolutionbtnFull setTitle:NSLocalizedString(@"SD", nil) forState:UIControlStateNormal];
            }
            [[P2PClient sharedClient] sendCommandType:USR_CMD_VIDEO_CTL andOption:5];
            [self updateRightButtonState:CONTROLLER_BTN_TAG_SD];
        }
            break;
        case CONTROLLER_BTN_TAG_LD:
        {
            if (self.isfullScreen) {
                [self.resolutionbtnFull setTitle:NSLocalizedString(@"LD", nil) forState:UIControlStateNormal];
            }
            [[P2PClient sharedClient] sendCommandType:USR_CMD_VIDEO_CTL andOption:6];
            [self updateRightButtonState:CONTROLLER_BTN_TAG_LD];
        }
            break;
        case CONTROLLER_BTN_TAG_SCREENSHOT://截图
        {
            [self.remoteView setIsScreenShotting:YES];
        }
            break;
        case CONTROLLER_BTN_TAG_PRESS_TALK://对讲
        {
            button.selected = !button.selected;
            if (self.isTalking)
            {
                [sender setBackgroundImage:[UIImage imageNamed:@"monitor_talk_full2.png"] forState:UIControlStateNormal];
                
                self.isTalking = NO;
                [self.talkingTipView setHidden:YES];
                [[PAIOUnit sharedUnit] setSpeckState:YES];
            }
            else{
                [sender setBackgroundImage:[UIImage imageNamed:@"monitor_talk_d.png"] forState:UIControlStateNormal];
                
                self.isTalking = YES;
                [self.talkingTipView setHidden:NO];
                [[PAIOUnit sharedUnit] setSpeckState:NO];
            }
        }
            break;
        case CONTROLLER_BTN_TAG_DEFENCE://布防
        {
            button.selected = !button.selected;
            [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:self.contact.contactId isClick:YES];
            if(self.contact.defenceState==DEFENCE_STATE_WARNING_NET||self.contact.defenceState==DEFENCE_STATE_WARNING_PWD){
                self.contact.defenceState = DEFENCE_STATE_LOADING;
                [[P2PClient sharedClient] getDefenceState:self.contact.contactId password:self.contact.contactPassword];
                
            }else if(self.contact.defenceState==DEFENCE_STATE_ON){
                self.contact.defenceState = DEFENCE_STATE_LOADING;
                [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF];
            }else if(self.contact.defenceState==DEFENCE_STATE_OFF){
                self.contact.defenceState = DEFENCE_STATE_LOADING;
                [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_ON];
            }
            [[P2PClient sharedClient] getDefenceState:self.contact.contactId password:self.contact.contactPassword];
        }
            break;
        case CONTROLLER_BTN_TAG_RECORD:
        {
            if (!self.isRecording) {
                for (UIView * view in self.recordbtn.subviews) {
                    if ([view isKindOfClass:[UIImageView class]]) {
                        UIImageView * imgview = (UIImageView *)view;
                        imgview.hidden = NO;
                    }
                }
                for (UIView * view in self.recordbtnFull.subviews) {
                    if ([view isKindOfClass:[UIImageView class]]) {
                        UIImageView * imgview = (UIImageView *)view;
                        imgview.hidden = NO;
                    }
                }
            }else{
                for (UIView * view in self.recordbtn.subviews) {
                    if ([view isKindOfClass:[UIImageView class]]) {
                        UIImageView * imgview = (UIImageView *)view;
                        imgview.hidden = YES;
                    }
                }
                for (UIView * view in self.recordbtnFull.subviews) {
                    if ([view isKindOfClass:[UIImageView class]]) {
                        UIImageView * imgview = (UIImageView *)view;
                        imgview.hidden = YES;
                    }
                }
            }
            self.isRecording = !self.isRecording;
            if (self.isRecording)
            {
                [[P2PClient sharedClient]startRecord];
            }
            else
            {
                [[P2PClient sharedClient]stopRecord];
            }
        }
            break;
        case CONTROLLER_BTN_TAG_FOLDER:
        {
        }
            break;
        case CONTROLLER_BTN_TAG_FULLSCREEN://半屏换全屏
        {
            
            
            
            
            if (!self.isfullScreen)
            {
                if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
                {
                    [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
                                                   withObject:(id)UIInterfaceOrientationLandscapeRight];
                }
            }
            else
            {
                if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
                {
                    [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
                                                   withObject:(id)UIDeviceOrientationPortrait];
                }
            }
            
        }
            break;
        case CONTROLLER_BTN_TAG_GPIO1_0://开锁
        {
            UIAlertView *doorBellAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"door_bell", nil) message:NSLocalizedString(@"confirm_open", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            doorBellAlert.tag = ALERT_TAG_DOORBELL;
            [doorBellAlert show];
            [doorBellAlert release];
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 截图成功后会调用
-(void)onScreenShotted:(UIImage *)image{
    UIImage *tempImage = [[UIImage alloc] initWithCGImage:image.CGImage];
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(tempImage)];
    [Utils saveScreenshotFileWithUserId:loginResult.contactId contactId:self.contact.contactId data:imgData];
    [tempImage release];
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    int imagewidth = width/4;
    NSArray *datas = [NSArray arrayWithArray:[Utils getScreenShotFilesWithContactId:self.contact.contactId]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //"截图声音
        NSString *path = [[NSBundle mainBundle]pathForResource:@"paizhao" ofType:@"m4r"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
        AudioServicesPlaySystemSound(soundId);
        //        截图成功
        [self.remoteView makeToast:NSLocalizedString(@"screenshot_success", nil)];
        
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self reloadScreenshotView];
        if (datas.count>4)
        {
            self.screenshotView.contentOffset = CGPointMake(imagewidth*(datas.count-4), 0);
        }
    });
}

#pragma mark - 设置高清、标清选中
-(void)updateRightButtonState:(NSInteger)tag{
    for(UIView *view in self.resolutionViewFull.subviews)
    {
        if (view.tag == tag) {
            [view setBackgroundColor:XBlue];
        }
        else
        {
            [view setBackgroundColor:[UIColor blackColor]];
        }
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        self.resolutionViewFull.frame = _rectResoutionHide;
    }];
    _isShowResolutionView = NO;
}

- (void)swipeUp:(id)sender {
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                    andOption:USR_CMD_OPTION_PTZ_TURN_DOWN];
}

- (void)swipeDown:(id)sender {
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                    andOption:USR_CMD_OPTION_PTZ_TURN_UP];
}

- (void)swipeLeft:(id)sender {
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                    andOption:USR_CMD_OPTION_PTZ_TURN_LEFT];
}

- (void)swipeRight:(id)sender {
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                    andOption:USR_CMD_OPTION_PTZ_TURN_RIGHT];
}

-(void)onDoubleTap{
    /*
     BOOL is16B9 = [[P2PClient sharedClient] is16B9];
     if(is16B9)
     return;
     */
    _isRenderViewStretch = !_isRenderViewStretch; // 注释后半屏双击就没法放大了
    [self stretchRenderView:_isRenderViewStretch];
}

-(void)onSingleTap{
    if (!_isfullScreen) {
        return;
    }
    if (self.isShowToolbarFull) {
        self.isShowToolbarFull = !self.isShowToolbarFull;
        [self.toolbarFull setAlpha:0.0];
        self.resolutionViewFull.frame = _rectResoutionHide;
        _isShowResolutionView = NO;
    }else{
        self.isShowToolbarFull = !self.isShowToolbarFull;
        [self.toolbarFull setAlpha:0.5];
    }
}

-(CGRect)getRenderViewFrame{
    CGRect rect, rectResult;
    
    rect = self.canvasView.frame;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    if(CURRENT_VERSION<7.0){
        height +=20;
    }
    BOOL is16B9 = [[P2PClient sharedClient] is16B9];
    if(is16B9)  //16:9 720p
    {
        CGFloat finalWidth = height*16/9;
        CGFloat finalHeight = height;
        if(finalWidth>width)  //超高则减高
        {
            finalWidth = width;
            finalHeight = width*9/16;
        }
        else                //超宽则减宽
        {
            finalWidth = height*16/9;
            finalHeight = height;
        }
        rectResult = CGRectMake((width-finalWidth)/2, (height-finalHeight)/2, finalWidth, finalHeight);
    }
    else        //4:3  960p
    {
        rectResult = CGRectMake(0, 0, width, height);
    }
    return rectResult;
}

-(void)stretchRenderView:(BOOL)bStretch{
    if (!bStretch)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        CGAffineTransform transform;
        transform = CGAffineTransformMakeScale(1.0, 1.0f);
        self.remoteView.transform = transform;
        [UIView commitAnimations];
    }
    else
    {
        CGRect rect = self.canvasView.frame;
        CGFloat width = rect.size.height;
        CGFloat height = rect.size.width;
        
        if(CURRENT_VERSION<7.0){
            height +=20;
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        /*
         if (CURRENT_VERSION>=8.0) {
         CGAffineTransform transform = CGAffineTransformMakeScale(height/(width*4/3),1.0f);
         self.remoteView.transform = transform;
         }else{
         CGAffineTransform transform = CGAffineTransformMakeScale(width/(height*4/3),1.0f);
         self.remoteView.transform = transform;
         }
         */
        CGRect rectCanvas = self.canvasView.frame;
        CGRect rectRemoteview = self.remoteView.frame;
        CGFloat rateX = rectCanvas.size.width/rectRemoteview.size.width;
        CGFloat rateY = rectCanvas.size.height/rectRemoteview.size.height;
        CGAffineTransform transform = CGAffineTransformMakeScale(rateX, rateY);
        self.remoteView.transform = transform;
        [UIView commitAnimations];
    }
}

//缩放
-(void)onPinch:(UIPinchGestureRecognizer *)gr
{
    //    self.isPinchGR = YES;
    //    CGRect frame = [[UIScreen mainScreen]bounds];
    //    CGFloat width = frame.size.width;
    //    CGFloat height = frame.size.height;
    self.remoteView.transform = CGAffineTransformScale(self.remoteView.transform, gr.scale, gr.scale);
    gr.scale = 1;
    //    self.remoteView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //        self->panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(addPanGR:)];
    //        [self.remoteView addGestureRecognizer:panGR];
    
}
//移动
//-(void)addPanGR:(UIPanGestureRecognizer *)gr
//{
//    CGPoint  center = self.remoteView.center;
//    CGPoint  t = [gr translationInView:self.view];
//    center.x +=t.x;
//    center.y +=t.y;
//    self.remoteView.center = center;
//    [gr setTranslation:CGPointZero inView:self.view];
//
//    [panGR release];
//}


- (TouchButton *)getControllerButton{
    TouchButton *button = [TouchButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 50, 38)];
    [button setOpaque:YES];
    [button setBackgroundColor:[UIColor darkGrayColor]];
    return button;
}

- (TouchButton *)getControllerButtonFull{
    TouchButton *button = [TouchButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 50, 38)];
    [button setOpaque:YES];
    [button setBackgroundColor:[UIColor blackColor]];
    return button;
}

#pragma mark - 预置位按钮相关
- (UILabel *)createHomeButtonView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    label.text = @"PS";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = label.frame.size.height / 2.f;
    label.backgroundColor =[UIColor redColor];
    label.clipsToBounds = YES;
    return label;
}

- (NSArray *)createDemoButtonArray {
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
    int i = 0;
    for (NSString *title in @[@"1", @"2", @"3", @"4", @"5"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.frame = CGRectMake(0.f, 0.f, 30.f, 30.f);
        button.layer.cornerRadius = button.frame.size.height / 2.f;
        button.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
        button.clipsToBounds = YES;
        button.tag = i++;
        [button addTarget:self action:@selector(clickedPresetBtn:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsMutable addObject:button];
        _yuzhiweib = button;
    }
    return [buttonsMutable copy];
}

- (void)clickedPresetBtn:(UIButton *)sender{
    // NSLog(@"Button tapped, tag: %ld", (long)sender.tag);

    UIActionSheet *presetSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"set_preset", nil),NSLocalizedString(@"check_preset", nil),NSLocalizedString(@"delete_preset", nil) ,nil];
    [presetSheet showInView:self.remoteView];
    [presetSheet release];
    self.presetTag = sender.tag;
}

- (UIButton *)createButtonWithName:(NSString *)imageName {
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(clickedPresetBtn:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}
#pragma mark - 预置位操作表的响应事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //    NSLog(@"self.presetTag:%d", self.presetTag);
    if (buttonIndex == 0)// learn preset
    {
        NSLog(@"Clicked setting preset button.");
        
        [[P2PClient sharedClient] setAndSearchPresetWithId:self.contact.contactId password:self.contact.contactPassword operation:1 presetNumber:self.presetTag];
        
}
    else if(buttonIndex == 1)// check preset
    {
        NSLog(@"Clicked check preset button.");

        [[P2PClient sharedClient] setAndSearchPresetWithId:self.contact.contactId password:self.contact.contactPassword operation:0 presetNumber:self.presetTag];
    
    }else if (buttonIndex == 2){
        
        int c = _Num & 0b0001;
        int d = _Num & 0b0010;
        int f = _Num & 0b0100;
        int g = _Num & 0b1000;
        int h = _Num & 0b10000;
        
        switch (self.presetTag) {
            case 0:
                [[P2PClient sharedClient] setAndSearchPresetWithId:self.contact.contactId password:self.contact.contactPassword operation:3 presetNumber:c];
                break;
            case 1:
                [[P2PClient sharedClient] setAndSearchPresetWithId:self.contact.contactId password:self.contact.contactPassword operation:3 presetNumber:d];
                break;
            case 2 :
                [[P2PClient sharedClient] setAndSearchPresetWithId:self.contact.contactId password:self.contact.contactPassword operation:3 presetNumber:f];
                break;
            case 3:
                [[P2PClient sharedClient] setAndSearchPresetWithId:self.contact.contactId password:self.contact.contactPassword operation:3 presetNumber:g];
                break;
            case 4:
                [[P2PClient sharedClient] setAndSearchPresetWithId:self.contact.contactId password:self.contact.contactPassword operation:3 presetNumber:h];
                break;
            default:
                break;
        }
    }else{
        
    }
    
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeRight;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.isfullScreen = NO;
        for (UIView * view in self.view.subviews) {
            view.hidden = NO;
        }
        self.talkingTipView.hidden = YES;
        self.shottopLabel.hidden = YES;
        self.fullShotimgScrollView.hidden = YES;
        self.toolbarFull.hidden = YES;
        self.resolutionViewFull.hidden = YES;
        self.resolutionViewFull.frame = _rectResoutionHide;
        _isShowResolutionView = NO;
        self.canvasView.frame = self.canvasframe;
        [self stretchRenderView:NO];
        self.remoteView.frame = [self getRenderViewFrame];
        if (_isRenderViewStretch) {
            [self stretchRenderView:YES];
        }
        self.viewerCountLable.frame = self.viewerCountFrame;
        self.viewerCountLable1.frame = self.viewerCountFrame1;
        self.talkingTipView.frame = self.talkingTipframe;
        self.connectingTipView.frame = self.connectingTipViewframe;
        [self reloadScreenshotView];
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.isfullScreen = YES;
        for (UIView * view in self.view.subviews) {
            view.hidden = YES;
        }
        CGRect rect = [AppDelegate getScreenSize:NO isHorizontal:YES];
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        
        [self stretchRenderView:NO];
#pragma mark - iOS7.1.2
        if (CURRENT_VERSION < 8.0) {
            self.canvasView.frame = CGRectMake(0, 0, width, height);
        }
        else
        {
            self.canvasView.frame = CGRectMake(0, 0, height, width);
        }
        
        self.remoteView.frame = [self getRenderViewFrame];
        if (_isRenderViewStretch) {
            [self stretchRenderView:YES];
        }
        self.canvasView.hidden = NO;
        if (CURRENT_VERSION < 8.0) {
            self.viewerCountLable.frame = CGRectMake(width - NUMBER_VIEW_LABEL_WIDTH, 5, NUMBER_VIEW_LABEL_WIDTH, NUMBER_VIEW_LABEL_HEIGHT);//height-NUMBER_VIEW_LABEL_WIDTH-15
            self.viewerCountLable1.frame = CGRectMake(width - NUMBER_VIEW_LABEL_WIDTH-100, 5, NUMBER_VIEW_LABEL_WIDTH, NUMBER_VIEW_LABEL_HEIGHT);//height-NUMBER_VIEW_LABEL_WIDTH-15
        }
        else if(CURRENT_VERSION > 8.0)
        {
            self.viewerCountLable.frame = CGRectMake(height - NUMBER_VIEW_LABEL_WIDTH, 5, NUMBER_VIEW_LABEL_WIDTH, NUMBER_VIEW_LABEL_HEIGHT);
            self.viewerCountLable1.frame = CGRectMake(height - NUMBER_VIEW_LABEL_WIDTH-100, 5, NUMBER_VIEW_LABEL_WIDTH, NUMBER_VIEW_LABEL_HEIGHT);
        }
        
        self.connectingTipView.frame = CGRectMake((height-LOADINGPRESSVIEW_WIDTH_HEIGHT)/2, (width-LOADINGPRESSVIEW_WIDTH_HEIGHT)/2, LOADINGPRESSVIEW_WIDTH_HEIGHT, LOADINGPRESSVIEW_WIDTH_HEIGHT);
        self.talkingTipView.frame = CGRectMake(10, width-10-PRESS_LAYOUT_WIDTH_AND_HEIGHT, PRESS_LAYOUT_WIDTH_AND_HEIGHT/2, PRESS_LAYOUT_WIDTH_AND_HEIGHT);
        self.toolbarFull.hidden = NO;
        self.resolutionViewFull.hidden = NO;
    }
}
//#pragma mark - 传感器配对
//-(void)clickedSensorMateBtn{
//    NSLog(@"Ender sensor mate mode.");
//    //    self.dwCurItem = self.learnedDeviceNum;//当前操作的行
//    
//    UIAlertView *learnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"learn_defence_prompt", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
//    learnAlert.tag = ALERT_TAG_LEARN;
//    [learnAlert show];
//    [learnAlert release];
//    self.isSettingSensor = YES;
//    //    if (self.dataArray.count > 0) {
//    self.dwCurItem = self.dataArray1.count;
//    //        self.dwCurItem ++;
//    //    }
//    if (self.dwCurItem < 8 ) {
//        self.lastGroup = 1;
//    }else if (self.dwCurItem>=8  && self.dwCurItem<16){
//        self.dwCurItem = self.dwCurItem-8;
//        self.lastGroup = 2;
//    }else if (self.dwCurItem>=16 && self.dwCurItem<24){
//        self.dwCurItem = self.dwCurItem-16;
//        self.lastGroup = 3;
//    }else if (self.dwCurItem>=24 && self.dwCurItem<32){
//        self.dwCurItem = self.dwCurItem-24;
//        self.lastGroup = 4;
//    }else if (self.dwCurItem>=32 && self.dwCurItem<40){
//        self.dwCurItem = self.dwCurItem-32;
//        self.lastGroup = 5;
//    }else if (self.dwCurItem>=40 && self.dwCurItem<48){
//        self.dwCurItem = self.dwCurItem-40;
//        self.lastGroup = 6;
//    }else if (self.dwCurItem>=48 && self.dwCurItem<56){
//        self.dwCurItem = self.dwCurItem-48;
//        self.lastGroup = 7;
//    }else if (self.dwCurItem>=56 && self.dwCurItem<64){
//        self.dwCurItem = self.dwCurItem-56;
//        self.lastGroup = 8;
//    }
//    
//    //    self.dwCurItem = 0;
//    //    self.isLoadDefenceSwitch = YES;
//    
//}
//#pragma mark - 遥控器配对
//-(void)clickedRemoteMateBtn{
//    NSLog(@"Ender remote mate mode.");
//    //    self.dwCurItem = self.learnedDeviceNum;//当前操作的行
//    
//    UIAlertView *learnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"learn_defence_prompt", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
//    learnAlert.tag = ALERT_TAG_LEARN;
//    [learnAlert show];
//    [learnAlert release];
//    self.isSettingRemote = YES;
//    self.lastGroup = 0;
//    //    self.dwCurItem = 0;
//    //    self.isLoadDefenceSwitch = YES;
//    self.dwCurItem = self.dataArray.count;
//    
//    
//    //    UIAlertView *nameAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"defence_name", nil) message:NSLocalizedString(@"set_name", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
//    //    nameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    //    self.nameAlertView = nameAlertView;
//    //    self.nameAlertView.tag = ALERT_TAG_NAME;
//    
//}

#pragma mark 删除和添加
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
//        case ALERT_TAG_CLEAR:
//        {
//            if(buttonIndex==1){
//                self.progressAlert.dimBackground = YES;
//                self.progressAlert.labelText = NSLocalizedString(@"clearing", nil);
//                [self.progressAlert show:YES];
//                
//                NSString *newName = self.text2.text;
//                DefenceDao *dao = [[DefenceDao alloc] init];
//                switch (_index1) {
//                    case 0:{
//                        //                        [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:1 item:self.dwCurItem type:1];
//                        _isdelete = YES;
//                        
//                        [dao deleteContent:self.contact.contactId group:0 item:self.dwCurItem text:newName];
//                    }
//                        break;
//                    case 1:{
//                        //                        [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:0 item:self.dwCurItem type:1];
//                        _isdelete = YES;
//                        [dao deleteContent:self.contact.contactId group:1 item:self.dwCurItem text:newName];
//                    }
//                        break;
//                        
//                    default:
//                        break;
//                }
//                [dao release];
//                
//                //更新界面
//                NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
//                [oneTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
//                [indexSet release];
//                [oneTableView reloadData];
//            }
//        }
//            break;
//#pragma mark - 传感器和遥控学习
//        case ALERT_TAG_LEARN:
//        {
//            if(buttonIndex==1)
//            {
//                //指示器
//                
//                self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
//                self.progressAlert.labelText = NSLocalizedString(@"learning",nil);
//                [self.view addSubview:self.progressAlert];
//                self.progressAlert.dimBackground = YES;
//                [self.progressAlert show:YES];
//                self.isLoadDefenceArea = YES;
//                if (self.isSettingSensor)//学门磁
//                {
//                    
//                    [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.lastGroup item:self.dwCurItem type:0];
//                    NSLog(@"%d,==%d===",self.lastGroup,self.dwCurItem);
//                    
//                }
//                else if(self.isSettingRemote)//学遥控
//                {
//                    NSLog(@"self.dwCurGroup:%d",self.dwCurGroup);
//                    [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.lastGroup item:self.dwCurItem type:0];
//                    NSLog(@"%d,==%d===",self.lastGroup,self.dwCurItem);
//                    
//                }
//            }
//        }
//            break;
//        case ALERT_TAG_LEARN_SENSOR:
//        {
//            if (buttonIndex == 1)
//            {
//                self.progressAlert = [[[MBProgressHUD alloc]initWithView:self.view]autorelease];
//                self.progressAlert.labelText = NSLocalizedString(@"learning", nil);
//                [self.view addSubview:self.progressAlert];
//                self.progressAlert.dimBackground = YES;
//                [self.progressAlert show:YES];
//                
//                [[P2PClient sharedClient] setDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword switchId:1 alarmCodeId:self.dwCurGroup alarmCodeIndex:self.dwCurItem];
//            }
//            
//        }
//            break;
        case ALERT_TAG_DOORBELL:
        {
            if (buttonIndex == 1)
            {
                //GPIO口开锁
                int time[8] = {0};
                time[0] = -15;
                time[1] = 6000;
                time[2] = -1;
                //记录当前的GPIO设置参数
                self.lastGroup = 1;
                self.lastPin = 0;
                self.lastValue = 3;
                self.lastTime = time;
                NSString *contactId = [[P2PClient sharedClient] callId];
                NSString *contactPassword = [[P2PClient sharedClient] callPassword];
                [[P2PClient sharedClient] setGpioCtrlWithId:contactId password:contactPassword group:1 pin:0 value:3 time:time];
                
                //透传开锁
                //                [[P2PClient sharedClient] sendCustomCmdWithId:contactId password:contactPassword cmd:@"IPC1anerfa:unlock"];
            }
        }
            break;
//        case ALERT_TAG_NAME:
//        {
//            NSLog(@"学习对码成功后，起名");
//            [self.nameAlertView release];
//            if (buttonIndex == 1)
//            {
//                NSLog(@"😄😢Clicked OK.");
//                UITextField *nameTF = [self.nameAlertView textFieldAtIndex:0];//用一个textField来接收用户输入内容
//                NSLog(@"用户输入了名字:%@", nameTF.text);
//                self.defenceName = nameTF.text;//receive name
//                [oneTableView reloadData];
//            }
//        }
//            break;
    }
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    if ([tableView isEqual:oneTableView]) {
//        return 2;
//    }else if ([tableView isEqual:twoTableView]){
//        return 1;
//    }
//    return 0;
//    
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    
//    if ([tableView isEqual:oneTableView]) {
//        switch (section) {
//            case 0:{
//                if (!_isdelete) {
//                    return self.dataArray.count;
//                    
//                }else if (_isdelete){
//                    return self.dataArray.count-1;
//                    
//                }
//            }
//                break;
//                
//            case 1:{
//                if (!_isdelete) {
//                    return self.dataArray1.count;
//                    
//                } else if(_isdelete){
//                    return self.dataArray1.count-1;
//                    
//                }
//            }
//                break;
//                
//            default:
//                break;
//        }
//        
//    }else if ([tableView isEqual:twoTableView]){
//        return 6;
//    }
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if ([tableView isEqual:oneTableView]) {
//        static NSString * reuseID1 = @"DefenceCell";
//        DefenceMagnetic1Cell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID1];
//        if (cell == nil) {
//            cell =[[[DefenceMagnetic1Cell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID1] autorelease];
//            //        cell.backgroundColor = [UIColor blueColor];
//        }
//        
//        cell.item = indexPath.row;
//        //    int section = indexPath.section;
//        int row = indexPath.row;
//        _index1 = indexPath.section;
//        switch (indexPath.section) {
//            case 0:
//                for (int i = 0; i< self.dataArray.count; i++) {
//                    cell.lab.text = [NSString stringWithFormat:@"遥控器 %d",row+1];
//                    cell.iconImage.image = [UIImage imageNamed:@"family_type"];
//                }
//                break;
//                
//            case 1:
//                for (int i = 0; i< self.dataArray1.count; i++) {
//                    cell.lab.text = [NSString stringWithFormat:@"通道 %d",row+1];
//                    cell.iconImage.image = [UIImage imageNamed:@"family_type"];
//                    
//                }
//                if (_text3.text) {
//                    cell.lab1.text = [NSString stringWithFormat:@"%d",_index];
//                    NSLog(@"=======%d=======",_index);
//                    cell.iconImage1.image= [UIImage imageNamed:@"baidu_sel"];
//                }
//                break;
//                
//                
//                
//            default:
//                break;
//        }
//        
//        return cell;
//        
//    }else if ([tableView isEqual:twoTableView]){
//        static NSString *reuseID2 = @"cell";
//        yizhiweiCell *cell =[tableView dequeueReusableCellWithIdentifier:reuseID2];
//        if (cell == nil) {
//            cell = [[yizhiweiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID2];
//            
//        }
//        
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.leftLab.text = [NSString stringWithFormat:@"%d",indexPath.row];
//        if (indexPath.row == _index) {
//            cell.img.image = [UIImage imageNamed:@"radio_btn_on"];
//        }else{
//            cell.img.image = [UIImage imageNamed:@"radio_btn_off"];
//        }
//        return cell;
//    }
//    
//    
//    return nil;
//}
//
//
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if ([tableView isEqual:oneTableView]) {
//        NSLog(@"%d",indexPath.row);
//        
//    }else if ([tableView isEqual:twoTableView]){
//        NSLog(@"%d",indexPath.row);
//        _index = indexPath.row;
//        if (indexPath.row != 0) {
//            [[P2PClient sharedClient]setDevicePresetWithId:self.contact.contactId password:self.contact.contactPassword type:0 presetNum:indexPath.row];
//            //            [[P2PClient sharedClient] setAlarmTypeMotorPresetPosWithId:self.contact.contactId password:self.contact.contactPassword alarmType:self.alarmType presetNumber:_index];
//        }
//        
//        if (indexPath.row ==0) {
//            _text3.text = @"";
//        }else{
//            _text3.text = [NSString stringWithFormat:@"%d",indexPath.row];
//        }
//        
//        NSLog(@"===%@",_sss);
//        [twoTableView reloadData];
//        [v1 removeFromSuperview];
//        
//    }
//    
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([tableView isEqual:oneTableView]) {
//        return 60;
//    }else if ([tableView isEqual:twoTableView]){
//        return 60;
//    }
//    return 0.0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if ([tableView isEqual:oneTableView]) {
//        return 20;
//    }else if ([tableView isEqual:twoTableView]){
//        return 40;
//    }
//    return 0.0;
//}
//
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if ([tableView isEqual:twoTableView]) {
//        return @"请选择预置位";
//        
//    }
//    return nil;
//}
//
//- (void)addviewcontroller{
//    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-100, self.view.frame.size.width, 200)];
//    v.backgroundColor = [UIColor grayColor];
//    [self.view addSubview:v];
//    _v = v;
//    if (self.isSettingSensor) {
//        UILabel *lab1 = [[UILabel alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
//        lab1.text = @"传感器配对";
//        lab1.textColor = [UIColor blackColor];
//        lab1.textAlignment = NSTextAlignmentCenter;
//        lab1.font = [UIFont boldSystemFontOfSize:16];
//        [_v addSubview:lab1];
//        
//        UILabel *lab2 =[[UILabel alloc] initWithFrame:CGRectMake(5, 35, 50, 30)];
//        lab2.text = @"传感器名称";
//        lab2.textAlignment = NSTextAlignmentLeft;
//        lab2.font = [UIFont boldSystemFontOfSize:10];
//        [_v addSubview:lab2];
//        
//        _text2 = [[UITextField alloc] initWithFrame:CGRectMake(56, 35, self.view.frame.size.width-60, 30)];
//        _text2.layer.borderWidth = 1.0;
//        _text2.layer.cornerRadius = 6.0;
//        _text2.clearButtonMode = UITextFieldViewModeWhileEditing;
//        
//        _text2.textAlignment = NSTextAlignmentLeft;
//        for (int i = 0; i< self.dataArray1.count; i++) {
//            _text2.text = [NSString stringWithFormat:@"通道 %d",i+1];
//        }
//        _text2.font = [UIFont boldSystemFontOfSize:10];
//        [_v addSubview:_text2];
//        
//        
//        UILabel *lab3 =[[UILabel alloc] initWithFrame:CGRectMake(5, 68, 50, 30)];
//        lab3.text = @"预置位";
//        lab3.textAlignment = NSTextAlignmentLeft;
//        lab3.font = [UIFont boldSystemFontOfSize:10];
//        [_v addSubview:lab3];
//        
//        _text3 = [[UITextField alloc] initWithFrame:CGRectMake(56, 68, self.view.frame.size.width-60, 30)];
//        _text3.layer.borderWidth = 1.0;
//        _text3.delegate = self;
//        _text3.clearButtonMode = UITextFieldViewModeWhileEditing;
//        _text3.textAlignment = NSTextAlignmentLeft;
//        _text3.font = [UIFont boldSystemFontOfSize:10];
//        _text3.text = _sss;
//        [_v addSubview:_text3];
//        
//        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        saveButton.frame =CGRectMake(20, 105, self.view.frame.size.width - 40, 30);
//        [saveButton setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
//        UIImage *saveButtonBackImg = [UIImage imageNamed:@"new_button.png"];
//        saveButtonBackImg = [saveButtonBackImg stretchableImageWithLeftCapWidth:saveButtonBackImg.size.width*0.5 topCapHeight:saveButtonBackImg.size.height*0.5];
//        
//        UIImage *saveButtonBackImg_p = [UIImage imageNamed:@"new_button3.png"];
//        saveButtonBackImg_p = [saveButtonBackImg_p stretchableImageWithLeftCapWidth:saveButtonBackImg_p.size.width*0.5 topCapHeight:saveButtonBackImg_p.size.height*0.5];
//        [saveButton addTarget:self action:@selector(onconfirm) forControlEvents:UIControlEventTouchUpInside];
//        
//        [saveButton setBackgroundImage:saveButtonBackImg forState:UIControlStateNormal];
//        [saveButton setBackgroundImage:saveButtonBackImg_p forState:UIControlStateHighlighted];
//        [_v addSubview:saveButton];
//        
//        
//    }else if (self.isSettingRemote){
//        UILabel *lab1 = [[UILabel alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
//        lab1.text = @"遥控器配对";
//        lab1.textColor = [UIColor blackColor];
//        lab1.textAlignment = NSTextAlignmentCenter;
//        lab1.font = [UIFont boldSystemFontOfSize:16];
//        [_v addSubview:lab1];
//        
//        UILabel *lab2 =[[UILabel alloc] initWithFrame:CGRectMake(5, 35, 50, 30)];
//        lab2.text = @"遥控器名称";
//        lab2.textAlignment = NSTextAlignmentLeft;
//        lab2.font = [UIFont boldSystemFontOfSize:10];
//        [_v addSubview:lab2];
//        
//        _text4 = [[UITextField alloc] initWithFrame:CGRectMake(56, 35, self.view.frame.size.width-60, 30)];
//        _text4.layer.borderWidth = 1.0;
//        _text4.layer.cornerRadius = 6.0;
//        _text4.clearButtonMode = UITextFieldViewModeWhileEditing;
//        _text4.textAlignment = NSTextAlignmentLeft;
//        for (int i = 0; i< self.dataArray.count; i++) {
//            _text4.text = [NSString stringWithFormat:@"遥控器 %d",i+1];
//            
//        }
//        _text4.font = [UIFont boldSystemFontOfSize:10];
//        [_v addSubview:_text4];
//        
//        
//        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        saveButton.frame =CGRectMake(20, 70, self.view.frame.size.width - 40, 30);
//        [saveButton setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
//        UIImage *saveButtonBackImg = [UIImage imageNamed:@"new_button.png"];
//        saveButtonBackImg = [saveButtonBackImg stretchableImageWithLeftCapWidth:saveButtonBackImg.size.width*0.5 topCapHeight:saveButtonBackImg.size.height*0.5];
//        
//        UIImage *saveButtonBackImg_p = [UIImage imageNamed:@"new_button3.png"];
//        saveButtonBackImg_p = [saveButtonBackImg_p stretchableImageWithLeftCapWidth:saveButtonBackImg_p.size.width*0.5 topCapHeight:saveButtonBackImg_p.size.height*0.5];
//        [saveButton addTarget:self action:@selector(onconfirm) forControlEvents:UIControlEventTouchUpInside];
//        [saveButton setBackgroundImage:saveButtonBackImg forState:UIControlStateNormal];
//        [saveButton setBackgroundImage:saveButtonBackImg_p forState:UIControlStateHighlighted];
//        [_v addSubview:saveButton];
//        
//    }
//    
//}
//-(void)textFieldDidBeginEditing:(UITextField*)textField
//{
//    [textField resignFirstResponder];
//    NSLog(@"11111");
//    v1 = [[UIView alloc] initWithFrame:CGRectMake(40, self.view.frame.size.height/2-150, self.view.frame.size.width-80, 300)];
//    v1.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:v1];
//    
//    twoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, v1.frame.size.width, v1.frame.size.height) style:UITableViewStylePlain];
//    twoTableView.delegate = self;
//    twoTableView.dataSource = self;
//    [v1 addSubview:twoTableView];
//    
//    
//}
//
//- (void)initNameArray{
//    //    DefenceDao *dao = [[DefenceDao alloc] init];
//    //    NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:0];
//    //    for (int i =0; i<self.dataArraycount.count; i++) {
//    //        NSString *name = [dao getItemName:self.contact.contactId group:self.lastGroup item:i];
//    ////        if (name ==nil) {
//    ////            name = [NSString stringWithFormat:@"%@ %d",[Utils defaultDefenceName:self.lastGroup],i+1];
//    ////
//    ////        }
//    //        [nameArray addObject:name];
//    //    }
//    //    [dao release];
//    //    self.nameArray = nameArray;
//    //
//}
//
//- (void)onconfirm{
//    
//    NSString *newName = self.text2.text;
//    DefenceDao *dao = [[DefenceDao alloc] init];
//    //    NSString *text = [dao getItemName:self.contact.contactId group:self.lastGroup item:self.dwCurItem];
//    //    NSLog(@"%@",text);
//    //    if (text == nil) {
//    //        [dao insert:self.contact.contactId group:self.lastGroup item:self.dwCurItem text:newName];
//    //
//    //    }else{
//    //        [dao update:self.contact.contactId group:self.lastGroup item:self.dwCurItem text:newName];
//    //    }
//    [dao insert:self.contact.contactId group:self.lastGroup item:self.dwCurItem text:newName];
//    
//    //    [self.nameArray  setObject:newName atIndexedSubscript:self.dwCurItem];
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dwCurItem inSection:self.lastGroup];
//    [oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
//    
//    [oneTableView reloadData];
//    [_v setHidden:YES ];
//    
//}
//
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    //    NSNumber* defenceStatus = [self.dataArraycount objectAtIndex:indexPath.row];
//    //    return ([defenceStatus intValue] == 0);
//    return YES;
//}
//#pragma mark - 删除
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        switch (indexPath.section) {
//            case 0:{
//                self.dwCurItem = indexPath.row;
//                UIAlertView *clearAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"clear_defence_prompt", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
//                clearAlert.tag = ALERT_TAG_CLEAR;
//                [clearAlert show];
//                [clearAlert release];
//            }
//                break;
//            case 1:{
//                
//                self.dwCurItem = indexPath.row;
//                UIAlertView *clearAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"clear_defence_prompt", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
//                clearAlert.tag = ALERT_TAG_CLEAR;
//                [clearAlert show];
//                [clearAlert release];
//                
//            }
//                break;
//            default:
//                break;
//        }
//    }
//}

@end







