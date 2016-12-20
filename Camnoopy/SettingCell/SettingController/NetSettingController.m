

#import "NetSettingController.h"
#import "Constants.h"
#import "P2PClient.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "P2PEmailSettingCell.h"
#import "P2PNetTypeCell.h"
#import "RadioButton.h"
#import "P2PWifiCell.h"
#import "Toast+UIView.h"
#import "MBProgressHUD.h"
#import "RadioButton.h"
#import "P2PSecurityCell.h"
#import "P2PSwitchCell.h"
#import "P2PTextInputCell.h"
#import "WifiListViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Toast+UIView.h"

@interface NetSettingController ()

@end

@implementation NetSettingController
-(void)dealloc{
    [self.names release];
    [self.types release];
    [self.strengths release];
    [self.tableView release];
    [self.contact release];
    [self.radioNetType1 release];
    [self.radioNetType2 release];
    [self.progressAlert release];
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.isLoadingNetType = YES;
    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
#if 1
        case RET_GET_NPCSETTINGS_NET_TYPE:
        {
            NSInteger type = [[parameter valueForKey:@"type"] intValue];
            //[self.progressAlert hide:YES];
            self.netType = type;
            [self.names removeAllObjects];
            [self.types removeAllObjects];
            [self.strengths removeAllObjects];
            self.wifiCount = 0;
            self.currentWifiIndex = 0;
            self.isLoadingNetType = NO;
            self.isLoadingWifiList = YES;
            
            if(self.netType==SETTING_VALUE_NET_TYPE_WIFI){
                [[P2PClient sharedClient] getWifiListWithId:self.contact.contactId password:self.contact.contactPassword];
            }else{
                if(self.contact.contactType==CONTACT_TYPE_IPC||self.contact.contactType==CONTACT_TYPE_DOORBELL){
                    [[P2PClient sharedClient] getWifiListWithId:self.contact.contactId password:self.contact.contactPassword];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressAlert hide:YES];
                [self changebtnstate];
                [self.tableView reloadData];
            });
            DLog(@"net type:%i",type);
        }
            break;
        case RET_SET_NPCSETTINGS_NET_TYPE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            if(result==0){
                self.lastNetType = self.netType;
                sleep(1.0);
                [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.progressAlert hide:YES];
                    self.isLoadingNetType = NO;
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    self.isLoadingNetType = NO;
                    self.netType = self.lastNetType;
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                    //[self changebtnstate];
                });
            }
        }
            break;
        case RET_GET_WIFI_LIST:
        {
            NSInteger count = [[parameter valueForKey:@"count"] intValue];
            NSInteger currentIndex = [[parameter valueForKey:@"currentIndex"] intValue];
            NSMutableArray *names = [parameter valueForKey:@"names"];
            NSMutableArray *types = [parameter valueForKey:@"types"];
            NSMutableArray *strengths = [parameter valueForKey:@"strengths"];
            
            self.names = [NSMutableArray arrayWithArray:names];
            self.types = [NSMutableArray arrayWithArray:types];
            self.strengths = [NSMutableArray arrayWithArray:strengths];
            self.wifiCount = count;
            self.currentWifiIndex = currentIndex;
            
            
            self.isLoadingWifiList = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            
        }
            break;
        case RET_SET_WIFI:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                self.isLoadingNetType = YES;
                sleep(1.0);
                [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                [self.progressAlert hide:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                    //[self changebtnstate];
                });
            }
            
        }
            break;
