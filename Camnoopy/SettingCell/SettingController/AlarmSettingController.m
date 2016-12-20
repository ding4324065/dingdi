

#import "AlarmSettingController.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "TopBar.h"
#import "P2PSwitchCell.h"
#import "P2PBuzzerCell.h"
#import "P2PEmailSettingCell.h"
#import "BindAlarmEmailController.h"
#import "RadioButton.h"
#import "MBProgressHUD.h"
#import "AddBindAccountController.h"
#import "Toast+UIView.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "AlarmAccountController.h"
#import "P2PSecurityCell.h"
#import "P2PTHDataCell.h"
#import "P2PMotionLevelSettingCell.h"
#import "FTPController.h"
@interface AlarmSettingController ()

@end

@implementation AlarmSettingController

-(void)dealloc{
    
    [self.tableView release];
    [self.contact release];
    [self.alarmSwitch release];
    [self.buzzerSwitch release];
    [self.motionSwitch release];
    [self.humanInfraredSwitch release];
    [self.temperatureSetSwitch release];
    [self.wiredAlarmInputSwitch release];
    [self.wiredAlarmOutputSwitch release];
    [self.radio1 release];
    [self.radio2 release];
    [self.radio3 release];
    [self.bindIds release];
    [self.bindEmail release];
    [self.lastSetBindEmail release];
    //[self.nowTemperature release];
    [self.nowHumidity release];
    [self.temperatureMin release];
    [self.temperatureMax release];
    
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

-(id)init{
    self = [super init];
    if(self){
        self.bindIds = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!self.isFirstLoadingCompolete){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        self.isLoadingAlarmState = YES;
        self.isLoadingBindEmail = YES;
        self.isLoadingBindId = YES;
        self.isLoadingBuzzer = YES;
        self.isLoadingMotionDetect = YES;
        self.isLoadingHumanInfrared = YES;
        self.isLoadingWiredAlarmInput = YES;
        self.isLoadingWiredAlarmOutput = YES;
        self.isLoadingTempOrHumi = YES;
        self.isLoadingSoundAlarm = YES;
        //        self.isLoadingModifyEmail = NO;
        self.isTemperatureMax = NO;
        self.isTemperatureMin = NO;
        self.isHumidityMax = NO;
        self.isHumidityMin = NO;
        self.isSupeortWiredIO = NO;
        
        self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
        self.buzzerState = SETTING_VALUE_BUZZER_STATE_OFF;
        self.motionState = SETTING_VALUE_MOTION_STATE_OFF;
        self.humanInfraredState = SETTING_VALUE_HUMAN_INFRARED_STATE_OFF;
        self.wiredAlarmInputState = SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF;
        self.wiredAlarmOutputState = SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF;
        self.temperatureNumState = SETTING_VALUE_LIMIT_TEMPERATURE_OFF;
        self.soundAlarmState = SETTING_VALUE_SOUND_STATE_OFF;
        //       报警邮箱
        [[P2PClient sharedClient] getAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword];
        //        绑定账户
        [[P2PClient sharedClient] getBindAccountWithId:self.contact.contactId password:self.contact.contactPassword];
        //        NPC摄像机设置
        [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
        //        TH设备
        [[P2PClient sharedClient] getDeviceTHWithId:self.contact.contactId password:self.contact.contactPassword];
        
        self.isFirstLoadingCompolete = !self.isFirstLoadingCompolete;
    }
    
    //isRefreshAlarmEmail = YES 表示在下个界面，重新修改了报警邮箱信息，在此处进行刷新
    //或者isNotVerifiedEmail = YES 邮箱未验证时，也刷新
    if (self.isRefreshAlarmEmail || self.isNotVerifiedEmail) {
        self.isRefreshAlarmEmail = NO;
        
        self.isLoadingBindEmail = YES;
        [self.tableView reloadData];
        [[P2PClient sharedClient] getAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword];
    }
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self sheetViewHiden];
    
}


- (void)receiveRemoteMessage:(NSNotification *)notification{
    
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    NSLog(@"key------%d",key);
    switch(key){
            //            移动侦测
        case RET_GET_NPCSETTINGS_MOTION:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            self.motionState = state;
            self.lastMotionState = state;
            self.isLoadingMotionDetect = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            DLog(@"motion state:%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_MOTION:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingMotionDetect = NO;
            if(result==0)
            {
                self.lastMotionState = self.motionState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastMotionState==SETTING_VALUE_MOTION_STATE_ON){
                        self.motionState = self.lastMotionState;
                        self.motionSwitch.on = YES;
                        
                    }else if(self.lastMotionState==SETTING_VALUE_MOTION_STATE_OFF){
                        self.motionState = self.lastMotionState;
                        self.motionSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            //       蜂鸣器
        case RET_GET_NPCSETTINGS_BUZZER:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.buzzerState = state;
            self.lastBuzzerState = state;
            self.isLoadingBuzzer = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            NSLog(@"buzzer state:%i",state);
            
        }
            break;
            
            
        case RET_SET_NPCSETTINGS_BUZZER:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingBuzzer = NO;
            if(result == 0){
                self.lastBuzzerState = self.buzzerState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastBuzzerState==SETTING_VALUE_BUZZER_STATE_OFF){
                        self.buzzerState = self.lastBuzzerState;
                        self.buzzerSwitch.on = NO;
                        
                    }
                    else if(self.lastMotionState!=SETTING_VALUE_MOTION_STATE_OFF){
                        self.motionState = self.lastMotionState;
                        self.motionSwitch.on = YES;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            //        email
        case RET_GET_ALARM_EMAIL:
        {
            self.isSMTP = [[parameter valueForKey:@"isSMTP"] intValue];
            self.isRightPwd = [[parameter valueForKey:@"isRightPwd"] intValue];
            self.isEmailVerified = [[parameter valueForKey:@"isEmailVerified"] intValue];
            if (self.isSMTP == 1 && self.isEmailVerified == 0) {//邮箱已验证
                self.isNotVerifiedEmail = NO;
            }
            self.smtpServer = [parameter valueForKey:@"smtpServer"];
            self.smtpPort = [[parameter valueForKey:@"smtpPort"] intValue];
            self.smtpUser = [parameter valueForKey:@"smtpUser"];
            if ([self.smtpUser isEqualToString:@"0"]) {
                self.smtpUser = @"";
            }
            self.smtpPwd = [parameter valueForKey:@"smtpPwd"];
            self.encryptType = [[parameter valueForKey:@"encryptType"] intValue];
            self.reserve = [[parameter valueForKey:@"reserve"] intValue];
            NSString *email = [parameter valueForKey:@"email"];
            
            if ([email isEqualToString:@"0"]) {
                self.bindEmail = @"";
            }else{
                self.bindEmail = email;
            }
            self.isLoadingBindEmail = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            DLog(@"alarm email:%@",email);
        }
            break;
            //         绑定账号
        case RET_GET_BIND_ACCOUNT:
        {
            LoginResult *loginResult = [UDManager getLoginInfo];
            //            NSInteger count = [[parameter valueForKey:@"count"] intValue];
            NSInteger maxCount = [[parameter valueForKey:@"maxCount"] intValue];
            NSArray *datas = [parameter valueForKey:@"datas"];
            
            self.maxBindIdCount = maxCount;
            self.bindIds = [NSMutableArray arrayWithArray:datas];
            
            if (self.bindIds.count==0) {
                self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
            }else if (self.bindIds.count>0){
                if ([self.bindIds containsObject:[NSNumber numberWithInt:loginResult.contactId.intValue]]) {
                    self.alarmState = SETTING_VALUE_ALARM_STATE_ON;
                }else{
                    self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
                }
            }
            
            self.isLoadingAlarmState = NO;
            self.isLoadingBindId = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
            break;
        case RET_SET_BIND_ACCOUNT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                self.bindIds = [NSMutableArray arrayWithArray:self.lastSetBindIds];
                self.lastAlarmState = self.alarmState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isLoadingAlarmState = NO;
                    
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            //       红外
        case RET_GET_NPCSETTINGS_HUMAN_INFRARED:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            self.isSupportHI_WI_WO = YES;
            self.humanInfraredState = state;
            self.lastHumanInfraredState = state;
            self.isLoadingHumanInfrared = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"human infrared state:%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_HUMAN_INFRARED:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingHumanInfrared = NO;
            if(result == 0)
            {
                self.lastHumanInfraredState = self.humanInfraredState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastHumanInfraredState==SETTING_VALUE_HUMAN_INFRARED_STATE_ON){
                        self.humanInfraredState = self.lastHumanInfraredState;
                        self.humanInfraredSwitch.on = YES;
                        
                    }else if(self.lastHumanInfraredState==SETTING_VALUE_HUMAN_INFRARED_STATE_OFF){
                        self.humanInfraredState = self.lastHumanInfraredState;
                        self.humanInfraredSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            //       报警输入
        case RET_GET_NPCSETTINGS_WIRED_ALARM_INPUT:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.wiredAlarmInputState = state;
            self.lastWiredAlarmInputState = state;
            self.isLoadingWiredAlarmInput = NO;
            self.isSupeortWiredIO = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            NSLog(@"wired alarm input state:%i",state);
            
        }
            break;
            //            报警输入
        case RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingWiredAlarmInput = NO;
            if(result==0){
                self.lastWiredAlarmInputState = self.wiredAlarmInputState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastWiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON){
                        self.wiredAlarmInputState = self.lastWiredAlarmInputState;
                        self.wiredAlarmInputSwitch.on = YES;
                        
                    }else if(self.lastWiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF){
                        self.wiredAlarmInputState = self.lastWiredAlarmInputState;
                        self.wiredAlarmInputSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            //       报警输出
        case RET_GET_NPCSETTINGS_WIRED_ALARM_OUTPUT:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.wiredAlarmOutputState = state;
            self.lastWiredAlarmOutputState = state;
            self.isLoadingWiredAlarmOutput = NO;
            self.isSupeortWiredIO = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            NSLog(@"wired alarm output state:%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingWiredAlarmOutput = NO;
            if(result==0){
                self.lastWiredAlarmOutputState = self.wiredAlarmOutputState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastWiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON){
                        self.wiredAlarmOutputState = self.lastWiredAlarmOutputState;
                        self.wiredAlarmOutputSwitch.on = YES;
                        
                    }else if(self.lastWiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF){
                        self.wiredAlarmOutputState = self.lastWiredAlarmOutputState;
                        self.wiredAlarmOutputSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            //      温湿度
        case RET_GET_TH_DATA:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            if (self.isTemperatureMax || self.isTemperatureMin || self.isHumidityMax || self.isHumidityMin)
            {
                return;
            }
            else if (result == 1)//get成功
            {
                NSString *nowTemperature = [NSString stringWithFormat:@"%@℃",[parameter valueForKey:@"nowTemperature"]];
                self.nowTemperature = nowTemperature;//当前温度
                
                NSString *nowHumidity = [NSString stringWithFormat:@"%@％",[parameter valueForKey:@"nowHumidity"]];
                self.nowHumidity = nowHumidity;//当前湿度
                
                NSString *temperatureMin = [NSString stringWithFormat:@"%@", [parameter valueForKey:@"temperatureMin"]];
                self.temperatureMin = temperatureMin;
                
                NSString *temperatureMax = [NSString stringWithFormat:@"%@", [parameter valueForKey:@"temperatureMax"]];
                self.temperatureMax = temperatureMax;
                
                NSString *humidityMin = [NSString stringWithFormat:@"%@", [parameter valueForKey:@"humidityMin"]];
                self.humidityMin = humidityMin;
                
                NSString *humidityMax = [NSString stringWithFormat:@"%@", [parameter valueForKey:@"humidityMax"]];
                self.humidityMax = humidityMax;
                
                self.isLoadingTempOrHumi = NO;
                self.isSupeortTH = YES;
            }
            else//不支持温湿度
            {
                return;
            }
        }
            break;
            //            温湿度报警
        case RET_GET_NPCSETTINGS_TH_DATA:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            self.temperatureNumState = state;
            self.lastTemperatureNumState = state;
            self.isLoadingTempOrHumi = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            //            NSLog(@"human infrared state:%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_TH_DATA:
        {
            
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingTempOrHumi = NO;
            if (result == 0)
            {
                self.lastTemperatureNumState = self.temperatureNumState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
            }
            else
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastTemperatureNumState == SETTING_VALUE_LIMIT_TEMPERATURE_ON){
                        self.temperatureNumState = self.lastTemperatureNumState;
                        self.temperatureSetSwitch.on = YES;
                        
                    }else if(self.lastTemperatureNumState == SETTING_VALUE_LIMIT_TEMPERATURE_OFF){
                        self.temperatureNumState = self.lastTemperatureNumState;
                        self.temperatureSetSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            //         声音报警
        case RET_GET_NPCSETTINGS_SOUNDALARM:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.soundAlarmState = state;
            self.lastSoundAlarmState = state;
            self.isLoadingSoundAlarm = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
            //            NSLog(@"&&&soundAlarm state:%i",state);
        }
            break;
        case RET_SET_NPCSETTINGS_SOUNDALARM:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingSoundAlarm = NO;
            if(result == 0)
            {
                self.lastSoundAlarmState = self.soundAlarmState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastSoundAlarmState==SETTING_VALUE_SOUND_STATE_ON)
                    {
                        self.soundAlarmState = self.lastSoundAlarmState;
                        self.soundAlarmSwitch.on = YES;
                    }
                    else if(self.lastSoundAlarmState==SETTING_VALUE_SOUND_STATE_OFF)
                    {
                        self.soundAlarmState = self.lastSoundAlarmState;
                        self.soundAlarmSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            //移动侦测灵敏度
        case RET_GET_NPCSETTINGS_MOTIONLEVEL:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.motionLevel = state;
            self.lastMotionLevel = state;
            self.isLoadingMotionLevel = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
            NSLog(@"motionLevel:%d",self.motionLevel);
        }
            break;
        case RET_SET_NPCSETTINGS_MOTIONLEVEL:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingMotionLevel = NO;
            if (result == 0)
            {
                self.lastMotionLevel = self.motionLevel;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                    [self.progressAlert hide:YES];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                    [self.progressAlert hide:YES];
                });
            }
        }
            break;
    }
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
            //        case ACK_RET_SET_ALARM_EMAIL:
            //        {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                if(result==1){
            //                    [self.progressAlert hide:YES];
            //                    [self.view makeToast:NSLocalizedString(@"original_password_error", nil)];
            //
            //                }else if(result==2){
            //                    DLog(@"resend set alarm email");
            //                    [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:self.lastSetBindEmail];
            //                }
            //
            //
            //            });
            //
            //
            //
            //
            //
            //            DLog(@"ACK_RET_SET_ALARM_EMAIL:%i",result);
            //        }
            //            break;
            
        case ACK_RET_GET_NPC_SETTINGS:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get npc settings");
                    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_GET_NPC_SETTINGS:%i",result);
        }
            break;
            
        case ACK_RET_SET_NPCSETTINGS_MOTION:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set motion state");
                    [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
                }
                
                
            });
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_MOTION:%i",result);
        }
            break;
            
        case ACK_RET_SET_NPCSETTINGS_BUZZER:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set buzzer state");
                    [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
                }
                
            });
            DLog(@"ACK_RET_SET_NPCSETTINGS_BUZZER:%i",result);
        }
            break;
        case ACK_RET_GET_ALARM_EMAIL:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get alarm email");
                    [[P2PClient sharedClient] getAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword];
                }
            });
            DLog(@"ACK_RET_GET_ALARM_EMAIL:%i",result);
        }
            break;
        case ACK_RET_GET_BIND_ACCOUNT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get bind account");
                    [[P2PClient sharedClient] getBindAccountWithId:self.contact.contactId password:self.contact.contactPassword];
                }
            });
            DLog(@"ACK_RET_GET_BIND_ACCOUNT:%i",result);
        }
            break;
        case ACK_RET_SET_BIND_ACCOUNT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set bind account");
                    [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                }
            });
            DLog(@"ACK_RET_SET_BIND_ACCOUNT:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_HUMAN_INFRARED:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set human infrared state");
                    [[P2PClient sharedClient] setHumanInfraredWithId:self.contact.contactId password:self.contact.contactPassword state:self.humanInfraredState];
                }
            });
            DLog(@"ACK_RET_SET_NPCSETTINGS_MOTION:%i",result);
        }
            break;
            
        case ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set wired alarm input state");
                    [[P2PClient sharedClient] setWiredAlarmInputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmInputState];
                }
            });
            DLog(@"ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT:%i",result);
        }
            break;
            
        case ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set wired alarm output state");
                    [[P2PClient sharedClient] setWiredAlarmOutputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmOutputState];
                }
            });
            DLog(@"ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT:%i",result);
        }
            break;
            
