//
//  TimeSettingController.m
//  Gviews
//
//  Created by guojunyi on 14-5-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//
#define RGBA(r,g,b,a)               [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:(float)a]

#import "TimeSettingController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "MyPickerView.h"
#import "P2PTimeSettingCell.h"
#import "Toast+UIView.h"
#import "Contact.h"
#import "Utils.h"
#import "TimezoneView.h"
#import "P2PTimezoneSettingCell.h"
#import "P2PSecurityCell.h"
@interface TimeSettingController ()

@end

@implementation TimeSettingController
-(void)dealloc{
    [self.time release];
    //[self.picker release];
    [self.dateString release];
    
    [self.tableView release];
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
    [[P2PClient sharedClient] getDeviceTimeWithId:self.contact.contactId password:self.contact.contactPassword];
    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
}


- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_GET_DEVICE_TIME:
        {
            
            NSString *time = [parameter valueForKey:@"time"];
            self.time = time;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            DLog(@"RET_GET_DEVICE_TIME");
        }
            break;
        case RET_SET_DEVICE_TIME:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            if(result==0){
                NSString *time = [Utils getDeviceTimeByIntValue:self.lastSetDate.year month:self.lastSetDate.month day:self.lastSetDate.day hour:self.lastSetDate.hour minute:self.lastSetDate.minute];
                self.time = time;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_TIME_ZONE:
        {
            NSInteger value = [[parameter valueForKey:@"value"] intValue];
            
            self.isSupportTimezone = YES;
            self.timezone = value;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"auto update state:%i",value);
            
        }
            break;
            
        case RET_SET_NPCSETTINGS_TIME_ZONE:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            if(result==0){
                self.timezone = self.lastSetTimezone;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
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
        case ACK_RET_GET_DEVICE_TIME:
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
                    DLog(@"resend get device time");
                    [[P2PClient sharedClient] getDeviceTimeWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            
            DLog(@"ACK_RET_GET_DEVICE_TIME:%i",result);
        }
            break;
        case ACK_RET_SET_DEVICE_TIME:
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
                    DLog(@"resend set device time");
                    [[P2PClient sharedClient] setDeviceTimeWithId:self.contact.contactId password:self.contact.contactPassword year:self.lastSetDate.year month:self.lastSetDate.month day:self.lastSetDate.day hour:self.lastSetDate.hour minute:self.lastSetDate.minute];
                }
                
                
            });
        }
            break;
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
        case ACK_RET_SET_TIME_ZONE:
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
                    DLog(@"resend set time zone");
                    [[P2PClient sharedClient] setDeviceTimezoneWithId:self.contact.contactId password:self.contact.contactPassword value:self.lastSetTimezone];
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
    [self inittimepicker];
    [self inittimezonepicker];
    NSDateComponents * components= [Utils getNowDateComponents];
    self.dateString = [Utils getDeviceTimeByIntValue:components.year month:components.month day:components.day hour:components.hour minute:components.minute];
    self.isIndiaTimezone = NO;
}

- (void)inittimezonepicker{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat rowheight = TEXT_FIELD_HEIGHT*3/5;
    
    self.timezoneview = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, width, TEXT_FIELD_HEIGHT*3)];
    [self.timezoneview setCurrentSelectPage:19];
    self.lastSetTimezone = 19;
    self.timezoneview.delegate = self;
    self.timezoneview.datasource = self;
    [self.timezoneview reloadData];
    [self setAfterScrollShowView:self.timezoneview andCurrentPage:1];
    
    UIView *beforeSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, rowheight, width, 1.0)];
    [beforeSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [_timezoneview addSubview:beforeSepLine];
    
    UIView *middleSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, rowheight*2+1, width, 0.5)];
    [middleSepLine setBackgroundColor:XBlack];//时区选中的cell的上方线条
    [_timezoneview addSubview:middleSepLine];
    [middleSepLine release];
    
    UIImage* image1= [UIImage imageNamed:@"timeset2.png"];//选中那行的左边框
    image1 = [image1 stretchableImageWithLeftCapWidth:image1.size.width*0.5 topCapHeight:image1.size.height*0.5];
    UIImageView * imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, width/30, rowheight*5-7)];
    imageview1.image=image1;
    [_timezoneview addSubview:imageview1];
    [imageview1 release];
    
    UIImage* image2= [UIImage imageNamed:@"timeset2.png"];//选中那行的右边框
    image2 = [image2 stretchableImageWithLeftCapWidth:image2.size.width*0.5 topCapHeight:image2.size.height*0.5];
    UIImageView * imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(width-width/30, 0, width/30, rowheight*5)];
    imageview2.image=image2;
    [_timezoneview addSubview:imageview2];
    [imageview2 release];
    
    //时区选中行的下方黑线
    UIView * middlesecSepLine =[[UIView alloc] initWithFrame:CGRectMake(0, rowheight*3+1, width, 0.5)];
    [middlesecSepLine setBackgroundColor:[UIColor blackColor]];
    [_timezoneview addSubview:middlesecSepLine];
    [middlesecSepLine release];
    
    UIView *bottomSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, rowheight*4+1, width, 0.5)];
    [bottomSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [_timezoneview addSubview:bottomSepLine];
    [bottomSepLine release];
    
}
#pragma mark - 时区选择的每个cell的字体颜色
- (void)setAfterScrollShowView:(MXSCycleScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    UILabel *oneLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:14]];
    [oneLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
    UILabel *twoLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber + 1];
    [twoLabel setFont:[UIFont systemFontOfSize:16]];
    [twoLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *currentLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber + 2];
    [currentLabel setFont:[UIFont systemFontOfSize:18]];
    [currentLabel setTextColor:RGBA(3.0, 162.0, 234.0, 1.0)];
    
    UILabel *threeLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber + 3];
    [threeLabel setFont:[UIFont systemFontOfSize:16]];
    [threeLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *fourLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber + 4];
    [fourLabel setFont:[UIFont systemFontOfSize:14]];
    [fourLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
}
#pragma mark mxccyclescrollview delegate
#pragma mark mxccyclescrollview databasesource
- (NSInteger)numberOfPages:(MXSCycleScrollView*)scrollView
{
    return 25;
}

