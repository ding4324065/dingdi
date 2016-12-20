//
//  MainContainer.m
//  Camnoopy
//
//  Created by wutong on 15-1-6.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "MainContainer.h"
#import "MainMenu.h"
#import "ContactController.h"
#import "AutoNavigation.h"
#import "P2PClient.h"
#import "P2PCallController.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "P2PMonitorController.h"
#import "P2PVideoController.h"
#import "KeyBoardController.h"
#import "ScreenshotController.h"
#import "AlarmHistoryController.h"
#import "AboutViewController.h"
#import "GlobalThread.h"
#import "FListManager.h"
#import "LoginController.h"
//#import "P2PRemotePlayListController.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "maskView.h"
#import "AccountController.h"
#import "AlarmPushController.h"
#import "AccountAlarmSetController.h"
#import "PlaybackTypeController.h"
#import "SysSettingsViewController.h"
#import "HelpViewController.h"

@interface MainContainer () 
{
    UIViewController*   _topViewController;
    MainMenu*   _mainMenu;
    maskView* _maskView;
}
@end

@implementation MainContainer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftMenuCommand:) name:SHOW_LEFTMENU_CMD object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHOW_LEFTMENU_CMD object:nil];
}

- (void)showLeftMenuCommand:(NSNotification *)notification{
    [self showLeftMenu:YES];
}


-(void)loadView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    UIView* view = [[UIView alloc]initWithFrame:frame];
#pragma mark - 侧滑菜单背景
    UIImage* backImg = [UIImage imageNamed:@"background2"];
    UIImageView* imgView = [[UIImageView alloc]initWithImage:backImg];
    [imgView setFrame:frame];
    [view addSubview:imgView];
    [imgView release];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[P2PClient sharedClient] setDelegate:self];
    LoginResult *loginResult = [UDManager getLoginInfo];
    BOOL result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
    if(result)
    {
        DLog(@"p2pConnect success.");
    }
    else
    {
        DLog(@"p2pConnect failure.");
    }
    
    //mainmenu
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(0, 0, screenSize.width*2/3, screenSize.height);
    _mainMenu = [[MainMenu alloc]initWithFrame:frame];
    //    _mainMenu.backgroundColor = [UIColor orangeColor];
    _mainMenu.delegate = self;
    [self.view addSubview:_mainMenu];
    [_mainMenu release];
    
    //controller-我的设备
    ContactController *contactController = [[ContactController alloc] init];
    AutoNavigation* controller1 = [[AutoNavigation alloc] initWithRootViewController:contactController];
    [contactController release];
    
    //controller-远程回放
//    P2PRemotePlayListController* controller2 = [[P2PRemotePlayListController alloc]init];
    PlaybackTypeController *controller2  = [[PlaybackTypeController alloc]init];
    //controller-查看截图
    ScreenshotController *controller3 = [[ScreenshotController alloc] init];
    //controller-报警记录
    AlarmHistoryController *controller4 = [[AlarmHistoryController alloc] init];
    //controller-报警管理
    AccountAlarmSetController *controller5 = [[AccountAlarmSetController alloc] init];
 
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //系统设置
//        SysSettingsViewController *controller6 = [[SysSettingsViewController alloc] init];
        //    帮助
        HelpViewController *controller6 = [[HelpViewController alloc] init];
        AboutViewController* controller7 = [[AboutViewController alloc]init];
        //controller-关于
        AboutViewController* controller8 = [[AboutViewController alloc]init];
        //controller-账号信息
        AccountController * controller9= [[AccountController alloc] init];

        NSArray* arrayController = [[NSArray alloc]initWithObjects:controller1, controller2, controller3, controller4, controller5,controller6,controller7,controller8,controller9, nil];
        for (int i=0; i<9; i++)
        {
            UIViewController* viewController = [arrayController objectAtIndex:i];
            //滑动手势
            UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
            [viewController.view addGestureRecognizer:pan];
            [pan release];
        }
        [arrayController release];
        
        [self addChildViewController:controller1];
        [self addChildViewController:controller2];
        [self addChildViewController:controller3];
        [self addChildViewController:controller4];
        [self addChildViewController:controller5];
        [self addChildViewController:controller6];
        [self addChildViewController:controller7];
        [self addChildViewController:controller8];
        [self addChildViewController:controller9];
        [controller1 release];
        [controller2 release];
        [controller3 release];
        [controller4 release];
        [controller5 release];
        [controller6 release];
        [controller7 release];
        [controller8 release];
        [controller9 release];
    }
    else
    {
        //系统设置
        SysSettingsViewController *controller6 = [[SysSettingsViewController alloc] init];
        //    帮助
        HelpViewController *controller7 = [[HelpViewController alloc] init];
        AboutViewController* controller8 = [[AboutViewController alloc]init];
        //controller-关于
        AboutViewController* controller9 = [[AboutViewController alloc]init];
        //controller-账号信息
        AccountController * controller10= [[AccountController alloc] init];

        NSArray* arrayController = [[NSArray alloc]initWithObjects:controller1, controller2, controller3, controller4, controller5,controller6,controller7,controller8,controller9,controller10, nil];
        for (int i=0; i<10; i++)
        {
            UIViewController* viewController = [arrayController objectAtIndex:i];
            //滑动手势
            UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
            [viewController.view addGestureRecognizer:pan];
            [pan release];
        }
        [arrayController release];
        
        [self addChildViewController:controller1];
        [self addChildViewController:controller2];
        [self addChildViewController:controller3];
        [self addChildViewController:controller4];
        [self addChildViewController:controller5];
        [self addChildViewController:controller6];
        [self addChildViewController:controller7];
        [self addChildViewController:controller8];
        [self addChildViewController:controller9];
        [self addChildViewController:controller10];
        [controller1 release];
        [controller2 release];
        [controller3 release];
        [controller4 release];
        [controller5 release];
        [controller6 release];
        [controller7 release];
        [controller8 release];
        [controller9 release];
        [controller10 release];
    }
    

    [self.view addSubview:controller1.view];
    _topViewController = controller1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 滑动手势
