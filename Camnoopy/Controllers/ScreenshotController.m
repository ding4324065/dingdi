
#define PAGECONTROL_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:40)
#import "ScreenshotController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Toast+UIView.h"
#import "Utils.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "ScreenshotCell.h"
#import "TopBar.h"

#import "LineLayout.h"
@interface ScreenshotController ()
{
    BOOL _isShowSheetView;
    NSMutableArray* _arrayMultiDelete;
    
    TopBar* _topBar;
}
@end

@implementation ScreenshotController

-(void)dealloc{
    [self.screenshotFiles release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self initComponent];
    [self sheetViewinit];
   
    
    _arrayMultiDelete = [[NSMutableArray alloc]init];
    _imageArr = [[NSMutableArray alloc] init];
//    [_imageArr addObject:[NSNull null]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_isShowSheetView) {
        [self cancelClick];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
    [self reloadScrollview];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    if (self.screenshotFiles != nil) {
        [self.screenshotFiles removeAllObjects];
    }

    NSArray *datas = [Utils getScreenShotFilesWithContactId:nil];
    self.screenshotFiles = [NSMutableArray arrayWithArray:datas];
}
#pragma mark - 滑动查看的scrollview
- (void)reloadScrollview
{
    for (UIView * view in self.detailImgScroll.subviews) {
        [view removeFromSuperview];
    }
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;

    self.detailImgScroll.contentSize = CGSizeMake(width*self.screenshotFiles.count, 0);

    for (NSInteger i =0; i<self.screenshotFiles.count; i++)
    {
        NSString *name = self.screenshotFiles[i];
        NSString *filePath = [Utils getScreenshotFilePathWithName:name contactId:nil];
        
        UIScrollView * imgscrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(width*i, 0, width, height)];
        imgscrollView.backgroundColor = XBlack;
        imgscrollView.showsVerticalScrollIndicator = NO;
        imgscrollView.contentSize = CGSizeMake(width, height);
        imgscrollView.bounces = NO;
        imgscrollView.delegate = self;
        imgscrollView.minimumZoomScale=1.0;
        imgscrollView.maximumZoomScale=3.0;
        [imgscrollView setZoomScale:1.0];
        [self.detailImgScroll addSubview:imgscrollView];
        [imgscrollView release];
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageWithContentsOfFile:filePath];
        imageView.userInteractionEnabled = YES;
        [imgscrollView addSubview:imageView];
        [imageView release];
//        点击两下进入全屏
        UITapGestureRecognizer*doubleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapOnPicture:)];
        [doubleTap setNumberOfTapsRequired:2];
        [imageView addGestureRecognizer:doubleTap];
        [doubleTap release];
//        点击一下退回查看截图界面
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnPicture:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [imageView addGestureRecognizer:singleTap];
        [singleTap release];
    }
}



