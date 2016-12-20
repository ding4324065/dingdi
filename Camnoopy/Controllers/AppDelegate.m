
#define sqlitename @"SHIELDIDDATA.sqlite"
#import "AppDelegate.h"
#import "UDManager.h"
#import "LoginController.h"
#import "Constants.h"
#import "AutoNavigation.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "NetManager.h"
#import "AccountResult.h"
#import "MainLoginController.h"
#import "Reachability.h"
#import "Message.h"
#import "Utils.h"
#import "MessageDAO.h"
#import "FListManager.h"
#import "CheckNewMessageResult.h"
#import "GetContactMessageResult.h"
#import "CheckAlarmMessageResult.h"
#import "ContactDAO.h"
#import "GlobalThread.h"
#import "Contact.h"
#import "Toast+UIView.h"
#import "UncaughtExceptionHandler.h"
#import "Alarm.h"
#import "AlarmDAO.h"
#import "UDPManager.h"
#import "AlarmPushController.h"
#import "WelcomViewController.h"
#import "shieldDao.h"
#import <UserNotifications/UserNotifications.h>
#define ALERT_TAG_APP_UPDATE 2

@implementation AppDelegate
#pragma mark - 返回三种类型的rect，分别是水平、7.0和其他情况
+(CGRect)getScreenSize:(BOOL)isNavigation isHorizontal:(BOOL)isHorizontal{
    CGRect rect = [UIScreen mainScreen].bounds;
    
    if(isHorizontal){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
    }
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-20);
    }
    return rect;
}

+ (AppDelegate *)sharedDefault
{
    return [UIApplication sharedApplication].delegate;
}

+(NSString*)getAppVersion{
    return [NSString stringWithFormat:APP_VERSION];
}

-(void)dealloc{
    [self.window release];
    [self.mainController release];
    [super dealloc];
}

- (void) reachabilityChanged:(NSNotification *)note
{
//    检测网络是否可用
    Reachability* curReach = [note object];
//    断言评估一个条件，如果条件为 false ，调用当前线程的断点句柄
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    self.networkStatus = [curReach currentReachabilityStatus];
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
    [parameter setObject:[NSNumber numberWithInt:self.networkStatus] forKey:@"status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NET_WORK_CHANGE
                                                        object:self
                                                      userInfo:parameter];
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskAll;
}
- (void)versionbutton
{
    //获取当前APP的版本号
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *nowVersion = [infoDict objectForKey:@"CFBundleVersion"];
    
    NSString *appleID = @"818973697";
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@",appleID];

    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ( [data length] > 0 && !error ) { // Success
            
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // All versions that have been uploaded to the AppStore
                NSArray *versionsInAppStore = [[appData valueForKey:@"results"] valueForKey:@"version"];
                
                if ( ![versionsInAppStore count] ) { // No versions of app in AppStore
                    
                    return;
                    
                } else {
                    //已经上架的APP的版本号
                    NSString *versionInAppStore = [versionsInAppStore objectAtIndex:0];

                    /*
                     *1. 不相等，说明有可更新的APP。此方式导致审核被拒绝，因为新版本与已发布版本不相等，弹出了更新提示框。
                     *2. “不相等”方式改为“小于”，再提示更新，只有上架的APP，才可检测更新并弹框。不过此方式只针对此类版本号（1或1.1），不适合此类版本号（1.1.1或1.1.1.x）
                     *3. 不过1.1~1.9，1.1~9.1，有81种，足够多的版本
                     *4. 改进1，若是1.1与1.1.1的比较（不同类比较），可以通过版本号的长度来提示更新，长度小于则提示。
                     *5. 改进2，若是1.1.1与1.1.2（即长度>=5）的比较（同类比较），取最后3位比较。
                     */
                    if([nowVersion floatValue] < [versionInAppStore floatValue]){
                        NSString *message=[[NSString alloc] initWithFormat:@"%@%@%@",NSLocalizedString(@"can_update_to", nil),versionInAppStore,NSLocalizedString(@"version", nil)];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"update", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"next_time", nil)  otherButtonTitles:NSLocalizedString(@"update_now", nil), nil];
                        alert.tag = ALERT_TAG_APP_UPDATE;
                        [alert show];
                        [alert release];
                    }
                }
                
            });
        }
        
    }];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case ALERT_TAG_APP_UPDATE://app检查更新
        {
            if(buttonIndex == 1){
                
                dispatch_after(0.2, dispatch_get_main_queue(), ^{
                    NSString *appleID = @"818973697";
                    
                    NSString *str = [NSString stringWithFormat:
                                     @"itms-apps://itunes.apple.com/gb/app/yi-dong-cai-bian/id%@?mt=8",appleID];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                });
            }
        }
        
            break;
    }
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    app版本更新提示
    [self versionbutton];
    
    
    NSLog(@"%@",launchOptions);
    
    [[UDPManager sharedDefault] ScanLanDevice];
    
    
    if (CURRENT_VERSION >=10.0 ){
        UNUserNotificationCenter *cencer = [UNUserNotificationCenter currentNotificationCenter];
        cencer.delegate = self;
        [cencer requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        if (!error) {
                NSLog(@"request authorization succeeded!");
                            [[UIApplication sharedApplication] registerForRemoteNotifications];
                            [cencer getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                                NSLog(@"%@",settings);
                            }];
            }
        }];
        
    }

    else if(CURRENT_VERSION>=8.0)
    {
        //8.0以后使用这种方法来注册推送通知
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    }
    
    //InstallUncaughtExceptionHandler();
    //[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
