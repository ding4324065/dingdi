//
//  ScanViewController.m
//  Camnoopy
//
//  Created by wutong on 15-1-8.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//


#import "ScanViewController.h"
#import "Constants.h"
#import "Contact.h"
#import "ContactDAO.h"
#import "AppDelegate.h"
#import "LocalDevice.h"
#import "UDPManager.h"
#import "IconButton.h"
#import "Toast+UIView.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#import "cooee.h"
#import "FListManager.h"

#define ICONCOUNT_PER_PAGE 8

@interface ScanViewController ()
{
    int _topInterval;
    
    CGPoint _arrayIconPoint[8];     //八个图标的坐标
    IconButton* _arrayButton[8];    //八个图标
    BOOL _arrayUsed[8];             //八个图标是否已经被使用
    int _pageSize;                  //每页八个图标
    int _currentPageIndex;          //当前第几页
    NSMutableArray* _arrayDevice;   //保存信息
    UIButton* _btnSwitch;           //切换页面按钮
    
    BOOL _bQuit;                    //针对2个后台线程
    
    scanAlertViewAdd* _alertViewAdd;

    BOOL _bShowAlertView;   //显示添加界面时，不加载图标
    BOOL _bLoadingIcon;     //正在加载时不响应addDevcie按钮事件，否则界面有问题
}
@end

@implementation ScanViewController

-(void)dealloc
{
    if (_arrayDevice) {
        [_arrayDevice release];
        _arrayDevice = nil;
    }

    [super dealloc];
}

-(void)initIconPoint
{
    float width = 423;
    float height = 746;
    CGPoint point[8];
    point[0] = CGPointMake(267, 127);
    point[1] = CGPointMake(57, 183);
    point[2] = CGPointMake(157, 248);
    point[3] = CGPointMake(357, 294);
    point[4] = CGPointMake(239, 423);
    point[5] = CGPointMake(76, 486);
    point[6] = CGPointMake(115, 635);
    point[7] = CGPointMake(327, 642);
    //以上参数是效果图尺寸
    
    //以下代码按效果图比例初始化8个中心点
    float widthScreen = [UIScreen mainScreen].bounds.size.width;
    float heightScreen = [UIScreen mainScreen].bounds.size.height;
    for (int i=0; i<8; i++) {
        _arrayIconPoint[i] = CGPointMake(widthScreen*point[i].x/width, heightScreen*point[i].y/height);
    }
}

-(void)loadView{
    UIView* view = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]];
    view.backgroundColor = [UIColor blueColor];
    

    NSArray *imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"scan01.png"],[UIImage imageNamed:@"scan02.png"],[UIImage imageNamed:@"scan03.png"], [UIImage imageNamed:@"scan04.png"],[UIImage imageNamed:@"scan05.png"],[UIImage imageNamed:@"scan06.png"],[UIImage imageNamed:@"scan07.png"],nil];
    
    UIImageView *animView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    animView.contentMode = UIViewContentModeScaleAspectFill;
    animView.animationImages = imagesArray;
    animView.animationDuration = ((CGFloat)[imagesArray count])*300.0f/1000.0f;
    animView.animationRepeatCount = 0;
    [animView startAnimating];
    [view addSubview:animView];
    [animView release];
    
    UIButton* btnBack = [[UIButton alloc]initWithFrame:CGRectMake(10, 22, 100, 30)];
    [btnBack addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setTitle:NSLocalizedString(@"back", nil) forState:UIControlStateNormal];
    [btnBack.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [btnBack.layer setBorderWidth:1.0]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 1 });
    [btnBack.layer setBorderColor:colorref];//边框颜色
    [view addSubview:btnBack];
    [btnBack release];
    
    UIButton* btnSwitch = [[UIButton alloc]initWithFrame:CGRectMake(210, 22, 100, 30)];
    [btnSwitch addTarget:self action:@selector(onSwitchPress) forControlEvents:UIControlEventTouchUpInside];
