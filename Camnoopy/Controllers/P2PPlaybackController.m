

#import "P2PPlaybackController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "TopBar.h"
#import "Utils.h"
#import "Contact.h"
#import "P2PClient.h"
#import "Toast+UIView.h"
#import "P2PPlayingbackController.h"
#import "SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
@interface P2PPlaybackController ()<UIGestureRecognizerDelegate>
{
    BOOL _isShowSheetView;
    NSMutableArray* _arrayMultiDelete;
    
}
@end

@implementation P2PPlaybackController
-(void)dealloc{
    DLog(@"release");
    [self.contact release];
    [self.layerView release];
    [self.searchBarView release];
    [self.playbackFiles release];
    [self.dayOneFiles release];
    [self.dayThreeFiles release];
    [self.dayMonthFiles release];
    [self.customFiles release];
    [self.playbackSize release];
    [self.timesData release];
    [self.tableView release];
    [self.searchMaskView release];
    [self.movieView release];
    [self.startTimeBtn release];
    [self.endTimeBtn release];
    [self.startTimeLabel release];
    [self.endTimeLabel release];
    [self.customView release];
    [[P2PClient sharedClient] setPlaybackDelegate:nil];
    [[P2PClient sharedClient] p2pHungUp];
    
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
//视频回放修复
    [[P2PClient sharedClient] setIsClearPlaybackFilesLength:YES];//isClearPlaybackFilesLength
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    DLog(@"viewDidAppear");
//    注册错误讯息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
//    注册数据分组确认错误讯息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    if(!self.isInitSearch){
        self.isInitSearch = !self.isInitSearch;
        [[P2PClient sharedClient] getPlaybackFilesWithId:self.contact.contactId password:self.contact.contactPassword timeInterval:1];
    }
    
    [[P2PClient sharedClient] setPlaybackDelegate:self];
  
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
//    if (_isShowSheetView) {
//        [self cancelClick];
//    }
}


- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
//       回放文件
        case RET_GET_PLAYBACK_FILES:
        {
            //回放文件名称
            NSArray *array = [NSArray arrayWithArray:(NSArray*)[parameter valueForKey:@"files"]];
            //回放文件的时间记录
            NSArray *times = [NSArray arrayWithArray:(NSArray*)[parameter valueForKey:@"times"]];
            //回放文件的播放时长
            NSArray *sizes = [NSArray arrayWithArray:(NSArray*)[parameter valueForKey:@"sizes"]];
            
            
            //选择最近1天、3天、1个月或者自定义时，清空存储回放文件的数组、存储播放时长的数组
            if (self.isChangePlaybackItem) {
                [self.playbackFiles removeAllObjects];
                [self.playbackSize removeAllObjects];
                self.isChangePlaybackItem = NO;
            }
            
            //若不是上拉加载更多时，则往已清空的数组存放回放文件
            //若是上拉加载更多，则往存有数据的数组末尾添加回放文件
            for (NSString *file in array){
                [self.playbackFiles addObject:file];
            }
            
            //若不是上拉加载更多时，则往数组存放回放文件的播放时长
            //若是上拉加载更多，则往数组末尾添加回放文件的播放时长
            for (NSString *size in sizes){
                [self.playbackSize addObject:size];
            }
            
            //刷新表格
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                if (self.playbackFiles.count < 1) {
//                    沒有搜索到回放文件
                    [self.view makeToast:NSLocalizedString(@"no_playback_file", nil)];
                }
            });
            
            
            self.timesData = [NSMutableArray arrayWithArray:times];
            if (self.timesData.count==0) {
                return;
            }
            
            //记录最近1天、3天...已显示文件里最后一个文件的时间（最早文件的时间）
            //用于上拉加载时传入的结束时间
            self.nextStartTime = [self.timesData lastObject];
        }
            break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_GET_PLAYBACK_FILES:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView transitionWithView:self.searchMaskView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut
                                animations:^{
                                    self.searchMaskView.alpha = 0.3;
                                }
                 
                                completion:^(BOOL finished){
                                    [self.searchMaskView setHidden:YES];
                                }
                 ];
                
                if(result==1){
//                    设备密码错误
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);//暂停执行
                        dispatch_async(dispatch_get_main_queue(), ^{
//                            返回到上一层
                            [self dismissViewControllerAnimated:YES completion:nil];
                        });
                    });
                }else if(result==2){
//                    请检查设备联网状况
                    [self.view makeToast:NSLocalizedString(@"net_exception", nil)];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_GET_PLAYBACK_FILES:%i",result);
        }
            break;
    }
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.selectedLabel = 1;
    self.playbackFiles = [NSMutableArray arrayWithCapacity:0];
    self.dayOneFiles = [NSMutableArray arrayWithCapacity:0];
    self.dayThreeFiles = [NSMutableArray arrayWithCapacity:0];
    self.dayMonthFiles = [NSMutableArray arrayWithCapacity:0];
    self.customFiles = [NSMutableArray arrayWithCapacity:0];
    
    _arrayMultiDelete = [NSMutableArray arrayWithCapacity:0];

    self.playbackSize = [NSMutableArray arrayWithCapacity:0];
    
    [self initComponent];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define SEARCH_BAR_HEIGHT 36