//    接收远程消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
//    确认_接收远程消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
//    操作id错误
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSessionIdError:) name:NOTIFICATION_ON_SESSION_ERROR object:nil];
//    正在接收的报警消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveAlarmMessage:) name:RECEIVE_ALARM_MESSAGE object:nil];
    [AppDelegate getAppVersion];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.networkStatus = ReachableViaWWAN;
//    网络是否可用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSString *remoteHostName = @"www.baidu.com";
    
    
    [[Reachability reachabilityWithHostName:remoteHostName] startNotifier];
    
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSInteger intertime =  [manager integerForKey:@"Local alarm interval"];
    if (intertime == 0)
    {
        [manager setInteger:10 forKey:@"Local alarm interval"];
    }
    
#pragma mark - 首次进入欢迎页(一次显示)
    BOOL isNotFirstLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"ISNOTFIRSTLOGIN"];
//    首次登陆
    if (!isNotFirstLogin)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ISNOTFIRSTLOGIN"];
        WelcomViewController *welcomeController = [[WelcomViewController alloc]init];
        AutoNavigation *mainController = [[AutoNavigation alloc]initWithRootViewController:welcomeController];
        self.window.rootViewController = mainController;
        [welcomeController release];
        [mainController release];
    }
    else
    {
        if([UDManager isLogin])//已经登陆
        {
            
            MainContainer* mainController = [[MainContainer alloc]init];
            self.mainController = mainController;
            self.window.rootViewController = self.mainController;
            [mainController release];
            LoginResult *loginResult = [UDManager getLoginInfo];
            [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
                
                AccountResult *accountResult = (AccountResult*)JSON;
                if(accountResult.error_code==NET_RET_GET_ACCOUNT_SUCCESS){
                    loginResult.email = accountResult.email;
                    loginResult.phone = accountResult.phone;
                    loginResult.countryCode = accountResult.countryCode;
                    [UDManager setLoginInfo:loginResult];
                }
            }];
        }
        
        else//没登陆
        {
            
            LoginController *loginController = [[LoginController alloc] init];
            AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
            self.window.rootViewController = mainController;
            [loginController release];
            [mainController release];
            
        }
    }
    
    self.currentShowAlarmId = @"";
    self.iCurrentShowAlarmType = -1;
    [self.window makeKeyAndVisible];
    
    return YES;
}