#endif
        case RET_SET_IPCONFIG:{
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            if(result==0){
                self.isLoadingNetType = NO;
                sleep(1.0);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                    sleep(1.0);
                    [self onBackPress];
                });
                
            }else{
                [self.progressAlert hide:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_IPCONFIG:{
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.ip = [parameter valueForKey:@"ip"];
            self.getway  = [parameter valueForKey:@"getway"];
            self.subnetmask = [parameter valueForKey:@"subnetmask"];
            self.dns = [parameter valueForKey:@"dns"];
            if(result==1){
                self.isLoadingNetType = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                [self.progressAlert hide:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
        default:
        {
            //NSLog(@"+++++++%@",parameter);
        }
            break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
            
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
        case ACK_RET_SET_NPCSETTINGS_NET_TYPE:
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
                    DLog(@"resend set net type");
                    [[P2PClient sharedClient] setNetTypeWithId:self.contact.contactId password:self.contact.contactPassword type:self.netType];
                }
                
                
            });
            DLog(@"ACK_RET_SET_NPCSETTINGS_NET_TYPE:%i",result);
        }
            break;
        case ACK_RET_GET_WIFI_LIST:
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
                    DLog(@"resend get wifi list");
                    [[P2PClient sharedClient] getWifiListWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            DLog(@"ACK_RET_GET_WIFI_LIST:%i",result);
        }
            break;
        case ACK_RET_SET_WIFI:
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
                    DLog(@"resend set wifi list");
                    int type = [[self.types objectAtIndex:self.selectWifiIndex] intValue];
                    NSString *name = [self.names objectAtIndex:self.selectWifiIndex];
                    
                    [[P2PClient sharedClient] setWifiWithId:self.contact.contactId password:self.contact.contactPassword type:type name:name wifiPassword:self.lastSetWifiPassword];
                }
                
                
            });
            DLog(@"ACK_RET_SET_WIFI:%i",result);
        }
            break;
        case ACK_RET_GET_IPCONFIG:
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
                    [[P2PClient sharedClient] GetIpConfigWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
        }
            break;
        case ACK_RET_SET_IPCONFIG:
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
                    if (self.isAutoGetIp) {
                        [[P2PClient sharedClient] SetIPConfigWithId:self.contact.contactId password:self.contact.contactPassword isAuto:1 ip:0 subnetmask:0 getway:0 dns:0];
                    }
                    [[P2PClient sharedClient] SetIPConfigWithId:self.contact.contactId password:self.contact.contactPassword isAuto:0 ip:self.lastsetIp subnetmask:self.lastsetSub getway:self.lastsetGet dns:self.lastsetDns];
                }
                
                
            });
        }
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
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"network_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    
    UIView *maskLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    
    UIView * selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, TEXT_FIELD_HEIGHT)];
    UIButton * netbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    netbutton.frame = CGRectMake(0, 0, width/2, TEXT_FIELD_HEIGHT);
    netbutton.backgroundColor = XBlue;
    netbutton.tag = 201;
    [netbutton setTitle:NSLocalizedString(@"wired", nil) forState:UIControlStateNormal];
    [netbutton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [netbutton addTarget:self action:@selector(netselectbuttonclick:) forControlEvents:UIControlEventTouchUpInside];
    self.netbtn = netbutton;
    [selectView addSubview:netbutton];
    [netbutton release];
    
    UIButton * wifibutton = [UIButton buttonWithType:UIButtonTypeCustom];
    wifibutton.frame = CGRectMake(width/2, 0, width/2, TEXT_FIELD_HEIGHT);
    wifibutton.backgroundColor = XBlue;
    wifibutton.tag = 202;
    [wifibutton setTitle:NSLocalizedString(@"wifi", nil) forState:UIControlStateNormal];
    [wifibutton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [wifibutton addTarget:self action:@selector(netselectbuttonclick:) forControlEvents:UIControlEventTouchUpInside];
    self.wifibtn = wifibutton;
    [selectView addSubview:wifibutton];
    [wifibutton release];
    
    [self changebtnstate];
    
    UIView * buleline = [[UIView alloc] initWithFrame:CGRectMake(0, TEXT_FIELD_HEIGHT-3, width/2, 3)];
    buleline.backgroundColor = [UIColor blueColor];
    self.bline = buleline;
    [selectView addSubview:buleline];
    [buleline release];
    [maskLayerView addSubview:selectView];
    [selectView release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, TEXT_FIELD_HEIGHT, width-10*2, height-NAVIGATION_BAR_HEIGHT*2) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    tableView.layer.cornerRadius=10;
    tableView.clipsToBounds=YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [maskLayerView addSubview:tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(-TEXT_FIELD_HEIGHT, 0, 0, 0);
    
    self.tableView = tableView;
    self.tableView.layer.cornerRadius = 20;
    self.tableView.clipsToBounds = YES;
    self.tableView.layer.borderWidth = 2.0f;
    self.tableView.layer.borderColor = [XGray CGColor];
    [tableView release];
    
    
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:maskLayerView] autorelease];
    [maskLayerView addSubview:self.progressAlert];
    
    [self.view addSubview:maskLayerView];
    [maskLayerView release];
    
}
- (void)changebtnstate{
    [self.progressAlert hide:YES];
    self.netbtn.userInteractionEnabled = NO;
    self.wifibtn.userInteractionEnabled = NO;
    if (self.netType == SETTING_VALUE_NET_TYPE_WIRED) {
        self.netbtn.selected = YES;
        self.wifibtn.selected = NO;
        self.wifibtn.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.5f animations:^{
            CGRect rect = self.bline.frame;
            rect.origin.x = self.netbtn.frame.origin.x;
            self.bline.frame = rect;
        } ];
        [self.tableView reloadData];
    }else if (self.netType == SETTING_VALUE_NET_TYPE_WIFI){
        self.netbtn.selected = NO;
        self.wifibtn.selected = YES;
        self.netbtn.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.5f animations:^{
            CGRect rect = self.bline.frame;
            rect.origin.x = self.wifibtn.frame.origin.x;
            self.bline.frame = rect;
        }];
        [self.tableView reloadData];
    }
}
- (void)netselectbuttonclick:(UIButton *)sender{
//    self.netbtn.selected = NO;
//    self.wifibtn.selected = NO;
//    sender.selected = YES;
//    self.netbtn.userInteractionEnabled = YES;
//    self.wifibtn.userInteractionEnabled = YES;
    //if (!self.isLoadingNetType) {
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
        switch (sender.tag) {
            case 201:
            {
//                self.netbtn.selected = YES;
//                self.netbtn.userInteractionEnabled = NO;
//                [UIView animateWithDuration:0.5f animations:^{
//                    CGRect rect = self.bline.frame;
//                    rect.origin.x = self.netbtn.frame.origin.x;
//                    self.bline.frame = rect;
//                }];
//                
//                self.netType = SETTING_VALUE_NET_TYPE_WIRED;
//                [self.tableView reloadData];
                [[P2PClient sharedClient] setNetTypeWithId:self.contact.contactId password:self.contact.contactPassword type:SETTING_VALUE_NET_TYPE_WIRED];
            }
                break;
            case 202:
            {
//                self.wifibtn.selected = YES;
//                self.wifibtn.userInteractionEnabled = NO;
//                [UIView animateWithDuration:0.5f animations:^{
//                    CGRect rect = self.bline.frame;
//                    rect.origin.x = self.wifibtn.frame.origin.x;
//                    self.bline.frame = rect;
//                }];
//                
//                self.netType = SETTING_VALUE_NET_TYPE_WIFI;
//                [self.tableView reloadData];
                [[P2PClient sharedClient] setNetTypeWithId:self.contact.contactId password:self.contact.contactPassword type:SETTING_VALUE_NET_TYPE_WIFI];
            }
                break;
            default:
                
                break;
        }
  
    //}
}


