//
//  LocalFilesListController.m
//  2cu
//
//  Created by wutong on 15-6-24.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "LocalFilesListController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Utils.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "Toast+UIView.h"

@interface LocalFilesListController ()
{
    int _currentPlayingIndex;
    GWMovieViewController* _movieCtrl;
    int _selectedRow;
}
@end

@implementation LocalFilesListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arrayFiles = [Utils getRecordFilesWithContactId:self.contact.contactId];
    [self initComponent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(movieFinishedCallback:)
                                                name:MPMoviePlayerPlaybackDidFinishNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(change1:)
                                                 name:MPMoviePlayerNowPlayingMovieDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(WillEnterFullscreen:)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DidEnterFullscreen:)
                                                 name:MPMoviePlayerDidEnterFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(WillExitFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DidExitFullscreen:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:nil];
    
    if ([self.arrayFiles count] == 0) {
        [self.view makeToast:NSLocalizedString(@"no_record_file", nil)];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:nil];
}

-(void)WillEnterFullscreen:(NSNotification*)notify
{
    NSLog(@"WillEnterFullscreen");
}

-(void)DidEnterFullscreen:(NSNotification*)notify
{
    NSLog(@"DidEnterFullscreen");
}

-(void)WillExitFullscreen:(NSNotification*)notify
{
    NSLog(@"WillExitFullscreen");
}

-(void)DidExitFullscreen:(NSNotification*)notify
{
    NSLog(@"DidExitFullscreen");
}

#define TOP_INFO_BAR_HEIGHT 70
#define TOP_HEAD_MARGIN 10
#define PLAYBACK_LIST_ITEM_HEIGHT 40

-(void)initComponent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    [self.view setBackgroundColor:XBgColor];
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
//    本地录像
    [topBar setTitle:NSLocalizedString(@"playback_cellphone",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    UIView *topInfoBarView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, TOP_INFO_BAR_HEIGHT)];
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
    [self.view addSubview:topInfoBarView];
    [topInfoBarView release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+TOP_INFO_BAR_HEIGHT, width, height-(NAVIGATION_BAR_HEIGHT+TOP_INFO_BAR_HEIGHT)) style:UITableViewStylePlain];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView setBackgroundColor:XBGAlpha];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

-(void)onBackPress{
//    [self.navigationController popViewControllerAnimated:YES];
      [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrayFiles count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return PLAYBACK_LIST_ITEM_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"PlaybackCell";
    FileListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[FileListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
        cell.delegate = self;
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
    
    NSString* fileName = [self.arrayFiles objectAtIndex:indexPath.row];
    NSString* dataText = [Utils getRecordInfoFromName:fileName];
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/record/%@/%@/%@",rootPath,loginResult.contactId, self.contact.contactId, fileName];
    long long filesize = [self fileSizeAtPath:filePath];
    
    if (filesize/1024/1024 > 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@   %lldMB", dataText, filesize/1024/1024];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@   %lldKB", dataText, filesize/1024];
    }
    
    cell.row = (int)indexPath.row;
    
    return cell;
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _currentPlayingIndex = (int)indexPath.row;
    NSString* fileName = [self.arrayFiles objectAtIndex:_currentPlayingIndex];
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/record/%@/%@/%@",rootPath,loginResult.contactId, self.contact.contactId, fileName];
    NSLog(@"selected %@", filePath);

    GWMovieViewController *movie = [[GWMovieViewController alloc]initWithContentURL:[NSURL fileURLWithPath:filePath]];
    movie.mp4Delegate = self;
    [movie.moviePlayer setControlStyle:MPMovieControlStyleNone];
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
    [movie.view setTransform:transform];
    [movie.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) ];

    [self.view addSubview:movie.view];
    [movie.moviePlayer play];
    _movieCtrl = movie;
//    [movie release];
}

-(void)change1:(NSNotification*)notify
{
    NSLog(@"change1");
}

-(void)movieFinishedCallback:(NSNotification*)notify
{
    if (_movieCtrl) {
        [_movieCtrl.view removeFromSuperview];
        [_movieCtrl release];
        _movieCtrl = nil;
    }
}