-(void)onSessionIdError:(id)sender{
    [UDManager setIsLogin:NO];
    
    [[GlobalThread sharedThread:NO] kill];
    [[FListManager sharedFList] setIsReloadData:YES];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    LoginController *loginController = [[LoginController alloc] init];
    loginController.isSessionIdError = YES;
    AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
    
    [AppDelegate sharedDefault].window.rootViewController = mainController;
    [loginController release];
    [mainController release];
    
#pragma mark - app将返回登陆界面时，注册新的token 登录时传给服务器
    [[AppDelegate sharedDefault] reRegisterForRemoteNotifications];
    
    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
    dispatch_async(queue, ^{
        [[P2PClient sharedClient] p2pDisconnect];
        DLog(@"p2pDisconnect.");
    });
}
#pragma mark - 报警类型
- (void)onReceiveAlarmMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    
    NSString *contactId   = [parameter valueForKey:@"contactId"];
    NSString *contanctPassword = [parameter valueForKey:@"contactPassword"];
    int type   = [[parameter valueForKey:@"type"] intValue];
    NSLog(@"type==%d",type);
    int group = [[parameter valueForKey:@"group"] intValue];
    NSLog(@"group==%d",group);
    int item = [[parameter valueForKey:@"item"] intValue];
    NSLog(@"item==%d",item);
    
    NSString *typeStr = @"";
    switch(type){
        case 1:
        {
//            外部报警
            typeStr = NSLocalizedString(@"extern_alarm", nil);
        }
            break;
        case 2:
        {
//            移动侦测
            typeStr = NSLocalizedString(@"motion_dect_alarm", nil);
        }
            break;
        case 3:
        {
//            紧急报警
            typeStr = NSLocalizedString(@"emergency_alarm", nil);
        }
            break;
        case 5:
        {
//            有线报警
            typeStr = NSLocalizedString(@"ext_line_alarm", nil);
        }
            break;
        case 6:
        {
//            低电压报警
            typeStr = NSLocalizedString(@"low_vol_alarm", nil);
        }
            break;
        case 7:
        {
//            人体红外报警
            typeStr = NSLocalizedString(@"pir_alarm", nil);
        }
            break;
        case 12:
        {
//            温湿度报警
            typeStr = NSLocalizedString(@"TH_alert", nil);
        }
            break;
        case 13://门铃报警类型
        {
            typeStr = NSLocalizedString(@"somebody_visit", nil);
        }
            break;
        case 33://声音报警
        {
            typeStr = NSLocalizedString(@"sound_alarm", nil);
        }
            break;
        default:
        {
            //未知类型
            typeStr = [NSString stringWithFormat:@"%d",type];
        }
            break;
    }
    
    //当前是否有设备正在连接
    P2PCallState p2pCallState = [[P2PClient sharedClient] p2pCallState];
    BOOL isCanShow = NO;
    if(p2pCallState==P2PCALL_STATE_NONE){
        isCanShow = YES;
    }else{
        isCanShow = NO;
    }
    //    BOOL ishaveline = NO;
    
    //是否已经屏蔽该设备(更新的)
    shieldDao* dao = [[shieldDao alloc]init];
    BOOL isShield = [dao isShield:contactId];
    [dao release];
    
    if (isShield) {
        return;
    }
    
    
    //发送通知，contact界面更新提示
    self.iAlarmLogCount ++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNewAlarmLog"
                                                        object:self
                                                      userInfo:nil];
    //如果后台运行，则发送本地通知
    if(self.isGoBack){
        UILocalNotification *alarmNotify = [[[UILocalNotification alloc] init] autorelease];
        alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
//  设置时区，使用本地时区
        alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
 // 设置提示音
        alarmNotify.soundName = @"default";
// 设置提示的文字
        alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,typeStr];
//   这个通知到时间时，你的应用程序右上角显示的数字. 获取当前的数字+1
        alarmNotify.applicationIconBadgeNumber = 1;
        alarmNotify.alertAction = NSLocalizedString(@"view", nil);
//    启用这个通知
        [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
    
        
    }
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSInteger intertime =  [manager integerForKey:@"Local alarm interval"];
    //上一次与当前推送的时间间隔,超过设置的秒数，则弹出推送框
    BOOL isTimeAfter = NO;
    if(([Utils getCurrentTimeInterval]-self.lastShowAlarmTimeInterval)>intertime){
        isTimeAfter = YES;
    }
    
    //弹出推送提示框，一是门铃推送，二是其他
    if(isTimeAfter&&!self.isGoBack)
    {//alarmAlertview   isCanShow&&
        dispatch_async(dispatch_get_main_queue(), ^{
            if (type == 13 && isCanShow)
            {//为门铃推送,isCanShow为YES表示不在监控中...
                self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
            }
            else
            {//为其他推送
                if (type == 13 && !isCanShow)
                {//为门铃推送,isCanShow为NO表示在监控中...
                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
                }
                else
                {
                    self.isDoorBellAlarm = NO;//在监控界面使用,区分门铃推送，其他推送
                }
            }
        });
    }
    
    BOOL isConnectting = ([[P2PClient sharedClient] p2pCallState] != P2PCALL_STATE_NONE);
    BOOL isNewAlarmInfo = (self.iCurrentShowAlarmType != type) || (![self.currentShowAlarmId isEqualToString:contactId]);
    if(isNewAlarmInfo &&  //当前没有显示报警提示界面
       !isConnectting &&        //没有设备正在连接
       isTimeAfter              //时间间隔
       )
    {
        if (self.iCurrentShowAlarmType != -1) {
            NSLog(@"post message");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateAlarmInformation"
                                                                object:self
                                                              userInfo:parameter];
        }
        else
        {
            NSLog(@"pop controller");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainController popAlarmWithType:type contactId:contactId password:contanctPassword group:group item:item];
            });
        }
        self.iCurrentShowAlarmType = type;
        self.currentShowAlarmId = contactId;
        //        NSLog(@"01 self.currentShowAlarmId = %@, self.iCurrentShowAlarmType = %d", self.currentShowAlarmId, self.iCurrentShowAlarmType);
    }
    
}