#pragma mark - 温度上下限_ack
        case ACK_RET_SET_TH_DATA:
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == 1)
                {
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }
                else if (result == 2)
                {
                    [[P2PClient sharedClient]setDeviceTHWithId:self.contact.contactId password:self.contact.contactPassword value:self.temperatureNumState type:0 bLimiteType:1];
                }
            });
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_SOUNDALARM://声音报警
        {
            //            NSLog(@"😄result: %i",result);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == 1)
                {
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }
                else if (result == 2)
                {
                    [[P2PClient sharedClient]setSoundAlarmWithId:self.contact.contactId password:self.contact.contactPassword state:self.soundAlarmState];
                }
            });
        }
            break;
        default:
            break;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initComponent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    //    报警设置
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"alarm_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [contentView addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [contentView addSubview:self.progressAlert];
    [self.view addSubview:contentView];
    //   没用
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    //    if (self.isSupeortTH)
    //    {
    //        return 5;
    //    }
    //    else
    //    {
    //        return 4;//890(蜂鸣器)
    //    }
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch(section){
        case 0:
        {
            if (self.isSupportHI_WI_WO)
            {
                return 4;
            }
            else if (self.isSupeortWiredIO)
            {
                return 5;
            }
            else
            {
                return 3;
            }
        }
            break;
            
        case 1://温湿度
        {
            if (self.isSupeortTH) {
                return 7;
            }
            else{
                return 0;
            }
        }
            break;
            
        case 2:
        {
            if(self.isLoadingBindId)
            {
                return 1;
            }
            else
            {
                return [self.bindIds count]+1;
            }
        }
            break;
        case 3:
        {
            return 1;
        }
            break;
        case 4:
        {
            
            if (self.buzzerState == SETTING_VALUE_BUZZER_STATE_OFF)
            {
                return 1;
            }
            else
            {
                return 2;
            }
            
        }
            break;
        case 5:
        {
            return 1;
        }
            break;
        case 6:
        {
            return 1;
        }
            break;
            //                    case 7:
            //                    {
            //                        return 1;
            //                    }
            //                        break;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        return BAR_BUTTON_HEIGHT*2;
    }
    else if(indexPath.section==1&&indexPath.row==1)
    {
        return BAR_BUTTON_HEIGHT;
    }
    else
    {
        return BAR_BUTTON_HEIGHT;
    }
}
#pragma mark - 统一设置tableView的可选情况
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        return NO;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6)
        {
            return YES;
        }
        return NO;
    }
    else if(indexPath.section == 2)
    {
        return NO;
    }
    else if (indexPath.section == 3){
        if (indexPath.row == 0) {
            return YES;
        }
        return NO;
    }
    else if(indexPath.section==4)
    {
        return NO;
    }
    else if(indexPath.section==5)
    {
        return NO;
    }
    else if(indexPath.section==6)
    {
        return NO;
    }
    else if(indexPath.section==7)
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PSwitchCell";
    static NSString *identifier2 = @"P2PBuzzerCell";
    static NSString *identifier3 = @"P2PEmailSettingCell";
    static NSString *identifier4 = @"P2PMotionLevelSettingCell";//移动侦测灵敏度调节
    static NSString *identifier5 = @"P2PTHDataCell";//温湿度
    
    UITableViewCell *cell = nil;
    int section = indexPath.section;
    int row = indexPath.row;
    if (section==0)
    {
        if (indexPath.row == 1)//移动侦测灵敏度调节
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
            if(cell==nil){
                cell = [[[P2PMotionLevelSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
            if(cell==nil)
            {
                cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }
        
    }
    else if(section==1)//温湿度
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
            if(cell==nil)
            {
                cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }
        else if(indexPath.row == 1 || indexPath.row == 2)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier5];
            if (cell == nil)
            {
                cell = [[[P2PTHDataCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier5] autorelease];
                [cell setBackgroundColor:XWhite];
            }
            
        }
        else//温湿度上下限
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier5];
            if(cell==nil){
                cell = [[[P2PTHDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier5] autorelease];
                [cell setBackgroundColor:XGray];
            }
        }
        
    }
    else if(section==2)//接收报警消息
        
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
            if(cell==nil)
            {
                cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
            if(cell==nil)
            {
                cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }
        
        
    }
    else if(section==3)
    {
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
        if(cell==nil){
            cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
            [cell setBackgroundColor:XWhite];
            
            P2PEmailSettingCell *emailsetCell = (P2PEmailSettingCell*)cell;
            emailsetCell.delegate = self;
            [emailsetCell setSection:indexPath.section];
            [emailsetCell setRow:indexPath.row];
        }
        
    }
    else if(section==4)//蜂鸣器
    {
        if(indexPath.row==0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
            if(cell==nil)
            {
                cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }
        else if(indexPath.row==1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
            if(cell==nil)
            {
                cell = [[[P2PBuzzerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }
    }
    
    else if(section==5)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil)
        {
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XWhite];
        }
    }
    //    else if(section==6)
    //    {
    //        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    //        if(cell==nil)
    //        {
    //            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
    //            [cell setBackgroundColor:XWhite];
    //        }
    //    }
    else if(section==6)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil)
        {
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XWhite];
        }
    }
    
    
    
    switch (section)
    {
        case 0:
        {
            if (row==0)//移动侦测
            {
                
                P2PSwitchCell *cell1 = (P2PSwitchCell*)cell;
                [cell1 setLeftLabelText:NSLocalizedString(@"motion", nil)];
                cell1.delegate = self;
                cell1.indexPath = indexPath;
                
                self.motionSwitch = cell1.switchView;
                if(self.isLoadingMotionDetect)
                {
                    [cell1 setProgressViewHidden:NO];
                    [cell1 setSwitchViewHidden:YES];
                }
                else
                {
                    [cell1 setProgressViewHidden:YES];
                    [cell1 setSwitchViewHidden:NO];
                    //                    打开
                    if(self.motionState==SETTING_VALUE_MOTION_STATE_ON)
                    {
                        cell1.on = YES;
                    }
                    else
                    {
                        cell1.on = NO;
                    }
                }
            }
            
            else if (row == 1)//移动侦测灵敏度
            {
                P2PMotionLevelSettingCell *cell2 = (P2PMotionLevelSettingCell*)cell;
                [cell2 setLeftLabelHidden:NO];
                [cell2 setLeftLabelText:NSLocalizedString(@"motion_adjust", nil)];
                if(self.isLoadingMotionLevel){
                    [cell2 setProgressViewHidden:NO];
                    [cell2 setCustomViewHidden:YES];
                }
                else{
                    [cell2 setProgressViewHidden:YES];
                    [cell2 setCustomViewHidden:NO];
                }
                //因为0和1太过于灵敏，所以把可调节范围缩小为：2～6
               
                int iValue = 4 - self.motionLevel + 2;//最大值变量:4
                [cell2 setVolumeValue:iValue];
//                [cell2 setVolumeValue:self.motionLevel];
                [cell2.slider addTarget:self action:@selector(onSlider:) forControlEvents:UIControlEventValueChanged];
                [cell2.slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpOutside];
                [cell2.slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpInside];
                [cell2.slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchCancel];
            }
            else if (row == 2)//声音报警
            {
                P2PSwitchCell *cell3 = (P2PSwitchCell*)cell;
                [cell3 setLeftLabelText:NSLocalizedString(@"sound_alarm", nil)];
                cell3.delegate = self;
                cell3.indexPath = indexPath;
                self.soundAlarmSwitch = cell3.switchView;
                if (self.isLoadingSoundAlarm)
                {
                    [cell3 setProgressViewHidden:NO];
                    [cell3 setSwitchViewHidden:YES];
                }
                else
                {
                    [cell3 setProgressViewHidden:YES];
                    [cell3 setSwitchViewHidden:NO];
                    if (self.soundAlarmState == SETTING_VALUE_SOUND_STATE_ON)
                    {
                        cell3.on = YES;
                    }
                    else
                    {
                        cell3.on = NO;
                    }
                }
            }
            else if (row == 3)//人体红外侦测或 有线报警输入
            {
                if (self.isSupportHI_WI_WO)
                {
                    P2PSwitchCell *cell4 = (P2PSwitchCell*)cell;
                    [cell4 setLeftLabelText:NSLocalizedString(@"human_infrared_detection", nil)];
                    cell4.delegate = self;
                    cell4.indexPath = indexPath;
                    self.humanInfraredSwitch = cell4.switchView;
                    if(self.isLoadingHumanInfrared)
                    {
                        [cell4 setProgressViewHidden:NO];
                        [cell4 setSwitchViewHidden:YES];
                    }
                    else
                    {
                        [cell4 setProgressViewHidden:YES];
                        [cell4 setSwitchViewHidden:NO];
                        if(self.humanInfraredState==SETTING_VALUE_HUMAN_INFRARED_STATE_ON)
                        {
                            cell4.on = YES;
                        }
                        else
                        {
                            cell4.on = NO;
                        }
                    }
                }
                else
                {
                    P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
                    [cell2 setLeftLabelText:NSLocalizedString(@"wired_alarm_input", nil)];
                    cell2.delegate = self;
                    cell2.indexPath = indexPath;
                    self.wiredAlarmInputSwitch = cell2.switchView;
                    if(self.isLoadingWiredAlarmInput){
                        [cell2 setProgressViewHidden:NO];
                        [cell2 setSwitchViewHidden:YES];
                    }
                    else
                    {
                        [cell2 setProgressViewHidden:YES];
                        [cell2 setSwitchViewHidden:NO];
                        if(self.wiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON){
                            cell2.on = YES;
                        }else{
                            cell2.on = NO;
                        }
                    }
                }
            }
            else if (row == 4)//有线报警输出
            {
                P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
                [cell2 setLeftLabelText:NSLocalizedString(@"wired_alarm_output", nil)];
                cell2.delegate = self;
                cell2.indexPath = indexPath;
                self.wiredAlarmOutputSwitch = cell2.switchView;
                if(self.isLoadingWiredAlarmOutput){
                    [cell2 setProgressViewHidden:NO];
                    [cell2 setSwitchViewHidden:YES];
                }else{
                    [cell2 setProgressViewHidden:YES];
                    [cell2 setSwitchViewHidden:NO];
                    if(self.wiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON){
                        cell2.on = YES;
                    }else{
                        cell2.on = NO;
                    }
                }
            }
        }
            break;
        case 1://温湿度
        {
            if (row == 0)
            {
                P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
                //                温湿度报警
                [cell2 setLeftLabelText:NSLocalizedString(@"TH_alert", nil)];
                cell2.delegate = self;
                cell2.indexPath = indexPath;
                self.temperatureSetSwitch = cell2.switchView;
                if(self.isLoadingTempOrHumi){
                    [cell2 setProgressViewHidden:NO];
                    [cell2 setSwitchViewHidden:YES];
                }
                else
                {
                    [cell2 setProgressViewHidden:YES];
                    [cell2 setSwitchViewHidden:NO];
                    if(self.temperatureNumState == SETTING_VALUE_LIMIT_TEMPERATURE_ON)
                    {
                        cell2.on = YES;
                    }
                    else
                    {
                        cell2.on = NO;
                    }
                    
                }
            }
            else if(row == 1)
            {
                
                int nowTemperature = self.nowTemperature.intValue;
                NSString *lastNowTemperature = [NSString stringWithFormat:@"%d", nowTemperature];
                NSString *nowTemperatures = [lastNowTemperature stringByAppendingString:@"℃"];
                
                P2PTHDataCell *temperatureCell = (P2PTHDataCell *)cell;
                
                [temperatureCell setLeftLableText:NSLocalizedString(@"temperature_now", nil)];
                [temperatureCell setRightLableText:nowTemperatures];
                
            }
            else if(row == 2)
            {
                P2PTHDataCell *humidityCell = (P2PTHDataCell *)cell;
                
                [humidityCell setLeftLableText:NSLocalizedString(@"humidity_now", nil)];
                [humidityCell setRightLableText:self.nowHumidity];
                
            }
            
#pragma mark - 温湿度上下限
            else if(row == 3)
            {
                
                int temperatureMax = self.temperatureMax.intValue;
                NSString *lastTemperatureMax = [NSString stringWithFormat:@"%d", temperatureMax];
                NSString *temperatureMaxs = [lastTemperatureMax stringByAppendingString:@"℃"];
                
                P2PTHDataCell *limitTempCell = (P2PTHDataCell *)cell;
                
                [limitTempCell setLeftLableText:NSLocalizedString(@"temperature_max", nil)];
                [limitTempCell setRightLableText:temperatureMaxs];
            }
            
            else if(row == 4)
            {
                int temperatureMin = self.temperatureMin.intValue;
                NSString *lastTemperatureMin = [NSString stringWithFormat:@"%d", temperatureMin];
                NSString *temperatureMins = [lastTemperatureMin stringByAppendingString:@"℃"];
                
                P2PTHDataCell *limitTempCell = (P2PTHDataCell *)cell;
                
                [limitTempCell setLeftLableText:NSLocalizedString(@"temperature_min", )];
                [limitTempCell setRightLableText:temperatureMins];
            }
            else if (row == 5)
            {
                int humidityMax = self.humidityMax.intValue;
                NSString *lastHumidity = [NSString stringWithFormat:@"%d", humidityMax];
                NSString *humidityMaxs = [lastHumidity stringByAppendingString:@"%"];
                
                P2PTHDataCell *limitTempCell = (P2PTHDataCell *)cell;
                
                [limitTempCell setLeftLableText:NSLocalizedString(@"humidity_max", )];
                [limitTempCell setRightLableText:humidityMaxs];
            }
            else if (row == 6)
            {
                int humidityMin = self.humidityMin.intValue;
                NSString *lastHumidity = [NSString stringWithFormat:@"%d", humidityMin];
                NSString *humidityMins = [lastHumidity stringByAppendingString:@"%"];
                
                P2PTHDataCell *limitTempCell = (P2PTHDataCell *)cell;
                
                [limitTempCell setLeftLableText:NSLocalizedString(@"humidity_min", )];
                [limitTempCell setRightLableText:humidityMins];
            }
            
        }
            break;
        case 2:
        {
#pragma mark - 接收报警消息
            if(row == 0)
            {
                P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
                [cell2 setLeftLabelText:NSLocalizedString(@"accept_alarm", nil)];
                cell2.delegate = self;
                cell2.indexPath = indexPath;
                self.alarmSwitch = cell2.switchView;
                if(self.isLoadingAlarmState)
                {
                    [cell2 setProgressViewHidden:NO];
                    [cell2 setSwitchViewHidden:YES];
                }
                else
                {
                    [cell2 setProgressViewHidden:YES];
                    [cell2 setSwitchViewHidden:NO];
                    if(self.alarmState==SETTING_VALUE_ALARM_STATE_ON)
                    {
                        cell2.on = YES;
                    }
                    else
                    {
                        
                        cell2.on = NO;
                    }
                }
            }
            if(row > 0)
            {
                P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
                emailCell.delegate = self;
                [emailCell setSection:indexPath.section];
                [emailCell setRow:indexPath.row];
                [emailCell setLeftIcon:@"ic_delete_alarm_id.png"];
                [emailCell setLeftIconHidden:NO];
                [emailCell setLeftLabelHidden:YES];
                [emailCell setRightIconHidden:YES];
                [emailCell setRightLabelHidden:NO];
                [emailCell setProgressViewHidden:YES];
                NSNumber *bindId = [self.bindIds objectAtIndex:row-1];
                [emailCell setRightLabelText:[NSString stringWithFormat:@"0%i",[bindId intValue]]];
            }
        }
            break;
        case 3:
        {
            if (row ==0) {
                P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
                [emailCell setRightIcon:@"ic_arrow.png"];
                if(self.isLoadingBindEmail){
                    [emailCell setLeftIconHidden:YES];
                    [emailCell setLeftLabelHidden:NO];
                    [emailCell setRightIconHidden:YES];
                    [emailCell setRightLabelHidden:YES];
                    [emailCell setProgressViewHidden:NO];
                }else{
                    [emailCell setLeftIconHidden:YES];
                    [emailCell setLeftLabelHidden:NO];
                    [emailCell setRightIconHidden:NO];
                    [emailCell setRightLabelHidden:NO];
                    [emailCell setProgressViewHidden:YES];
                    if(self.bindEmail&&self.bindEmail.length>0){
                        [emailCell setRightLabelText:self.bindEmail];
                    }else{
                        //                   未绑定
                        [emailCell setRightLabelText:NSLocalizedString(@"unbind", nil)];
                    }
                }
                [emailCell setLeftLabelText:NSLocalizedString(@"alarm_email", nil)];
            }
        }
            break;
        case 4:
        {
            if (row == 0)
            {
                if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_OFF)
                {
                }
                else
                {
                }
                P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
                [cell2 setLeftLabelText:NSLocalizedString(@"buzzer", nil)];
                cell2.delegate = self;
                cell2.indexPath = indexPath;
                self.buzzerSwitch = cell2.switchView;
                if(self.isLoadingBuzzer)
                {
                    [cell2 setProgressViewHidden:NO];
                    [cell2 setSwitchViewHidden:YES];
                }
                else
                {
                    [cell2 setProgressViewHidden:YES];
                    [cell2 setSwitchViewHidden:NO];
                    if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_OFF)
                    {
                        cell2.on = NO;
                    }
                    else
                    {
                        cell2.on = YES;
                    }
                    
                }
            }
            else
            {
                P2PBuzzerCell *buzzerCell = (P2PBuzzerCell*)cell;
                [buzzerCell setLeftLabelText:NSLocalizedString(@"buzzer_time", nil)];
                [buzzerCell.radio1 addTarget:self action:@selector(onRadio1Press:) forControlEvents:UIControlEventTouchUpInside];
                [buzzerCell.radio2 addTarget:self action:@selector(onRadio2Press:) forControlEvents:UIControlEventTouchUpInside];
                [buzzerCell.radio3 addTarget:self action:@selector(onRadio3Press:) forControlEvents:UIControlEventTouchUpInside];
                
                self.radio1 = buzzerCell.radio1;
                self.radio2 = buzzerCell.radio2;
                self.radio3 = buzzerCell.radio3;
                if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_ON_ONE)
                {
                    [buzzerCell setSelectedIndex:0];
                }
                else if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_ON_TWO)
                {
                    [buzzerCell setSelectedIndex:1];
                }
                else if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_ON_THREE)
                {
                    [buzzerCell setSelectedIndex:2];
                }
                
            }
        }
            break;
            //        case 5:
            //        {
            //            P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
            //            [cell2 setLeftLabelText:NSLocalizedString(@"human_infrared_detection", nil)];
            //            cell2.delegate = self;
            //            cell2.indexPath = indexPath;
            //            self.humanInfraredSwitch = cell2.switchView;
            //            if(self.isLoadingHumanInfrared){
            //                [cell2 setProgressViewHidden:NO];
            //                [cell2 setSwitchViewHidden:YES];
            //            }else{
            //                [cell2 setProgressViewHidden:YES];
            //                [cell2 setSwitchViewHidden:NO];
            //                if(self.humanInfraredState==SETTING_VALUE_HUMAN_INFRARED_STATE_ON){
            //                    cell2.on = YES;
            //                }else{
            //                    cell2.on = NO;
            //                }
            //
            //            }
            //        }
            //            break;
            
            break;
        case 5:
        {
            //backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            //backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            
            P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
            [cell2 setLeftLabelText:NSLocalizedString(@"wired_alarm_input", nil)];
            cell2.delegate = self;
            cell2.indexPath = indexPath;
            self.wiredAlarmInputSwitch = cell2.switchView;
            if(self.isLoadingWiredAlarmInput){
                [cell2 setProgressViewHidden:NO];
                [cell2 setSwitchViewHidden:YES];
            }else{
                [cell2 setProgressViewHidden:YES];
                [cell2 setSwitchViewHidden:NO];
                if(self.wiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON){
                    cell2.on = YES;
                }else{
                    cell2.on = NO;
                }
            }
        }
            break;
        case 6:
        {
            //backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            //backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            
            P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
            [cell2 setLeftLabelText:NSLocalizedString(@"wired_alarm_output", nil)];
            cell2.delegate = self;
            cell2.indexPath = indexPath;
            self.wiredAlarmOutputSwitch = cell2.switchView;
            if(self.isLoadingWiredAlarmOutput){
                [cell2 setProgressViewHidden:NO];
                [cell2 setSwitchViewHidden:YES];
            }else{
                [cell2 setProgressViewHidden:YES];
                [cell2 setSwitchViewHidden:NO];
                if(self.wiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON){
                    cell2.on = YES;
                }else{
                    cell2.on = NO;
                }
            }
        }
            break;
            
    }
    return cell;
}