#define TOP_INFO_BAR_HEIGHT 70
#define PLAYBACK_LIST_ITEM_HEIGHT 40
#define TOP_HEAD_MARGIN 10
#define PROGRESS_WIDTH_AND_HEIGHT 58
#define ANIM_VIEW_WIDTH_AND_HEIGHT 80


-(void)initComponent{
//    背景
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    [self.view setBackgroundColor:XBgColor];
//    导航栏
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
//    远程录像
    [topBar setTitle:NSLocalizedString(@"playback_TFCard",nil)];
    [self.view addSubview:topBar];
    [topBar release];
//    头部
    UIView *topInfoBarView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, TOP_INFO_BAR_HEIGHT)];
    [topInfoBarView setBackgroundColor:[UIColor colorWithRed:215/255.0f green:240/255.0f blue:250/255.0f alpha:1]];

    UIImageView *headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(TOP_HEAD_MARGIN, TOP_HEAD_MARGIN, (TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)*4/3, TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)];
//    修圆角
    headImgView.layer.cornerRadius = 7;
    headImgView.layer.masksToBounds = YES;//图片圆角
//   取图片
    NSString *filePath = [Utils getHeaderFilePathWithId:self.contact.contactId];
    UIImage *headImg = [UIImage imageWithContentsOfFile:filePath];
    if(headImg==nil)
    {
//        取系统给定的图片
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
    [self.view addSubview:topInfoBarView];
    [topInfoBarView release];
    
//
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+TOP_INFO_BAR_HEIGHT, width, SEARCH_BAR_HEIGHT)];
    [searchBarView setBackgroundColor:XWhite];
    UIImageView *layarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width/4, SEARCH_BAR_HEIGHT)];
    [layarView setBackgroundColor:XBlue];
    [searchBarView addSubview:layarView];
    self.layerView = layarView;
    [layarView release];
    
    for(int i=0;i<4;i++){
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*width/4,0,width/4,SEARCH_BAR_HEIGHT)];
        button.tag = i;
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,button.frame.size.width,button.frame.size.height)];
        
        textLabel.textAlignment = NSTextAlignmentCenter;
        ;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        if(i==0){
            textLabel.textColor = XBlack;
            textLabel.text = NSLocalizedString(@"recent_one_day", nil);
        }else if(i==1){
            textLabel.textColor = UIColorFromRGB(0x808080);
            textLabel.text = NSLocalizedString(@"recent_three_day", nil);
        }else if(i==2){
            textLabel.textColor = UIColorFromRGB(0x808080);
            textLabel.text = NSLocalizedString(@"recent_one_month", nil);
        }else if(i==3){
            textLabel.textColor = UIColorFromRGB(0x808080);
            textLabel.text = NSLocalizedString(@"custom", nil);
        }
        
        [button addSubview:textLabel];
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [searchBarView addSubview:button];
        [textLabel release];
        [button release];
        
    }
    
    [self.view addSubview:searchBarView];
    self.searchBarView = searchBarView;
    [searchBarView release];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+TOP_INFO_BAR_HEIGHT+SEARCH_BAR_HEIGHT, width, height-(NAVIGATION_BAR_HEIGHT+TOP_INFO_BAR_HEIGHT+SEARCH_BAR_HEIGHT)) style:UITableViewStylePlain];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView setBackgroundColor:XBGAlpha];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        
        //获取的回放文件里会包含endDate时间的文件
        NSDate * endDate = [Utils dateFromString:self.nextStartTime];
        
        if (self.selectedLabel==1) {
            //1 day
            //获取当前时间
            NSDate *nowDate = [NSDate date];
            //1天前
            NSDate *startDate = [nowDate dateByAddingTimeInterval: -(24*60*60)];
            
            [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneDay:YES];
            
            [[P2PClient sharedClient] getPlaybackFilesWithIdByDate:self.contact.contactId password:self.contact.contactPassword startDate:startDate endDate:endDate];
        }else if (self.selectedLabel==2){//3 days
            
            NSDate *nowDate = [NSDate date];
            //3天前
            NSDate *startDate = [nowDate dateByAddingTimeInterval: -(3*24*60*60)];
            
            [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForThreeDay:YES];
            
            [[P2PClient sharedClient] getPlaybackFilesWithIdByDate:self.contact.contactId password:self.contact.contactPassword startDate:startDate endDate:endDate];
        }else if (self.selectedLabel==3){//1 mon
            
            NSDate *nowDate = [NSDate date];
            //1个月前
            NSDate *startDate = [nowDate dateByAddingTimeInterval: -(31*24*60*60)];
            
            [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForOneMon:YES];
            
            [[P2PClient sharedClient] getPlaybackFilesWithIdByDate:self.contact.contactId password:self.contact.contactPassword startDate:startDate endDate:endDate];
        }else if (self.selectedLabel==4){
            
            [[P2PClient sharedClient] setIsLoadMorePlaybackFilesForCustom:YES];
            
            NSDate *customStartDate = [Utils dateFromString:self.startTime];
            [[P2PClient sharedClient] getPlaybackFilesWithIdByDate:self.contact.contactId password:self.contact.contactPassword startDate:customStartDate endDate:endDate];
        }
        //视频回放修复
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            延迟1秒
            sleep(1.0);
            dispatch_async(dispatch_get_main_queue(), ^{
//                停止动画
                [self.tableView.infiniteScrollingView stopAnimating];
            });
        });
        
    }];
    
    self.tableView = tableView;
    [tableView release];
    
