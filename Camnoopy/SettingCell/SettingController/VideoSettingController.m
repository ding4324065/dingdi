

#import "VideoSettingController.h"
#import "P2PClient.h"
#import "Constants.h"
#import "Toast+UIView.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "P2PVideoFormatSettingCell.h"
#import "P2PVideoVolumeSettingCell.h"
#import "TopBar.h"
#import "RadioButton.h"
#import "P2PSwitchCell.h"
#import "MBProgressHUD.h"
@interface VideoSettingController ()

@end

@implementation VideoSettingController
-(void)dealloc{
    [self.radio1 release];
    [self.radio2 release];
    [self.tableView release];
    [self.contact release];
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
    self.isVideoVolumeLoading = YES;
    self.isVideoFormatLoading = YES;
    self.isLoadingImageInversion = YES;
    self.imageInversionState = SETTING_VALUE_IMAGE_INVERSION_STATE_OFF;
    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_GET_NPCSETTINGS_VIDEO_FORMAT:
        {
            
            NSInteger type = [[parameter valueForKey:@"type"] intValue];
            self.isInitNpcSettings = YES;
            self.isVideoFormatLoading = NO;
            self.videoType = type;
            self.lastSetVideoType = type;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.progressAlert hide:YES];
                [self.tableView reloadData];
            });
            DLog(@"video type:%i",type);
            
        }
            break;
        case RET_GET_NPCSETTINGS_VIDEO_VOLUME:
        {
            NSInteger value = [[parameter valueForKey:@"value"] intValue];
            self.isInitNpcSettings = YES;
            self.isVideoVolumeLoading = NO;
            self.videoVolume = value;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.progressAlert hide:YES];
                [self.tableView reloadData];
            });
            DLog(@"video volume:%i",value);
        }
            break;
        case RET_SET_NPCSETTINGS_VIDEO_FORMAT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isVideoFormatLoading = NO;
            if(result==0){
                self.lastSetVideoType = self.videoType;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastSetVideoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_NTSC){
                        self.videoType = self.lastSetVideoType;
                        [self.radio1 setSelected:NO];
                        [self.radio2 setSelected:YES];
                    }else if(self.lastSetVideoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_PAL){
                        self.videoType = self.lastSetVideoType;
                        [self.radio1 setSelected:YES];
                        [self.radio2 setSelected:NO];
                    }
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            
        case RET_SET_NPCSETTINGS_VIDEO_VOLUME:
        {
            
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isVideoVolumeLoading = NO;
            if(result==0){
                self.lastSetVideoVolume = self.videoVolume;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.videoVolume = self.lastSetVideoVolume;
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            
        case RET_GET_NPCSETTINGS_IMAGE_INVERSION:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            self.isSupportImageInversion = YES;
            self.imageInversionState = state;
            self.lastImageInversionState = state;
            self.isLoadingImageInversion = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"image inversion state:%i",state);
            
        }
            break;
            
        case RET_SET_NPCSETTINGS_IMAGE_INVERSION:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingImageInversion = NO;
            if(result==0)
            {
                self.lastImageInversionState = self.imageInversionState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastImageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_ON){
                        self.imageInversionState = self.lastImageInversionState;
                        self.imageInversionSwitch.on = YES;
                        
                    }else if(self.lastImageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_OFF){
                        self.imageInversionState = self.lastImageInversionState;
                        self.imageInversionSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
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
        case ACK_RET_SET_NPCSETTINGS_VIDEO_FORMAT:
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
                    DLog(@"resend set video format");
                    [[P2PClient sharedClient] setVideoFormatWithId:self.contact.contactId password:self.contact.contactPassword type:self.lastSetVideoType];
                }
            });
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_VIDEO_FORMAT:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_VIDEO_VOLUME:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result == 1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set video volume");
                    [[P2PClient sharedClient] setVideoVolumeWithId:self.contact.contactId password:self.contact.contactPassword value:self.videoVolume];
                }
            });
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_VIDEO_VOLUME:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_IMAGE_INVERSION:
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
                    DLog(@"resend set image inversion state");
                    [[P2PClient sharedClient] setImageInversionWithId:self.contact.contactId password:self.contact.contactPassword state:self.imageInversionState];
                }
            });
            DLog(@"ACK_RET_SET_NPCSETTINGS_IMAGE_INVERSION:%i",result);
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
//    媒体设置
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"media_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
}