#define ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 150:90)
#define ITEM_MARGIN 10
-(void)initComponent{
#pragma mark - 导航栏
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar.leftButton setHidden:NO];
    [topBar setLeftButtonIcon:[UIImage imageNamed:@"open_menu"]];
    [topBar.leftButton addTarget:self action:@selector(onMenuPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setRightButtonHidden:YES];
    [topBar setTitle:NSLocalizedString(@"screenshot",nil)];
    _topBar = topBar;
    [self.view addSubview:topBar];
    [topBar release];
    
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [tableView setBackgroundColor:XBGAlpha];
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    //init scrollview
    UIScrollView * imgscrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
//    [imgscrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//    [imgscrollView setAutoresizesSubviews:YES];
    imgscrollView.showsVerticalScrollIndicator = NO;
    imgscrollView.showsHorizontalScrollIndicator = NO;
    imgscrollView.bounces = NO;
    imgscrollView.pagingEnabled = YES;
    imgscrollView.delegate = self;
    imgscrollView.hidden = YES;
    self.detailImgScroll = imgscrollView;
    [self.view addSubview:imgscrollView];
    [imgscrollView release];
//    拍摄前标签
    UILabel * shottopLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, PAGECONTROL_WIDTH, width, PAGECONTROL_WIDTH)];
    shottopLabel.textAlignment= NSTextAlignmentCenter;
    shottopLabel.textColor = XWhite;
    shottopLabel.hidden = YES;
    [self.view addSubview:shottopLabel];
    self.shottopLabel = shottopLabel;
    [shottopLabel release];
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView{
    for(UIView*v in scrollView.subviews){
        return v;
    }
    return nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView{
    if(scrollView ==self.detailImgScroll){
        CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
        CGFloat width = rect.size.width;
        int offset = scrollView.contentOffset.x/width;
        NSArray *datas = [NSArray arrayWithArray:[Utils getScreenShotFilesWithContactId:nil]];
        self.shottopLabel.text = [NSString stringWithFormat:@"%d/%d",offset+1,datas.count];
        CGFloat x = scrollView.contentOffset.x;
        if(x==-333){
        }
        else{
            //            offset = x;
            for(UIScrollView *s in scrollView.subviews){
                if([s isKindOfClass:[UIScrollView class]]){
                    [s setZoomScale:1.0]; //scrollView每滑动一次将要出现的图片较正常时候图片的倍数（将要出现的图片显示的倍数）
                }
            }
        }
    }
}

#pragma mark -
-(void)doubleTapOnPicture:(UIGestureRecognizer*)gesture{
    
    UIScrollView* scrollView = (UIScrollView*)gesture.view.superview;
    BOOL isZoomed = !([scrollView zoomScale] == [scrollView minimumZoomScale]);
    
    float newScale;
    CGRect zoomRect;
    if (isZoomed) {
        zoomRect = [scrollView bounds];
    } else {
        newScale = [scrollView maximumZoomScale];
        zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    }
    [scrollView zoomToRect:zoomRect animated:YES];
    /*
    float newScale = [(UIScrollView*)gesture.view.superview zoomScale] *1.5;//每次双击放大倍数
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [(UIScrollView*)gesture.view.superview zoomToRect:zoomRect animated:YES];
     */
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height=self.view.frame.size.height/ scale;
    zoomRect.size.width=self.view.frame.size.width/ scale;
    zoomRect.origin.x= center.x- (zoomRect.size.width/2.0);
    zoomRect.origin.y= center.y- (zoomRect.size.height/2.0);
    return zoomRect;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int iFileCount = [self.screenshotFiles count];
    if (iFileCount == 0) {
        return 0;
    }
    else
    {
        return iFileCount/2 + iFileCount%2;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ITEM_HEIGHT;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"ScreenshotCell";
    ScreenshotCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[ScreenshotCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    cell.backgroundColor = XBGAlpha;
    
    NSString* name0 = @"";
    NSString* name1 = @"";
    if ([self.screenshotFiles count] > indexPath.row*2) {
        name0 = [self.screenshotFiles objectAtIndex:indexPath.row*2];
    }
    if ([self.screenshotFiles count] > indexPath.row*2+1) {
        name1 = [self.screenshotFiles objectAtIndex:indexPath.row*2+1];
    }
    
    NSString *filePath1 = [Utils getScreenshotFilePathWithName:name0 contactId:nil];
    NSString *filePath2 = [Utils getScreenshotFilePathWithName:name1 contactId:nil];
    [cell setRow:indexPath.row];
    cell.delegate = self;
    if(!name0||[name0 isEqualToString:@""]){
        [cell setFilePath1:@""];
    }else{
        [cell setFilePath1:filePath1];
        
        NSMutableArray* array = [Utils getCaptureInfoFromPath:name0];
        NSString* text = [NSString stringWithFormat:@"id:%@ %@", [array objectAtIndex:0], [array objectAtIndex:1]];
        [cell setText1:text];
    }
    
    if(!name1||[name1 isEqualToString:@""]){
        [cell setFilePath2:@""];
    }else{
        [cell setFilePath2:filePath2];
        
        NSMutableArray* array = [Utils getCaptureInfoFromPath:name1];
        NSString* text = [NSString stringWithFormat:@"id:%@ %@", [array objectAtIndex:0], [array objectAtIndex:1]];
        [cell setText2:text];
    }
    
    NSNumber* number = [NSNumber numberWithInt:indexPath.row*2];
    if ([_arrayMultiDelete containsObject:number]) {
        [cell setIsHiddenMask1:NO];
    }
    else
    {
        [cell setIsHiddenMask1:YES];
    }
    
    number = [NSNumber numberWithInt:indexPath.row*2+1];
    if ([_arrayMultiDelete containsObject:number]) {
        [cell setIsHiddenMask2:NO];
    }

    else
    {
        [cell setIsHiddenMask2:YES];
    }
    
    
    
    return cell;
}
#pragma mark - 单点
-(void)onItemClick:(ScreenshotCell *)screenshotCell row:(NSInteger)row index:(NSInteger)index{
    if (!_isShowSheetView) {
        if(self.isShowDetail){
            return;
        }
        _selectedRow = row;
        NSLog(@"%ld...",_selectedRow);
        self.isShowDetail = YES;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        NSInteger cnt = row*2+index;
        
        NSArray *datas = [NSArray arrayWithArray:[Utils getScreenShotFilesWithContactId:nil]];
        self.shottopLabel.text = [NSString stringWithFormat:@"%ld/%ld",cnt+1,datas.count];
        self.shottopLabel.hidden = NO;
        
        self.detailImgScroll.contentOffset = CGPointMake(width*cnt, 0);
        self.detailImgScroll.hidden = NO;
        self.detailImgScroll.transform = CGAffineTransformMakeScale(0.3, 0.3);
        self.detailImgScroll.alpha = 0.1;
        [UIView transitionWithView:self.detailImgScroll duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            self.detailImgScroll.alpha = 1.0;
                            self.detailImgScroll.transform = CGAffineTransformMakeScale(1.0, 1.0);
                        }
                        completion:^(BOOL finished) {
                            
                        }
         ];
    }
    else
    {
        NSNumber* number = [NSNumber numberWithInt:row*2+index];
        if ([_arrayMultiDelete containsObject:number])
        {
            [_arrayMultiDelete removeObject:number];
        }
        else{
            [_arrayMultiDelete addObject:number];
        }
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
        UIButton* btnDelete = (UIButton*)[self.selectView viewWithTag:102];
        btnDelete.enabled = ([_arrayMultiDelete count] > 0);
    }
}
#pragma mark - 长按
-(void)onItemLongPress:(ScreenshotCell *)screenshotCell row:(NSInteger)row index:(NSInteger)index
{
    if (_isShowSheetView) {
        return;
    }
    _isShowSheetView = YES;
    _selectedRow = row*2+index;
    NSLog(@"%d",_selectedRow);
    
    //更新内存
    NSNumber* number = [NSNumber numberWithInt:row*2+index];
    [_arrayMultiDelete addObject:number];
    
    //更新界面
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    
    [self animationstart];
    
}

-(void)singleTapOnPicture:(UIGestureRecognizer*)gesture
{
    self.isShowDetail = NO;
    self.shottopLabel.hidden = YES;
    [UIView transitionWithView:self.detailImgScroll duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.detailImgScroll.alpha = 0.1;
                        self.detailImgScroll.transform = CGAffineTransformMakeScale(0.3, 0.3);
                    }
                    completion:^(BOOL finished) {
                        self.detailImgScroll.hidden = YES;
                        
                        for(UIScrollView *s in self.detailImgScroll.subviews){
                            if([s isKindOfClass:[self.detailImgScroll class]]){
                                [s setZoomScale:1.0]; //scrollView每滑动一次将要出现的图片较正常时候图片的倍数（将要出现的图片显示的倍数）
                            }
                        }
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

-(void)onMenuPress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_LEFTMENU_CMD object:self];
    });
}
#define SHEET_VIEW_HEIGHT   50
#pragma mark - 底部视图
-(void)sheetViewinit{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, SHEET_VIEW_HEIGHT)];
    view.backgroundColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1];//工具条背景色
    [self.view addSubview:view];
    self.selectView = view;
    [view release];
    #pragma mark - 底部按钮
    int intervalX = 0;
    int intervalY = 5;
    int btnWidth = width/4;
    
    UIButton* btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(intervalX, intervalY, btnWidth, SHEET_VIEW_HEIGHT-intervalY*2)];
    btnCancel.tag = 101;
    [btnCancel setBackgroundImage:[UIImage imageNamed:@"monitor_sharpness"] forState:UIControlStateNormal];
    [btnCancel.titleLabel setFont:XFontBold_14];
    [btnCancel setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    [self.selectView addSubview:btnCancel];
    [btnCancel release];

    UIButton* btnDelete = [[UIButton alloc]initWithFrame:CGRectMake(intervalX+btnWidth, intervalY, btnWidth, SHEET_VIEW_HEIGHT-intervalY*2)];
    btnDelete.tag = 102;
    [btnDelete setBackgroundImage:[UIImage imageNamed:@"monitor_sharpness"] forState:UIControlStateNormal];
    [btnDelete.titleLabel setFont:XFontBold_14];
    [btnDelete setTitle:NSLocalizedString(@"delete", nil) forState:UIControlStateNormal];
    [btnDelete addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.selectView addSubview:btnDelete];
    [btnDelete release];
    
    UIButton* btnSelectAll = [[UIButton alloc]initWithFrame:CGRectMake(intervalX+btnWidth*2, intervalY, btnWidth, SHEET_VIEW_HEIGHT-intervalY*2)];

    btnSelectAll.tag = 103;
    [btnSelectAll setBackgroundImage:[UIImage imageNamed:@"monitor_sharpness"] forState:UIControlStateNormal];
    [btnSelectAll.titleLabel setFont:XFontBold_14];
    [btnSelectAll setTitle:NSLocalizedString(@"select_all", nil) forState:UIControlStateNormal];
    [btnSelectAll addTarget:self action:@selector(selectClick) forControlEvents:UIControlEventTouchUpInside];
    [self.selectView addSubview:btnSelectAll];
    [btnSelectAll release];
    
    UIButton* btnPhone = [[UIButton alloc]initWithFrame:CGRectMake(intervalX+btnWidth*3, intervalY, btnWidth, SHEET_VIEW_HEIGHT-intervalY*2)];

    btnPhone.tag = 104;
    [btnPhone setBackgroundImage:[UIImage imageNamed:@"monitor_sharpness"] forState:UIControlStateNormal];
    [btnPhone.titleLabel setFont:XFontBold_14];
    [btnPhone setTitle:NSLocalizedString(@"save_to_photoalbum", nil) forState:UIControlStateNormal];
    [btnPhone addTarget:self action:@selector(btnPhoneClick) forControlEvents:UIControlEventTouchUpInside];
    [self.selectView addSubview:btnPhone];
    [btnPhone release];

}