//    换一批
    [btnSwitch setTitle:NSLocalizedString(@"scan_switch", nil) forState:UIControlStateNormal];
    [btnSwitch.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [btnSwitch.layer setBorderWidth:1.0]; //边框宽度
    [btnSwitch.layer setBorderColor:colorref];//边框颜色
    btnSwitch.showsTouchWhenHighlighted = YES;
    [btnSwitch setHidden:YES];
    [view addSubview:btnSwitch];
    _btnSwitch = btnSwitch;
    [btnSwitch release];
    
    int backWidth = [UIScreen mainScreen].bounds.size.width;
    int backHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIButton* btnComplete = [[UIButton alloc]initWithFrame:CGRectMake(backWidth/2-40, backHeight-35, 100, 30)];
    [btnComplete addTarget:self action:@selector(onCompletePress) forControlEvents:UIControlEventTouchUpInside];
//    完成添加
    [btnComplete setTitle:NSLocalizedString(@"scan_complete", nil) forState:UIControlStateNormal];
    [btnComplete.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [btnComplete.layer setBorderWidth:1.0]; //边框宽度
    [btnComplete.layer setBorderColor:colorref];//边框颜色
    btnComplete.showsTouchWhenHighlighted = YES;
    [view addSubview:btnComplete];
    [btnComplete release];

    self.view = view;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _topInterval = 40;
        _pageSize = 8;
        _currentPageIndex = 0;
        _arrayDevice = [[NSMutableArray alloc]initWithCapacity:0];
        [self initIconPoint];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //初始化队列
    NSArray* array = [[UDPManager sharedDefault]getLanDevices];
    for (int i=0; i<[array count]; i++)
    {
        LocalDevice *localDevice = [array objectAtIndex:i];
        if ([self IsInLocalDeviceList:localDevice]) {
            continue;
        }
        else{
            [_arrayDevice addObject:localDevice];
        }
    }
    
    [self refreshDevicesIcon:_currentPageIndex bClear:NO bDelay:YES];
    [self setSwitchBtnStatus];

    //设置委托
    [[UDPManager sharedDefault]setDelegateUDPScan:self];
    
    [self startSetWifiLoop];
    [self startCheckTimeoutLoop];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    //设置委托
    [[UDPManager sharedDefault]setDelegateUDPScan:nil];

    _bQuit = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
 pageIndex: 显示第pageIndex页
 bClear:    清空页面再加载
 bDelay:    延时加载
 */
-(void)refreshDevicesIcon:(int)pageIndex bClear:(BOOL)bClear bDelay:(BOOL)bDelay
{
    if (bClear) {
        for (int i=0; i<_pageSize; i++)
        {
            [self SetIcon:i deviceInfo:nil];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _bLoadingIcon = YES;
        for (int i=0; i<_pageSize; i++)
        {
            LocalDevice* localDevice = nil;
            if ([_arrayDevice count] > (pageIndex*_pageSize+i))
            {
                localDevice = [_arrayDevice objectAtIndex:(pageIndex*_pageSize+i)];
                _arrayUsed[i] = TRUE;
            }
            else
            {
                _arrayUsed[i] = FALSE;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self SetIcon:i deviceInfo:localDevice];
            });
            
            if (bDelay)
            {
                usleep(300000);
            }
        }
        _bLoadingIcon = NO;
    });
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

- (void)SetIcon:(NSInteger)index deviceInfo:(LocalDevice*)deviceInfo
{
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionFade];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:1.0f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    if (_arrayButton[index]) {
        [_arrayButton[index] removeFromSuperview];
        _arrayButton[index] = nil;
    }
    
    if (deviceInfo) {
        IconButton *btn = [[IconButton alloc] initWithFrame:CGRectMake(0, 0, 80, 62)];
        btn.center = _arrayIconPoint[index];
        
        UIImage* image = deviceInfo.flag ? [UIImage imageNamed:@"scanTarget01"] : [UIImage imageNamed:@"scanTarget02"];
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop]; //设置对齐后可以比较方便的设置偏移位置
        [btn setImage:image forState:UIControlStateNormal];
        NSString* text = deviceInfo.contactId;
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [btn setTitle:text forState:UIControlStateNormal];
        [btn layoutIfNeeded];
        
        int imageWidth = 40, imageHeight = 40;;
        int interva1 = btn.bounds.size.width/2-imageWidth/2;
        CGSize labelSize = [text sizeWithFont:btn.titleLabel.font];
        int interval2 = btn.bounds.size.width/2 - labelSize.width/2;

        //相对于btn.frame的坐标
        btn.titleEdgeInsets = UIEdgeInsetsMake(imageHeight, -(image.size.width-interval2), 0, 0);
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, interva1, btn.bounds.size.height-imageHeight, interva1);
        btn.showsTouchWhenHighlighted = YES;
        [btn addTarget:self action:@selector(onIconPress:) forControlEvents:UIControlEventTouchDown];
        btn.localDevice = deviceInfo;
        btn.index = index;
        [self.view addSubview:btn];
        _arrayButton[index] = btn;
        [btn release];
    }
    
  [[self.view layer] addAnimation:animation forKey:@"pageTurnAnimation"];
}