#pragma mark - 时区选择的每一个cell相关
- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(MXSCycleScrollView *)scrollView
{
    _timezoneLable = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height/5)]autorelease];
    
    _timezoneLable.tag = index+100;
    
    switch (index) {
        case 0:
            _timezoneLable.text = @"0";
            break;
        case 1:
            _timezoneLable.text = @"1";
            break;
        case 2:
            _timezoneLable.text = @"2";
            break;
        case 3:
            _timezoneLable.text = @"3";
            break;
        case 4:
            _timezoneLable.text = @"4";
            break;
        case 5:
            _timezoneLable.text = @"5";
            break;
        case 6:
            _timezoneLable.text = @"5.5";
            break;
        case 7:
            _timezoneLable.text = @"6";
            break;
        case 8:
            _timezoneLable.text = @"7";
            break;
        case 9:
            _timezoneLable.text = @"8";
            break;
        case 10:
            _timezoneLable.text = @"9";
            break;
        case 11:
            _timezoneLable.text = @"10";
            break;
        case 12:
            _timezoneLable.text = @"11";
            break;
        case 13:
            _timezoneLable.text = @"12";
            break;
        case 14:
            _timezoneLable.text = @"-11";
            break;
        case 15:
            _timezoneLable.text = @"-10";
            break;
        case 16:
            _timezoneLable.text = @"-9";
            break;
        case 17:
            _timezoneLable.text = @"-8";
            break;
        case 18:
            _timezoneLable.text = @"-7";
            break;
        case 19:
            _timezoneLable.text = @"-6";
            break;
        case 20:
            _timezoneLable.text = @"-5";
            break;
        case 21:
            _timezoneLable.text = @"-4";
            break;
        case 22:
            _timezoneLable.text = @"-3";
            break;
        case 23:
            _timezoneLable.text = @"-2";
            break;
        case 24:
            _timezoneLable.text = @"-1";
            break;
        default:
            break;
    }
    
    _timezoneLable.font = [UIFont systemFontOfSize:12];
    _timezoneLable.textAlignment = NSTextAlignmentCenter;
    _timezoneLable.backgroundColor = [UIColor clearColor];
    
    return _timezoneLable;
}