-(void)initsqlite{
    if([self openDB]){
        char *errMsg;
        
        if(sqlite3_exec(self.db, [[self getCreateTableString] UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
            NSLog(@"Table Contact failed to create.");
            sqlite3_free(errMsg);
        }
        [self closeDB];
    }
}

-(NSString *)getCreateTableString{
    return @"CREATE TABLE IF NOT EXISTS SHIELDIDDATA(ID INTEGER PRIMARY KEY AUTOINCREMENT,shieldID Text)";
}

-(NSString*)dbPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:sqlitename];
    return path;
}
-(BOOL)openDB{
    BOOL result = NO;
    if(sqlite3_open([[self dbPath] UTF8String], &_db)==SQLITE_OK){
        result = YES;
    }else{
        result = NO;
        NSLog(@"Failed to open database");
    }
    
    return result;
}

-(BOOL)closeDB{
    if(sqlite3_close(self.db)==SQLITE_OK){
        return YES;
    }else{
        return NO;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_ALARMING:
        {
            
            if(buttonIndex==0){
                ContactDAO *contactDAO = [[ContactDAO alloc] init];
                Contact *contact = [contactDAO isContact:self.alarmContactId];
                
                if(nil!=contact){
                    [[P2PClient sharedClient] p2pHungUp];
                    [self.mainController dismissP2PView:^{
                        [self.mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
                        self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                        self.isShowAlarmTip = NO;
                    }];
                    
                }else{
                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                    passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    inputAlert.tag = ALERT_TAG_MONITOR;
                    [inputAlert show];
                    [inputAlert release];
                }
            }else{
                self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                self.isShowAlarmTip = NO;
            }
        }
            break;
        case ALERT_TAG_MONITOR:
        {
            
            if(buttonIndex==1){
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                
                NSString *inputPwd = passwordField.text;
                if(!inputPwd||inputPwd.length==0){
                    [self.mainController.view makeToast:NSLocalizedString(@"input_device_password", nil)];
                    self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                    self.isShowAlarmTip = NO;
                    return;
                }
                [[P2PClient sharedClient] p2pHungUp];
                [self.mainController dismissP2PView:^{
                    [self.mainController setUpCallWithId:self.alarmContactId password:inputPwd callType:P2PCALL_TYPE_MONITOR];
                    self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                    self.isShowAlarmTip = NO;
                }];
                
                
            }
            self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
            self.isShowAlarmTip = NO;
        }
            break;
    }
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_RECEIVE_MESSAGE:
        {
        }
            break;
            
        case RET_GET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            NSString *contactId = [parameter valueForKey:@"contactId"];
            if(state==SETTING_VALUE_REMOTE_DEFENCE_STATE_ON){
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_ON];
            }else{
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_OFF];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                    object:self
                                                                  userInfo:nil];
            });
            DLog(@"RET_GET_NPCSETTINGS_REMOTE_DEFENCE");
        }
            break;
            
        case RET_SET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            NSString *contactId = [parameter valueForKey:@"contactId"];
            if(state==SETTING_VALUE_REMOTE_DEFENCE_STATE_ON){
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_ON];
            }else{
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_OFF];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage" object:nil];
            });
        }
            break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    NSString *contactId = [parameter valueForKey:@"contactId"];
    switch(key){
        case ACK_RET_SEND_MESSAGE:
        {
                        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                int flag = [[parameter valueForKey:@"flag"] intValue];
                MessageDAO *messageDAO = [[MessageDAO alloc] init];
                if(result==0){
                    [messageDAO updateMessageStateWithFlag:flag state:MESSAGE_STATE_NO_READ];
                }else{
                    [messageDAO updateMessageStateWithFlag:flag state:MESSAGE_STATE_SEND_FAILURE];
                }
                [messageDAO release];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                        object:self
                                                                      userInfo:nil];
                });
            });
            
            
            DLog(@"ACK_RET_GET_DEVICE_TIME:%i",result);
        }
            break;
        case ACK_RET_GET_DEFENCE_STATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //                NSString *contactId = @"10000";
                if(result==1){
                    
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"device_password_error", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if(result==2){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"net_exception", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if (result==4){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"no_permission", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }
                
                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
                
            });
            
            DLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