- (void) handlePan: (UIPanGestureRecognizer *)recognizer
{
    static int pos = 0;
    static int arrayFlag[2] = {0};
    
    CGPoint point = [recognizer translationInView:self.view];
    arrayFlag[pos] = point.x;
    pos = !pos;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    
    if ((recognizer.view.center.x + point.x) < screenSize.width/2)
    {
        if (recognizer.view.center.x != self.view.center.x ||
            recognizer.view.center.y != self.view.center.y) {
            [self showLeftMenu:TRUE];
        }
        return;
    }
    
    CGPoint pointx = _topViewController.view.center;
    float menuShowRate = (pointx.x - screenSize.width/2)/(screenSize.width*2/3);
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + point.x, recognizer.view.center.y);
    //    recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1-0.3*menuShowRate, 1-0.3*menuShowRate);
    recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    _mainMenu.alpha = menuShowRate;
    
    {
        CGAffineTransform transform=_mainMenu.transform;
        transform=CGAffineTransformScale(CGAffineTransformIdentity, 0.7+0.3*menuShowRate, 0.7+0.3*menuShowRate);
        _mainMenu.transform=transform;
        
        CGPoint center = _mainMenu.center;
        float width = screenSize.width*2/3;
        center.x = (0.7*width + 0.3*width*menuShowRate)/2;
        _mainMenu.center = center;
    }
    
    //手势结束后修正位置
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (arrayFlag[pos] > 0)  //收缩
        {
            [self showLeftMenu:TRUE];
        }
        else
        {
            [self showLeftMenu:FALSE];
        }
        
    }
}

-(void)popAlarmWithType:(int)type contactId:(NSString*)contactId  password:(NSString *)password group:(int)group item:(int)item
{
    UIViewController *presentView1 = self.presentedViewController;
    UIViewController *presentView2 = self.presentedViewController.presentedViewController;
    if(presentView2){
        [self dismissViewControllerAnimated:NO completion:nil];
    }else{
        [presentView1 dismissViewControllerAnimated:NO completion:nil];
    }
    
    AlarmPushController * alarmpushcontroller = [[AlarmPushController alloc] init];
    
    alarmpushcontroller.alarmtype = type;
    alarmpushcontroller.contactId = contactId;
    alarmpushcontroller.contactPassWord = self.contact.contactPassword;
    
    alarmpushcontroller.group = group;
    alarmpushcontroller.item = item;
    [self presentViewController:alarmpushcontroller animated:NO completion:nil];
    [alarmpushcontroller release];
}


-(void)setUpCallWithId:(NSString *)contactId password:(NSString *)password callType:(P2PCallType)type{
    [[P2PClient sharedClient] setIsBCalled:NO];
    [[P2PClient sharedClient] setCallId:contactId];
    [[P2PClient sharedClient] setP2pCallType:type];
    [[P2PClient sharedClient] setCallPassword:password];
    
    if(!self.presentedViewController){
        P2PMonitorController *monitorController = [[P2PMonitorController alloc] init];
        monitorController.contact = self.contact;//ios7.1.2 null
        NSLog(@"id=%@, pwd=%@", self.contact.contactId, self.contact.contactPassword);
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:monitorController animated:YES completion:nil];
        }else{
            [self presentViewController:monitorController animated:YES completion:nil];
        }
        [monitorController release];
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

-(void)P2PClientReady:(NSDictionary*)info{
    DLog(@"P2PClientReady");
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STET_READY];
    
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_MONITOR)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MONITOR_START_MESSAGE
                                                            object:self
                                                          userInfo:NULL];
    }
    else if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO)
    {
        P2PVideoController *videoController = [[P2PVideoController alloc] init];
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:videoController animated:YES completion:nil];
        }else{
            [self presentViewController:videoController animated:YES completion:nil];
        }
        
        [videoController release];
    }
}

#define ALERT_TAG_EXIT 0
#define ALERT_TAG_LOGOUT 1
#define ALERT_TAG_UPDATE 2

