
#define RGBA(r,g,b,a)               [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:(float)a]

#import "RecordSettingController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Toast+UIView.h"
#import "Constants.h"
#import "Contact.h"
#import "Utils.h"
#import "P2PClient.h"
#import "P2PEmailSettingCell.h"
#import "P2PRecordTypeCell.h"
#import "P2PRecordTimeCell.h"
#import "P2PTimeSettingCell.h"
#import "RadioButton.h"
#import "P2PPlanTimeSettingCell.h"
#import "PlanTimePickView.h"
#import "P2PSwitchCell.h"
#import "P2PSecurityCell.h"
#import "MBProgressHUD.h"
@interface RecordSettingController ()

@end

@implementation RecordSettingController
-(void)dealloc{
    [self.radioRecordType1 release];
    [self.radioRecordType2 release];
    [self.radioRecordType3 release];
    [self.tableView release];
    [self.contact release];
    
    [self.planPicker1 release];
    [self.planPicker2 release];
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
    
    self.isLoadingRecordType = YES;
    self.isFirstCompoleteLoadRecordType = NO;
    self.recordType = SETTING_VALUE_RECORD_MANUAL;
    self.isLoadingRecordTime = YES;
    self.recordTime = SETTING_VALUE_RECORD_TIME_ONE;
    self.isLoadingRecordPlanTime = YES;
    
    self.isLoadingRemoteRecord = YES;
    self.remoteRecordState = SETTING_VALUE_REMOTE_RECORD_STATE_ON;
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
        case RET_GET_NPCSETTINGS_RECORD_TYPE:
        {
            NSInteger type = [[parameter valueForKey:@"type"] intValue];
            
            self.recordType = type;
            self.isFirstCompoleteLoadRecordType = YES;
            self.isLoadingRecordType = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
            DLog(@"record type:%i",type);
            
        }
            break;
        case RET_SET_NPCSETTINGS_RECORD_TYPE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingRecordType = NO;
            if(result==0){
                self.lastRecordType = self.recordType;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.recordType = self.lastRecordType;
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_RECORD_TIME:
        {
            NSInteger time = [[parameter valueForKey:@"time"] intValue];
            
            self.recordTime = time;
            self.isFirstCompoleteLoadRecordType = YES;
            self.isLoadingRecordTime = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            DLog(@"record time:%i",time);
        }
            break;
        case RET_SET_NPCSETTINGS_RECORD_TIME:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingRecordTime = NO;
            if(result==0){
                self.lastRecordTime = self.recordTime;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.recordTime = self.lastRecordTime;
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_RECORD_PLAN_TIME:      //计划录像时间设置
        {
            NSInteger time = [[parameter valueForKey:@"time"] intValue];
            
            self.planTime = time;
            self.timestring = [NSString stringWithFormat:@"%02d:%02d-%02d:%02d",(time>>24) & 0xff,(time>>8) & 0xff,(time>>16) & 0xff,time & 0xff];
            self.isFirstCompoleteLoadRecordType = YES;
            self.isLoadingRecordPlanTime = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.beginhour setCurrentSelectPage:(time>>24) & 0xff];
                [self.endhour setCurrentSelectPage:(time>>16) & 0xff];
                [self.beginmin setCurrentSelectPage:(time>>8) & 0xff];
                [self.endmin setCurrentSelectPage:time & 0xff];
                
                [self.beginhour reloadData];
                [self.beginmin reloadData];
                [self.endhour reloadData];
                [self.endmin reloadData];
            });
            DLog(@"record plan time:%i",time);
        }
            break;
        case RET_SET_NPCSETTINGS_RECORD_PLAN_TIME:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingRecordPlanTime = NO;
            if(result==0){
                self.lastPlanTime = self.planTime;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.planTime = self.lastPlanTime;
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_REMOTE_RECORD:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.remoteRecordState = state;
            if (self.isSetRemoteRecordState) {
                if (self.remoteRecordState == SETTING_VALUE_REMOTE_RECORD_STATE_OFF) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.view makeToast:NSLocalizedString(@"device_not_support_no_storage", nil)];
                    });
                }
                self.isSetRemoteRecordState = NO;
            }
            self.isLoadingRemoteRecord = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"remote record state:%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_REMOTE_RECORD:
        {
            //            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
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
        case ACK_RET_SET_NPCSETTINGS_RECORD_TYPE:
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
                    DLog(@"resend set record type");
                    [[P2PClient sharedClient] setRecordTypeWithId:self.contact.contactId password:self.contact.contactPassword type:self.recordType];
                }
                
                
            });
            DLog(@"ACK_RET_SET_NPCSETTINGS_RECORD_TYPE:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_RECORD_TIME:
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
                    DLog(@"resend set record time");
                    [[P2PClient sharedClient] setRecordTimeWithId:self.contact.contactId password:self.contact.contactPassword value:self.recordTime];
                }
                
                
            });
            DLog(@"ACK_RET_SET_NPCSETTINGS_RECORD_TIME:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_RECORD_PLAN_TIME:
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
                    DLog(@"resend set record plan time");
                    [[P2PClient sharedClient] setRecordPlanTimeWithId:self.contact.contactId password:self.contact.contactPassword time:self.planTime];
                }
                
                
            });
            DLog(@"ACK_RET_SET_NPCSETTINGS_RECORD_PLAN_TIME:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_REMOTE_RECORD:
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
                    DLog(@"resend set remote record state");
                    [[P2PClient sharedClient] setRemoteRecordWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteRecordState];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_REMOTE_RECORD:%i",result);
        }
            break;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
    [self inittimepicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)inittimepicker{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width/8;
    CGFloat width1 = rect.size.width;
    CGFloat rowheight = BAR_BUTTON_HEIGHT;
    NSArray * arr = @[@"1",@"2",@"5",@"6"];
    NSArray * headarr = @[NSLocalizedString(@"hour", nil),NSLocalizedString(@"minute", nil),NSLocalizedString(@"hour", nil),NSLocalizedString(@"minute", nil)];
    self.timepicker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, BAR_BUTTON_HEIGHT*5)];
    //self.timepicker.backgroundColor = XBlue;
    for (int  i = 0; i<arr.count; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(width*[arr[i] integerValue], 0, width, BAR_BUTTON_HEIGHT)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = XFontBold_16;
        label.text = headarr[i];
        [self.timepicker addSubview:label];
    }
    UILabel * beglabel = [[UILabel alloc] initWithFrame:CGRectMake(width, BAR_BUTTON_HEIGHT*4, width*2, BAR_BUTTON_HEIGHT)];
    beglabel.textAlignment = NSTextAlignmentCenter;
    beglabel.font = XFontBold_16;
    beglabel.text = NSLocalizedString(@"start_time", nil);
    [self.timepicker addSubview:beglabel];
    UILabel * endlabel = [[UILabel alloc] initWithFrame:CGRectMake(width*5, BAR_BUTTON_HEIGHT*4, width*2, BAR_BUTTON_HEIGHT)];
    endlabel.textAlignment = NSTextAlignmentCenter;
    endlabel.font = XFontBold_16;
    endlabel.text = NSLocalizedString(@"end_time", nil);
    [self.timepicker addSubview:endlabel];
    self.beginhour = [[MXSCycleScrollView3 alloc] initWithFrame:CGRectMake(width,BAR_BUTTON_HEIGHT, width, BAR_BUTTON_HEIGHT*3)];
    self.beginhour.delegate = self;
    self.beginhour.datasource = self;
    [self.beginhour reloadData];
    [self setAfterScrollShowView:self.beginhour andCurrentPage:1];
    //    [self.beginhour setCurrentSelectPage:2];
    [self.timepicker addSubview:_beginhour];
    
    self.beginmin = [[MXSCycleScrollView3 alloc] initWithFrame:CGRectMake(width*2,BAR_BUTTON_HEIGHT, width, BAR_BUTTON_HEIGHT*3)];
    self.beginmin.delegate = self;
    self.beginmin.datasource = self;
    [self.beginmin reloadData];
    [self setAfterScrollShowView:self.beginmin andCurrentPage:1];
    [self.timepicker addSubview:_beginmin];
    
    self.endhour = [[MXSCycleScrollView3 alloc] initWithFrame:CGRectMake(width*5,BAR_BUTTON_HEIGHT, width, BAR_BUTTON_HEIGHT*3)];
    self.endhour.delegate = self;
    self.endhour.datasource = self;
    [self.endhour reloadData];
    [self setAfterScrollShowView:self.endhour andCurrentPage:1];
    [self.timepicker addSubview:_endhour];
    
    self.endmin = [[MXSCycleScrollView3 alloc] initWithFrame:CGRectMake(width*6,BAR_BUTTON_HEIGHT, width, BAR_BUTTON_HEIGHT*3)];
    self.endmin.delegate = self;
    self.endmin.datasource = self;
    [self.endmin reloadData];
    [self setAfterScrollShowView:self.endmin andCurrentPage:1];
    [self.timepicker addSubview:_endmin];
    
    //    UIView *beforeSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, BAR_BUTTON_HEIGHT+rowheight, width1, 1.0)];
    //    [beforeSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    //    [_timepicker addSubview:beforeSepLine];
    
    UIView *middleSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, BAR_BUTTON_HEIGHT+rowheight, width1, 0.5)];
    [middleSepLine setBackgroundColor:[UIColor blackColor]];
    [_timepicker addSubview:middleSepLine];
    
    //    UIView * middlebule = [[UIView alloc] initWithFrame:CGRectMake(0, BAR_BUTTON_HEIGHT+rowheight, width1/40, rowheight)];
    //    [middlebule setBackgroundColor:[UIColor blueColor]];
    //    [_timepicker addSubview:middlebule];
    
    UIImage* image1= [UIImage imageNamed:@"timeset2.png"];
    image1 = [image1 stretchableImageWithLeftCapWidth:image1.size.width*0.5 topCapHeight:image1.size.height*0.5];
    UIImageView * imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, width1/30, rowheight*5-7)];
    imageview1.image=image1;
    [_timepicker addSubview:imageview1];
    
    UIImage* image2= [UIImage imageNamed:@"timeset2.png"];
    image2 = [image2 stretchableImageWithLeftCapWidth:image2.size.width*0.5 topCapHeight:image2.size.height*0.5];
    UIImageView * imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(width1-width1/30, 0, width1/30, rowheight*5)];
    imageview2.image=image2;
    [_timepicker addSubview:imageview2];
    
    UIView * middlesecSepLine =[[UIView alloc] initWithFrame:CGRectMake(0, BAR_BUTTON_HEIGHT+rowheight*2, width1, 0.5)];
    [middlesecSepLine setBackgroundColor:[UIColor blackColor]];
    [_timepicker addSubview:middlesecSepLine];
    
    //    UIView *bottomSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, BAR_BUTTON_HEIGHT+rowheight*4+1, width1, 1.5)];
    //    [bottomSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    //    [_timepicker addSubview:bottomSepLine];
    
}
- (void)setAfterScrollShowView:(MXSCycleScrollView3 *)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    //    UILabel *oneLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber];
    //    [oneLabel setFont:[UIFont systemFontOfSize:14]];
    //    [oneLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
    UILabel *twoLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber];
    [twoLabel setFont:[UIFont systemFontOfSize:16]];
    [twoLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *currentLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+1];
    [currentLabel setFont:[UIFont systemFontOfSize:18]];
    [currentLabel setTextColor:RGBA(3.0, 162.0, 234.0, 1.0)];
    
    UILabel *threeLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+2];
    [threeLabel setFont:[UIFont systemFontOfSize:16]];
    [threeLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    //    UILabel *fourLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+4];
    //    [fourLabel setFont:[UIFont systemFontOfSize:14]];
    //    [fourLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
}
#pragma mark mxccyclescrollview delegate
#pragma mark mxccyclescrollview databasesource
- (NSInteger)numberOfPages:(MXSCycleScrollView3 *)scrollView
{
    if (scrollView == self.beginhour||scrollView == self.endhour) {
        return 24;
    }
    return 60;
}

- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(MXSCycleScrollView3 *)scrollView
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height/3)];
    
    l.tag = index+100;
    
    l.text = [NSString stringWithFormat:@"%d",index];
    l.font = XFontBold_14;
    l.textAlignment = NSTextAlignmentCenter;
    l.backgroundColor = [UIColor clearColor];
    return l;
}

#pragma mark 当滚动时设置选中的cell
- (void)scrollviewDidChangeNumber
{
    
    UILabel * label = [[(UILabel*)[[self.beginhour subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    label.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    
    label = [[(UILabel*)[[self.beginmin subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    label.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    
    label = [[(UILabel*)[[self.endhour subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    label.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    
    label = [[(UILabel*)[[self.endmin subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    label.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
}
#pragma mark 滚动完成后的回调
- (void)scrollviewDidEndChangeNumber
{
    
    UILabel * beghlabel = [[(UILabel*)[[self.beginhour subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    beghlabel.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    NSString * beghstr = beghlabel.text;
    
    UILabel * begmlabel = [[(UILabel*)[[self.beginmin subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    begmlabel.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    NSString * begmstr = begmlabel.text;
    
    UILabel * endhlabel = [[(UILabel*)[[self.endhour subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    endhlabel.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    NSString * endhstr = endhlabel.text;
    
    UILabel * endmlabel = [[(UILabel*)[[self.endmin subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    endmlabel.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    NSString * endmstr = endmlabel.text;
    
    if ([beghstr integerValue]<10) {
        beghstr = [NSString stringWithFormat:@"0%@",beghstr];
    }
    if ([begmstr integerValue]<10){
        begmstr = [NSString stringWithFormat:@"0%@",begmstr];
    }
    if ([endhstr integerValue]<10){
        endhstr = [NSString stringWithFormat:@"0%@",endhstr];
    }
    if ([endmstr integerValue]<10){
        endmstr = [NSString stringWithFormat:@"0%@",endmstr];
    }
    self.startTimeString = [NSString stringWithFormat:@"%@:%@",beghstr,begmstr];
    self.endTimeString = [NSString stringWithFormat:@"%@:%@",endhstr,endmstr];
    self.timestring = [NSString stringWithFormat:@"%@:%@-%@:%@",beghstr,begmstr,endhstr,endmstr];
    [self.tableView reloadData];
}
-(void)initComponent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"record_set",nil)];
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
    
    UIView * alphaView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    alphaView.backgroundColor = XBlack_128;
    [self.view addSubview:alphaView];
    self.alphaView = alphaView;
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, CUSTOM_VIEW_HEIGHT)];
    view.backgroundColor = XWhite;
    [alphaView addSubview:view];
    self.selectView = view;
    [view release];
    [alphaView release];
    
    //录像模式标题
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 50)];
    label.backgroundColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"record_type", nil);
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [self.selectView addSubview:label];
    
    UILabel * linelabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, width, 1)];
    linelabel1.backgroundColor = XGray;
    [self.selectView addSubview:linelabel1];
    [linelabel1 release];
    
    UILabel * linelabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 150, width, 1)];
    linelabel2.backgroundColor = XGray;
    [self.selectView addSubview:linelabel2];
    [linelabel2 release];
    
    UILabel * linelabel3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 200, width, 1)];
    linelabel3.backgroundColor = XGray;
    [self.selectView addSubview:linelabel3];
    [linelabel3 release];
    
    RadioButton *radio1 = [[RadioButton alloc] initWithFrame:CGRectMake(0, 50, width, 49)];
    radio1.tag = 101;
    [radio1 setText:NSLocalizedString(@"manual_record", nil)];
    [self.selectView addSubview:radio1];
    [radio1 addTarget:self action:@selector(onNetType1Press:) forControlEvents:UIControlEventTouchUpInside];
    self.radio1 = radio1;
    
    
    RadioButton *radio2 = [[RadioButton alloc] initWithFrame:CGRectMake(0, 100, width, 49)];
    radio2.tag = 102;
    [radio2 setText:NSLocalizedString(@"alarm_record", nil)];
    [self.selectView addSubview:radio2];
    [radio2 addTarget:self action:@selector(onNetType1Press:) forControlEvents:UIControlEventTouchUpInside];
    self.radio2 = radio2;
    
    RadioButton *radio3 = [[RadioButton alloc] initWithFrame:CGRectMake(0, 150, width, 49)];
    radio3.tag = 103;
    [radio3 setText:NSLocalizedString(@"timer_record", nil)];
    [self.selectView addSubview:radio3];
    [radio3 addTarget:self action:@selector(onNetType1Press:) forControlEvents:UIControlEventTouchUpInside];
    self.radio3 = radio3;
    
    [self.radio1 setSelected:NO];
    [self.radio2 setSelected:NO];
    [self.radio3 setSelected:NO];
    if (self.isSetRecordModel) {
        if (self.recordType==SETTING_VALUE_RECORD_MANUAL) {
            [self.radio1 setSelected:YES];
        }else if (self.recordType==SETTING_VALUE_RECORD_ALARM){
            [self.radio2 setSelected:YES];
        }else if (self.recordType==SETTING_VALUE_RECORD_TIMER){
            [self.radio3 setSelected:YES];
        }
    }else{
        if (self.recordTime==SETTING_VALUE_RECORD_TIME_ONE) {
            [self.radio1 setSelected:YES];
        }else if (self.recordTime==SETTING_VALUE_RECORD_TIME_TWO){
            [self.radio2 setSelected:YES];
        }else if (self.recordTime==SETTING_VALUE_RECORD_TIME_THREE){
            [self.radio3 setSelected:YES];
        }
    }
    if (self.isSetRecordModel) {
        label.text = NSLocalizedString(@"record_type", nil);
        [radio1 setText:NSLocalizedString(@"manual_record", nil)];
        [radio2 setText:NSLocalizedString(@"alarm_record", nil)];
        [radio3 setText:NSLocalizedString(@"timer_record", nil)];
    }else{
        label.text = NSLocalizedString(@"record_time", nil);
        [radio1 setText:NSLocalizedString(@"one_min", nil)];
        [radio2 setText:NSLocalizedString(@"two_min", nil)];
        [radio3 setText:NSLocalizedString(@"three_min", nil)];
    }
    
    [label release];
    [radio3 release];
    [radio2 release];
    [radio1 release];
    
#pragma mark - 取消按钮
    UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"new_button.png"] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    [button setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [button setTitleColor:XWhite forState:UIControlStateNormal];
    button.frame=CGRectMake(20, 210, width-2*20, 34);
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
    self.selectView.frame = CGRectMake(0, height-CUSTOM_VIEW_HEIGHT, width, CUSTOM_VIEW_HEIGHT);
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
        self.selectView.frame = CGRectMake(0, height, width, CUSTOM_VIEW_HEIGHT);
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
-(void)onNetType1Press:(id)sender{
    
    self.lastRecordType = self.recordType;
    [self.radio1 setSelected:NO];
    [self.radio2 setSelected:NO];
    [self.radio3 setSelected:NO];
    RadioButton * button = (RadioButton *)sender;
    if (self.isSetRecordModel) {
        self.isLoadingRecordType = YES;
        switch (button.tag) {
            case 101:
            {
                [self.radio1 setSelected:YES];
                self.recordType = SETTING_VALUE_RECORD_MANUAL;
            }
                break;
            case 102:
            {
                [self.radio2 setSelected:YES];
                self.recordType = SETTING_VALUE_RECORD_ALARM;
            }
                break;
            case 103:
            {
                [self.radio3 setSelected:YES];
                self.recordType = SETTING_VALUE_RECORD_TIMER;
            }
                break;
            default:
                break;
        }
        [[P2PClient sharedClient] setRecordTypeWithId:self.contact.contactId password:self.contact.contactPassword type:self.recordType];
    }else{
        self.isLoadingRecordTime = YES;
        switch (button.tag) {
            case 101:
            {
                [self.radio1 setSelected:YES];
                self.lastRecordTime = self.recordTime;
                self.recordTime = SETTING_VALUE_RECORD_TIME_ONE;
            }
                break;
            case 102:
            {
                [self.radio2 setSelected:YES];
                self.lastRecordTime = self.recordTime;
                self.recordTime = SETTING_VALUE_RECORD_TIME_TWO;
            }
                break;
            case 103:
            {
                [self.radio3 setSelected:YES];
                self.lastRecordTime = self.recordTime;
                self.recordTime = SETTING_VALUE_RECORD_TIME_THREE;
            }
                break;
            default:
                break;
        }
        
        [[P2PClient sharedClient] setRecordTimeWithId:self.contact.contactId password:self.contact.contactPassword value:self.recordTime];
    }
    [self cancel];
    [self.tableView reloadData];
}
-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //    if(self.recordType==SETTING_VALUE_RECORD_MANUAL){
    //        return 2;
    //    }else{
    //        return 2;
    //    }
    return  2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 1;
    }else if(section==1){
        if(self.recordType==SETTING_VALUE_RECORD_TIMER){
            return 3;
        }else{
            return 1;
        }
    }else
        return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0&&indexPath.row==1){
        //return BAR_BUTTON_HEIGHT*3;
        return BAR_BUTTON_HEIGHT;
    }
    else if(indexPath.section==1&&self.recordType==SETTING_VALUE_RECORD_TIMER){
        if(indexPath.row==1){
            return BAR_BUTTON_HEIGHT*5;
        }else{
            return BAR_BUTTON_HEIGHT;
        }
    }else
        return BAR_BUTTON_HEIGHT;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.recordType==SETTING_VALUE_RECORD_TIMER&&indexPath.section==1){
        return NO;
    }else{
        return YES;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PEmailSettingCell";
    static NSString *identifier2 = @"P2PRecordTypeCell";
    static NSString *identifier3 = @"P2PRecordTimeCell";
    static NSString *identifier4 = @"P2PTimeSettingCell";
    static NSString *identifier6 = @"P2PSwitchCell";
    static NSString *identifier7 = @"P2PSecurityCell";
    
    UITableViewCell *cell = nil;
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    if(section==0){
        if(row==0){
            cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
            if(cell==nil){
                cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }else if(row==1){
            cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
            if(cell==nil){
                cell = [[[P2PRecordTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }
        
        
    }else if(section==1){
        if(self.recordType==SETTING_VALUE_RECORD_ALARM){
            if(row==0){
                cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
                if(cell==nil){
                    cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }else if(row==1){
                cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
                if(cell==nil){
                    cell = [[[P2PRecordTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }
        }else if(self.recordType==SETTING_VALUE_RECORD_TIMER){
            if(row==0){
                cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
                if(cell==nil){
                    cell = [[[P2PTimeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }else if(row==1){
                cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
                if(cell==nil){
                    cell = [[[P2PTimeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }else if(row==2){
                cell = [tableView dequeueReusableCellWithIdentifier:identifier7];
                if(cell==nil){
                    cell = [[[P2PSecurityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier7] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }
        }else if(self.recordType==SETTING_VALUE_RECORD_MANUAL){
            if(row==0){
                cell = [tableView dequeueReusableCellWithIdentifier:identifier6];
                if(cell==nil){
                    cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier6] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }
        }
    }
    
    
    
    switch (section) {
            
        case 0:
        {
            
            if(row==0){
                P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
                if(self.isFirstCompoleteLoadRecordType){
                    //backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                    //backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                }else{
                    //backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                    //backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                }
                if (self.recordType==SETTING_VALUE_RECORD_MANUAL) {
                    self.selectType = NSLocalizedString(@"manual_record", nil);
                }else if(self.recordType==SETTING_VALUE_RECORD_ALARM){
                    self.selectType = NSLocalizedString(@"alarm_record", nil);
                }else if (self.recordType==SETTING_VALUE_RECORD_TIMER){
                    self.selectType = NSLocalizedString(@"timer_record", nil);
                }
                [emailCell setLeftLabelText:NSLocalizedString(@"record_type", nil)];
                [emailCell setRightLabelText:self.selectType];
                [emailCell setRightIcon:@"new_right.png"];
                if(self.isLoadingRecordType){
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
                }
                
            }else if(row==1){
                P2PRecordTypeCell *recordTypeCell = (P2PRecordTypeCell*)cell;
                //backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                //backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                self.radioRecordType1 = recordTypeCell.radio1;
                self.radioRecordType2 = recordTypeCell.radio2;
                self.radioRecordType3 = recordTypeCell.radio3;
                [recordTypeCell.radio1 addTarget:self action:@selector(onRadioRecordType1Press) forControlEvents:UIControlEventTouchUpInside];
                [recordTypeCell.radio2 addTarget:self action:@selector(onRadioRecordType2Press) forControlEvents:UIControlEventTouchUpInside];
                [recordTypeCell.radio3 addTarget:self action:@selector(onRadioRecordType3Press) forControlEvents:UIControlEventTouchUpInside];
                if(self.recordType==SETTING_VALUE_RECORD_MANUAL){
                    [recordTypeCell setSelectedIndex:0];
                }else if(self.recordType==SETTING_VALUE_RECORD_ALARM){
                    [recordTypeCell setSelectedIndex:1];
                }else if(self.recordType==SETTING_VALUE_RECORD_TIMER){
                    [recordTypeCell setSelectedIndex:2];
                }
            }
            
        }
            break;
        case 1:
        {
            if(self.recordType==SETTING_VALUE_RECORD_ALARM){
                if(row==0){
                    P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
                    //backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                    //backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                    [emailCell setLeftLabelText:NSLocalizedString(@"record_time", nil)];
                    if(self.recordTime==SETTING_VALUE_RECORD_TIME_ONE){
                        
                        [emailCell setRightLabelText:NSLocalizedString(@"one_min", nil)];
                    }else if(self.recordTime==SETTING_VALUE_RECORD_TIME_TWO){
                        
                        [emailCell setRightLabelText:NSLocalizedString(@"two_min", nil)];
                    }else if(self.recordTime==SETTING_VALUE_RECORD_TIME_THREE){
                        
                        [emailCell setRightLabelText:NSLocalizedString(@"three_min", nil)];
                    }
                    [emailCell setRightIcon:@"new_right.png"];
                    if(self.isLoadingRecordTime){
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
                    }
                }else if(row==1){
                    P2PRecordTimeCell *recordTimeCell = (P2PRecordTimeCell*)cell;
                    //backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                    //backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                    
                    recordTimeCell.delegate = self;
                    if(self.recordTime==SETTING_VALUE_RECORD_TIME_ONE){
                        
                        [recordTimeCell setSelectedIndex:0];
                    }else if(self.recordTime==SETTING_VALUE_RECORD_TIME_TWO){
                        
                        [recordTimeCell setSelectedIndex:1];
                    }else if(self.recordTime==SETTING_VALUE_RECORD_TIME_THREE){
                        
                        [recordTimeCell setSelectedIndex:2];
                    }
                }
            }else if(self.recordType==SETTING_VALUE_RECORD_TIMER){
                P2PTimeSettingCell *timeCell = (P2PTimeSettingCell*)cell;
                if(row==0){
                    //backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                    //backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                    [timeCell setLeftLabelHidden:YES];
                    [timeCell setRightLabelHidden:YES];
                    [timeCell setCustomViewHidden:YES];
                    [timeCell setTitleViewHidden:YES];
                    [timeCell setProgressViewHidden:YES];
                    [timeCell setMiddleLabelHidden:NO];
                    if (self.timestring) {
                        [timeCell setMiddleLabelText:self.timestring];
                    }else {
                        [timeCell setMiddleLabelText:@"00:00-00:00"];
                    }
                }else if(row==1){
                    //backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                    //backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
                    
                    [timeCell setLeftLabelHidden:YES];
                    [timeCell setRightLabelHidden:YES];
                    [timeCell setMiddleLabelHidden:YES];
                    [timeCell setCustomViewHidden:NO];
                    [timeCell setTitleViewHidden:NO];
                    [timeCell setProgressViewHidden:YES];
                    //timeCell.customView = self.cycleview;
                    [timeCell.contentView addSubview:self.timepicker];
                    //[timeCell.contentView addSubview:self.headlabelview];
                }else {
                    P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                    settingCell.delegate = self;
                    [settingCell setMiddleLabelHidden:YES];
                    [settingCell setLeftLabelHidden:YES];
                    [settingCell setMiddleButtonHidden:NO];
                }
            }else if(self.recordType==SETTING_VALUE_RECORD_MANUAL){
                if(row==0){
                    P2PSwitchCell *switchCell = (P2PSwitchCell*)cell;
                    //backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                    //backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                    [switchCell setLeftLabelText:NSLocalizedString(@"remote_record_switch", nil)];
                    if(self.isLoadingRemoteRecord){
                        [switchCell setProgressViewHidden:NO];
                        [switchCell setSwitchViewHidden:YES];
                    }else{
                        [switchCell setProgressViewHidden:YES];
                        [switchCell setSwitchViewHidden:NO];
                        [switchCell.switchView addTarget:self action:@selector(onRemoteRecordChange:) forControlEvents:UIControlEventValueChanged];
                        NSLog(@"++++++++++%d",self.remoteRecordState);
                        if(self.remoteRecordState==SETTING_VALUE_REMOTE_RECORD_STATE_OFF){
                            switchCell.on = NO;
                        }else{
                            switchCell.on = YES;
                            
                        }
                    }
                }
            }
        }
            break;
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0&&!self.isLoadingRecordType) {
        self.isSetRecordModel = YES;
        [self sheetViewinit];
        [self animationstart];
    }
    if (self.recordType==SETTING_VALUE_RECORD_ALARM&&indexPath.section==1) {
        self.isSetRecordModel = NO;
        [self sheetViewinit];
        [self animationstart];
    }
}

-(void)onDatePickChange:(UIDatePicker*)datePick{
    self.startTimeString = [Utils stringFromDate2:[self.datePicker1 date]];
    
    [self.tableView reloadData];
    
}

-(void)onDatePickChange1:(UIDatePicker*)datePick{
    self.endTimeString = [Utils stringFromDate2:[self.datePicker2 date]];
    
    [self.tableView reloadData];
    
}
#pragma mark 设置时间
-(void)savePress:(NSInteger)section row:(NSInteger)row{
    UILabel * Endhlabel = [[(UILabel*)[[self.endhour subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    UILabel * Endmlabel = [[(UILabel*)[[self.endmin subviews] objectAtIndex:0] subviews] objectAtIndex:2];
    if (([Endhlabel.text integerValue]==0)&&([Endmlabel.text integerValue]==0)){
        [self.view makeToast:NSLocalizedString(@"结束时间不能为零", nil)];
    }else{
        
        self.lastPlanTime = self.planTime;
        UILabel * beghlabel = [[(UILabel*)[[self.beginhour subviews] objectAtIndex:0] subviews] objectAtIndex:2];
        NSInteger hour_from = [beghlabel.text integerValue];
        beghlabel = [[(UILabel*)[[self.beginmin subviews] objectAtIndex:0] subviews] objectAtIndex:2];
        NSInteger minute_from = [beghlabel.text integerValue];
        beghlabel = [[(UILabel*)[[self.endhour subviews] objectAtIndex:0] subviews] objectAtIndex:2];
        NSInteger hour_to = [beghlabel.text integerValue];
        beghlabel = [[(UILabel*)[[self.endmin subviews] objectAtIndex:0] subviews] objectAtIndex:2];
        NSInteger minute_to = [beghlabel.text integerValue];
        if ((hour_from<<8|minute_from<<0)>=(hour_to<<8|minute_to<<0)) {
            [self.view makeToast:NSLocalizedString(@"开始时间应该小于结束时间", nil)];
        }else{
            self.planTime = (int)(hour_from<<24|hour_to<<16|minute_from<<8|minute_to<<0);
            NSLog(@"plantime=====%i",self.planTime);
            self.progressAlert.dimBackground = YES;
            [self.progressAlert show:YES];
            [[P2PClient sharedClient] setRecordPlanTimeWithId:self.contact.contactId password:self.contact.contactPassword time:self.planTime];
        }
    }
    
}


-(void)onRadioRecordType1Press{
    if(!self.isLoadingRecordType&&!self.radioRecordType1.isSelected){
        [self.radioRecordType1 setSelected:YES];
        [self.radioRecordType2 setSelected:NO];
        [self.radioRecordType3 setSelected:NO];
        self.isLoadingRecordType = YES;
        
        self.lastRecordType = self.recordType;
        self.recordType = SETTING_VALUE_RECORD_MANUAL;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setRecordTypeWithId:self.contact.contactId password:self.contact.contactPassword type:self.recordType];
        
    }
}

-(void)onRadioRecordType2Press{
    if(!self.isLoadingRecordType&&!self.radioRecordType2.isSelected){
        [self.radioRecordType1 setSelected:NO];
        [self.radioRecordType2 setSelected:YES];
        [self.radioRecordType3 setSelected:NO];
        self.isLoadingRecordType = YES;
        
        if(self.recordType==SETTING_VALUE_RECORD_MANUAL){
            [self.tableView reloadData];
            self.lastRecordType = self.recordType;
            self.recordType = SETTING_VALUE_RECORD_ALARM;
        }else{
            self.lastRecordType = self.recordType;
            self.recordType = SETTING_VALUE_RECORD_ALARM;
            [self.tableView reloadData];
            
        }
        
        [[P2PClient sharedClient] setRecordTypeWithId:self.contact.contactId password:self.contact.contactPassword type:self.recordType];
        
    }
}

-(void)onRadioRecordType3Press{
    if(!self.isLoadingRecordType&&!self.radioRecordType3.isSelected){
        [self.radioRecordType1 setSelected:NO];
        [self.radioRecordType2 setSelected:NO];
        [self.radioRecordType3 setSelected:YES];
        self.isLoadingRecordType = YES;
        
        if(self.recordType==SETTING_VALUE_RECORD_MANUAL){
            [self.tableView reloadData];
            self.lastRecordType = self.recordType;
            self.recordType = SETTING_VALUE_RECORD_TIMER;
        }else{
            self.lastRecordType = self.recordType;
            self.recordType = SETTING_VALUE_RECORD_TIMER;
            [self.tableView reloadData];
        }
        
        
        [[P2PClient sharedClient] setRecordTypeWithId:self.contact.contactId password:self.contact.contactPassword type:self.recordType];
        
    }
}

-(void)onRecordTimeCellRadioClick:(RadioButton *)radio index:(NSInteger)index{
    switch(index){
        case 0:
        {
            if(!self.isLoadingRecordTime&&!self.radioRecordTime1.isSelected){
                [self.radioRecordTime1 setSelected:YES];
                [self.radioRecordTime2 setSelected:NO];
                [self.radioRecordTime3 setSelected:NO];
                self.isLoadingRecordTime = YES;
                
                self.lastRecordTime = self.recordTime;
                self.recordTime = SETTING_VALUE_RECORD_TIME_ONE;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setRecordTimeWithId:self.contact.contactId password:self.contact.contactPassword value:self.recordTime];
                
            }
        }
            break;
        case 1:
        {
            if(!self.isLoadingRecordTime&&!self.radioRecordTime2.isSelected){
                [self.radioRecordTime1 setSelected:NO];
                [self.radioRecordTime2 setSelected:YES];
                [self.radioRecordTime3 setSelected:NO];
                self.isLoadingRecordTime = YES;
                
                self.lastRecordTime = self.recordTime;
                self.recordTime = SETTING_VALUE_RECORD_TIME_TWO;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setRecordTimeWithId:self.contact.contactId password:self.contact.contactPassword value:self.recordTime];
                
            }
        }
            break;
        case 2:
        {
            if(!self.isLoadingRecordTime&&!self.radioRecordTime3.isSelected){
                [self.radioRecordTime1 setSelected:NO];
                [self.radioRecordTime2 setSelected:NO];
                [self.radioRecordTime3 setSelected:YES];
                self.isLoadingRecordTime = YES;
                
                self.lastRecordTime = self.recordTime;
                self.recordTime = SETTING_VALUE_RECORD_TIME_THREE;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setRecordTimeWithId:self.contact.contactId password:self.contact.contactPassword value:self.recordTime];
                
            }
        }
            break;
    }
}


-(void)onRemoteRecordChange:(UISwitch*)sender{
    if(self.remoteRecordState==SETTING_VALUE_REMOTE_RECORD_STATE_OFF&&sender.on){
        self.isLoadingRemoteRecord = YES;
        self.isSetRemoteRecordState = YES;
        self.lastRemoteRecordState = self.remoteRecordState;
        self.remoteRecordState = SETTING_VALUE_REMOTE_RECORD_STATE_ON;
        NSLog(@"-------------%d",self.remoteRecordState);
        [self.tableView reloadData];
        
        [[P2PClient sharedClient] setRemoteRecordWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteRecordState];
    }else if(self.remoteRecordState!=SETTING_VALUE_REMOTE_RECORD_STATE_OFF&&!sender.on){
        self.isLoadingRemoteRecord = YES;
        
        self.lastRemoteRecordState = self.remoteRecordState;
        self.remoteRecordState = SETTING_VALUE_REMOTE_RECORD_STATE_OFF;
        NSLog(@"-------------%d",self.remoteRecordState);
        [self.tableView reloadData];
        [[P2PClient sharedClient] setRemoteRecordWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteRecordState];
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