#pragma mark 自定义类似弹框
-(void)sheetViewinit{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat rowheight = CUSTOM_VIEW_HEIGHT_SHORT/4;
    
    UIView * alphaView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    alphaView.backgroundColor = XBlack_128;
    [self.view addSubview:alphaView];
    self.alphaView = alphaView;
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, CUSTOM_VIEW_HEIGHT_SHORT)];
    view.backgroundColor = XWhite;
    [alphaView addSubview:view];
    self.selectView = view;
    [view release];
    [alphaView release];
#pragma mark - 视频制式选择框
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, rowheight)];
    label.backgroundColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"video_format", nil);
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = XWhite;
    [self.selectView addSubview:label];
    [label release];
    
    UILabel * linelabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, rowheight*2, width, 1)];
    linelabel1.backgroundColor = XGray;
    [self.selectView addSubview:linelabel1];
    [linelabel1 release];
    
    UILabel * linelabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, rowheight*3, width, 1)];
    linelabel2.backgroundColor = XGray;
    [self.selectView addSubview:linelabel2];
    [linelabel2 release];
    
    RadioButton *radio1 = [[RadioButton alloc] initWithFrame:CGRectMake(0, rowheight, width, rowheight-1)];
    [radio1 setText:NSLocalizedString(@"video_format_pal", nil)];
    [self.selectView addSubview:radio1];
    [radio1 addTarget:self action:@selector(onPalRadioPress:) forControlEvents:UIControlEventTouchUpInside];
    self.radio1 = radio1;
    
    
    RadioButton *radio2 = [[RadioButton alloc] initWithFrame:CGRectMake(0, rowheight*2, width, 34)];
    [radio2 setText:NSLocalizedString(@"video_format_ntsc", nil)];
    [self.selectView addSubview:radio2];
    [radio2 addTarget:self action:@selector(onNstcRadioPress:) forControlEvents:UIControlEventTouchUpInside];
    self.radio2 = radio2;
    
    
    if (self.videoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_PAL) {
        [self.radio1 setSelected:YES];
        [self.radio2 setSelected:NO];
    }else if (self.videoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_NTSC){
        [self.radio1 setSelected:NO];
        [self.radio2 setSelected:YES];
    }
    
    [radio2 release];
    [radio1 release];
    
    UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"new_button.png"] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    [button setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [button setTitleColor:XWhite forState:UIControlStateNormal];
    button.frame=CGRectMake(20, rowheight*3+5, width-2*20, rowheight - 3*2);
    [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.selectView addSubview:button];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.alphaView addGestureRecognizer:tap];
    [tap release];
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
    self.selectView.frame = CGRectMake(0, height-CUSTOM_VIEW_HEIGHT_SHORT, width, CUSTOM_VIEW_HEIGHT_SHORT);
    self.alphaView.frame = CGRectMake(0, 0, width, height);
    
    [UIView setAnimationDelegate:self];
    // 动画完毕后调用animationFinished
    [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    [UIView commitAnimations];
}

-(void)cancel{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
        self.selectView.frame = CGRectMake(0, height, width, CUSTOM_VIEW_HEIGHT_SHORT);
        //    self.alphaView.frame = CGRectMake(0, height, width, height);
        
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
    
}

-(void)animationFinished{
    //NSLog(@"动画结束!");
    
}

-(void)onNstcRadioPress:(id)sender{
    self.isVideoFormatLoading = YES;
    self.lastSetVideoType = self.videoType;
    self.videoType = SETTING_VALUE_VIDEO_FORMAT_TYPE_NTSC;
    [self.radio1 setSelected:YES];
    [self.radio2 setSelected:NO];
    [self cancel];
    
    [[P2PClient sharedClient] setVideoFormatWithId:self.contact.contactId password:self.contact.contactPassword type:SETTING_VALUE_VIDEO_FORMAT_TYPE_PAL];
}