- (void)OnMenuBtnAction:(NSInteger)tag
{
    
    
    NSLog(@"%d",tag);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (tag == 7)
        {
            //提示消息
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logout_prompt", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            alert.tag = ALERT_TAG_LOGOUT;
            [alert show];
            [alert release];
            
            return;
        }
        //关闭平滑功能
        [self showLeftMenu:NO];
        int count  = (int)[self.childViewControllers count];
        if (tag > count)
            return;
        if (tag == 9) {
            tag = tag-1;
        }


}
    else
    {
        if (tag == 8)
        {
            //提示消息
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logout_prompt", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            alert.tag = ALERT_TAG_LOGOUT;
            [alert show];
            [alert release];
            
            return;
        }
        //关闭平滑功能
        [self showLeftMenu:NO];
        int count  = (int)[self.childViewControllers count];
        if (tag > count)
            return;
        if (tag == 10) {
            tag = tag-1;
        }


    }
//    //点击注销按钮
//    if (tag == 8)
//    {
//        //提示消息
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logout_prompt", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
//        alert.tag = ALERT_TAG_LOGOUT;
//        [alert show];
//        [alert release];
//        
//        return;
//    }
    //关闭平滑功能
//    [self showLeftMenu:NO];
    
//    int count  = (int)[self.childViewControllers count];
//    if (tag > count)
//        return;
//    if (tag == 9) {
//        tag = tag-1;
//    }
    UIViewController* newController = self.childViewControllers[tag];
    
    if (newController != _topViewController && newController)
    {
        double delayInSeconds = 0.5;
        //延迟
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            newController.view.frame = [_topViewController.view frame];
            [self transitionFromViewController:_topViewController
                              toViewController:newController
                                      duration:0
                                       options:0
                                    animations:^{
                                        
                                    }
                                    completion:^(BOOL finished) {
                                        _topViewController = newController;
                                    }];
        });
    }
}

#pragma mark - 实现抽屉平滑功能

- (void)showLeftMenu:(BOOL)bShow
{
    if (!_topViewController)
        return;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    int xPos = 0;
    xPos = bShow ? screenSize.width*7/6 : screenSize.width/2;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         if (bShow)
                         {
                             {
                                 CGAffineTransform transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                                 _topViewController.view.transform=transform;
                                 CGPoint center = _topViewController.view.center;
                                 center.x = xPos;
                                 _topViewController.view.center = center;
                             }
                             
                             
                             _mainMenu.alpha = 1 ;
                             {
                                 CGAffineTransform transform=CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                 _mainMenu.transform=transform;
                             }
                             _mainMenu.frame = CGRectMake(0, 0, screenSize.width*2/3, screenSize.height);
                             
                             if (!_maskView)
                             {
                                 _maskView = [[maskView alloc] initWithFrame:_topViewController.view.bounds];
                                 [_topViewController.view addSubview:_maskView];
                             }
                         }
                         else
                         {
                             {
                                 CGAffineTransform transform=CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                 _topViewController.view.transform=transform;
                                 CGPoint center = _topViewController.view.center;
                                 center.x = xPos;
                                 _topViewController.view.center = center;
                             }
                             _mainMenu.alpha = 0;
                             {
                                 CGAffineTransform transform=CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
                                 _mainMenu.transform=transform;
                             }
                             _mainMenu.frame = CGRectMake(0, screenSize.height*1.5/10, (screenSize.width*2/3)*0.7, screenSize.height*0.7);
                             
                             [_maskView removeFromSuperview];
                             _maskView = nil;
                         }
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_EXIT:
        {
            if(buttonIndex==1){
                
            }
        }
            break;
        case ALERT_TAG_LOGOUT:
        {
            if(buttonIndex==1){
                [UDManager setIsLogin:NO];
                
                [[GlobalThread sharedThread:NO] kill];
                [[FListManager sharedFList] setIsReloadData:YES];
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                LoginController *loginController = [[LoginController alloc] init];
                AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
                
                self.view.window.rootViewController = mainController;
                [loginController release];
                [mainController release];
                
                [[AppDelegate sharedDefault] reRegisterForRemoteNotifications];
                
                dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
                dispatch_async(queue, ^{
                    [[P2PClient sharedClient] p2pDisconnect];
                });
                
            }
        }
            break;
        case ALERT_TAG_UPDATE:
        {
            if (buttonIndex==1) {
                NSString *iTunesUrl = [NSString stringWithFormat:@"https://itunes.apple.com/gb/app/yi-dong-cai-bian/id1012269519?mt=8"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesUrl]];
            }else if (buttonIndex==2){
                NSString *iTunesUrl = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1012269519"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesUrl]];
            }
        }
            break;
    }
}

-(void)P2PClientReject:(NSDictionary*)info{
    DLog("P2PClientReject");
    
    
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATE_NONE];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        usleep(500000);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissP2PView];
            [self.view makeToast:[info objectForKey:@"rejectMsg"]];
        });
    });
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
            alarmNotify.alertAction = NSLocalizedString(@"view", nil);
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
            }
            else
            {
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