//    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    lpgr.minimumPressDuration = 1.0; //seconds  设置响应时间
//    lpgr.delegate = self;
//    [self.tableView addGestureRecognizer:lpgr]; //启用长按事件

    
    
    UIView *searchMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-NAVIGATION_BAR_HEIGHT)];
    [searchMaskView setBackgroundColor:XBlack_128];
//    加载圆圈
    UIActivityIndicatorView *progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    progress.frame = CGRectMake((searchMaskView.frame.size.width-PROGRESS_WIDTH_AND_HEIGHT)/2, (searchMaskView.frame.size.height-PROGRESS_WIDTH_AND_HEIGHT)/2, PROGRESS_WIDTH_AND_HEIGHT, PROGRESS_WIDTH_AND_HEIGHT);
    [progress startAnimating];
    [searchMaskView addSubview:progress];
    [progress release];
    
    [searchMaskView setHidden:NO];
    [self.view addSubview:searchMaskView];
    self.searchMaskView = searchMaskView;
    [searchMaskView release];
    
    UIView *movieView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-NAVIGATION_BAR_HEIGHT)];
    [movieView setBackgroundColor:XBlack_128];
    UIImageView *animView = [[UIImageView alloc] initWithFrame:CGRectMake((movieView.frame.size.width-ANIM_VIEW_WIDTH_AND_HEIGHT)/2, (movieView.frame.size.height-ANIM_VIEW_WIDTH_AND_HEIGHT)/2, ANIM_VIEW_WIDTH_AND_HEIGHT, ANIM_VIEW_WIDTH_AND_HEIGHT)];
    
    NSArray *imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"movie1.png"],[UIImage imageNamed:@"movie2.png"],[UIImage imageNamed:@"movie3.png"],nil];
