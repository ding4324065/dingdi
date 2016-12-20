//
//  P2PPlaybackControllerEx.m
//  Camnoopy
//
//  Created by wutong on 15-1-19.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "P2PPlaybackControllerEx.h"
#import "Constants.h"
#import "P2PClient.h"
#import "Toast+UIView.h"
#import "Utils.h"
#import "RecordInfo.h"

@interface P2PPlaybackControllerEx ()
{
    KTVideoTimerView* _timeView;
    UIActivityIndicatorView* _indicator;
    UIButton* _btnPlay;
    
    NSDate* _beginSearchDate;
    NSDate* _endSearchDate;

    NSDate* _beginShowDate;
    NSDate* _endShowDate;
    
    NSMutableArray* _arraryRecordInfo;
    
    BOOL _bSearching;   //防止pc端搜索时，结果返回到Camnoopy，造成错误
}
@end

@implementation P2PPlaybackControllerEx

-(void)dealloc
{
    [_beginSearchDate release];
    _beginSearchDate = nil;
    
    [_endSearchDate release];
    _endSearchDate = nil;

    [[P2PClient sharedClient] setPlaybackDelegate:nil];

    [self.remoteView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor grayColor];
        _arraryRecordInfo = [[NSMutableArray alloc]initWithCapacity:0];
        
        [[P2PClient sharedClient] setPlaybackDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initComponents];
}


#define SEARCH_BAR_HEIGHT 36
#define TOP_INFO_BAR_HEIGHT 80
#define PLAYBACK_LIST_ITEM_HEIGHT 40
#define TOP_HEAD_MARGIN 10
#define PROGRESS_WIDTH_AND_HEIGHT 58
#define ANIM_VIEW_WIDTH_AND_HEIGHT 80
- (void)initComponents
{
    CGRect frame = [UIScreen mainScreen].bounds;
    CGFloat height = frame.size.height;
    
    //OPenGL view
    OpenGLView *glView = [[OpenGLView alloc] init];
    self.remoteView = glView;
    [self.remoteView.layer setMasksToBounds:YES];
    [self.view addSubview:self.remoteView];
    [glView release];
    
    //进度条
    _timeView = [[KTVideoTimerView alloc] initWithFrame:CGRectMake(0, 0, height, 55)];
    _timeView.center = CGPointMake(self.view.bounds.size.height/2.0, self.view.bounds.size.width-60);
    //    _timeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    //    _timeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pb_time_bg"]];
    //    _timeView.backgroundColor = [UIColor orangeColor];
    _timeView.loadRdListdelegate = self;
    _timeView.alpha = 0.7;
    [self.view addSubview:_timeView];
    [_timeView release];
    
    UIButton* btnFresh = [[UIButton alloc]initWithFrame:CGRectMake(30, 30, 60, 20)];
    [btnFresh setTitle:@"refresh" forState:UIControlStateNormal];   //wxlanguage
    [btnFresh showsTouchWhenHighlighted];
    [btnFresh addTarget:self action:@selector(onBtnFresh) forControlEvents:UIControlEventTouchDown];
    btnFresh.alpha = 0.7;
    [self.view addSubview:btnFresh];
    [btnFresh release];
    
    _btnPlay = [[UIButton alloc]initWithFrame:CGRectMake(30, 100, 60, 25)];
    [_btnPlay setTitle:@"play" forState:UIControlStateNormal];      //wxlanguage
    [_btnPlay showsTouchWhenHighlighted];
    [_btnPlay addTarget:self action:@selector(onBtnPlay) forControlEvents:UIControlEventTouchDown];
    _btnPlay.alpha = 0.7;
    [self.view addSubview:_btnPlay];
    [_btnPlay release];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationLandscapeRight );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}