#pragma mark 自定义类似弹框 温湿度上下限
-(void)sheetViewinit{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIView * alphaView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    alphaView.backgroundColor = XBlack_128;
    [self.view addSubview:alphaView];
    self.alphaView = alphaView;
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, height/2)];
    view.backgroundColor = XWhite;
    //view.alpha = 0.3f;
    [alphaView addSubview:view];
    self.ModifyPasswordView = view;
    self.ModifyPasswordView.layer.contents = (id)[UIImage imageNamed:@"about_bk.png"].CGImage;
    [view release];
    [alphaView release];
    
    UIView * headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    headview.backgroundColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    [self.ModifyPasswordView addSubview:headview];
    
    UILabel * headnamelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, width - 10, 30)];
    headnamelabel.backgroundColor = [UIColor clearColor];
    headnamelabel.textAlignment = NSTextAlignmentCenter;
    headnamelabel.textColor = XWhite;
    headnamelabel.text = NSLocalizedString(@"set_TH_alert", nil);
    [self.ModifyPasswordView addSubview:headnamelabel];
    
    UIButton * DownBtn = [[UIButton alloc] init];
    DownBtn.frame = CGRectMake(width - 40, 5, 40, 34);
    UIImageView *downImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 20, 20)];
    downImage.image = [UIImage imageNamed:@"ic_down.png"];
    [DownBtn addSubview:downImage];
    [DownBtn addTarget:self action:@selector(sheetViewHiden) forControlEvents:UIControlEventTouchUpInside];
    [self.ModifyPasswordView addSubview:DownBtn];
    [DownBtn release];
    [downImage release];
    
    self.field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT, width - 30, TEXT_FIELD_HEIGHT)];
    self.field1.textAlignment = NSTextAlignmentLeft;
    self.field1.backgroundColor = [UIColor whiteColor];
    //    请输入数值
    self.field1.placeholder = NSLocalizedString(@"please_input_number", nil);
    self.field1.borderStyle = UITextBorderStyleRoundedRect;
    self.field1.returnKeyType = UIReturnKeyDone;
    self.field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.field1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.OldPWtextView = self.field1;
    [self.ModifyPasswordView addSubview:self.field1];
    [self.field1 release];
    
    UILabel *tipsLable = [[UILabel alloc]init];
    tipsLable.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT + 45, width - 30, TEXT_FIELD_HEIGHT*2 - 10);
    tipsLable.font = XFontBold_16;
    tipsLable.text = NSLocalizedString(@"input_TH_tips", nil);
    //自动折行设置
    tipsLable.lineBreakMode = NSLineBreakByWordWrapping;
    tipsLable.numberOfLines = 0;
    //    tipsLable.backgroundColor = [UIColor redColor];
    [self.ModifyPasswordView addSubview:tipsLable];
    [tipsLable release];
    
    //确定按钮
    UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"new_button.png"] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    [button setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame=CGRectMake(15, self.ModifyPasswordView.frame.size.height - 45, width - 30, 34);
    [button addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [self.ModifyPasswordView addSubview:button];
}

#pragma mark - 收起操作框
-(void)sheetViewHiden{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
        self.ModifyPasswordView.frame = CGRectMake(0, height, width, height/2);
        self.UnBindView.frame = CGRectMake(0, height, width, height/2+50);
        self.BindView.frame = CGRectMake(0, height, width, height/2+50);
        //    self.alphaView.frame = CGRectMake(0, height, width, height);
        [self.BindEmailtextView resignFirstResponder];
        [UIView setAnimationDelegate:self];
        // 动画完毕后调用animationFinished
        [UIView setAnimationDidStopSelector:@selector(animationFinished)];
        [UIView commitAnimations];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            usleep(600000);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.alphaView setHidden:YES];
                
            });
        });
    });
    [self.view endEditing:YES];
}