//    给图片动画
    animView.animationImages = imagesArray;
    animView.animationDuration = ((CGFloat)[imagesArray count])*100.0f/1000.0f;
    animView.animationRepeatCount = 0;
    [animView startAnimating];
    
    [movieView addSubview:animView];
    [animView release];
    [movieView setHidden:YES];
    [self.view addSubview:movieView];
    self.movieView = movieView;
    [movieView release];
    
    
    [self initCustomView];
    
    
}
#define SHEET_VIEW_HEIGHT   50
//-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer  //长按响应函数
//{
//    
//
//    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
//    CGFloat width = rect.size.width;
//    CGFloat height = rect.size.height;
//    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height-SHEET_VIEW_HEIGHT, width, SHEET_VIEW_HEIGHT)];
//    view.backgroundColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1];//工具条背景色
//    [self.view addSubview:view];
//    self.selectView = view;
//    NSLog(@"＝＝＝%f ＝＝＝＝%f",view.frame.size.width, view.frame.size.height);
//#pragma mark - 底部按钮
//    int intervalX = 0;
//    int intervalY = 5;
//    int btnWidth = width/4;
//    
//    UIButton* btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(intervalX, intervalY, btnWidth, SHEET_VIEW_HEIGHT-intervalY*2)];
//    btnCancel.tag = 1010;
//    [btnCancel setBackgroundImage:[UIImage imageNamed:@"monitor_sharpness"] forState:UIControlStateNormal];
//    [btnCancel.titleLabel setFont:XFontBold_14];
//    [btnCancel setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
//    [btnCancel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.selectView addSubview:btnCancel];
//    [btnCancel release];
//    
//    UIButton* btnDelete = [[UIButton alloc]initWithFrame:CGRectMake(intervalX+btnWidth, intervalY, btnWidth, SHEET_VIEW_HEIGHT-intervalY*2)];
//    btnDelete.tag = 1020;
//    [btnDelete setBackgroundImage:[UIImage imageNamed:@"monitor_sharpness"] forState:UIControlStateNormal];
//    [btnDelete.titleLabel setFont:XFontBold_14];
//    [btnDelete setTitle:NSLocalizedString(@"delete", nil) forState:UIControlStateNormal];
//    [btnDelete addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.selectView addSubview:btnDelete];
//    [btnDelete release];
//    
//    UIButton* btnSelectAll = [[UIButton alloc]initWithFrame:CGRectMake(intervalX+btnWidth*2, intervalY, btnWidth, SHEET_VIEW_HEIGHT-intervalY*2)];
//    
//    btnSelectAll.tag = 1030;
//    [btnSelectAll setBackgroundImage:[UIImage imageNamed:@"monitor_sharpness"] forState:UIControlStateNormal];
//    [btnSelectAll.titleLabel setFont:XFontBold_14];
//    [btnSelectAll setTitle:NSLocalizedString(@"select_all", nil) forState:UIControlStateNormal];
//    [btnSelectAll addTarget:self action:@selector(selectClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.selectView addSubview:btnSelectAll];
//    [btnSelectAll release];
//    
//    UIButton* btnPhone = [[UIButton alloc]initWithFrame:CGRectMake(intervalX+btnWidth*3, intervalY, btnWidth, SHEET_VIEW_HEIGHT-intervalY*2)];
//    
//    btnPhone.tag = 1040;
//    [btnPhone setBackgroundImage:[UIImage imageNamed:@"monitor_sharpness"] forState:UIControlStateNormal];
//    [btnPhone.titleLabel setFont:XFontBold_14];
//    [btnPhone setTitle:NSLocalizedString(@"save_to_photoalbum", nil) forState:UIControlStateNormal];
//    [btnPhone addTarget:self action:@selector(btnPhoneClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.selectView addSubview:btnPhone];
//    [btnPhone release];
//
//    
//}
//
//- (void)cancelClick{
//    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
//    CGFloat width = rect.size.width;
//    CGFloat height = rect.size.height;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        [UIView beginAnimations:nil context:context];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
//        self.selectView.frame = CGRectMake(0, self.view.frame.size.height-SHEET_VIEW_HEIGHT, width, SHEET_VIEW_HEIGHT);
//        [UIView setAnimationDelegate:self];
//        [UIView commitAnimations];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            usleep(600000);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.selectView setHidden:YES];
//                
//            });
//        });
//    });
//    if (_isShowSheetView)
//    {
//        [_arrayMultiDelete removeAllObjects];
//        [self.tableView reloadData];
//        _isShowSheetView = NO;
//    }
//
//}