-(void)setSwitchBtnStatus
{
    if ([_arrayDevice count] > _pageSize) {
        [_btnSwitch setHidden:NO];
    }
    else
    {
        [_btnSwitch setHidden:YES];
    }
}


-(BOOL)addInfoToArray:(LocalDevice*)localDevice
{
    for (int i=0; i<[_arrayDevice count]; i++) {
        LocalDevice* info = [_arrayDevice objectAtIndex:i];
        if ([info.contactId integerValue] == [localDevice.contactId integerValue])
        {
            return FALSE;
        }
    }
    [_arrayDevice addObject:localDevice];
    return TRUE;
}

-(BOOL)IsInLocalDeviceList:(LocalDevice*)localDevice
{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:localDevice.contactId];
    [contactDAO release];
    if(nil==contact){
        return FALSE;
    }
    return TRUE;
}

-(void)removeDevice:(LocalDevice*)localDevice
{
    for (int i=0; i<[_arrayDevice count]; i++) {
        LocalDevice* info = [_arrayDevice objectAtIndex:i];
        if ([info.contactId integerValue] == [localDevice.contactId integerValue])
        {
            [_arrayDevice removeObjectAtIndex:i];
            return;
        }
    }
}

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

#pragma mark 按钮响应
-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onCompletePress{
    [self.delegateQuit setQuit:YES];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)onSwitchPress
{
    if ([_arrayDevice count] <= _pageSize) {
        return;
    }
    
    int pageCount = ([_arrayDevice count]+_pageSize-1)/_pageSize;
    
    if (_currentPageIndex+1 >= pageCount) {
        _currentPageIndex = 0;
    }
    else
    {
        _currentPageIndex++;
    }
    
    [self refreshDevicesIcon:_currentPageIndex bClear:YES bDelay:YES];
}

-(void)onIconPress:(id)sender
{
     if (!_bLoadingIcon)
     {
     _bShowAlertView = TRUE;
     IconButton* btn = (IconButton*)sender;
     
     _alertViewAdd = [[scanAlertViewAdd alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
     [_alertViewAdd setDelegate:self localDevice:btn.localDevice];
     [self.view addSubview:_alertViewAdd];
     [_alertViewAdd release];
     }
}

#pragma mark 委托-添加设备/初始化密码
-(void)alertAddClickOK:(LocalDevice *)localDevice deviceName:(NSString *)deviceName
{
    [_alertViewAdd removeFromSuperview];
    _bShowAlertView = FALSE;
    
    [self removeDevice:localDevice];        //更新队列
    [self refreshDevicesIcon:0 bClear:NO bDelay:NO];  //更新界面
    [self setSwitchBtnStatus];              //更新switch按钮
    
    [self.view makeToast:[NSString stringWithFormat:@"%@ %@", deviceName, NSLocalizedString(@"scan_add_successfully", nil)]];
}

-(void)alertAddClickCancel
{
    [_alertViewAdd removeFromSuperview];
    _bShowAlertView = FALSE;
//    [self refreshDevicesIcon:_currentPageIndex bClear:NO bDelay:NO];  //更新界面
}


-(void)setInitPasswrod:(NSString *)contactID pwd:(NSString *)pwd
{
    _alertViewAdd.progressAlert.dimBackground = YES;
    [_alertViewAdd.progressAlert show:YES];

    [[P2PClient sharedClient] setInitPasswordWithId:contactID initPassword:pwd];
}

#pragma mark 委托-提示
-(void)alertTipClickCancel
{
    [self onCompletePress];
}

-(void)alertTipClickTryAgain
{
    [self onBackPress];
}

#pragma mark 委托-udp局域网搜索
-(void)onFoundLanDevice:(LocalDevice *)localDevice
{
    if (_bShowAlertView)
    {
        return;
    }
    
    if ([self IsInLocalDeviceList:localDevice])
    {
        return;     //存在本地设备列表中（database中）
    }
    
    BOOL ret = [self addInfoToArray:localDevice];
    if (!ret)
    {
        return;     //此设备已存在_arrayDevice中
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setSwitchBtnStatus];
        for (int i=0; i<_pageSize; i++)
        {
            if (_arrayUsed[i] == FALSE) {
                [self SetIcon:i deviceInfo:localDevice];
                _arrayUsed[i] = TRUE;
                return;
            }
        }
    });
}