- (void)receiveRemoteMessage:(NSNotification *)notification
{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    if (key != RET_GET_PLAYBACK_FILES) {
        return;
    }
    
    NSArray *array = [NSArray arrayWithArray:(NSArray*)[parameter valueForKey:@"files"]];
    NSArray *times = [NSArray arrayWithArray:(NSArray*)[parameter valueForKey:@"times"]];
    NSArray *lengths = [NSArray arrayWithArray:(NSArray*)[parameter valueForKey:@"lengths"]];
    
    NSMutableArray* arrayRecordInfo = [[NSMutableArray alloc]initWithCapacity:0];
    for (int i=0; i<[times count]; i++)
    {
        RecordInfo* rdInfo = [[RecordInfo alloc]init];
        NSString* str = [times objectAtIndex:i];
        rdInfo.startTime = [Utils dateFromString:str];
        
        NSNumber* size = [lengths objectAtIndex:i];
        DWORD length = [size unsignedIntValue];
        rdInfo.endTime = [[NSDate date] initWithTimeInterval:length sinceDate:rdInfo.startTime];

        [arrayRecordInfo addObject:rdInfo];
    }
    
    if ([array count] == 64)
    {
        RecordInfo* rdInfo = [arrayRecordInfo firstObject];
        if ([rdInfo.startTime timeIntervalSince1970] < [_endSearchDate timeIntervalSince1970])
        {
            [self saveValidRecordInfo:arrayRecordInfo];
            [[P2PClient sharedClient]getPlaybackFilesWithIdByDate:self.contact.contactId password:self.contact.contactPassword startDate:rdInfo.startTime endDate:_endSearchDate];
        }
        else
        {
            [self saveValidRecordInfo:arrayRecordInfo];
            [self stopSearchList:YES];
        }
    }
    else if ([array count] < 64)
    {
        [self saveValidRecordInfo:arrayRecordInfo];
        [self stopSearchList:YES];
    }
    
    /*
    NSLog(@"array count = %d, times count = %d", [array count], [times count]);
    for (int i=0; i<[array count]; i++) {
        NSString* s1 = [array objectAtIndex:i];
        NSString* s2 = [times objectAtIndex:i];
        NSNumber* length = [lengths objectAtIndex:i];
        NSLog(@"*****index%02d*****%@*****%@, size=%d", i, s1, s2, [length unsignedIntValue]);
    }
    */
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    
    if (key != ACK_RET_GET_PLAYBACK_FILES) {
        return;
    }
    
    if (result != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopSearchList:NO];
        });
    }
    
    if(result==1){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                usleep(800000);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
                });
        });
    }else if(result==2){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:NSLocalizedString(@"net_exception", nil)];
        });
    }
}

- (void)startAnimation
{
    if (!_indicator)
    {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
        _indicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        _indicator.hidesWhenStopped = YES;
        _indicator.color = [UIColor blackColor];
        [self.view addSubview:_indicator];
        [_indicator release];
    }
    [_indicator startAnimating];
}

- (void)stopAnimation
{
    [_indicator stopAnimating];
}


-(void)onBtnFresh
{
    NSDate* dateCurrent = [NSDate date];
    NSDate *dateNew = [[NSDate date] initWithTimeInterval:-24 *60 * 60 sinceDate:dateCurrent];
    
    NSTimeInterval t1 = [dateNew timeIntervalSince1970];
    unsigned int t2 = (unsigned int)t1;
    t2 -= t2%3600;
    dateNew = [NSDate dateWithTimeIntervalSince1970:t2];    //开始时间取整数
    
    self.beginSearchDate = dateNew;
    self.endSearchDate = dateCurrent;

    self.beginShowDate = dateNew;
    self.endShowDate = dateCurrent;
    
    [self startSearchListFromDate:_beginSearchDate toDate:_endSearchDate reSet:YES];
}

-(void)startSearchListFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate reSet:(BOOL)reSet
{
    NSLog(@"search %@ ======== %@", fromDate, toDate);
    [self startAnimation];
    
    if (reSet) {
        [_arraryRecordInfo removeAllObjects];
    }
    
    _bSearching = YES;
    [[P2PClient sharedClient]getPlaybackFilesWithIdByDate:self.contact.contactId password:self.contact.contactPassword startDate:fromDate endDate:toDate];
}