#define CUSTOM_VIEW_RIGHT_BTN_WIDTH_AND_HEIGHT 38
#define CUSTOM_VIEW_INPUT_VIEW_HEIGHT 100
#define CUSTOM_VIEW_INPUT_VIEW_ITEM_LEFT_LABEL_WIDTH 85
-(void)initCustomView{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, height, width, 338)];
    [customView setBackgroundColor:XWhite];//自定义查询录像回放滚轮背景色
//    查询按钮
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn addTarget:self action:@selector(onCustomSearch:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setBackgroundColor:[UIColor grayColor]];
    [searchBtn setBackgroundImage:[UIImage imageNamed:@"bg_normal_cell_p.png"] forState:UIControlStateHighlighted];
    searchBtn.frame = CGRectMake(0, 0, customView.frame.size.width, CUSTOM_VIEW_RIGHT_BTN_WIDTH_AND_HEIGHT);
    
    UILabel *searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, searchBtn.frame.size.width, searchBtn.frame.size.height)];
    searchLabel.textAlignment = NSTextAlignmentCenter;
    searchLabel.textColor = XWhite;
    searchLabel.font = XFontBold_16;
    searchLabel.backgroundColor = [UIColor colorWithRed:3.0/255.0 green:162.0/255 blue:234.0/255.0 alpha:1.0];
    searchLabel.text = NSLocalizedString(@"search", nil);
    [searchBtn addSubview:searchLabel];
    [searchLabel release];
    
    [customView addSubview:searchBtn];
//
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, CUSTOM_VIEW_RIGHT_BTN_WIDTH_AND_HEIGHT, customView.frame.size.width, CUSTOM_VIEW_INPUT_VIEW_HEIGHT)];
    [inputView setBackgroundColor:XWhite];
//    开始时间
    UIButton *startTime = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, inputView.frame.size.width-20, (inputView.frame.size.height-30)/2)];
    startTime.tag = 0;
    startTime.layer.cornerRadius = 2;
    startTime.layer.borderWidth = 1;
    startTime.layer.borderColor = [XWhite CGColor];
    startTime.layer.masksToBounds = YES;
    startTime.backgroundColor = UIColorFromRGB(0xcccccc);
    [startTime.layer setShadowOffset:CGSizeMake(0, 0)];//阴影偏移
    [startTime.layer setShadowColor:[XBlue CGColor]];
    [startTime.layer setShadowOpacity:1.0];//阴影透明度
