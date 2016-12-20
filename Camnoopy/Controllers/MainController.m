

#import "MainController.h"
#import "KeyBoardController.h"
#import "SettingController.h"
#import "RecentController.h"
#import "DiscoverController.h"
#import "ContactController.h"
#import "P2PVideoController.h"
#import "Constants.h"
#import "P2PClient.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "P2PMonitorController.h"
#import "Toast+UIView.h"
#import "P2PCallController.h"
#import "AutoNavigation.h"
#import "GlobalThread.h"
#import "AccountResult.h"
#import "NetManager.h"
#import "AppDelegate.h"
#import "ToolBoxController.h"
#import "CameraManager.h"

@interface MainController ()

@end

@implementation MainController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[P2PClient sharedClient] setDelegate:self];
    [self initComponent];
    LoginResult *loginResult = [UDManager getLoginInfo];
    BOOL result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
    if(result){
        DLog(@"p2pConnect success.");
    }else{
        DLog(@"p2pConnect failure.");

    }
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        while (true) {
//            DLog(@"test thread");
//            sleep(1.0);
//        }
//    });
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initComponent{
    
    //contact
    ContactController *contactController = [[ContactController alloc] init];
    AutoNavigation *controller1 = [[AutoNavigation alloc] initWithRootViewController:contactController];
    
    
    [contactController release];
    
    //keyboard
    
    KeyBoardController *keyBoardController = [[KeyBoardController alloc] init];
    AutoNavigation *controller2 = [[AutoNavigation alloc] initWithRootViewController:keyBoardController];
    [keyBoardController release];
    
    //discover
    ToolBoxController *toolboxController = [[ToolBoxController alloc] init];
    AutoNavigation *controller3 = [[AutoNavigation alloc] initWithRootViewController:toolboxController];
    
    
    [toolboxController release];
    
    //setting
    SettingController *settingController = [[SettingController alloc] init];
    AutoNavigation *controller5 = [[AutoNavigation alloc] initWithRootViewController:settingController];
    
    
    [settingController release];
    
    
    [self setViewControllers:@[controller1,controller2,controller3,controller5]];
    [controller1 release];
    //[controller2 release];
    [controller3 release];
    [controller5 release];
    
    [self setSelectedIndex:0];
//    int i = 0;
//    for(RDVTabBarItem *item in self.tabBar.items){
//        switch(i){
//            case 0:
//            {
//                [item setBackgroundSelectedImage:[UIImage imageNamed:@"ic_tab_contact_p.png"] withUnselectedImage:[UIImage imageNamed:@"ic_tab_contact.png"]];
//                
//            }
//            break;
//            case 1:
//            {
//                [item setBackgroundSelectedImage:[UIImage imageNamed:@"ic_tab_keyboard_p.png"] withUnselectedImage:[UIImage imageNamed:@"ic_tab_keyboard.png"]];
//            }
//            break;
//            case 2:
//            {
//                [item setBackgroundSelectedImage:[UIImage imageNamed:@"ic_tab_discover_p.png"] withUnselectedImage:[UIImage imageNamed:@"ic_tab_discover.png"]];
//            }
//            break;
//            case 3:
//            {
//                [item setBackgroundSelectedImage:[UIImage imageNamed:@"ic_tab_recent_p.png"] withUnselectedImage:[UIImage imageNamed:@"ic_tab_recent.png"]];
//            }
//            break;
//            case 4:
//            {
//                [item setBackgroundSelectedImage:[UIImage imageNamed:@"ic_tab_setting_p.png"] withUnselectedImage:[UIImage imageNamed:@"ic_tab_setting.png"]];
//            }
//            break;
//        }
//        
//        
//        i++;
//    }
    
    
    
}


-(void)setUpCallWithId:(NSString *)contactId password:(NSString *)password callType:(P2PCallType)type{
    [[P2PClient sharedClient] setIsBCalled:NO];
    [[P2PClient sharedClient] setCallId:contactId];
    [[P2PClient sharedClient] setP2pCallType:type];
    [[P2PClient sharedClient] setCallPassword:password];

    if(!self.presentedViewController){
        
        P2PCallController *p2pCallController = [[P2PCallController alloc] init];
        p2pCallController.contactName = self.contactName;
        
        AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
        [self presentViewController:controller animated:YES completion:^{
            
        }];
        [p2pCallController release];
        [controller release];
        //[[P2PClient sharedClient] p2pCallWithId:contactId password:password callType:type];
    }
}

-(void)setUpCallWithId:(NSString *)contactId address:(NSString*)address password:(NSString *)password callType:(P2PCallType)type{
    [[P2PClient sharedClient] setIsBCalled:NO];
    [[P2PClient sharedClient] setCallId:contactId];
    [[P2PClient sharedClient] setP2pCallType:type];
    [[P2PClient sharedClient] setCallPassword:password];

    if(!self.presentedViewController){
        
        P2PCallController *p2pCallController = [[P2PCallController alloc] init];
        [p2pCallController setAddress:address];
        AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
        [self presentViewController:controller animated:YES completion:^{
            
        }];
        [p2pCallController release];
        [controller release];
        //[[P2PClient sharedClient] p2pCallWithId:contactId password:password callType:type];
    }
}


-(void)P2PClientCalling:(NSDictionary*)info{
    DLog(@"P2PClientCalling");
    BOOL isBCalled = [[P2PClient sharedClient] isBCalled];
    NSString *callId = [[P2PClient sharedClient] callId];
    if(isBCalled){
        if([[AppDelegate sharedDefault] isGoBack]){
            UILocalNotification *alarmNotify = [[[UILocalNotification alloc] init] autorelease];
            alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
            alarmNotify.soundName = @"default";
            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:Calling!",callId];
            alarmNotify.applicationIconBadgeNumber = 1;
            alarmNotify.alertAction = @"打开";
            [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
            return;
        }
        
        if(!self.isShowP2PView){
            self.isShowP2PView = YES;
            UIViewController *presentView1 = self.presentedViewController;
            UIViewController *presentView2 = self.presentedViewController.presentedViewController;
            if(presentView2){
                [self dismissViewControllerAnimated:YES completion:^{
                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                    
                    [self presentViewController:controller animated:YES completion:^{
                        
                    }];
                    
                    [p2pCallController release];
                    [controller release];
                }];
            }else if(presentView1){
                [presentView1 dismissViewControllerAnimated:YES completion:^{
                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                    
                    [self presentViewController:controller animated:YES completion:^{
                        
                    }];
                    
                    [p2pCallController release];
                    [controller release];
                }];
            }else{
                P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                
                [self presentViewController:controller animated:YES completion:^{
                    
                }];
                
                [p2pCallController release];
                [controller release];
            }
            
            
        }
        
    }
}

-(void)dismissP2PView{
    UIViewController *presentView1 = self.presentedViewController;
    UIViewController *presentView2 = self.presentedViewController.presentedViewController;
    if(presentView2){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [presentView1 dismissViewControllerAnimated:YES completion:nil];
    }
    self.isShowP2PView = NO;
}

-(void)dismissP2PView:(void (^)())callBack{
    UIViewController *presentView1 = self.presentedViewController;
    UIViewController *presentView2 = self.presentedViewController.presentedViewController;
    if(presentView2){
        [self dismissViewControllerAnimated:YES completion:^{
            callBack();
        }];
    }else if(presentView1){
        [presentView1 dismissViewControllerAnimated:YES completion:^{
            callBack();
        }];
    }else{
        callBack();
    }
    self.isShowP2PView = NO;
}

-(void)P2PClientReject:(NSDictionary*)info{
    DLog("P2PClientReject");
    

    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATE_NONE];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        usleep(500000);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [self dismissP2PView];
            
            
            int errorFlag = [[info objectForKey:@"errorFlag"] intValue];
            switch(errorFlag)
            {
                case CALL_ERROR_NONE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_unknown_error", nil)];
                    break;
                }
                case CALL_ERROR_DESID_NOT_ENABLE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_disabled", nil)];
                    break;
                }
                case CALL_ERROR_DESID_OVERDATE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_overdate", nil)];
                    break;
                }
                case CALL_ERROR_DESID_NOT_ACTIVE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_inactived", nil)];

                    break;
                }
                case CALL_ERROR_DESID_OFFLINE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_offline", nil)];

                    break;
                }
                case CALL_ERROR_DESID_BUSY:
                {
                    [self.view makeToast:NSLocalizedString(@"id_busy", nil)];

                    break;
                }
                case CALL_ERROR_DESID_POWERDOWN:
                {
                    [self.view makeToast:NSLocalizedString(@"id_powerdown", nil)];

                    break;
                }
                case CALL_ERROR_NO_HELPER:
                {
                    [self.view makeToast:NSLocalizedString(@"id_connect_failed", nil)];

                    break;
                }
                case CALL_ERROR_HANGUP:
                {
                    [self.view makeToast:NSLocalizedString(@"id_hangup", nil)];

                    break;
                }
                case CALL_ERROR_TIMEOUT:
                {
                    [self.view makeToast:NSLocalizedString(@"id_timeout", nil)];

                    break;
                }
                case CALL_ERROR_INTER_ERROR:
                {
                    [self.view makeToast:NSLocalizedString(@"id_internal_error", nil)];

                    break;
                }
                case CALL_ERROR_RING_TIMEOUT:
                {
                    [self.view makeToast:NSLocalizedString(@"id_no_accept", nil)];

                    break;
                }
                case CALL_ERROR_PW_WRONG:
                {
                    [self.view makeToast:NSLocalizedString(@"id_password_error", nil)];

                    break;
                }
                case CALL_ERROR_NOT_SUPPORT:
                {
                    [self.view makeToast:NSLocalizedString(@"id_not_support", nil)];
                    break;
                }
                case CALL_ERROR_CONN_FAIL:
                {
                    [self.view makeToast:NSLocalizedString(@"id_connect_failed", nil)];
                    break;
                }
                default:
                    [self.view makeToast:NSLocalizedString(@"id_unknown_error", nil)];

                    break;
            }
        });
    });
    
    
    
    
}


-(void)P2PClientAccept:(NSDictionary*)info{
    DLog(@"P2PClientAccept");
}

-(void)P2PClientReady:(NSDictionary*)info{
    DLog(@"P2PClientReady");
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STET_READY];
    
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_MONITOR){
        P2PMonitorController *monitorController = [[P2PMonitorController alloc] init];
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:monitorController animated:YES completion:nil];
        }else{
            [self presentViewController:monitorController animated:YES completion:nil];
        }
        
        [monitorController release];
    }else if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO){
        P2PVideoController *videoController = [[P2PVideoController alloc] init];
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:videoController animated:YES completion:nil];
        }else{
            [self presentViewController:videoController animated:YES completion:nil];
        }
        
        [videoController release];
    }
    
    
}

@end