-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
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

-(void)onKeyBoardWillHide:(NSNotification*)notification{
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        if(self.netType==SETTING_VALUE_NET_TYPE_WIRED){
            return 7;
//            return 8;
        }else if(self.netType==SETTING_VALUE_NET_TYPE_WIFI){
            return 8;
        }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.section==0&&indexPath.row==1){
//        return BAR_BUTTON_HEIGHT*2;
//    }else{
//        return BAR_BUTTON_HEIGHT;
//    }
    
    return BAR_BUTTON_HEIGHT;

}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isAutoGetIp) {
        if (3<=indexPath.row|indexPath.row<=6|indexPath.row==0|indexPath.row==1) {
            return NO;
        }else{
            return YES;
        }
    }else{
        if (indexPath.row==0|indexPath.row==1) {
            return NO;
        }else{
            return YES;
        }
    }
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    P2PSecurityCell * cell = [[P2PSecurityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"P2PSecurityCell"];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.delegate = self;
    [cell setMiddleLabelHidden:YES];
    [cell setLeftLabelHidden:YES];
    [cell setMiddleButtonHidden:NO];
    return cell;
}

- (void)savePress:(NSInteger)section row:(NSInteger)row{
    if (self.isAutoGetIp) {
        [[P2PClient sharedClient]SetIPConfigWithId:self.contact.contactId password:self.contact.contactPassword isAuto:1 ip:0 subnetmask:0 getway:0 dns:0];
    }else{
        NSString * ip = self.iptextfiled.text;

        NSString *  submask = self.submasktextfiled.text;
        NSString *  getway = self.getwaytextfiled.text;
        NSString *  dns = self.dnstextfiled.text;
    
        NSArray * ipseparr = [ip componentsSeparatedByString:@"."];
        NSArray * subseparr = [submask componentsSeparatedByString:@"."];
        NSArray * getseparr = [getway componentsSeparatedByString:@"."];
        NSArray * dnsseparr = [dns componentsSeparatedByString:@"."];
        if (ipseparr.count!=4||subseparr.count!=4||getseparr.count!=4||dnsseparr.count!=4) {
            [self.view makeToast:@"输入的网络配置错误"];
        }else if ([ip isEqualToString:@"255.255.255.255"]||([ipseparr[0] isEqualToString:@"0"])||(([ipseparr[1] integerValue]==0)&&([ipseparr[2] integerValue]==0)&&([ipseparr[3] integerValue]==0))||(([ipseparr[2] integerValue]==0)&&([ipseparr[3] integerValue]==0))||([ipseparr[3] integerValue]==0)){
            [self.view makeToast:@"ip地址错误"];
        }else if ((([subseparr[0] integerValue]!=0)&&(![subseparr[0] isEqualToString:@"255"]))||(([subseparr[1] integerValue]!=0)&&(![subseparr[1] isEqualToString:@"255"]))||(([subseparr[2] integerValue]!=0)&&(![subseparr[2] isEqualToString:@"255"]))||(([subseparr[3] integerValue]!=0)&&(![subseparr[3] isEqualToString:@"255"]))){
            [self.view makeToast:@"子网掩码错误，每个字节只能是0或255"];
        }
        else{
            unsigned int d = ([ipseparr[0] intValue]<<24);
            unsigned int c = ([ipseparr[1] intValue]<<16);
            unsigned int b = ([ipseparr[2] intValue]<<8);
            unsigned int a = ([ipseparr[3] intValue]);
            unsigned int ipvalue = a|b|c|d;
            self.lastsetIp = ipvalue;
            d = ([subseparr[0] intValue]<<24);
            c = ([subseparr[1] intValue]<<16);
            b = ([subseparr[2] intValue]<<8);
            a = ([subseparr[3] intValue]);
            unsigned int subvalue = a|b|c|d;
            self.lastsetSub = subvalue;
            d = ([getseparr[0] intValue]<<24);
            c = ([getseparr[1] intValue]<<16);
            b = ([getseparr[2] intValue]<<8);
            a = ([getseparr[3] intValue]);
            unsigned int getvalue = a|b|c|d;
            self.lastsetGet = getvalue;
            d = ([dnsseparr[0] intValue]<<24);
            c = ([dnsseparr[1] intValue]<<16);
            b = ([dnsseparr[2] intValue]<<8);
            a = ([dnsseparr[3] intValue]);
            unsigned int dnsvalue = a|b|c|d;
            self.lastsetDns = dnsvalue;
            if ((ipvalue&subvalue)!=(getvalue&subvalue)) {
                [self.view makeToast:@"ip和网关需在同一网段"];
            }else{
        
                [[P2PClient sharedClient]SetIPConfigWithId:self.contact.contactId password:self.contact.contactPassword isAuto:0 ip:ipvalue subnetmask:subvalue getway:getvalue dns:dnsvalue];
            }
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return BAR_BUTTON_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PEmailSettingCell";
    static NSString *identifier3 = @"P2PWifiCell";
    static NSString *identifier4 = @"P2PTextInputCell";
    static NSString *identifier5 = @"P2PSwitchCell";
    
    UITableViewCell *cell = nil;
    int row = (int)indexPath.row;
    switch (row) {
        case 0:
        case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
                if(cell==nil){
                    cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }
                break;
        case 2:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:identifier5];
                if(cell==nil){
                    cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier5] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }
                break;
        case 3:
        case 4:
        case 5:
        case 6:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
                if(cell==nil){
                    cell = [[[P2PTextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
                P2PTextInputCell *SecurityCell = (P2PTextInputCell*)cell;
                SecurityCell.rightTextFieldView.secureTextEntry = NO;
            }
            break;
        case 7:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if(cell==nil){
                    cell = [[[P2PWifiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }
            break;
        default:
            break;
    }
    switch (row) {
        case 0:{
            P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
                            if(!self.isLoadingNetType){
                            }else{
                            }
            
                            [emailCell setLeftLabelText:NSLocalizedString(@"mac_address", nil)];
                            [emailCell setRightLabelText:self.selectType];
                            [emailCell setRightIcon:@"new_right.png"];
            
                            if(self.isLoadingNetType){
                                [emailCell setLeftIconHidden:YES];
                                [emailCell setLeftLabelHidden:NO];
                                [emailCell setRightIconHidden:YES];
                                [emailCell setRightLabelHidden:YES];
                                [emailCell setProgressViewHidden:NO];
                            }else{
                                [emailCell setLeftIconHidden:YES];
                                [emailCell setLeftLabelHidden:NO];
                                [emailCell setRightIconHidden:YES];
                                [emailCell setRightLabelHidden:NO];
                                [emailCell setProgressViewHidden:YES];
                            }
        }
            break;
        case 1:
        {
            P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
            if(!self.isLoadingNetType){
            }else{
            }
            
            [emailCell setLeftLabelText:NSLocalizedString(@"enabled", nil)];
            [emailCell setRightLabelText:self.selectType];
            [emailCell setRightIcon:@"new_right.png"];
            
            if(self.isLoadingNetType){
                [emailCell setLeftIconHidden:YES];
                [emailCell setLeftLabelHidden:NO];
                [emailCell setRightIconHidden:YES];
                [emailCell setRightLabelHidden:YES];
                [emailCell setProgressViewHidden:NO];
            }else{
                [emailCell setLeftIconHidden:YES];
                [emailCell setLeftLabelHidden:NO];
                [emailCell setRightIconHidden:YES];
                [emailCell setRightLabelHidden:NO];
                [emailCell setProgressViewHidden:YES];
            }

        }
            break;
        case 2:
        {
            P2PSwitchCell *switchCell = (P2PSwitchCell*)cell;
            [switchCell setLeftLabelText:NSLocalizedString(@"Automatic_get_ip", nil)];
                [switchCell setProgressViewHidden:YES];
                [switchCell setSwitchViewHidden:NO];
                [switchCell.switchView addTarget:self action:@selector(onRemoteDefenceChange:) forControlEvents:UIControlEventValueChanged];
            if (self.netType == SETTING_VALUE_NET_TYPE_WIFI ) {
                switchCell.userInteractionEnabled = NO;
                switchCell.contentView.backgroundColor = XGray;
            }else{
                switchCell.userInteractionEnabled = YES;
                switchCell.contentView.backgroundColor = [UIColor clearColor];
            }
            
            if (self.isAutoGetIp) {
                switchCell.on = YES;
            }else{
                switchCell.on = NO;
            }
        }
            break;
        case 3:{
            P2PTextInputCell *SecurityCell = (P2PTextInputCell*)cell;
            SecurityCell.leftLabelText = NSLocalizedString(@"ip_address", nil);
            if (self.ip) {
               SecurityCell.rightTextFieldView.text = self.ip;
            }else{
               SecurityCell.rightTextFieldText = NSLocalizedString(@"input_ip", nil);
            }
            if (self.netType == SETTING_VALUE_NET_TYPE_WIFI ) {
                SecurityCell.userInteractionEnabled = NO;
                SecurityCell.contentView.backgroundColor = XGray;
            }else{
                if (self.isAutoGetIp) {
                    SecurityCell.userInteractionEnabled = NO;
                    SecurityCell.contentView.backgroundColor = XGray;
                }else{
                    SecurityCell.userInteractionEnabled = YES;
                    SecurityCell.contentView.backgroundColor = [UIColor clearColor];
                }
            }
            SecurityCell.rightTextFieldView.secureTextEntry = NO;
            self.iptextfiled = SecurityCell.rightTextFieldView;
            self.iptextfiled.secureTextEntry = NO;
        }
            break;
        case 4:{
            P2PTextInputCell *SecurityCell = (P2PTextInputCell*)cell;
            SecurityCell.leftLabelText = NSLocalizedString(@"Subnet_mask", nil);
            if (self.subnetmask) {
                SecurityCell.rightTextFieldView.text = self.subnetmask;
            }else{
                SecurityCell.rightTextFieldText = NSLocalizedString(@"input_subnet", nil);
            }
            if (self.netType == SETTING_VALUE_NET_TYPE_WIFI ) {
                SecurityCell.userInteractionEnabled = NO;
                SecurityCell.contentView.backgroundColor = XGray;
            }else{
                if (self.isAutoGetIp) {
                    SecurityCell.userInteractionEnabled = NO;
                    SecurityCell.contentView.backgroundColor = XGray;
                }else{
                    SecurityCell.userInteractionEnabled = YES;
                    SecurityCell.contentView.backgroundColor = [UIColor clearColor];
                }
            }
            SecurityCell.rightTextFieldView.secureTextEntry = NO;
            self.submasktextfiled = SecurityCell.rightTextFieldView;
        }
            break;
        case 5:{
            P2PTextInputCell *SecurityCell = (P2PTextInputCell*)cell;
            SecurityCell.leftLabelText = NSLocalizedString(@"gateway", nil);
            if (self.getway) {
                SecurityCell.rightTextFieldView.text = self.getway;
            }else{
                SecurityCell.rightTextFieldText = NSLocalizedString(@"input_gateway", nil);
            }
            if (self.netType == SETTING_VALUE_NET_TYPE_WIFI ) {
                SecurityCell.userInteractionEnabled = NO;
                SecurityCell.contentView.backgroundColor = XGray;
            }else{
                if (self.isAutoGetIp) {
                    SecurityCell.userInteractionEnabled = NO;
                    SecurityCell.contentView.backgroundColor = XGray;
                }else{
                    SecurityCell.userInteractionEnabled = YES;
                    SecurityCell.contentView.backgroundColor = [UIColor clearColor];
                }
            }
            SecurityCell.rightTextFieldView.secureTextEntry = NO;
            self.getwaytextfiled = SecurityCell.rightTextFieldView;
        }
            break;
        case 6:
        {
            P2PTextInputCell *SecurityCell = (P2PTextInputCell*)cell;
            SecurityCell.leftLabelText = NSLocalizedString(@"dns", nil);
            if (self.dns) {
                SecurityCell.rightTextFieldView.text = self.dns;
            }else{
                SecurityCell.rightTextFieldText = NSLocalizedString(@"input_dns", nil);
            }
            if (self.netType == SETTING_VALUE_NET_TYPE_WIFI ) {
                SecurityCell.userInteractionEnabled = NO;
                SecurityCell.contentView.backgroundColor = XGray;
            }else{
                if (self.isAutoGetIp) {
                    SecurityCell.userInteractionEnabled = NO;
                    SecurityCell.contentView.backgroundColor = XGray;
                }else{
                    SecurityCell.userInteractionEnabled = YES;
                    SecurityCell.contentView.backgroundColor = [UIColor clearColor];
                }
            }
            SecurityCell.rightTextFieldView.secureTextEntry = NO;
            self.dnstextfiled = SecurityCell.rightTextFieldView;
        }
            break;
        case 7:
        {
            P2PWifiCell *WifiCell = (P2PWifiCell*)cell;
            if (self.nowwifi) {
                [WifiCell setLeftStatelabelText:NSLocalizedString(@"connected", nil)];
                WifiCell.leftLabelText = self.nowwifi.wifiname;
                int strength = (int)self.nowwifi.sigLevel;
                [WifiCell setRightIcon2:@"ic_wifi_selected.png"];
                switch(strength){
                    case 0:
                    {
                        [WifiCell setRightIcon:@"ic_strength0.png"];
                    }
                        break;
                    case 1:
                    {
                        [WifiCell setRightIcon:@"ic_strength1.png"];
                    }
                        break;
                    case 2:
                    {
                        [WifiCell setRightIcon:@"ic_strength2.png"];
                    }
                        break;
                    case 3:
                    {
                        [WifiCell setRightIcon:@"ic_strength3.png"];
                    }
                        break;
                    case 4:
                    {
                        [WifiCell setRightIcon:@"ic_strength4.png"];
                    }
                }
            }else{
                WifiCell.leftLabelText = NSLocalizedString(@"wifi_list", nil);
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

//获取连接wifi的名字
- (id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}
-(void)setdevicewifisecuss:(DeviceWiFi *)nowwifi{
    self.nowwifi = nowwifi;
    [self.tableView reloadData];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==7) {
        NSDictionary *ifs = [self fetchSSIDInfo];
        NSLog(@"ifs:%@",ifs);
        NSString *ssid = [ifs objectForKey:@"SSID"];
        NSString * ipcwifiname = [NSString stringWithFormat:@"IPC_%@",self.contact.contactId];
//        if (ssid==nil) {
//            [self.view makeToast:@"请连接Wifi"];
//        }
        if (self.ishavewifilist) {
            WifiListViewController * wifilistvc = [[WifiListViewController alloc] init];
            wifilistvc.contact = self.contact;
            wifilistvc.givenwifi = self.wifilist;
            wifilistvc.givenlastwifi = self.lastwifilist;
            wifilistvc.isgivenwifi = YES;
            wifilistvc.delegate = self;
            [self.navigationController pushViewController:wifilistvc animated:YES];
        }else if ((![ssid isEqualToString:ipcwifiname])||(ssid==nil)){
            [self.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"connect_ipc_wifi", nil),ipcwifiname]];
        }else{
            WifiListViewController * wifilistvc = [[WifiListViewController alloc] init];
            wifilistvc.contact = self.contact;
            wifilistvc.delegate = self;
            [self.navigationController pushViewController:wifilistvc animated:YES];
        }
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_NET_TYPE1:
        {
            if(buttonIndex==0){
                [self.radioNetType1 setSelected:NO];
                [self.radioNetType2 setSelected:YES];
            }else if(buttonIndex==1){
                self.isLoadingNetType = YES;
                self.lastNetType = self.netType;
                self.netType = SETTING_VALUE_NET_TYPE_WIRED;
                [self.tableView reloadData];
                
                [[P2PClient sharedClient] setNetTypeWithId:self.contact.contactId password:self.contact.contactPassword type:self.netType];
            }
        }
            break;
        case ALERT_TAG_NET_TYPE2:
        {
            if(buttonIndex==0){
                [self.radioNetType1 setSelected:YES];
                [self.radioNetType2 setSelected:NO];
            }else if(buttonIndex==1){
                self.isLoadingNetType = YES;
                self.lastNetType = self.netType;
                self.netType = SETTING_VALUE_NET_TYPE_WIFI;
                [self.tableView reloadData];
                
                [[P2PClient sharedClient] setNetTypeWithId:self.contact.contactId password:self.contact.contactPassword type:self.netType];
            }
        }
            break;
        case ALERT_TAG_CHANGE_WIFI:
        {
            if(buttonIndex==0){
                
            }else if(buttonIndex==1){
                NSString *name = [self.names objectAtIndex:self.selectWifiIndex];
                UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_wifi_password", nil) message:name delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
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
                int type = [[self.types objectAtIndex:self.selectWifiIndex] intValue];
                NSString *name = [self.names objectAtIndex:self.selectWifiIndex];
                self.lastSetWifiPassword = [NSString stringWithFormat:@"%@",inputPwd];
                [[P2PClient sharedClient] setWifiWithId:self.contact.contactId password:self.contact.contactPassword type:type name:name wifiPassword:self.lastSetWifiPassword];
            }
        }
            break;
            
    }
}

-(BOOL)shouldAutorotate{
    return YES;
}
#pragma mark 获取ip等信息
-(void)onRemoteDefenceChange:(UISwitch*)sender{
    self.isAutoGetIp = !self.isAutoGetIp;
    if (self.isAutoGetIp) {
        [[P2PClient sharedClient] GetIpConfigWithId:self.contact.contactId password:self.contact.contactPassword];
    }
    [self.tableView reloadData];
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