-(void)animationstart{
    self.selectView.hidden = NO;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    self.selectView.frame = CGRectMake(0, height-SHEET_VIEW_HEIGHT, width, SHEET_VIEW_HEIGHT);
    UIButton* btnDelete = (UIButton*)[self.selectView viewWithTag:102];
    btnDelete.enabled = YES;
    UIButton* btnPhone = (UIButton*)[self.selectView viewWithTag:104];
    btnPhone.enabled = YES;
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

#pragma mark - 取消按钮
-(void)cancelClick{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
        self.selectView.frame = CGRectMake(0, height, width, SHEET_VIEW_HEIGHT);
        [UIView setAnimationDelegate:self];
        [UIView commitAnimations];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            usleep(600000);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.selectView setHidden:YES];
                
            });
        });
    });
    if (_isShowSheetView)
    {
        [_arrayMultiDelete removeAllObjects];
        [self.tableView reloadData];
        _isShowSheetView = NO;
    }
}
#pragma mark - 删除按钮
-(void)deleteClick
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_delete", nil)
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    alert.tag = 10001;
    [alert show];
    [alert release];
}
#pragma mark - 全选按钮
-(void)selectClick
{
    if ([_arrayMultiDelete count] == [self.screenshotFiles count])
    {
        //已经是全选状态，再点全取消
        [_arrayMultiDelete removeAllObjects];
        
        UIButton* btnDelete = (UIButton*)[self.selectView viewWithTag:102];
        btnDelete.enabled = NO;
        UIButton*  btnPhone= (UIButton*)[self.selectView viewWithTag:104];
        btnPhone.enabled = NO;
    }
    else
    {
        //不是全选状态，则设置成全选
        [_arrayMultiDelete removeAllObjects];
        for (int i=0; i<[self.screenshotFiles count]; i++) {
            NSNumber* number = [NSNumber numberWithInt:i];
            [_arrayMultiDelete addObject:number];
        }
        
        UIButton* btnDelete = (UIButton*)[self.selectView viewWithTag:102];
        btnDelete.enabled = YES;
        UIButton*  btnPhone= (UIButton*)[self.selectView viewWithTag:104];
        btnPhone.enabled =YES;
    }
    
    [self.tableView reloadData];
    
}
#pragma mark - 保存相册按钮
- (void)btnPhoneClick
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"save_to_photoalbum", nil)
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    alert.tag = 10002;
    [alert show];
    [alert release];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1)
    {
#pragma mark - 删除文件
        if (alertView.tag == 10001)
        {
            LoginResult *loginResult = [UDManager getLoginInfo];
            NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePath = [NSString stringWithFormat:@"%@/screenshot/%@",rootPath,loginResult.contactId];
            
            NSFileManager *manager = [NSFileManager defaultManager];
            NSError *error;
            
            for (int i=0; i<[_arrayMultiDelete count]; i++)
            {
                int index = [[_arrayMultiDelete objectAtIndex:i]intValue];
                NSString* pngPath = [NSString stringWithFormat:@"%@/%@", filePath, [self.screenshotFiles objectAtIndex:index]];
                [manager removeItemAtPath:pngPath error:&error];
                if(error)
                {
                    //DLog(@"%@",error);
                }
            }
            //退出
            [self.view makeToast:NSLocalizedString(@"delete_success", nil)];
        }
#pragma mark - 保存相册
        else if (alertView.tag == 10002)
        {
                LoginResult *loginResult = [UDManager getLoginInfo];
                NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                for (int i = 0; i < _arrayMultiDelete.count; i++) {
                    int index = [[_arrayMultiDelete objectAtIndex:i] intValue];
                    NSString* fileName = [self.screenshotFiles objectAtIndex:index];
                    _filePath = [NSString stringWithFormat:@"%@/screenshot/%@/%@",rootPath,loginResult.contactId,fileName];
                    UIImage *img1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@",_filePath]];
                    [_imageArr addObject:img1];
//                   NSLog(@"%@",_imageArr);
            }
            UIImageWriteToSavedPhotosAlbum([_imageArr objectAtIndex:0], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    //刷新内存
    [self reloadData];
    
    //更新界面
    [self reloadScrollview];
    [self.tableView reloadData];
    [self cancelClick];
}
#pragma 递归
-(void) saveNext{
    if (_imageArr.count > 0)
    {
        UIImage *image = [_imageArr objectAtIndex:0];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }
    else
    {
        [self allDone];
    }
}
- (void)allDone
{
    [_imageArr removeAllObjects];
    
}
#pragma mark - 检查访问相册的权限
-(void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo
{
    if (error != NULL) {
        NSLog(@"%@",error);
        BOOL ret = [Utils IsGetPhotoAlbumAuthorization];
        if (!ret) {
            [self.view makeToast:NSLocalizedString(@"save_photoalbum_tip", nil)];
        }
    }
    else
    {
//        NSLog(@"%d----111111",_imageArr.count);
//        NSLog(@"%@",_imageArr);

        if (_imageArr.count>0) {
            [_imageArr removeObjectAtIndex:0];
        }
        [self.view makeToast:NSLocalizedString(@"save_ok_photoalbum", nil)];
        NSLog(@"save ok");
    }
    [self saveNext];
}

- (void)uibutton:(UIButton *)uibutton clickedButtonTag:(NSInteger)tag
{
    
}
#pragma mark - 重新加载语言
-(void)ReloadLanguage
{
    [_topBar setTitle:NSLocalizedString(@"screenshot",nil)];
    
    UIButton* btnCancel = (UIButton*)[self.selectView viewWithTag:101];
    [btnCancel setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    
    UIButton* btnDelete = (UIButton*)[self.selectView viewWithTag:102];
    [btnDelete setTitle:NSLocalizedString(@"delete", nil) forState:UIControlStateNormal];
    
    UIButton* btnSelectAll = (UIButton*)[self.selectView viewWithTag:103];
    [btnSelectAll setTitle:NSLocalizedString(@"select_all", nil) forState:UIControlStateNormal];
    
    UIButton* btnPhone = (UIButton*)[self.selectView viewWithTag:104];
    [btnPhone setTitle:NSLocalizedString(@"save_to_photoalbum", nil) forState:UIControlStateNormal];
}

#ifdef _FOR_DEBUG_
- (BOOL)respondsToSelector:(SEL)rtSelector
{
    NSString *className = NSStringFromClass([self class]) ;
    NSLog(@"%@ --> RTSelector: %s",className,[NSStringFromSelector(rtSelector)UTF8String]);
    return [super respondsToSelector:rtSelector];
}
#endif
@end