//    决定了子视图的显示范围。具体的说，就是当取值为YES时，剪裁超出父视图范围的子视图部分；当取值为NO时，不剪裁子视图
    [startTime setClipsToBounds:NO];
    self.startTimeBtn = startTime;
    [startTime addTarget:self action:@selector(changeTimeBtnShadow:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *startLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CUSTOM_VIEW_INPUT_VIEW_ITEM_LEFT_LABEL_WIDTH, startTime.frame.size.height)];
    startLeftLabel.textAlignment = NSTextAlignmentRight;
    startLeftLabel.textColor = XBlue;
    startLeftLabel.font = XFontBold_16;
    startLeftLabel.backgroundColor = XBGAlpha;
    startLeftLabel.text = NSLocalizedString(@"start_time", nil);
    [startTime addSubview:startLeftLabel];
    [startLeftLabel release];
    
    UILabel *startRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CUSTOM_VIEW_INPUT_VIEW_ITEM_LEFT_LABEL_WIDTH, 0, startTime.frame.size.width-CUSTOM_VIEW_INPUT_VIEW_ITEM_LEFT_LABEL_WIDTH, startTime.frame.size.height)];
    startRightLabel.textAlignment = NSTextAlignmentCenter;
    startRightLabel.textColor = XBlue;
    startRightLabel.font = XFontBold_16;
    startRightLabel.backgroundColor = XBGAlpha;
    startRightLabel.text = @"";
    [startTime addSubview:startRightLabel];
    self.startTimeLabel = startRightLabel;
    [startRightLabel release];
    
    [inputView addSubview:startTime];
//    结束时间
    UIButton *endTime = [[UIButton alloc] initWithFrame:CGRectMake(10, 10+(inputView.frame.size.height-30)/2+10, inputView.frame.size.width-20, (inputView.frame.size.height-30)/2)];
    endTime.tag = 1;
    endTime.layer.cornerRadius = 2;
    endTime.layer.borderWidth = 1;
    endTime.layer.borderColor = [XWhite CGColor];
    endTime.layer.masksToBounds = YES;
    endTime.backgroundColor = UIColorFromRGB(0xcccccc);
    [endTime.layer setShadowOffset:CGSizeMake(1, 1)];
    [endTime.layer setShadowColor:[XBGAlpha CGColor]];
    [endTime.layer setShadowOpacity:1.0];
    [endTime setClipsToBounds:NO];
    self.endTimeBtn = endTime;
    [endTime addTarget:self action:@selector(changeTimeBtnShadow:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *endLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CUSTOM_VIEW_INPUT_VIEW_ITEM_LEFT_LABEL_WIDTH, endTime.frame.size.height)];
    endLeftLabel.textAlignment = NSTextAlignmentRight;
    endLeftLabel.textColor = XBlue;
    endLeftLabel.font = XFontBold_16;
    endLeftLabel.backgroundColor = XBGAlpha;
    endLeftLabel.text = NSLocalizedString(@"end_time", nil);
    [endTime addSubview:endLeftLabel];
    [endLeftLabel release];
    
    
    UILabel *endRightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CUSTOM_VIEW_INPUT_VIEW_ITEM_LEFT_LABEL_WIDTH, 0, endTime.frame.size.width-CUSTOM_VIEW_INPUT_VIEW_ITEM_LEFT_LABEL_WIDTH, endTime.frame.size.height)];
    endRightLabel.textAlignment = NSTextAlignmentCenter;
    endRightLabel.textColor = XBlue;
    endRightLabel.font = XFontBold_16;
    endRightLabel.backgroundColor = XBGAlpha;
    endRightLabel.text = @"";
    [endTime addSubview:endRightLabel];
    self.endTimeLabel = endRightLabel;
    [endRightLabel release];
    
    [inputView addSubview:endTime];
    
    
    [customView addSubview: inputView];
    [inputView release];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CUSTOM_VIEW_RIGHT_BTN_WIDTH_AND_HEIGHT+CUSTOM_VIEW_INPUT_VIEW_HEIGHT, customView.frame.size.width, 338-CUSTOM_VIEW_RIGHT_BTN_WIDTH_AND_HEIGHT-CUSTOM_VIEW_INPUT_VIEW_HEIGHT)];
    // 显示模式
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker setDate:[NSDate date] animated:NO];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"zh-Hans-CN"]) {
   // 根据本地标识符创建本地化对象
        NSLocale* locale=[[NSLocale alloc]initWithLocaleIdentifier:@"zh-Hans-CN"];
        [datePicker setLocale:locale];
    }else if ([language isEqualToString:@"en"]){
        NSLocale* locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en"];
        [datePicker setLocale:locale];
    }
    // 设置显示最小时间
    [datePicker setMinimumDate:[Utils dateFromString:[NSString stringWithFormat:@"2013-07-01 00:00"]]];
    // 设置显示最大时间
    [datePicker setMaximumDate:[Utils dateFromString:[NSString stringWithFormat:@"2035-12-31 23:59"]]];