-(void)onSlider:(id)sender{
    
}

-(void)onSliderEnd:(id)sender{
    
    UISlider *slider = (UISlider*)sender;
    int iValue = (int)slider.value;
    [slider setValue:iValue];
    self.isLoadingMotionLevel = YES;
    self.lastMotionLevel = self.motionLevel;
    self.motionLevel = 4 - iValue +2;//数据处理
    [self.tableView reloadData];
    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    
    [[P2PClient sharedClient] setMotionLevelWithId:self.contact.contactId password:self.contact.contactPassword level:self.motionLevel];
    DLog(@"%i",iValue);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //[self.textField resignFirstResponder];
    [self.ModifyPasswordView endEditing:YES];
}

-(void)animationFinished{
    //        NSLog(@"动画结束!");
    
}

//温湿度
-(void)onSavePress{
    
    int inputNumber = self.field1.text.intValue;
    if ([self.field1.text isEqualToString:@""])
    {
        [self.view makeToast:NSLocalizedString(@"please_input_number", nil)];
        return;
    }
    else if (self.field1.text.length > 2)
    {
        [self.view makeToast:NSLocalizedString(@"tempe_format_error", nil)];
        return;
    }
    
    self.setTHLimitValue = inputNumber;
    if (self.isTemperatureMax)
    {
        if (self.setTHLimitValue > 65 || self.setTHLimitValue < 5)
        {
            [self.view makeToast:NSLocalizedString(@"input_outnumber_limit", nil)];
            return;
        }
        [[P2PClient sharedClient]setDeviceTHWithId:self.contact.contactId password:self.contact.contactPassword value:self.setTHLimitValue type:0 bLimiteType:1];
        self.temperatureMax = self.field1.text;
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    else if(self.isTemperatureMin)
    {
        if (self.setTHLimitValue > 55 || self.setTHLimitValue < -5)
        {
            [self.view makeToast:NSLocalizedString(@"input_outnumber_limit", nil)];
            return;
        }
        [[P2PClient sharedClient]setDeviceTHWithId:self.contact.contactId password:self.contact.contactPassword value:self.setTHLimitValue type:0 bLimiteType:0];
        self.temperatureMin = self.field1.text;
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:4 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    else if (self.isHumidityMax)
    {
        if (self.setTHLimitValue > 90 || self.setTHLimitValue < 30)
        {
            [self.view makeToast:NSLocalizedString(@"input_outnumber_limit", nil)];
            return;
        }
        [[P2PClient sharedClient]setDeviceTHWithId:self.contact.contactId password:self.contact.contactPassword value:self.setTHLimitValue type:1 bLimiteType:1];
        self.humidityMax = self.field1.text;
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:5 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationTop];
        NSLog(@"湿度上限值范围");
    }
    
    else if (self.isHumidityMin)
    {
        if (self.setTHLimitValue > 70 || self.setTHLimitValue < 10)
        {
            [self.view makeToast:NSLocalizedString(@"input_outnumber_limit", nil)];
            return;
        }
        [[P2PClient sharedClient]setDeviceTHWithId:self.contact.contactId password:self.contact.contactPassword value:self.setTHLimitValue type:1 bLimiteType:0];
        self.humidityMin = self.field1.text;
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:6 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationTop];
        NSLog(@"湿度下限值范围");
    }
    self.alphaView.hidden = YES;
    [self.ModifyPasswordView endEditing:YES];
}


