

#import "AlarmHistoryController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "TopBar.h"
#import "Alarm.h"
#import "AlarmDAO.h"
#import "AlarmHistoryCell.h"
#import "Utils.h"
#import "Toast+UIView.h"
#import "UDManager.h"
#import "NetManager.h"
#import "LoginResult.h"
#import "GetAlarmRecordResult.h"
#import "SVPullToRefresh.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"
#import "MBProgressHUD.h"

#define ALERT_TAG_CLEAR 1
@interface AlarmHistoryController ()<MJRefreshBaseViewDelegate>
{
    //上拉
    MJRefreshFooterView *footerView;
    //
    BOOL isLocalAlarmRecord;
}
@end

@implementation AlarmHistoryController

-(void)dealloc{
    [self.tableView release];
    [self.alarmHistory release];
    [footerView free];
    [self.progressAlert release];
    [super dealloc];
}

- (void)initFooterView
{
    footerView = [[MJRefreshFooterView alloc] initWithScrollView:self.tableView];
    footerView.delegate = self;
}

#pragma mark -MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == footerView)
    {
        LoginResult * login = [UDManager getLoginInfo];
       
        Alarm * alarm = self.alarmHistory[self.alarmHistory.count-1];
        NSString * index = alarm.msgIndex;
        [[NetManager sharedManager] getAlarmRecordWithUsername:login.contactId  sessionId:login.sessionId option:@"1" msgIndex:index senderList:@"1052614" checkLevelType:@"1" vKey:@"1" callBack:^(id JSON) {
            
            GetAlarmRecordResult * alarmRecordResult = (GetAlarmRecordResult *)JSON;
            
            for (Alarm * alarm in alarmRecordResult.alarmRecord) {
                [self.alarmHistory addObject:alarm];
            }

            int error_code = alarmRecordResult.error_code;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //整理报警记录，刷新表格
                [footerView endRefreshing];
                if (error_code == NET_RET_NO_RECORD) {
                    //无记录,显示提示信息
                    [self.view makeToast:NSLocalizedString(@"no_more_record", nil)];
                }else if (error_code == NET_RET_NO_PERMISSION){
                    [self.view makeToast:NSLocalizedString(@"no_permission", nil)];
                }else if (error_code == NET_RET_UNKNOWN_ERROR){
                    [self.view makeToast:NSLocalizedString(@"unknown_error", nil)];
                }
                if (self.tableView) {
                    [self.tableView reloadData];
                }
            });
        }];
    }
}

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
    //NSLog(@"沙盒:%@",NSHomeDirectory());
    [self initComponent];
    // Do any additional setup after loading the view.
    //must be after initComponent
    if (!isLocalAlarmRecord) {
        [self initFooterView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateTableView];
}

-(void)updateTableView{
    if (isLocalAlarmRecord) {
        //存放报警记录的数据库
            AlarmDAO * alarmDAO = [[AlarmDAO alloc]init];
            self.alarmHistory = [NSMutableArray arrayWithArray:[alarmDAO findAll]];
            [alarmDAO release];
        if (self.tableView) {
            [self.tableView reloadData];
        }
    }else{
        //向服务器请求报警记录
        LoginResult * login = [UDManager getLoginInfo];
        
        [[NetManager sharedManager] getAlarmRecordWithUsername:login.contactId  sessionId:login.sessionId option:@"2" msgIndex:nil senderList:@"1052614" checkLevelType:@"1" vKey:@"1" callBack:^(id JSON) {
            
            GetAlarmRecordResult * alarmRecordResult = (GetAlarmRecordResult *)JSON;
            self.alarmHistory = [NSMutableArray arrayWithArray:alarmRecordResult.alarmRecord];
            
            int error_code = alarmRecordResult.error_code;
            if (self.alarmHistory.count == 0) {
                [footerView setHidden:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressAlert hide:YES];
                //整理报警记录，刷新表格
                if (error_code == NET_RET_NO_RECORD) {
                    //无记录,显示提示信息
                    [self.view makeToast:NSLocalizedString(@"no_record", nil)];
                }else if (error_code == NET_RET_NO_PERMISSION){
                    [self.view makeToast:NSLocalizedString(@"no_permission", nil)];
                }else if (error_code == NET_RET_UNKNOWN_ERROR){
                    [self.view makeToast:NSLocalizedString(@"unknown_error", nil)];
                }
                if (self.tableView) {
                    [self.tableView reloadData];
                }
            });
        }];
    }
}



