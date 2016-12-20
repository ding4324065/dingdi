


#import "MainSettingController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "Utils.h"
#import "Contact.h"
#import "CustomCell.h"
#import "TimeSettingController.h"
#import "SecuritySettingController.h"
#import "VideoSettingController.h"
#import "AutoNavigation.h"
#import "AlarmSettingController.h"
#import "RecordSettingController.h"
#import "StorageSettingController.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "DefenceSettingController.h"
#import "NetSettingControllerEX.h"
#import "FListManager.h"
#import "DefenceAreaSettingController.h"
#import "FTPController.h"
#import "MainSettingCell.h"
@interface MainSettingController ()
@property (assign)BOOL isCancelUpdateDeviceOk;
@end


@implementation MainSettingController

-(void)dealloc{
    [self.progressAlert release];
    [self.contact release];
    [self.progressView release];
    [self.progressMaskView release];
    [self.progressLabel release];
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
    //    MainController *mainController = [AppDelegate sharedDefault].mainController;
    //    [mainController setBottomBarHidden:YES];
    self.isSendRomoteMessageInCurrentInterface = NO;
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}
#define MESG_PARAM_VALUE_INVALID 254
#define MESG_SET_DEVICE_NOT_SUPPORT 255

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    //
    //        if (!self.isSendRomoteMessageInCurrentInterface) {//设备检查更新
    //            //YES表示当前界面发送远程消息，才可以继续往下执行
    //            //因为在ContactController里下拉发送这设备检查更新的请求
    //            return;
    //        }
    
    switch(key){
            
        case RET_CHECK_DEVICE_UPDATE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSString *curVersion = [parameter valueForKey:@"curVersion"];
            NSString *upgVersion = [parameter valueForKey:@"upgVersion"];
            
            switch (result) {
                case 1:
                { dispatch_async(dispatch_get_main_queue(), ^{
                    self.curVersion = curVersion;
                    self.upgVersion  = upgVersion;
                    [self.progressAlert hide:YES];
                    NSString *title = [NSString stringWithFormat:@"%@:%@,%@:%@",NSLocalizedString(@"cur_version_is", nil),curVersion,NSLocalizedString(@"can_update_to", nil),upgVersion];
                    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
                    deleteAlert.tag = ALERT_TAG_UPDATE;
                    [deleteAlert show];
                    [deleteAlert release];
                });
                }
                    break;
                case 72:
                {dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.progressAlert hide:YES];
                    //                  cur_version_is  当前版本为  "can_update_to" = "可升级至";
                    NSString *title = [NSString stringWithFormat:@"%@:%@,%@",NSLocalizedString(@"cur_version_is", nil),curVersion,NSLocalizedString(@"can_update_sd", nil)];
                    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
                    deleteAlert.tag = ALERT_TAG_UPDATE;
                    [deleteAlert show];
                    [deleteAlert release];
                });}
                    break;
                case 54:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.progressAlert hide:YES];
                        [self.view makeToast:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"now_version_is_latest", nil),curVersion]];
                    });
                    
                }
                    break;
                case 58:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.progressAlert hide:YES];
                        [self.view makeToast:NSLocalizedString(@"other_was_check_device_update", nil)];
                    });
                }
                    break;
                    
                default:
                    break;
            }
            
            //            if (result == 1) {
            //                //读取到了服务器升级文件
            //                dispatch_async(dispatch_get_main_queue(), ^{
            //                    self.curVersion = curVersion;
            //                    self.upgVersion  = upgVersion;
            //                    [self.progressAlert hide:YES];
            //                    NSString *title = [NSString stringWithFormat:@"%@:%@,%@:%@",NSLocalizedString(@"cur_version_is", nil),curVersion,NSLocalizedString(@"can_update_to", nil),upgVersion];
            //                    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
            //                    deleteAlert.tag = ALERT_TAG_UPDATE;
            //                    [deleteAlert show];
            //                    [deleteAlert release];
            //                });
            //            }
            //            if(result==72){
            //                //读取到了sd卡升级文件
            //                dispatch_async(dispatch_get_main_queue(), ^{
            //
            //                    [self.progressAlert hide:YES];
            //                    //                  cur_version_is  当前版本为  "can_update_to" = "可升级至";
            //                    NSString *title = [NSString stringWithFormat:@"%@:%@,%@",NSLocalizedString(@"cur_version_is", nil),curVersion,NSLocalizedString(@"can_update_sd", nil)];
            //                    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
            //                    deleteAlert.tag = ALERT_TAG_UPDATE;
            //                    [deleteAlert show];
            //                    [deleteAlert release];
            //                });
            //            }else if(result==54){
            //                //最新版本
            //                dispatch_async(dispatch_get_main_queue(), ^{
            //
            //                    [self.progressAlert hide:YES];
            //                    [self.view makeToast:[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"now_version_is_latest", nil),curVersion]];
            //                });
            //            }else if(result==58){
            //                //设备繁忙
            //                dispatch_async(dispatch_get_main_queue(), ^{
            //
            
            //                    [self.progressAlert hide:YES];
            //                    [self.view makeToast:NSLocalizedString(@"other_was_check_device_update", nil)];
            //                });
            //            }else {
            //                dispatch_async(dispatch_get_main_queue(), ^{
            //                    [self.progressAlert hide:YES];
            //                    [self.view makeToast:NSLocalizedString(@"update_failed", nil)];
            //                });
            //            }
        }
            break;
        case RET_DEVICE_NOT_SUPPORT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //                设备不支持
                [self.progressAlert hide:YES];
                [self.view makeToast:NSLocalizedString(@"device_not_support", nil)];
            });
        }
            break;
            
        case RET_DO_DEVICE_UPDATE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSInteger value = [[parameter valueForKey:@"value"] intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.progressAlert hide:YES];
                
                if(result==1){
                    self.progressLabel.text = [NSString stringWithFormat:@"%i%@",value,@"%"];
                    [self.progressMaskView setHidden:NO];
                    DLog(@"%i",value);
                }else if(result==65){
                    [self.progressMaskView setHidden:YES];
                    //                    开始更新  更新失败
                    [self.view makeToast:NSLocalizedString(@"start_update", nil)];
                    //设备升级成功，将设备的isNewVersionDevice设置为NO，刷新表格，去除红色角标
                    for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {
                        if ([self.contact.contactId isEqualToString:contact.contactId]) {
                            contact.isNewVersionDevice = NO;
                        }
                    }
                    [self.tableView reloadData];
                    
                }else{
                    _isCancelUpdateDeviceOk = YES;
                    [self.progressMaskView setHidden:YES];
                    [self.view makeToast:NSLocalizedString(@"update_failed", nil)];
                }
            });
            
        }
            break;
        case RET_GET_DEVICE_INFO:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSString *curVersion = [parameter valueForKey:@"curVersion"];
            NSString *kernelVersion = [parameter valueForKey:@"kernelVersion"];
            NSString *rootfsVersion = [parameter valueForKey:@"rootfsVersion"];
            NSString *ubootVersion = [parameter valueForKey:@"ubootVersion"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.progressAlert hide:YES];
                
                if(result==1){
                    [self showDeviceInfoViewWithCurVersion:curVersion kernelVersion:kernelVersion rootfsVersion:rootfsVersion ubootVersion:ubootVersion];
                }
            });
        }
            break;
        case RET_GET_SDCARD_INFO:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == 1) {
                    StorageSettingController *storageSettingController = [[StorageSettingController alloc] init];
                    storageSettingController.contact = self.contact;
                    [self presentViewController:storageSettingController animated:YES completion:nil];
                    [storageSettingController release];
                }else{
                    //显示没有sd卡
                    [self.view makeToast:NSLocalizedString(@"no_storage", nil)];
                }
            });
        }
            break;
        case RET_SET_REMOTE_REBOOT:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            if (result == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                    
                });
            }else if (result == MESG_PARAM_VALUE_INVALID){
                
            }else if (result == MESG_SET_DEVICE_NOT_SUPPORT){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.view makeToast:NSLocalizedString(@"not_support_operation", nil)];
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
    //        if (!self.isSendRomoteMessageInCurrentInterface) {//设备检查更新
    //            //YES表示当前界面发送远程消息，才可以继续往下执行
    //            //因为在ContactController里下拉发送这设备检查更新的请求
    //            return;
    //        }
    
    switch(key){
        case ACK_RET_CHECK_DEVICE_UPDATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend check device update");
                    [[P2PClient sharedClient] checkDeviceUpdateWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            DLog(@"ACK_RET_CHECK_DEVICE_UPDATE:%i",result);
        }
            break;
        case ACK_RET_DO_DEVICE_UPDATE:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] doDeviceUpdateWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            
            DLog(@"ACK_RET_DO_DEVICE_UPDATE:%i",result);
        }
            break;
        case ACK_RET_GET_DEVICE_INFO:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] getDeviceInfoWithId:self.contact.contactId password:self.contact.contactPassword];
                    
                }
                
                
            });
            
            DLog(@"ACK_RET_GET_DEVICE_INFO:%i",result);
        }
            break;
        case ACK_RET_GET_SDCARD_INFO:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] getSDCardInfoWithId:self.contact.contactId password:self.contact.contactPassword];
                    
                }
            });
            DLog(@"ACK_RET_GET_SDCARD_INFO:%i",result);
        }
            break;
        case ACK_RET_SET_REMOTE_REBOOT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == 1) {
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                }else if (result == 2){
                    
                    [[P2PClient sharedClient] setDeviceRemoteRebootRWithId:self.contact.contactId password:self.contact.contactPassword value:self.lastTime bRebootType:self.lastValue];
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

#define TOP_INFO_BAR_HEIGHT 70

#define TOP_HEAD_MARGIN 10
#define PROGRESS_VIEW_WIDTH 160
#define PROGRESS_VIEW_HEIGHT 140

#define INDECATOR_LABEL_HEIGHT 100
#define VIEW_DEVICE_BUTTON_WIDTH 80
#define VIEW_DEVICE_BUTTON_HEIGHT 34

-(void)initComponent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"device_control",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    
    
    UIView *topInfoBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, TOP_INFO_BAR_HEIGHT)];
    [topInfoBarView setBackgroundColor:[UIColor colorWithRed:215/255.0f green:240/255.0f blue:250/255.0f alpha:1]];
    UIImageView *headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(TOP_HEAD_MARGIN, TOP_HEAD_MARGIN, (TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)*4/3, TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)];
    headImgView.layer.cornerRadius = 7;
    headImgView.layer.masksToBounds = YES;//图片圆角
    NSString *filePath = [Utils getHeaderFilePathWithId:self.contact.contactId];
    
    UIImage *headImg = [UIImage imageWithContentsOfFile:filePath];
    if(headImg==nil){
        headImg = [UIImage imageNamed:@"ic_header.png"];
    }
    headImgView.image = headImg;
    
    [topInfoBarView addSubview:headImgView];
    [headImgView release];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_HEAD_MARGIN+(TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)*4/3+TOP_HEAD_MARGIN,0,width-(TOP_HEAD_MARGIN+(TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)*4/3+TOP_HEAD_MARGIN),TOP_INFO_BAR_HEIGHT)];
    
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = XBlack;
    nameLabel.backgroundColor = XBGAlpha;
    [nameLabel setFont:XFontBold_16];
    
    nameLabel.text = self.contact.contactName;
    [topInfoBarView addSubview:nameLabel];
    [nameLabel release];
    //设备信息
    if(self.contact.contactType==CONTACT_TYPE_IPC || self.contact.contactType==CONTACT_TYPE_DOORBELL ||self.contact.contactId.intValue<256){//IP添加设备
        UIButton *viewDeviceInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        viewDeviceInfoButton.frame = CGRectMake(width-5-VIEW_DEVICE_BUTTON_WIDTH, (TOP_INFO_BAR_HEIGHT-VIEW_DEVICE_BUTTON_HEIGHT)/2, VIEW_DEVICE_BUTTON_WIDTH, VIEW_DEVICE_BUTTON_HEIGHT);
        viewDeviceInfoButton.layer.cornerRadius = 5.0;
        viewDeviceInfoButton.backgroundColor = [UIColor colorWithRed:51/255.0f green:153/255.0f blue:254/255.0f alpha:1];
        [viewDeviceInfoButton addTarget:self action:@selector(onViewDeviceInfoButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *deviceInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewDeviceInfoButton.frame.size.width, viewDeviceInfoButton.frame.size.height)];
        deviceInfoLabel.backgroundColor = [UIColor clearColor];
        deviceInfoLabel.textAlignment = NSTextAlignmentCenter;
        deviceInfoLabel.textColor = [UIColor whiteColor];
        deviceInfoLabel.font = XFontBold_14;
        deviceInfoLabel.text = NSLocalizedString(@"device_info", nil);
        [viewDeviceInfoButton addSubview:deviceInfoLabel];
        [deviceInfoLabel release];
        
        [topInfoBarView addSubview:viewDeviceInfoButton];
    }
    
    
    [contentView addSubview:topInfoBarView];
    [topInfoBarView release];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,TOP_INFO_BAR_HEIGHT, width, height-(NAVIGATION_BAR_HEIGHT+TOP_INFO_BAR_HEIGHT)) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    tableView.delegate = self;
    tableView.dataSource = self;
    [contentView addSubview:tableView];
    [tableView release];
    
    
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:contentView] autorelease];
    [contentView addSubview:self.progressAlert];
    
    UIView *progressMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
    [contentView addSubview:progressMaskView];
    self.progressMaskView = progressMaskView;
    [progressMaskView release];
    
    [self.view addSubview:contentView];
    
    [contentView release];
    
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake((width-PROGRESS_VIEW_WIDTH)/2, (height-PROGRESS_VIEW_HEIGHT)/2, PROGRESS_VIEW_WIDTH, PROGRESS_VIEW_HEIGHT)];
    progressView.layer.borderColor = [XBlack CGColor];
    progressView.layer.cornerRadius = 2.0;
    progressView.layer.borderWidth = 1.0;
    progressView.backgroundColor = XBlack_128;
    progressView.layer.masksToBounds = YES;
    
    
    UILabel *indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PROGRESS_VIEW_WIDTH, INDECATOR_LABEL_HEIGHT)];
    indicatorLabel.backgroundColor = [UIColor clearColor];
    indicatorLabel.textAlignment = NSTextAlignmentCenter;
    indicatorLabel.textColor = XWhite;
    indicatorLabel.font = XFontBold_18;
    indicatorLabel.text = @"%0";
    [progressView addSubview:indicatorLabel];
    self.progressLabel = indicatorLabel;
    
    
    UIButton *indicatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    indicatorButton.frame = CGRectMake(0, indicatorLabel.frame.origin.y+indicatorLabel.frame.size.height, PROGRESS_VIEW_WIDTH, PROGRESS_VIEW_HEIGHT-(indicatorLabel.frame.origin.y+indicatorLabel.frame.size.height));
    indicatorButton.layer.borderWidth = 1.0;
    indicatorButton.layer.borderColor = [XBlack CGColor];
    UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, indicatorButton.frame.size.width, indicatorButton.frame.size.height)];
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    buttonLabel.textColor = XWhite;
    buttonLabel.font = XFontBold_16;
    //    取消更新
    buttonLabel.text = NSLocalizedString(@"cancel_update", nil);
    [indicatorButton addSubview:buttonLabel];
    [buttonLabel release];
    [indicatorButton addTarget:self action:@selector(onCancelUpdateButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [indicatorButton addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
    [indicatorButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
    [indicatorButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    [indicatorButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    [progressView addSubview:indicatorButton];
    
    [self.progressMaskView addSubview:progressView];
    
    self.progressView = progressView;
    
    [indicatorLabel release];
    [progressView release];
    
    [self.progressMaskView setHidden:YES];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)lightButton:(UIView*)view{
    view.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    view.backgroundColor = [UIColor clearColor];
}

-(void)onViewDeviceInfoButtonPress:(UIButton*)button{
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    self.isSendRomoteMessageInCurrentInterface = YES;//设备检查更新
    
    [[P2PClient sharedClient] getDeviceInfoWithId:self.contact.contactId password:self.contact.contactPassword];
}

-(void)onCancelUpdateButtonPress:(UIButton*)button{
    [self normalButton:button];
    self.isSendRomoteMessageInCurrentInterface = YES;//设备检查更新
    [[P2PClient sharedClient] cancelDeviceUpdateWithId:self.contact.contactId password:self.contact.contactPassword];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(didHiddenProgressMaskView) userInfo:nil repeats:NO];
}

-(void)didHiddenProgressMaskView{
    if (!_isCancelUpdateDeviceOk) {
        [self.progressMaskView setHidden:YES];
        [self.view makeToast:NSLocalizedString(@"device_update_timeout", nil)];
    }
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.contact.contactType==CONTACT_TYPE_IPC)
    {
        return 12;
    }
    else
    {
        return 11;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //        static NSString *identifier = @"SettingCell";
    NSString *identifier = [NSString stringWithFormat:@"cell%d%d",indexPath.section,indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        [cell setBackgroundColor:XWhite];
        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = XFontBold_16;
    int row = indexPath.row;
    
    if(row==0){
        cell.textLabel.text = NSLocalizedString(@"time_set", nil);
        //        UILabel *time_setLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        time_setLab.text = NSLocalizedString(@"time_set", nil);
        //        time_setLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:time_setLab];
        //        [time_setLab release];
        
    }else if(row==1){
        cell.textLabel.text = NSLocalizedString(@"media_set", nil);
        //        UILabel *media_setLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        media_setLab.text = NSLocalizedString(@"media_set", nil);
        //        media_setLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:media_setLab];
        //        [media_setLab release];
        
        
    }else if(row==2){
        cell.textLabel.text = NSLocalizedString(@"security_set", nil);
        //        UILabel *security_setLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        security_setLab.text = NSLocalizedString(@"security_set", nil);
        //        security_setLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:security_setLab];
        //        [security_setLab release];
        
        
    }else if(row==3){
        cell.textLabel.text = NSLocalizedString(@"network_set", nil);
        //        UILabel *network_setLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        network_setLab.text = NSLocalizedString(@"network_set", nil);
        //        network_setLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:network_setLab];
        //        [network_setLab release];
        
        
    }else if(row==4){
        cell.textLabel.text = NSLocalizedString(@"alarm_set", nil);
        //        UILabel *alarm_setLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        alarm_setLab.text = NSLocalizedString(@"alarm_set", nil);
        //        alarm_setLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:alarm_setLab];
        //        [alarm_setLab release];
        
        
    }else if (row == 5){
        cell.textLabel.text = NSLocalizedString(@"FTP", nil);
        //        UILabel *FTPLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        FTPLab.text = NSLocalizedString(@"FTP", nil);
        //        FTPLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:FTPLab];
        //        [FTPLab release];
        
        
    }
    else if(row==6){
        cell.textLabel.text = NSLocalizedString(@"record_set", nil);
        //        UILabel *record_setLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        record_setLab.text = NSLocalizedString(@"record_set", nil);
        //        record_setLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:record_setLab];
        //        [record_setLab release];
        
        
    }else if(row==7){
        cell.textLabel.text = NSLocalizedString(@"defenceArea_set", nil);
        //        UILabel *defenceArea_setLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        defenceArea_setLab.text = NSLocalizedString(@"defenceArea_set", nil);
        //        defenceArea_setLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:defenceArea_setLab];
        //        [defenceArea_setLab release];
        
        
    }else if(row==8){
        cell.textLabel.text = NSLocalizedString(@"storage_info", nil);
        //        UILabel *storage_infoLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        storage_infoLab.text = NSLocalizedString(@"storage_info", nil);
        //        storage_infoLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:storage_infoLab];
        //        [storage_infoLab release];
        
    }else if (row ==9){
        cell.textLabel.text = NSLocalizedString(@"restart_set", nil);
        //        UILabel *urestart_setLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        urestart_setLab.text = NSLocalizedString(@"restart_set", nil);
        //        urestart_setLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:urestart_setLab];
        //        [urestart_setLab release];
        
        
    }else if(row==10){
        cell.textLabel.text = NSLocalizedString(@"remote_reset", nil);
        //        UILabel *remote_resetLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
        //        remote_resetLab.text = NSLocalizedString(@"remote_reset", nil);
        //        remote_resetLab.font = [UIFont boldSystemFontOfSize:16];
        //        [cell.contentView addSubview:remote_resetLab];
        //        [remote_resetLab release];
        
    }
    else if (row==11){
        {
            cell.textLabel.text = NSLocalizedString(@"device_update",nil);
            //            UILabel *updateLab = [[UILabel alloc] initWithFrame:CGRectMake(40,BAR_IMAGE_HEIGHT , 150, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
            //            updateLab.text = NSLocalizedString(@"device_update", nil);
            //            updateLab.font = [UIFont boldSystemFontOfSize:16];
            //            [cell.contentView addSubview:updateLab];
            //            [updateLab release];
            
            
            UIImageView *updateImg = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-BAR_IMAGE_WEIGHT*4, BAR_IMAGE_HEIGHT, 40, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
            //             UIImageView *updateImg = [[UIImageView alloc] initWithFrame:CGRectMake(updateLab.frame.size.width + 5, BAR_IMAGE_HEIGHT, 40, BAR_BUTTON_HEIGHT-BAR_IMAGE_WEIGHT)];
            updateImg.contentMode = UIViewContentModeScaleAspectFit;
            if (!self.contact.isNewVersionDevice) {
                updateImg.image = [UIImage imageNamed:@""];
            }else{
                updateImg.image = [UIImage imageNamed:@"updatenew"];
            }
            [cell.contentView addSubview:updateImg];
            [updateImg release];
            
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int section = indexPath.section;
    int row = indexPath.row;
    NSLog(@"----------%d",indexPath.row);
    switch(section){
        case 0:
        {
            if(row==0){
                TimeSettingController *timeSettingController = [[TimeSettingController alloc] init];
                timeSettingController.contact = self.contact;
                [self presentViewController:timeSettingController animated:YES completion:nil];
                [timeSettingController release];
                
            }else if(row==1){
                VideoSettingController *videoSettingController = [[VideoSettingController alloc] init];
                videoSettingController.contact = self.contact;
                [self presentViewController:videoSettingController animated:YES completion:nil];
                [videoSettingController release];
                
            }else if(row==2){
                SecuritySettingController *securitySettingController = [[SecuritySettingController alloc] init];
                securitySettingController.contact = self.contact;
                AutoNavigation *autoNavigation = [[AutoNavigation alloc] initWithRootViewController:securitySettingController];
                [self presentViewController:autoNavigation animated:YES completion:nil];
                [securitySettingController release];
                [autoNavigation release];
                
            }else if(row==3){
                NetSettingControllerEX * netSettingControllerEX = [[NetSettingControllerEX alloc] init];
                netSettingControllerEX.contact = self.contact;
                AutoNavigation *autoNavigationEX = [[AutoNavigation alloc] initWithRootViewController:netSettingControllerEX];
                [self presentViewController:autoNavigationEX animated:YES completion:nil];
                [netSettingControllerEX release];
                [autoNavigationEX release];
                
            }else if(row==4){
                AlarmSettingController *alarmSettingController = [[AlarmSettingController alloc] init];
                alarmSettingController.contact = self.contact;
                //[self presentViewController:alarmSettingController animated:YES completion:nil];
                [self.navigationController pushViewController:alarmSettingController animated:YES];
                [alarmSettingController release];
                
            }else if (row==5) {
                FTPController *FTPcontroller = [[FTPController alloc] init];
                FTPcontroller.contact = self.contact;
                [self.navigationController pushViewController:FTPcontroller animated:YES];
                [FTPcontroller release];
            }
            else if(row==6){
                RecordSettingController *recordSettingController = [[RecordSettingController alloc] init];
                recordSettingController.contact = self.contact;
                [self presentViewController:recordSettingController animated:YES completion:nil];
                [recordSettingController release];
                
            }else if(row==7){
                DefenceSettingController  *defenceSettingController = [[DefenceSettingController alloc] init];
                defenceSettingController.contact = self.contact;
                [self presentViewController:defenceSettingController animated:YES completion:nil];
                [defenceSettingController release];
            }
            else if(row==8){
                [[P2PClient sharedClient] getSDCardInfoWithId:self.contact.contactId password:self.contact.contactPassword];
            }
            else if(row==9){
                UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"select_restart", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
                resetAlert.tag = ALERT_TAG_RESTAR;
                [resetAlert show];
                [resetAlert release];
                
            }else if(row==10){
                UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"select_reset", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
                resetAlert.tag = ALERT_TAG_RESET;
                [resetAlert show];
                [resetAlert release];
                
            }else if(row==11){
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                self.isSendRomoteMessageInCurrentInterface = YES;//设备检查更新
                [[P2PClient sharedClient] checkDeviceUpdateWithId:self.contact.contactId password:self.contact.contactPassword];
            }
        }
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_UPDATE:
        {
            if(buttonIndex==1){
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                self.isSendRomoteMessageInCurrentInterface = YES;//设备检查更新
                [[P2PClient sharedClient] doDeviceUpdateWithId:self.contact.contactId password:self.contact.contactPassword];
            }else{
                self.isSendRomoteMessageInCurrentInterface = YES;//设备检查更新
                [[P2PClient sharedClient] cancelDeviceUpdateWithId:self.contact.contactId password:self.contact.contactPassword];
            }
        }
            break;
        case ALERT_TAG_RESET:
        {
            if (buttonIndex == 1)
            {
                self.isSendRomoteMessageInCurrentInterface = YES;//设备检查更新
                [[P2PClient sharedClient]remoteResetWithId:self.contact.contactId password:self.contact.contactPassword state:1];
            }
        }
            break;
        case ALERT_TAG_RESTAR:
        {
            if (buttonIndex == 1)
            {
                self.lastTime = 2;
                self.lastValue =1;
                [[P2PClient sharedClient] setDeviceRemoteRebootRWithId:self.contact.contactId password:self.contact.contactPassword value:self.lastTime bRebootType:self.lastValue];
            }
        }
            break;
    }
}


#define INFO_VIEW_WIDTH 240
#define INFO_VIEW_HEIGHT 200
#define TITLE_LABEL_HEIGHT 40

-(void)showDeviceInfoViewWithCurVersion:(NSString*)curVersion kernelVersion:(NSString*)kernelVersion rootfsVersion:(NSString*)rootfsVersion ubootVersion:(NSString*)ubootVersion
{
    UIButton *parent = [UIButton buttonWithType:UIButtonTypeCustom];
    parent.tag = 800;
    parent.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    parent.backgroundColor = XBlack_128;
    [parent addTarget:self action:@selector(hideDeviceInfoView:) forControlEvents:UIControlEventTouchUpInside];
    parent.alpha = 0.3;
    [self.view addSubview:parent];
    
    /*设备信息view*/
    UIButton *infoView = [UIButton buttonWithType:UIButtonTypeCustom];
    infoView.layer.borderWidth = 2;
    infoView.layer.borderColor = [XBlack CGColor];
    infoView.backgroundColor = XBlack_128;
    infoView.frame = CGRectMake((parent.frame.size.width-INFO_VIEW_WIDTH)/2, (parent.frame.size.height-INFO_VIEW_HEIGHT)/2, INFO_VIEW_WIDTH, INFO_VIEW_HEIGHT);
    [infoView.layer setCornerRadius:10.0];//圆角
    [infoView.layer setMasksToBounds:YES];
    [infoView addTarget:self action:@selector(hideDeviceInfoView:) forControlEvents:UIControlEventTouchUpInside];
    [parent addSubview:infoView];
    
    DWORD interval = 10;
    DWORD itemHeight = (INFO_VIEW_HEIGHT-interval*2)/5;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, interval, infoView.frame.size.width, itemHeight)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = UIColorFromRGB(0xffffff);
    titleLabel.font = XFontBold_16;
    titleLabel.text = NSLocalizedString(@"device_info", nil);
    [infoView addSubview:titleLabel];
    [titleLabel release];
#pragma mark - 设备信息
    NSArray* arrayString = [NSArray arrayWithObjects:
                            NSLocalizedString(@"cur_version", nil), curVersion,
                            NSLocalizedString(@"kernel_version", nil), kernelVersion,
                            NSLocalizedString(@"rootfs_version", nil), rootfsVersion,
                            NSLocalizedString(@"uboot_version", nil), ubootVersion, nil];
    
    for(int i=0;i<8;i++){
        int x = i%2;
        int y = i/2;
        CGFloat itemWidth = INFO_VIEW_WIDTH/2;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x*itemWidth+25, titleLabel.frame.origin.y+titleLabel.frame.size.height+y*itemHeight, itemWidth, itemHeight)];
        label.backgroundColor = [UIColor clearColor];
        label.text = [arrayString objectAtIndex:i];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = UIColorFromRGB(0xffffff);
        label.font = XFontBold_16;
        [infoView addSubview:label];
        [label release];
    }
    
    [UIView transitionWithView:parent duration:0.3 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        parent.alpha = 1.0;
                    }
     
                    completion:^(BOOL Finished){
                        
                    }
     ];
    
    infoView.transform = CGAffineTransformMakeScale(0.6,0.6);
    [UIView transitionWithView:infoView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        infoView.transform = CGAffineTransformMakeScale(1.0,1.0);
                    }
     
                    completion:^(BOOL Finished){
                        
                    }
     ];
}

-(void)hideDeviceInfoView:(UIButton*)button{
    
    UIButton *parent = (UIButton*)[self.view viewWithTag:800];
    [UIView transitionWithView:parent duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        parent.alpha = 0.3;
                    }
     
                    completion:^(BOOL Finished){
                        
                    }
     ];
    
    UIButton *infoView = [[parent subviews] objectAtIndex:0];
    
    [UIView transitionWithView:infoView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        infoView.transform = CGAffineTransformMakeScale(0.6,0.6);
                    }
     
                    completion:^(BOOL Finished){
                        [parent removeFromSuperview];
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

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (void) handlePan: (UIPanGestureRecognizer *)recognizer
{
    //do nothing. write this for shield recognizer in the control's view
}
@end