#pragma mark 输入框限制
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 64) {
        textField.text = [textField.text substringToIndex:64];
    }
}


-(void)havetapLeftIconView:(NSInteger)section androw:(NSInteger)row{
    UIAlertView *unBindAccountAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_unbind_account", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    unBindAccountAlert.tag = ALERT_TAG_UNBIND_ALARM_ID;
    self.selectedUnbindAccountIndex = row - 1;
    [unBindAccountAlert show];
    [unBindAccountAlert release];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==3 )
    {
        if (indexPath.row == 0&& !self.isLoadingBindEmail) {
            BindAlarmEmailController *bindAlarmEmailController = [[BindAlarmEmailController alloc] init];
            bindAlarmEmailController.contact = self.contact;
            bindAlarmEmailController.alarmSettingController = self;
            [self.navigationController pushViewController:bindAlarmEmailController animated:YES];
            [bindAlarmEmailController release];
        }
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 3)
        {
            [self sheetViewinit];
            [self animationstart];
            self.isTemperatureMin = NO;
            self.isHumidityMax = NO;
            self.isHumidityMin = NO;
            self.isTemperatureMax = YES;
        }
        else if (indexPath.row == 4)
        {
            [self sheetViewinit];
            [self animationstart];
            self.isTemperatureMax = NO;
            self.isHumidityMax = NO;
            self.isHumidityMin = NO;
            self.isTemperatureMin = YES;
            
        }
        else if (indexPath.row == 5)
        {
            [self sheetViewinit];
            [self animationstart];
            self.isTemperatureMax = NO;
            self.isTemperatureMin = NO;
            self.isHumidityMin = NO;
            self.isHumidityMax = YES;
        }
        else if (indexPath.row == 6)
        {
            [self sheetViewinit];
            [self animationstart];
            self.isTemperatureMax = NO;
            self.isTemperatureMin = NO;
            self.isHumidityMax = NO;
            self.isHumidityMin = YES;
        }
    }
}