//                    设备密码错误
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"device_password_error", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if(result==2){
//                    请检查设备联网状况
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"net_exception", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if (result==4){
//                    权限不足
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"no_permission", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }
                
                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
                
            });
            DLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
        }
            break;
            
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken
{
    
    
    DLog(@"%@",pToken);
    NSString *deviceToken = [[pToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    //注册成功，将deviceToken保存到应用服务器数据库中
    DLog(@"%@",deviceToken);
    
    self.token = [NSString stringWithFormat:@"%@",deviceToken];
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"%@%@",@"didFailToRegisterForRemoteNotificationsWithError:",[error localizedDescription]);
    
    
}
#pragma  mark - ios10以前获取用户的信息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // 处理推送消息
    NSLog(@"userinfo:%@",userInfo);
    NSArray *allKeys = [userInfo allKeys];
    for (NSString *aString in allKeys) {
        DLog(@"id %@ content is %@", aString, userInfo[aString]);
    }
    NSLog(@"收到推送消息:%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    
}

#pragma mark - ios10新特性 app在前台获取通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题wo
    
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@",userInfo);
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
        //        需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
}

#pragma  mark - iOS10新特性 点击通知进入app

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    
}


-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    DLog(@"%@",notification.alertBody);
    [Utils playMusicWithName:@"message" type:@"mp3"];
}

UIBackgroundTaskIdentifier backgroundTask;
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLog(@"applicationDidEnterBackground");
    
    
    [[P2PClient sharedClient] p2pHungUp];
    [self.mainController dismissP2PView];
    
    
    
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier taskID = 0;
    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
        [[P2PClient sharedClient] p2pDisconnect];
        [app endBackgroundTask:taskID];
    }];
    
    if (taskID == UIBackgroundTaskInvalid) {
        [[P2PClient sharedClient] p2pDisconnect];
        NSLog(@"Failed to start background task!");
        return;
    }
    
    self.isGoBack = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self.isGoBack) {
            DLog(@"run background");
            sleep(1.0);
            
        }
    });
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DLog(@"applicationWillEnterForeground");
    self.isGoBack = NO;
    if([UDManager isLogin]){
        application.applicationIconBadgeNumber = 0;
        LoginResult *loginResult = [UDManager getLoginInfo];
        BOOL result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
        if(result){
            DLog(@"p2pConnect success.");
        }else{
            DLog(@"p2pConnect failure.");
        }
        
        [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
            AccountResult *accountResult = (AccountResult*)JSON;
            loginResult.email = accountResult.email;
            loginResult.phone = accountResult.phone;
            loginResult.countryCode = accountResult.countryCode;
            [UDManager setLoginInfo:loginResult];
        }];
        
        [[NetManager sharedManager] checkAlarmMessage:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
            CheckAlarmMessageResult *checkAlarmMessageResult = (CheckAlarmMessageResult*)JSON;
            if(checkAlarmMessageResult.error_code==NET_RET_CHECK_ALARM_MESSAGE_SUCCESS){
                if(checkAlarmMessageResult.isNewAlarmMessage){
                    DLog(@"have new");
                }
            }else{
                
            }
        }];
    }
}

#pragma mark - APP将返回登录界面时，注册新的token，登录时传给服务器
-(void)reRegisterForRemoteNotifications{
    if (CURRENT_VERSION>=9.3) {
        if(CURRENT_VERSION>=8.0){//8.0以后使用这种方法来注册推送通知
            if(CURRENT_VERSION>=10.0){
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (!error) {
                        NSLog(@"request authorization succeeded!");
                    }
                }];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                
                
            }
            else{
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                [[UIApplication sharedApplication] registerForRemoteNotifications];
                
            }
            
        }else{
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
        }
    }
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