- (void)moviePlayerPlaybackStateChanged:(NSNotification *)notification {
    MPMoviePlayerController *moviePlayer = notification.object;
    MPMoviePlaybackState playbackState = moviePlayer.playbackState;
    switch (playbackState) {
        case MPMoviePlaybackStateStopped:
        {
            NSLog(@"MPMoviePlaybackStateStopped");
            if (_movieCtrl)
            {
                [_movieCtrl.view removeFromSuperview];
                [_movieCtrl release];
                _movieCtrl = nil;
            }
            break;
        }
            
        case MPMoviePlaybackStatePlaying:
        {
            NSLog(@"MPMoviePlaybackStatePlaying");
            break;
        }
            
        case MPMoviePlaybackStatePaused:
        {
            NSLog(@"MPMoviePlaybackStatePaused");
            break;
        }
            
        case MPMoviePlaybackStateInterrupted:
        {
            NSLog(@"MPMoviePlaybackStateInterrupted");
            break;
        }
            
        case MPMoviePlaybackStateSeekingForward:
        {
            NSLog(@"MPMoviePlaybackStateSeekingForward");
            break;
        }
            
        case MPMoviePlaybackStateSeekingBackward:
        {
            NSLog(@"MPMoviePlaybackStateSeekingBackward");
            break;
        }
            
        default:
        {
            NSLog(@"unkunow flag");
        }
            break;
    }
}

-(void)onSwitchFileNext:(BOOL)isNext
{
    if (isNext)
    {
        _currentPlayingIndex ++;
        if (_currentPlayingIndex >= [self.arrayFiles count])
        {
            [_movieCtrl.view makeToast:NSLocalizedString(@"no_previous_files", nil)];
            _currentPlayingIndex--;
            return;
        }
    }
    else
    {
        _currentPlayingIndex --;
        if (_currentPlayingIndex < 0)
        {
            [_movieCtrl.view makeToast:NSLocalizedString(@"no_next_files", nil)];
            _currentPlayingIndex = 0;
            return;
        }

    }
    NSString* fileName = [self.arrayFiles objectAtIndex:_currentPlayingIndex];
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/record/%@/%@/%@",rootPath,loginResult.contactId, self.contact.contactId, fileName];
    NSLog(@"selected %@", filePath);
    
    [_movieCtrl.moviePlayer pause];
    [_movieCtrl.moviePlayer setContentURL:[NSURL fileURLWithPath:filePath]];
    [_movieCtrl.moviePlayer play];
}

- (void) handlePan: (UIPanGestureRecognizer *)recognizer
{
    //do nothing. write this for shield recognizer in the control's view
}

-(void)onLongPress:(int)row
{
    _selectedRow = row;
    NSString* fileName = [self.arrayFiles objectAtIndex:_selectedRow];
    NSString* dataText = [Utils getRecordInfoFromName:fileName];
    NSString* text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"file_info", nil), dataText];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"save_to_photoalbum", nil),nil];
    
    [alert addButtonWithTitle:NSLocalizedString(@"delete", nil)];
    
    
    [alert show];
    [alert release];
    
    [self.tableView reloadData];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if (error != NULL) {
        //检查访问相册的权限
        BOOL ret = [Utils IsGetPhotoAlbumAuthorization];
        if (!ret) {
            [self.view makeToast:NSLocalizedString(@"save_photoalbum_tip", nil)];
        }
    }
    else
    {
        [self.view makeToast:NSLocalizedString(@"save_ok_photoalbum", nil)];
        NSLog(@"save ok");
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if  (buttonIndex == 0)
    {
        return;
    }
    else
    {
        NSString* fileName = [self.arrayFiles objectAtIndex:_selectedRow];
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
         NSLog(@"%@",rootPath);
        NSString *filePath = [NSString stringWithFormat:@"%@/record/%@/%@/%@",rootPath,loginResult.contactId, self.contact.contactId, fileName];
        NSLog(@"%@",filePath);
        
        if (buttonIndex == 1) {
            //保存到相册
            UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }
        else if (buttonIndex == 2)
        {
            //删除文件
            
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            if ([fileMgr removeItemAtPath:filePath error:&err] == YES)
            {
                //更新内存、ui
                [self.arrayFiles removeObjectAtIndex:_selectedRow];
                [self.tableView reloadData];
                
                //提示
                [self.view makeToast:NSLocalizedString(@"modify_success", nil)];
            }
            else
            {
                [self.view makeToast:NSLocalizedString(@"modify_failure", nil)];
            }
        }
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

@end