#pragma mark p2p通知 (初始化密码结果)
- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    if (key != ACK_RET_SET_INIT_PASSWORD) {
        return;
    }
    
    int result = [[parameter valueForKey:@"result"] intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(result==1)   //密码错误
        {
            [_alertViewAdd.progressAlert hide:YES];
            [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
        }
        else if(result==2)  //网络异常
        {
            [_alertViewAdd.progressAlert hide:YES];
            [self.view makeToast:NSLocalizedString(@"net_exception", nil)];
        }
    });
    DLog(@"ACK_RET_SET_INIT_PASSWORD:%i",result);
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key = [[parameter valueForKey:@"key"] intValue];
    if (key != RET_SET_INIT_PASSWORD) {
        return;
    }
    
    int result = [[parameter valueForKey:@"result"] intValue];
    if(result==0)
    {
        Contact *contact = [[Contact alloc] init];
        contact.contactId = _alertViewAdd.localDevice.contactId;
        contact.contactName = _alertViewAdd.textFieldName.text;
        contact.contactPassword = _alertViewAdd.textFieldPassword.text;
        contact.contactType = CONTACT_TYPE_UNKNOWN;
        [[FListManager sharedFList] insert:contact];
        
        [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
        [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
        [contact release];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeDevice:_alertViewAdd.localDevice];        //更新队列
            [self refreshDevicesIcon:0 bClear:NO bDelay:NO];  //更新界面
            [self setSwitchBtnStatus];              //更新switch按钮
            
            [_alertViewAdd.progressAlert hide:YES];
            [_alertViewAdd removeFromSuperview];
            _bShowAlertView = FALSE;
            
            [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
        });
    }
    else if(result==43)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertViewAdd.progressAlert hide:YES];
            [self.view makeToast:NSLocalizedString(@"device_already_exist_password", nil)];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertViewAdd.progressAlert hide:YES];
            [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
        });
    }
}

#pragma mark 后台线程
- (void)startSetWifiLoop
{
#if !(TARGET_IPHONE_SIMULATOR)
    if ([self.wifiName length] == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!_bQuit)
        {
            const char *PWD = [self.wifiPwd UTF8String];
            const char *SSID = [self.wifiName UTF8String];
            
            const char *KEY = [@"" UTF8String];
            struct in_addr addr;
            inet_aton([[self getIPAddress] UTF8String], &addr);
            unsigned int ip = CFSwapInt32BigToHost(ntohl(addr.s_addr));
            
            
            send_cooee(SSID, (int)strlen(SSID), PWD, (int)strlen(PWD), KEY, 0, ip);
            NSLog(@"set wifi");
            
            usleep(1000000);
        }
    });
#endif
}

- (void)startCheckTimeoutLoop
{
    NSTimeInterval startInterval = [[NSDate date] timeIntervalSince1970];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!_bQuit)
        {
            for (int i=0; i<_pageSize; i++) {
                if (_arrayUsed[i])
                    return;
            }
            
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            if ((currentInterval - startInterval)>60) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    scanAlertviewTip* tip = [[scanAlertviewTip alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
                    [tip setDelegate:self];
                    [self.view addSubview:tip];
                    [tip release];
                });
            }
            
            usleep(1000000);
        }
    });
}
#pragma mark 键盘将要弹起时，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, -NAVIGATION_BAR_HEIGHT);
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
@end