-(void)stopSearchList:(BOOL)success
{
    if (!_bSearching) {
        return;
    }
    _bSearching = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       [self stopAnimation];
    });
    
    /*****reload list****/
    if (success) {
        NSLog(@"show %@ ======== %@", self.beginShowDate, self.endShowDate);

        _timeView.startTm = self.beginShowDate;
        _timeView.endTm = self.endShowDate;
        [_timeView setRecordList:_arraryRecordInfo offsetDate:self.endSearchDate];
    }
}

-(void)saveValidRecordInfo:(NSArray*)arrayRecordInfo
{
    for (int i=0; i<[arrayRecordInfo count]; i++)
    {
        RecordInfo* rdInfo = [arrayRecordInfo objectAtIndex:i];
        if([rdInfo.startTime timeIntervalSince1970] < [_endSearchDate timeIntervalSince1970])
        {
            [_arraryRecordInfo addObject:rdInfo];
        }
    }
}

-(void)loadRecordList:(BOOL)bTowardLeft
{
    if (bTowardLeft)   //向左搜索
    {
        NSDate *newdate = [[NSDate date] initWithTimeInterval:-24 *60 * 60 sinceDate:self.beginShowDate];
        self.endSearchDate = self.beginShowDate;
        self.beginSearchDate = newdate;
        self.beginShowDate = newdate;

        [self startSearchListFromDate:newdate toDate:_timeView.startTm reSet:NO];
    }
    else                //向右搜索
    {
        NSDate *newdate = [[NSDate date] initWithTimeInterval:24 *60 * 60 sinceDate:self.endShowDate];
        self.beginSearchDate = self.endShowDate;
        self.endSearchDate = newdate;
        self.endShowDate = newdate;
        
        [self startSearchListFromDate:_timeView.endTm toDate:newdate reSet:NO];
    }
}

-(void)onBtnPlay
{
    [self startAnimation];
    [[P2PClient sharedClient] p2pPlaybackCallWithId:self.contact.contactId password:self.contact.contactPassword index:0];

}

- (void)renderView
{
    GAVFrame * m_pAVFrame ;
    
    while (1)   //wxlanguage
    {
        if([[P2PClient sharedClient] playbackState]==PLAYBACK_STATE_PAUSE){
            usleep(10000);
            continue;
        }
        
        if(fgGetVideoFrameToDisplay(&m_pAVFrame))
        {
            [self.remoteView render:m_pAVFrame];
            vReleaseVideoFrame();
            
        }
        usleep(10000);
        
        
    }
    
}

-(void)P2PPlaybackReady:(NSDictionary *)info{
    DLog(@"P2PPlaybackReady");
    dispatch_async(dispatch_get_main_queue(), ^{
        //指示器停止转动
        [self stopAnimation];
        
        //设置OPenGL view
        CGRect frame = [UIScreen mainScreen].bounds;
        CGFloat height, width;
        if(CURRENT_VERSION>=8.0)
        {
            width = frame.size.width;
            height = frame.size.height;
        }
        else
        {
            width = frame.size.height;
            height = frame.size.width;
        }
        
        if([[P2PClient sharedClient] is16B9])
        {
            CGFloat finalWidth = height*16/9;
            CGFloat finalHeight = height;
            if(finalWidth>width){
                finalWidth = width;
                finalHeight = width*9/16;
            }else{
                finalWidth = height*16/9;
                finalHeight = height;
            }
            self.remoteView.frame = CGRectMake((width-finalWidth)/2, (height-finalHeight)/2, finalWidth, finalHeight);
            
        }
        else
        {
            self.remoteView.frame = CGRectMake((width-height*4/3)/2, 0, height*4/3, height);
        }
        
        //开始获取视频帧且渲染
        [NSThread detachNewThreadSelector:@selector(renderView) toTarget:self withObject:nil];
    });
}

-(void)P2PPlaybackReject:(NSDictionary *)info{
    DLog(@"P2PPlaybackReject");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopAnimation];
        [self.view makeToast:[info objectForKey:@"rejectMsg"]];
    });
}
@end