//    回调的方法
    [datePicker addTarget:self action:@selector(onDatePickChange:) forControlEvents:UIControlEventValueChanged];
    
    [customView addSubview:datePicker];
    [datePicker release];
    
    [self.view addSubview:customView];
    self.customView = customView;
    [customView release];
}

-(void)onCustomSearch:(UIButton*)button{
    NSString *startTime = self.startTimeLabel.text;
    NSString *endTime = self.endTimeLabel.text;
    
    self.startTime = startTime;
    self.endTime = endTime;
    
    if(!startTime||!startTime.length>0){
//        请选择开始时间
        [self.view makeToast:NSLocalizedString(@"unselected_start_time", nil)];
        return;
    }
    
    if(!endTime||!endTime.length>0){
//        请选择结束时间
        [self.view makeToast:NSLocalizedString(@"unselected_end_time", nil)];
        return;
    }
    
    NSDate *startDate = [Utils dateFromString:startTime];
    NSDate *endDate = [Utils dateFromString:endTime];
    if([startDate timeIntervalSince1970]>=[endDate timeIntervalSince1970]){
//        开始时间必须在结束时间之前
        [self.view makeToast:NSLocalizedString(@"start_time_must_before_end_time", nil)];
        return;
    }
    
    
    [self.searchMaskView setHidden:NO];
    self.searchMaskView.alpha = 0.3;
    
    [UIView transitionWithView:self.searchMaskView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.searchMaskView.alpha = 1.0;
    }
     
                    completion:^(BOOL finished){
                        
                    }
     ];
    
    if(self.isShowCustomView){
        self.isShowCustomView = !self.isShowCustomView;
        [UIView transitionWithView:self.customView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
//                            平移:设置平移量
                            self.customView.transform = CGAffineTransformMakeTranslation(0,0);
                        }
         
                        completion:^(BOOL isFinish){
                            
                        }
         ];
    }
    
    [[P2PClient sharedClient] getPlaybackFilesWithIdByDate:self.contact.contactId password:self.contact.contactPassword startDate:startDate endDate:endDate];
}

-(void)changeTimeBtnShadow:(UIButton*)button{
    self.selectedTimeTag = button.tag;
    switch(button.tag){
        case 0:
        {
            [self.startTimeBtn.layer setShadowColor:[XBlue CGColor]];
            [self.endTimeBtn.layer setShadowColor:[XBGAlpha CGColor]];
            
        }
            break;
        case 1:
        {
            [self.startTimeBtn.layer setShadowColor:[XBGAlpha CGColor]];
            [self.endTimeBtn.layer setShadowColor:[XBlue CGColor]];
        }
            break;
    }
}

-(void)onDatePickChange:(UIDatePicker*)datePick{
    NSString *dateString = [Utils stringFromDate:[datePick date]];
    switch(self.selectedTimeTag){
        case 0:
        {
            self.startTimeLabel.text = dateString;
        }
            break;
        case 1:
        {
            self.endTimeLabel.text = dateString;
        }
            break;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.playbackFiles count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return PLAYBACK_LIST_ITEM_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"PlaybackCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
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
    
    cell.textLabel.text = [self.playbackFiles objectAtIndex:indexPath.row];
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.movieView setHidden:NO];
    self.movieView.alpha = 0.3;
    
    [UIView transitionWithView:self.movieView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.movieView.alpha = 1.0;
                    }
     
                    completion:^(BOOL finished){
                        
                    }
     ];
    [[P2PClient sharedClient] p2pPlaybackCallWithId:self.contact.contactId password:self.contact.contactPassword index:indexPath.row];
}