#define CONTACT_ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 120:90)

-(void)initComponent{
    self.view.layer.contents = XBgImage;
    //显示server OR local的alarmRecords(.plist)
    NSString * plist = [[NSBundle mainBundle] pathForResource:@"Alarm-Record" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
    isLocalAlarmRecord = [dic[@"isLocalAlarmRecord"] boolValue];
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"alarm_history",nil)];
    [topBar.leftButton setHidden:NO];
    [topBar setLeftButtonIcon:[UIImage imageNamed:@"open_menu.png"]];
    [topBar.leftButton addTarget:self action:@selector(onMenuPress) forControlEvents:UIControlEventTouchUpInside];
    if (isLocalAlarmRecord) {
        [topBar setRightButtonHidden:NO];
    }else{
        [topBar setRightButtonHidden:YES];
    }
    [topBar setRightButtonIcon:[UIImage imageNamed:@"ic_bar_btn_clear.png"]];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.rightButton addTarget:self action:@selector(clearPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [tableView setBackgroundColor:XBGAlpha];
    
    if (!isLocalAlarmRecord) {
        [tableView addPullToRefreshWithActionHandler:^{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                sleep(1.0);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self updateTableView];
                    [self.tableView.pullToRefreshView stopAnimating];
                });
            });
            
        }];
    }
  
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    if (!isLocalAlarmRecord) {
        self.progressAlert = [[MBProgressHUD alloc]initWithView:self.view];
        self.progressAlert.labelText = NSLocalizedString(@"loading", nil);
        [self.view addSubview:self.progressAlert];
    }

}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}
//删除按钮
-(void)clearPress{
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_clear", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    deleteAlert.tag = ALERT_TAG_CLEAR;
    [deleteAlert show];
    [deleteAlert release];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.alarmHistory count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CONTACT_ITEM_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"AlarmHistoryCell";
    
    
    AlarmHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell==nil){
        cell = [[[AlarmHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        [cell setBackgroundColor:XBGAlpha];
        
    }
    
    Alarm * alarm = [self.alarmHistory objectAtIndex:indexPath.row];
    [cell setDeviceId:alarm.deviceId];
    [cell setAlarmTime:[Utils convertTimeByInterval:alarm.alarmTime]];
    [cell setAlarmType:alarm.alarmType];
    
    UIImage *backImg = [UIImage imageNamed:@"bg_normal_cell.png"];
    UIImage *backImg_p = [UIImage imageNamed:@"bg_normal_cell_p.png"];
    UIImageView *backImageView = [[UIImageView alloc] init];
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    
    [backImageView release];
    [backImageView_p release];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
//        case ALERT_TAG_DELETE:
//        {
//            if(buttonIndex==1){
//                RecentDAO *recentDAO = [[RecentDAO alloc] init];
//                [recentDAO delete:[self.recents objectAtIndex:self.curDelIndexPath.row]];
//                [self.recents removeObjectAtIndex:self.curDelIndexPath.row];
//                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.curDelIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//                [recentDAO release];
//                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
//            }
//        }
//            break;
        case ALERT_TAG_CLEAR:
        {
            if(buttonIndex==1){
                AlarmDAO *alarmDAO = [[AlarmDAO alloc] init];
                [alarmDAO clear];
                [self updateTableView];
                [alarmDAO release];
                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
            }
        }
            break;
    }
}

-(void)onMenuPress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_LEFTMENU_CMD object:self];
    });
}

@end