-(void)onPalRadioPress:(id)sender{
    self.isVideoFormatLoading = YES;
    self.lastSetVideoType = self.videoType;
    self.videoType = SETTING_VALUE_VIDEO_FORMAT_TYPE_PAL;
    [self.radio1 setSelected:NO];
    [self.radio2 setSelected:YES];
    [self cancel];
    
    [[P2PClient sharedClient] setVideoFormatWithId:self.contact.contactId password:self.contact.contactPassword type:SETTING_VALUE_VIDEO_FORMAT_TYPE_NTSC];
    
    
}
-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.isSupportImageInversion){
        return 3;
    }else{
        return 2;
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return BAR_BUTTON_HEIGHT;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0&&indexPath.row==0) {
        return YES;
    }else
    return NO;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PSettingCell1";
    static NSString *identifier2 = @"P2PSettingCell2";
    static NSString *identifier3 = @"P2PSwitchCell";
    UITableViewCell *cell = nil;
    
    int section = indexPath.section;
    
    if(section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PVideoFormatSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XWhite];
        }
    }else if(section==1){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if(cell==nil){
            cell = [[[P2PVideoVolumeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
            [cell setBackgroundColor:XWhite];
        }
    }else if(section==2){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
        if(cell==nil){
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
            [cell setBackgroundColor:XWhite];
        }
    }
    
    switch (section) {
        case 0:
        {
            P2PVideoFormatSettingCell *cell1 = (P2PVideoFormatSettingCell*)cell;
            if(!self.isVideoFormatLoading)
            {
                [cell1 setProgressViewHidden:YES];
                [cell1 setRightLabelHidden:NO];
                
                if (self.videoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_NTSC)
                {
//                    60Hz
                    [cell1 setRightLabelText:NSLocalizedString(@"video_format_ntsc", nil)];
                }
                else if (self.videoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_PAL)
                {
//                    50Hz
                    [cell1 setRightLabelText:NSLocalizedString(@"video_format_pal", nil)];
                }
            }
            else
            {
                [cell1 setProgressViewHidden:NO];
                [cell1 setRightLabelHidden:YES];
            }
            
            [cell1 setLeftLabelText:NSLocalizedString(@"video_format", nil)];//视频制式
        }
            break;
            
        case 1:
        {
            P2PVideoVolumeSettingCell *cell2 = (P2PVideoVolumeSettingCell*)cell;
            [cell2 setLeftLabelHidden:NO];
            
            if(!self.isVideoVolumeLoading){
                [cell2 setProgressViewHidden:YES];
                [cell2 setCustomViewHidden:NO];
            }else{
                [cell2 setProgressViewHidden:NO];
                [cell2 setCustomViewHidden:YES];
            }
            
            [cell2 setLeftLabelText:NSLocalizedString(@"volume", nil)];
            [cell2 setVolumeValue:self.videoVolume];
            [cell2.slider addTarget:self action:@selector(onSlider:) forControlEvents:UIControlEventValueChanged];
            [cell2.slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpOutside];
            [cell2.slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpInside];
            [cell2.slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchCancel];
        }
            break;
            
        case 2:
        {
//            图像倒转
            P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
            [cell2 setLeftLabelText:NSLocalizedString(@"image_inversion", nil)];
            cell2.delegate = self;
            cell2.indexPath = indexPath;
            self.imageInversionSwitch = cell2.switchView;
            if(self.isLoadingImageInversion){
                [cell2 setProgressViewHidden:NO];
                [cell2 setSwitchViewHidden:YES];
            }else{
                [cell2 setProgressViewHidden:YES];
                [cell2 setSwitchViewHidden:NO];
                if(self.imageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_ON){
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0&&indexPath.row==0&&!self.isVideoFormatLoading)
    {
        [self sheetViewinit];
        [self animationstart];
    }

}

-(void)onSwitchValueChange:(UISwitch *)sender indexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 2:
        {
            if(self.imageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_OFF&&sender.on){
                self.isLoadingImageInversion = YES;
                
                self.lastImageInversionState = self.imageInversionState;
                self.imageInversionState = SETTING_VALUE_IMAGE_INVERSION_STATE_ON;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setImageInversionWithId:self.contact.contactId password:self.contact.contactPassword state:self.imageInversionState];
            }else if(self.imageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_ON&&!sender.on){
                self.isLoadingImageInversion = YES;
                
                self.lastImageInversionState = self.imageInversionState;
                self.imageInversionState = SETTING_VALUE_IMAGE_INVERSION_STATE_OFF;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setImageInversionWithId:self.contact.contactId password:self.contact.contactPassword state:self.imageInversionState];
            }
            
        }
            break;
    }
}

-(void)onSlider:(id)sender{
    
}

-(void)onSliderEnd:(id)sender{
    
    UISlider *slider = (UISlider*)sender;
    int iValue = (int)slider.value;
    [slider setValue:iValue];
    self.isVideoVolumeLoading = YES;
    self.lastSetVideoVolume = self.videoVolume;
    self.videoVolume = iValue;
    [self.tableView reloadData];
    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    
    [[P2PClient sharedClient] setVideoVolumeWithId:self.contact.contactId password:self.contact.contactPassword value:iValue];
    DLog(@"%i",iValue);
}

-(BOOL)shouldAutorotate{
    return YES;
}
//是否可以旋转
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

- (void) handleTap: (UITapGestureRecognizer *)recognizer
{
    if (self.selectView == nil) {
        return;
    }
    CGPoint point = [recognizer locationInView:self.alphaView];
    
    if (!CGRectContainsPoint(self.selectView.frame, point)) {
        [self cancel];
    }
}












@end