-(void)updateLabelColor:(NSInteger)index{
    for(UIView *view in self.searchBarView.subviews){
        if([view isKindOfClass:[UIButton class]]){
            UILabel *label = [view.subviews objectAtIndex:0];
            
            if(view.tag==index){
                label.textColor = XBlack;
            }else{
                label.textColor = UIColorFromRGB(0x808080);
            }
        }
        
    }
}

-(void)onButtonPress:(id)sender{
    UIButton *button = (UIButton*)sender;
    BOOL isCustom = NO;
    self.isChangePlaybackItem = YES;//视频回放修复
    [[P2PClient sharedClient] setIsClearPlaybackFilesLength:YES];//视频回放修复
    switch(button.tag){
        case 0:
        {
            self.selectedLabel = 1;
            [[P2PClient sharedClient] getPlaybackFilesWithId:self.contact.contactId password:self.contact.contactPassword timeInterval:1];
            [self updateLabelColor:0];
            
        }
            break;
        case 1:
        {
            self.selectedLabel = 2;
            [[P2PClient sharedClient] getPlaybackFilesWithId:self.contact.contactId password:self.contact.contactPassword timeInterval:3];
            [self updateLabelColor:1];
        }
            break;
        case 2:
        {
            self.selectedLabel = 3;
            [[P2PClient sharedClient] getPlaybackFilesWithId:self.contact.contactId password:self.contact.contactPassword timeInterval:31];
            [self updateLabelColor:2];
        }
            break;
        case 3:
        {
            self.selectedLabel = 4;
            isCustom = YES;
            [self updateLabelColor:3];
            
            
        }
            break;
    }
    
    
    [UIView transitionWithView:self.layerView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.layerView.frame = CGRectMake(button.tag*button.frame.size.width, self.layerView.frame.origin.y, self.layerView.frame.size.width, self.layerView.frame.size.height);
                    }
     
                    completion:^(BOOL finished){
                        
                    }
     ];
    
    if(!isCustom){
        [self.searchMaskView setHidden:NO];
        self.searchMaskView.alpha = 0.3;
        
        [UIView transitionWithView:self.searchMaskView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.searchMaskView.alpha = 1.0;
        }
         
                        completion:^(BOOL finished){
                            
                        }
         ];
        
        if(self.isShowCustomView){
            self.isShowCustomView = !self.isShowCustomView;
            [UIView transitionWithView:self.customView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                            animations:^{
                                self.customView.transform = CGAffineTransformMakeTranslation(0,0);
                            }
             
                            completion:^(BOOL isFinish){
                                
                            }
             ];
        }
    }else{
        if(!self.isShowCustomView){
            self.isShowCustomView = !self.isShowCustomView;
            [UIView transitionWithView:self.customView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                            animations:^{
                                self.customView.transform = CGAffineTransformMakeTranslation(0, -self.customView.frame.size.height);
                            }
             
                            completion:^(BOOL isFinish){
                                
                            }
             ];
        }
    }
    
}


-(void)onBackPress{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)P2PPlaybackReady:(NSDictionary *)info{
    DLog(@"P2PPlaybackReady");
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.movieView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            self.movieView.alpha = 0.3;
                        }
         
                        completion:^(BOOL finished){
                            [self.movieView setHidden:YES];
                            P2PPlayingbackController *playingbackController = [[P2PPlayingbackController alloc] init];
                            [self presentViewController:playingbackController animated:YES completion:nil];
                            [playingbackController release];
                        }
         ];
    });
}

-(void)P2PPlaybackReject:(NSDictionary *)info{
    DLog(@"P2PPlaybackReject");
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.movieView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            self.movieView.alpha = 0.3;
                        }
         
                        completion:^(BOOL finished){
                            [self.movieView setHidden:YES];
                            [self.view makeToast:[info objectForKey:@"rejectMsg"]];
                        }
         ];
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
@end