#pragma mark 当滚动时设置选中的cell
- (void)scrollviewDidChangeNumber
{
    UILabel * label = [[(UILabel*)[[self.timezoneview subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    label.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
}
#pragma mark 滚动完成后的回调
- (void)scrollviewDidEndChangeNumber
{
    UILabel * label = [[(UILabel*)[[self.timezoneview subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    label.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    self.lastSetTimezone = [label.text integerValue] + 11;
    if ([self.timezoneview currentPage] == 6)
    {
        self.isIndiaTimezone = YES;
    }
    else
    {
        self.isIndiaTimezone = NO;
    }
}

#pragma mark - 时间选择器
- (void)inittimepicker{
    CGRect frame = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].contentView.bounds;
    CGFloat width = frame.size.width;
    
    self.cycleview = [[CyclePickerView alloc] initWithFrame:CGRectMake(0,20, width, TEXT_FIELD_HEIGHT*5)];
    
    self.cycleview.delegate = self;
    self.cycleview.datasource = self;
    [self.cycleview reloadScroll];
    
    NSDateComponents *dateComponents = [Utils getNowDateComponents];
    
    int year = [dateComponents year];
    int month = [dateComponents month];
    int day = [dateComponents day];
    int hour = [dateComponents hour];
    int minute = [dateComponents minute];
    _date.year = year;
    _date.month = month;
    _date.day = day;
    _date.hour = hour;
    _date.minute = minute;
    DLog(@"%i %i %i",day,hour,minute);
    [_cycleview selectCell:year-2010 inScroll:0];
    [_cycleview selectCell:month-1 inScroll:1];
    [_cycleview selectCell:day-1 inScroll:2];
    [_cycleview selectCell:hour inScroll:3];
    [_cycleview selectCell:minute inScroll:4];
    _headlabelview = [[UIView alloc] initWithFrame:CGRectMake(0,0, width, TEXT_FIELD_HEIGHT)];
    NSArray * arr = @[NSLocalizedString(@"year", nil),NSLocalizedString(@"month", nil),NSLocalizedString(@"day", nil),NSLocalizedString(@"hour", nil),NSLocalizedString(@"minute", nil)];
    CGFloat noworigin = 0.0;
    for (NSInteger i = 0; i<5; i++) {
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(noworigin*_headlabelview.frame.size.width, 0, [_cycleview.scrollWidthProportion[i] floatValue]*_headlabelview.frame.size.width, _headlabelview.frame.size.height)];
        label.text = arr[i];
        label.textAlignment = NSTextAlignmentCenter;
        [_headlabelview addSubview:label];
        [label release];
        noworigin+=[_cycleview.scrollWidthProportion[i] floatValue];
    }
    
    /*选中那行的背景*/
    //_selectbackview = [[UIView alloc] initWithFrame:CGRectMake(width/30, TEXT_FIELD_HEIGHT*3+2, width*28.5/30, TEXT_FIELD_HEIGHT-2)];
    //_selectbackview.backgroundColor = [UIColor greenColor];
    //_selectbackview.alpha = 0.1;
}
//指定每一列的滚轮上的Cell的个数
- (NSUInteger)numberOfCellsInScroll:(NSUInteger)scroll{
    switch (scroll) {
        case 0:
            return 27;
            break;
        case 1:
            return 12;
            break;
        case 2:
            return 31;
            break;
        case 3:
            return 24;
            break;
        case 4:
            return 60;
            break;
        default:
            return 10;
            break;
    }
    return 0;
}
//指定每一列滚轮所占整体宽度的比例，以:分隔
- (NSString *)scrollWidthProportion{
    return @"1:1:1:1:1";
}
//指定每一列的滚轮上的Cell的初始值，以:分隔
- (NSString *)valueOfCellsInScroll{
    return @"2010:1:1:0:0";
}
- (void)CyclePickerViewDidChangeValue:(NSArray *)valuearr{
    _date.year = [valuearr[0] integerValue];
    _date.month = [valuearr[1] integerValue];
    _date.day = [valuearr[2] integerValue];
    _date.hour = [valuearr[3] integerValue];
    _date.minute = [valuearr[4] integerValue];
    //    if (self.delegate) {
    //        [self.delegate reloadTimeSetting];
    //    }
    [self reloadTimeSetting];
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
    [topBar setTitle:NSLocalizedString(@"time_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    //UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, 500, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.separatorStyle = NO;//去除分割线
    [self.tableView reloadData];
    [tableView release];
    
    
}


-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.isSupportTimezone){
        return 2;
    }else
        return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PTimeSettingCell";
    static NSString *identifier2 = @"P2PTimezoneSettingCell";
    static NSString *identifier3 = @"P2PSecurityCell";
    static NSString *identifier4 = @"P2PNormalCell";
    
    int section = indexPath.section;
    int row = indexPath.row;
    UITableViewCell *cell = nil;
    
    if(section==0){
        if (row==2) {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
            if(cell==nil){
                cell = [[[P2PSecurityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }else if (row==0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
            if(cell==nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4] autorelease];
                [cell setBackgroundColor:XWhite];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
            if(cell==nil){
                cell = [[[P2PTimeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                [cell setBackgroundColor:XWhite];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }else if(section==1){
        if (row==2) {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
            if(cell==nil){
                cell = [[[P2PSecurityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
                [cell setBackgroundColor:XWhite];
            }
        }else if(row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
            if(cell==nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4] autorelease];
                [cell setBackgroundColor:XWhite];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
            if(cell==nil){
                cell = [[[P2PTimeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                [cell setBackgroundColor:XWhite];
            }
            
        }
        
    }
    
    switch (section) {
        case 0:
        {
            if(row==0){
                NSString* text = [NSString stringWithFormat:@"%@", self.time];
                cell.textLabel.text = text;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = XFontBold_16;
                cell.textLabel.textColor = [UIColor colorWithRed:3.0/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
            }else if(row==1){
                P2PTimeSettingCell *timeCell = (P2PTimeSettingCell*)cell;
                [timeCell setLeftLabelHidden:YES];
                [timeCell setRightLabelHidden:YES];
                [timeCell setMiddleLabelHidden:YES];
                [timeCell setCustomViewHidden:NO];
                [timeCell setTitleViewHidden:NO];
                [timeCell setProgressViewHidden:YES];
                timeCell.customView = self.cycleview;
                [timeCell.contentView addSubview:self.cycleview];
                [timeCell.contentView addSubview:self.headlabelview];
            }else if(row==2){
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                [settingCell setMiddleLabelHidden:YES];
                [settingCell setLeftLabelHidden:YES];
                [settingCell setMiddleButtonHidden:NO];
                settingCell.delegate = self;
                settingCell.section = indexPath.section;
                settingCell.row = indexPath.row;
            }
        }
            break;
        case 1:
        {
            if(row==0)
            {
                NSString* text = nil;
                if(self.timezone-11<0)
                {
                    text = [NSString stringWithFormat:@"%@:UTC - %i:00",NSLocalizedString(@"time_zone", nil), 11-self.timezone];
                    if (self.isIndiaTimezone)
                    {
                        text = [NSString stringWithFormat:@"%@:UTC + 5.5:00",NSLocalizedString(@"time_zone", nil)];
                    }
                }
                else
                {
                    text = [NSString stringWithFormat:@"%@:UTC + %i:00",NSLocalizedString(@"time_zone", nil),self.timezone-11];
                    if (self.isIndiaTimezone)
                    {
                        text = [NSString stringWithFormat:@"%@:UTC + 5.5:00",NSLocalizedString(@"time_zone", nil)];
                    }
                }
                cell.textLabel.text = text;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = XFontBold_16;
                cell.textLabel.textColor = [UIColor colorWithRed:3.0/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
            }else if(row==1){
                P2PTimeSettingCell *timeCell = (P2PTimeSettingCell*)cell;
                [timeCell setLeftLabelHidden:YES];
                [timeCell setRightLabelHidden:YES];
                [timeCell setMiddleLabelHidden:YES];
                [timeCell setCustomViewHidden:NO];
                [timeCell setTitleViewHidden:NO];
                [timeCell setProgressViewHidden:YES];
                [timeCell.contentView addSubview:self.timezoneview];
            }else if(row == 2){
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                [settingCell setMiddleLabelHidden:YES];
                [settingCell setLeftLabelHidden:YES];
                [settingCell setMiddleButtonHidden:NO];
                settingCell.delegate = self;
                settingCell.section = indexPath.section;
                settingCell.row = indexPath.row;
            }
        }
            break;
    }
    return cell;
    
}

-(void)reloadTimeSetting{
    //NSString *time = [Utils getDeviceTimeByIntValue:self.picker.date.year month:self.picker.date.month day:self.picker.date.day hour:self.picker.date.hour minute:self.picker.date.minute];
    NSString *time = [Utils getDeviceTimeByIntValue:self.date.year month:self.date.month day:self.date.day hour:self.date.hour minute:self.date.minute];
    self.dateString = time;
    [self.tableView reloadData];
    
}

-(void)savePress:(NSInteger)section row:(NSInteger)row{
    if (section == 0 && row == 2) {
        _lastSetDate.year = self.date.year;
        _lastSetDate.month = self.date.month;
        _lastSetDate.day = self.date.day;
        _lastSetDate.hour = self.date.hour;
        _lastSetDate.minute = self.date.minute;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setDeviceTimeWithId:self.contact.contactId password:self.contact.contactPassword year:self.lastSetDate.year month:self.lastSetDate.month day:self.lastSetDate.day hour:self.lastSetDate.hour minute:self.lastSetDate.minute];
    }
    else if (section == 1 & row == 2)
    {
        [[P2PClient sharedClient] setDeviceTimezoneWithId:self.contact.contactId password:self.contact.contactPassword value:self.lastSetTimezone];
        if (self.isIndiaTimezone)
        {
            [[P2PClient sharedClient]setIndiaTimezoneWithId:self.contact.contactId password:self.contact.contactPassword value: 24];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0)
    {
        if(indexPath.row==1)
        {
            return TEXT_FIELD_HEIGHT*6;
        }
        else
        {
            return BAR_BUTTON_HEIGHT;
        }
    }
    else
    {
        if(indexPath.row==1)
        {
            return TEXT_FIELD_HEIGHT*3;
        }
        else
        {
            return BAR_BUTTON_HEIGHT;
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
