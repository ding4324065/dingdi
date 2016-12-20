//
//  WifiListViewController.m
//  Camnoopy
//
//  Created by 高琦 on 15/1/30.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "WifiListViewController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "MBProgressHUD.h"
#import "P2PWifiCell.h"
#import "Constants.h"
#import "Contact.h"
#import "P2PClient.h"
#import "GCDAsyncUdpSocket.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "mesg.h"
#import "Utils.h"
#import "ContactDAO.h"
#import "Toast+UIView.h"
#import "NetSettingController.h"

@interface WifiListViewController ()

@end

@implementation WifiListViewController
-(void)dealloc{
    
    [self.tableView release];
    [self.sotypes release];
    [self.flags release];
    [self.addresses release];
    [self.wifilist release];
    [super dealloc];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    MainController *mainController = [AppDelegate sharedDefault].mainController;
//    [mainController setBottomBarHidden:YES];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UDPManager * manager = (UDPManager *)[UDPManager sharedDefault];
    manager.getwifidelegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressAlert show:YES];
        [self.progressAlert hide:NO];
        [self.tableView reloadData];
    });
    if (self.isgivenwifi) {
        self.wifilist = self.givenwifi;
        self.lastwifilist = self.givenlastwifi;
    }else{
        [[UDPManager sharedDefault] GetWifiList];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.wifilist removeAllObjects];
    [self.tableView reloadData];
}



- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
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
- (void)receiveWifiList:(NSDictionary *)dictionary{
    [self.progressAlert show:NO];
    if (self.isgivenwifi) {
        self.wifilist = self.givenwifi;
    }else{
        self.wifilist= [dictionary objectForKey:@"wifinamelist"];
    }
    self.lastwifilist = [dictionary objectForKey:@"wifinamelist"];
    self.nowcontactwifi = (NSInteger)[dictionary objectForKey:@"nowcontactwifi"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressAlert hide:YES];
        [self.tableView reloadData];
    });
}
- (void)setWifiSuccess{
    self.nowcontactwifi = self.selectWifiIndex;
    DeviceWiFi * wifi  = self.wifilist[self.nowcontactwifi];
    if ([self.delegate respondsToSelector:@selector(setdevicewifisecuss:)]) {
        [self.delegate setdevicewifisecuss:wifi];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressAlert hide:YES];
        [self.tableView reloadData];
    });
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initComponent];
}
-(void)initComponent{
    self.view.layer.contents = XBgImage;
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"network_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    
    UIView *maskLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    
   
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(30, NAVIGATION_BAR_HEIGHT, width-30*2, height-NAVIGATION_BAR_HEIGHT*2) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    tableView.layer.cornerRadius=10;
    tableView.clipsToBounds=YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    [maskLayerView addSubview:tableView];
    self.tableView = tableView;
    self.tableView.layer.cornerRadius = 20;
    self.tableView.clipsToBounds = YES;
    self.tableView.layer.borderWidth = 3.0f;
    self.tableView.layer.borderColor = [[UIColor grayColor] CGColor];
    [tableView release];
    
    
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:maskLayerView] autorelease];
    [maskLayerView addSubview:self.progressAlert];
    
    [self.view addSubview:maskLayerView];
    [maskLayerView release];
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return self.wifilist.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)onBackPress{
    NetSettingController * vc =  self.navigationController.viewControllers[0];
    vc.ishavewifilist = YES;
    vc.wifilist = self.wifilist;
    vc.lastwifilist = self.wifilist;
    [[UDPManager sharedDefault] quitWifiSet];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PWifiCell";
    UITableViewCell *cell = nil;
    int section = indexPath.section;
    int row = indexPath.row;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    if(cell==nil){
        cell = [[[P2PWifiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
        [cell setBackgroundColor:XWhite];
    }
    P2PWifiCell *wifiCell = (P2PWifiCell*)cell;
    if (self.isgivenwifi) {
        if (row == 0&&section==0) {
            [wifiCell setLeftStatelabelText:@"已连接"];
            [wifiCell setRightIcon2:@"ic_wifi_selected.png"];
        }
    }else if ((self.nowcontactwifi)>0&&(self.nowcontactwifi<=self.lastwifilist.count)) {
        DeviceWiFi * wifis  = self.lastwifilist[self.nowcontactwifi];
        [self.wifilist removeObjectAtIndex:self.nowcontactwifi];
        [self.wifilist insertObject:wifis atIndex:0];
        if (row == 0&&section ==0) {
            [wifiCell setLeftStatelabelText:@"已连接"];
            [wifiCell setRightIcon2:@"ic_wifi_selected.png"];
        }
    }
    DeviceWiFi * wifi  = self.wifilist[row];
    [wifiCell setLeftLabelText:wifi.wifiname];
    int strength = wifi.sigLevel;
    int type = wifi.encryptType;
    if(type==0){
        [wifiCell setRightIcon2:@""];
    }else{
        [wifiCell setRightIcon2:@"ic_wifi_lock.png"];
    }
    switch(strength){
        case 0:
        {
            [wifiCell setRightIcon:@"ic_strength0.png"];
        }
            break;
        case 1:
        {
            [wifiCell setRightIcon:@"ic_strength1.png"];
        }
            break;
        case 2:
        {
            [wifiCell setRightIcon:@"ic_strength2.png"];
        }
            break;
        case 3:
        {
            [wifiCell setRightIcon:@"ic_strength3.png"];
        }
            break;
        case 4:
        {
            [wifiCell setRightIcon:@"ic_strength4.png"];
        }
            break;
        default:
            break;
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectWifiIndex = indexPath.row;
    UIAlertView * changewifi = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"change_net_prompt",nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    changewifi.alertViewStyle = UIAlertActionStyleDefault;
    changewifi.tag = ALERT_TAG_CHANGE_WIFI;
    [changewifi show];
    [changewifi release];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_CHANGE_WIFI:
        {
            if(buttonIndex==0){
                
            }else if(buttonIndex==1){
                
                UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_wifi_password", nil) message:@"更改wifi" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                
                inputAlert.tag = ALERT_TAG_INPUT_WIFI_PASSWORD;
                [inputAlert show];
                [inputAlert release];
            }
        }
            break;
        case ALERT_TAG_INPUT_WIFI_PASSWORD:
        {
            if(buttonIndex==0){
                
            }else if(buttonIndex==1){
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                
                NSString *inputPwd = passwordField.text;
                if(!inputPwd||inputPwd.length==0){
                    [self.view makeToast:NSLocalizedString(@"input_wifi_password", nil)];
                    return;
                }
                
                if(inputPwd.length<8){
                    [self.view makeToast:NSLocalizedString(@"wifi_password_format_error", nil)];
                    return;
                }
                
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                DeviceWiFi * dev = self.wifilist[self.selectWifiIndex];
                UDPManager * manager = (UDPManager *)[UDPManager sharedDefault];
                manager.setwifidelegate = self;
                //[[UDPManager sharedDefault] ScanLanDevice];
                [[UDPManager sharedDefault] SetWifiInfo:self.selectWifiIndex andssid:dev.wifiname andpassword:inputPwd];
                self.lastSetWifiPassword = [NSString stringWithFormat:@"%@",inputPwd];
            }
        }
            break;
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