/*
 *删除绑定帐号
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_UNBIND_ALARM_ID:
        {
            if(buttonIndex==1){
                
                NSMutableArray *datas = [NSMutableArray arrayWithArray:self.bindIds];
                NSString * str = [datas[self.selectedUnbindAccountIndex] stringValue];
                if ([str isEqualToString:self.contact.contactId]) {
                    self.alarmSwitch.on = NO;
                }
                [datas removeObjectAtIndex:self.selectedUnbindAccountIndex];
                self.lastSetBindIds = [NSMutableArray arrayWithArray:datas];
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                [[P2PClient sharedClient] getBindAccountWithId:self.contact.contactId password:self.contact.contactPassword];
                [self.tableView reloadData];
            }
        }
            break;
    }
}

-(void)onSwitchValueChange:(UISwitch *)sender indexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row==0)
            {
                if(self.motionState==SETTING_VALUE_MOTION_STATE_OFF&&sender.on)
                {
                    self.isLoadingMotionDetect = YES;
                    self.lastMotionState = self.motionState;
                    self.motionState = SETTING_VALUE_MOTION_STATE_ON;
                    [self.tableView reloadData];
                    [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
                }
                else if(self.motionState==SETTING_VALUE_MOTION_STATE_ON&&!sender.on)
                {
                    self.isLoadingMotionDetect = YES;
                    self.lastMotionState = self.motionState;
                    self.motionState = SETTING_VALUE_MOTION_STATE_OFF;
                    [self.tableView reloadData];
                    [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
                }
            }
            else if (indexPath.row==2)
            {
                if (self.soundAlarmState == SETTING_VALUE_SOUND_STATE_OFF && sender.on)//开
                {
                    self.isLoadingSoundAlarm = YES;
                    self.lastSoundAlarmState = self.soundAlarmState;
                    self.soundAlarmState = SETTING_VALUE_SOUND_STATE_ON;
                    [self.tableView reloadData];
                    [[P2PClient sharedClient]setSoundAlarmWithId:self.contact.contactId password:self.contact.contactPassword state:self.soundAlarmState];
                }
                else if (self.soundAlarmState == SETTING_VALUE_SOUND_STATE_ON && !sender.on)//关
                {
                    self.isLoadingSoundAlarm = YES;
                    self.lastSoundAlarmState = self.soundAlarmState;
                    self.soundAlarmState = SETTING_VALUE_SOUND_STATE_OFF;
                    [self.tableView reloadData];
                    [[P2PClient sharedClient]setSoundAlarmWithId:self.contact.contactId password:self.contact.contactPassword state:self.soundAlarmState];
                }
            }
            
            else if (indexPath.row == 3)
            {
                if (self.isSupportHI_WI_WO)
                {
                    if(self.humanInfraredState == SETTING_VALUE_HUMAN_INFRARED_STATE_OFF &&sender.on)
                    {
                        self.isLoadingHumanInfrared = YES;
                        
                        self.lastHumanInfraredState = self.humanInfraredState;
                        self.humanInfraredState = SETTING_VALUE_HUMAN_INFRARED_STATE_ON;
                        [self.tableView reloadData];
                        [[P2PClient sharedClient] setHumanInfraredWithId:self.contact.contactId password:self.contact.contactPassword state:self.humanInfraredState];
                    }
                    else if(self.humanInfraredState == SETTING_VALUE_HUMAN_INFRARED_STATE_ON &&!sender.on)
                    {
                        self.isLoadingHumanInfrared = YES;
                        
                        self.lastHumanInfraredState = self.humanInfraredState;
                        self.humanInfraredState = SETTING_VALUE_HUMAN_INFRARED_STATE_OFF;
                        [self.tableView reloadData];
                        [[P2PClient sharedClient] setHumanInfraredWithId:self.contact.contactId password:self.contact.contactPassword state:self.humanInfraredState];
                    }
                }
                else
                {
                    if(self.wiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF&&sender.on){
                        self.isLoadingWiredAlarmInput = YES;
                        
                        self.lastWiredAlarmInputState = self.wiredAlarmInputState;
                        self.wiredAlarmInputState = SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON;
                        [self.tableView reloadData];
                        [[P2PClient sharedClient] setWiredAlarmInputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmInputState];
                    }else if(self.wiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON&&!sender.on){
                        self.isLoadingWiredAlarmInput = YES;
                        
                        self.lastWiredAlarmInputState = self.wiredAlarmInputState;
                        self.wiredAlarmInputState = SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF;
                        [self.tableView reloadData];
                        [[P2PClient sharedClient] setWiredAlarmInputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmInputState];
                    }
                }
                
            }
            else if (indexPath.row == 4)//有线报警输出
            {
                if(self.wiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF&&sender.on){
                    self.isLoadingWiredAlarmOutput = YES;
                    
                    self.lastWiredAlarmOutputState = self.wiredAlarmOutputState;
                    self.wiredAlarmOutputState = SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON;
                    [self.tableView reloadData];
                    [[P2PClient sharedClient] setWiredAlarmOutputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmOutputState];
                }else if(self.wiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON&&!sender.on){
                    self.isLoadingWiredAlarmOutput = YES;
                    
                    self.lastWiredAlarmOutputState = self.wiredAlarmOutputState;
                    self.wiredAlarmOutputState = SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF;
                    [self.tableView reloadData];
                    [[P2PClient sharedClient] setWiredAlarmOutputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmOutputState];
                }
            }
        }
            break;
        case 1:
        {
            if(indexPath.row==0)
            {
                if(self.temperatureNumState == SETTING_VALUE_LIMIT_TEMPERATURE_OFF &&sender.on)
                {
                    self.isLoadingTempOrHumi = YES;
                    self.lastTemperatureNumState = self.temperatureNumState;
                    self.temperatureNumState = SETTING_VALUE_LIMIT_TEMPERATURE_ON;
                    if (self.nowTemperature < self.temperatureMin || self.temperatureMax < self.nowTemperature)
                    {
                        [[P2PClient sharedClient]setTHAlertWithId:self.contact.contactId password:self.contact.contactPassword state:self.temperatureNumState];
                        [self.tableView reloadData];
                    }
                    
                    else {}
                }
                else if(self.temperatureNumState == SETTING_VALUE_LIMIT_TEMPERATURE_ON &&!sender.on)
                {
                    self.isLoadingTempOrHumi = YES;
                    self.lastTemperatureNumState = self.temperatureNumState;
                    self.temperatureNumState = SETTING_VALUE_LIMIT_TEMPERATURE_OFF;
                    [self.tableView reloadData];
                    [[P2PClient sharedClient]setTHAlertWithId:self.contact.contactId password:self.contact.contactPassword state:self.temperatureNumState];
                }
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0)
            {
                if (self.bindIds.count<self.maxBindIdCount)
                {
                    if(self.alarmState==SETTING_VALUE_ALARM_STATE_OFF&&sender.on)
                    {
                        self.isLoadingAlarmState = YES;
                        
                        self.lastAlarmState = self.alarmState;
                        self.alarmState = SETTING_VALUE_ALARM_STATE_ON;
                        [self.tableView reloadData];
                        LoginResult *loginResult = [UDManager getLoginInfo];
                        [self.bindIds addObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                        self.lastSetBindIds = [NSMutableArray arrayWithArray:self.bindIds];
                        
                        [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                        
                    }
                    else if(self.alarmState==SETTING_VALUE_ALARM_STATE_ON&&!sender.on)
                    {
                        self.isLoadingAlarmState = YES;
                        self.lastAlarmState = self.alarmState;
                        self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
                        [self.tableView reloadData];
                        NSMutableArray *datas = [NSMutableArray arrayWithArray:self.bindIds];
                        LoginResult *loginResult = [UDManager getLoginInfo];
                        [datas removeObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                        self.lastSetBindIds = [NSMutableArray arrayWithArray:datas];
                        [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                    }
                    
                }
                else
                {
                    
                    if(self.alarmState==SETTING_VALUE_ALARM_STATE_OFF&&sender.on)
                    {
                        self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                            [self.view makeToast:[NSString stringWithFormat:@"%@ %i %@",NSLocalizedString(@"add_bind_account_prompt1", nil),self.maxBindIdCount,NSLocalizedString(@"add_bind_account_prompt2", nil)]];
                        });
                        
                        
                    }
                    else if(self.alarmState==SETTING_VALUE_ALARM_STATE_ON&&!sender.on)
                    {
                        self.isLoadingAlarmState = YES;
                        
                        self.lastAlarmState = self.alarmState;
                        self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
                        [self.tableView reloadData];
                        NSMutableArray *datas = [NSMutableArray arrayWithArray:self.bindIds];
                        LoginResult *loginResult = [UDManager getLoginInfo];
                        [datas removeObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                        self.lastSetBindIds = [NSMutableArray arrayWithArray:datas];
                        [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                    }
                }
            }
        }
            break;
        case 4:
        {
            if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_OFF&&sender.on)
            {
                self.isLoadingBuzzer = YES;
                
                self.lastBuzzerState = self.buzzerState;
                self.buzzerState = SETTING_VALUE_BUZZER_STATE_ON_ONE;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
            }
            else if(self.buzzerState!=SETTING_VALUE_BUZZER_STATE_OFF&&!sender.on)
            {
                self.isLoadingBuzzer = YES;
                
                self.lastBuzzerState = self.buzzerState;
                self.buzzerState = SETTING_VALUE_BUZZER_STATE_OFF;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
            }
        }
            break;
            
        case 5:
        {
            if(self.wiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF&&sender.on){
                self.isLoadingWiredAlarmInput = YES;
                
                self.lastWiredAlarmInputState = self.wiredAlarmInputState;
                self.wiredAlarmInputState = SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setWiredAlarmInputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmInputState];
            }else if(self.wiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON&&!sender.on){
                self.isLoadingWiredAlarmInput = YES;
                
                self.lastWiredAlarmInputState = self.wiredAlarmInputState;
                self.wiredAlarmInputState = SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setWiredAlarmInputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmInputState];
            }
        }
            break;
        case 6:
        {
            if(self.wiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF&&sender.on){
                self.isLoadingWiredAlarmOutput = YES;
                
                self.lastWiredAlarmOutputState = self.wiredAlarmOutputState;
                self.wiredAlarmOutputState = SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setWiredAlarmOutputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmOutputState];
            }else if(self.wiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON&&!sender.on){
                self.isLoadingWiredAlarmOutput = YES;
                
                self.lastWiredAlarmOutputState = self.wiredAlarmOutputState;
                self.wiredAlarmOutputState = SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setWiredAlarmOutputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmOutputState];
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)onMotionChange:(UISwitch*)sender{
    if(self.motionState==SETTING_VALUE_MOTION_STATE_OFF&&sender.on){
        self.isLoadingMotionDetect = YES;
        
        self.lastMotionState = self.motionState;
        self.motionState = SETTING_VALUE_MOTION_STATE_ON;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
    }else if(self.motionState==SETTING_VALUE_MOTION_STATE_ON&&!sender.on){
        self.isLoadingMotionDetect = YES;
        
        self.lastMotionState = self.motionState;
        self.motionState = SETTING_VALUE_MOTION_STATE_OFF;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
    }
    
}


-(void)onRadio1Press:(id)sender{
    if(!self.isLoadingBuzzer&&!self.radio1.isSelected){
        [self.radio1 setSelected:YES];
        [self.radio2 setSelected:NO];
        [self.radio3 setSelected:NO];
        self.isLoadingBuzzer = YES;
        [self.tableView reloadData];
        self.lastBuzzerState = self.buzzerState;
        self.buzzerState = SETTING_VALUE_BUZZER_STATE_ON_ONE;
        [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
    }
}

-(void)onRadio2Press:(id)sender{
    if(!self.isLoadingBuzzer&&!self.radio2.isSelected){
        [self.radio1 setSelected:NO];
        [self.radio2 setSelected:YES];
        [self.radio3 setSelected:NO];
        self.isLoadingBuzzer = YES;
        [self.tableView reloadData];
        self.lastBuzzerState = self.buzzerState;
        self.buzzerState = SETTING_VALUE_BUZZER_STATE_ON_TWO;
        [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
        
    }
}
-(void)onRadio3Press:(id)sender{
    if(!self.isLoadingBuzzer&&!self.radio3.isSelected){
        [self.radio1 setSelected:NO];
        [self.radio2 setSelected:NO];
        [self.radio3 setSelected:YES];
        self.isLoadingBuzzer = YES;
        [self.tableView reloadData];
        self.lastBuzzerState = self.buzzerState;
        self.buzzerState = SETTING_VALUE_BUZZER_STATE_ON_THREE;
        [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
        
    }
}

#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, -kbSize.height);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark 键盘将要收起时，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}




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

-(void)animationstart{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    self.ModifyPasswordView.frame = CGRectMake(0, height-height/2, width, height/2);
    
    self.alphaView.frame = CGRectMake(0, 0, width, height);
    
    [UIView setAnimationDelegate:self];
    // 动画完毕后调用animationFinished
    [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    [UIView commitAnimations];
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
    
}

- (void) handlePan: (UIPanGestureRecognizer *)recognizer
{
    //do nothing. write this for shield recognizer in the control's view
}



@end











