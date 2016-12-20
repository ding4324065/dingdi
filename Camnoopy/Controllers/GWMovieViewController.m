//
//  GWMovieViewController.m
//  2cu
//
//  Created by wutong on 15-6-24.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "GWMovieViewController.h"
#import "AppDelegate.h"

@interface GWMovieViewController ()
{
    BOOL _isPause;
    BOOL _isReject;
    BOOL _isDraging;
    UIView* _viewToolbar;
    UIButton* _btnPlayPause;
    UILabel* _lablePlayedTime;
    UILabel* _lableRemainingTime;
    UISlider* _sliderProgress;
}
@end

@implementation GWMovieViewController

-(void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initFullControllerbar];
    
    [NSThread detachNewThreadSelector:@selector(showPlayStatus) toTarget:self withObject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[P2PClient sharedClient]setP2pCallState:P2PCALL_STET_LOCALPLAY];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isReject = YES;
    [[P2PClient sharedClient]setP2pCallState:P2PCALL_STATE_NONE];
}


-(void)initFullControllerbar{
    CGRect rect = [AppDelegate getScreenSize:NO isHorizontal:YES];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    int interval = 20;
    int btnWidth = 50;
    int itemHeight = 50;
    
    UIView* viewToolbar= [[UIView alloc]initWithFrame:CGRectMake(0, height-itemHeight, width, itemHeight)];
    viewToolbar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:144.0/255.0];
    [self.view addSubview:viewToolbar];
    _viewToolbar = viewToolbar;
    [viewToolbar release];
    
    
    UIButton* btnDone = [[UIButton alloc]initWithFrame:CGRectMake(width-interval-btnWidth, 0, btnWidth, itemHeight)];
    [btnDone setImage:[UIImage imageNamed:@"ic_ctl_hungup.png"] forState:UIControlStateNormal];
    [btnDone setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone.titleLabel setFont:XFontBold_14];
    [btnDone addTarget:self action:@selector(stopMovie) forControlEvents:UIControlEventTouchDown];
    [viewToolbar addSubview:btnDone];
    [btnDone release];
    
    UIButton* btnNext = [[UIButton alloc]initWithFrame:CGRectMake(width-interval-btnWidth*2, 0, btnWidth, itemHeight)];
    [btnNext setImage:[UIImage imageNamed:@"ic_playing_next.png"] forState:UIControlStateNormal];
    [btnNext setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext.titleLabel setFont:XFontBold_14];
    [btnNext addTarget:self action:@selector(nextMovie) forControlEvents:UIControlEventTouchDown];
    [viewToolbar addSubview:btnNext];
    [btnNext release];
    
    UIButton* btnPlayPause = [[UIButton alloc]initWithFrame:CGRectMake(width-interval-btnWidth*3, 0, btnWidth, itemHeight)];
    [btnPlayPause setImage:[UIImage imageNamed:@"ic_playing_pause.png"] forState:UIControlStateNormal];
    [btnPlayPause setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btnPlayPause setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPlayPause.titleLabel setFont:XFontBold_14];
    [btnPlayPause addTarget:self action:@selector(playMovie) forControlEvents:UIControlEventTouchDown];
    [viewToolbar addSubview:btnPlayPause];
    _btnPlayPause = btnPlayPause;
    [btnPlayPause release];
    
    UIButton* btnPre = [[UIButton alloc]initWithFrame:CGRectMake(width-interval-btnWidth*4, 0, btnWidth, itemHeight)];
    [btnPre setImage:[UIImage imageNamed:@"ic_playing_previous.png"] forState:UIControlStateNormal];
    [btnPre setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btnPre setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPre.titleLabel setFont:XFontBold_14];
    [btnPre addTarget:self action:@selector(preMovie) forControlEvents:UIControlEventTouchDown];
    [viewToolbar addSubview:btnPre];
    [btnPre release];
    
    UILabel* lableRemainingTime = [[UILabel alloc]initWithFrame:CGRectMake(width-interval-btnWidth*5, 0, 40, itemHeight)];
    lableRemainingTime.text = @"0:00";
    [lableRemainingTime setTextColor:[UIColor whiteColor]];
    [lableRemainingTime setFont:XFontBold_14];
    lableRemainingTime.textAlignment = NSTextAlignmentLeft;
    [viewToolbar addSubview:lableRemainingTime];
    _lableRemainingTime = lableRemainingTime;
    [lableRemainingTime release];
    
    UILabel* lablePlayedTime = [[UILabel alloc]initWithFrame:CGRectMake(interval, 0, 40, itemHeight)];
    lablePlayedTime.text = @"0:00";
    [lablePlayedTime setTextColor:[UIColor whiteColor]];
    [lablePlayedTime setFont:XFontBold_14];
    lablePlayedTime.textAlignment = NSTextAlignmentRight;
    [viewToolbar addSubview:lablePlayedTime];
    _lablePlayedTime = lablePlayedTime;
    [lablePlayedTime release];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(interval+btnWidth, 0, width-interval*2-btnWidth*6, itemHeight)];
    slider.minimumValue = 0;
    slider.enabled = YES;
    [slider addTarget:self action:@selector(onSlider:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpOutside];
    [slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchCancel];
    [viewToolbar addSubview: slider];
    _sliderProgress = slider;
    [slider release];
    
    UITapGestureRecognizer *singleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    [singleTapG setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTapG];
    [singleTapG release];
}

-(void)onSlider:(id)sender{
    UISlider *slider = (UISlider*)sender;
    int pos = slider.value * self.moviePlayer.duration;
    NSString* text = [NSString stringWithFormat:@"%d:%02d", pos/60, pos%60];
    [_lablePlayedTime setText:text];
    
    _isDraging = YES;
}


-(void)onSliderEnd:(id)sender{
    UISlider *slider = (UISlider*)sender;
    self.moviePlayer.currentPlaybackTime = self.moviePlayer.duration*slider.value;
    
    _isDraging = NO;
}

-(void)stopMovie
{
    [self.moviePlayer stop];
}

-(void)nextMovie
{
    [self.mp4Delegate onSwitchFileNext:YES];
}

-(void)preMovie
{
    [self.mp4Delegate onSwitchFileNext:NO];
}

-(void)playMovie
{
    if (_isPause) {
        [self.moviePlayer play];
        [_btnPlayPause setImage:[UIImage imageNamed:@"ic_playing_pause.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.moviePlayer pause];
        [_btnPlayPause setImage:[UIImage imageNamed:@"ic_playing_start.png"] forState:UIControlStateNormal];
    }
    
    _isPause = !_isPause;
}

- (void)showPlayStatus
{
    while (!_isReject)
    {
        if (!_isDraging &&
            self.moviePlayer.duration != 0) {
            NSTimeInterval duration = self.moviePlayer.duration;
            NSTimeInterval currentPlaybackTime = self.moviePlayer.currentPlaybackTime;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //进度条
                _sliderProgress.value = (float)currentPlaybackTime/(float)duration;
                //播放时长
                [_lablePlayedTime setText:[NSString stringWithFormat:@"%d:%02d", (int)currentPlaybackTime/60, (int)currentPlaybackTime%60]];
                //总时长
                [_lableRemainingTime setText:[NSString stringWithFormat:@"%d:%02d", (int)duration/60, (int)duration%60]];
            });
        }
        usleep(1000000);
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

/*
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
 return (interface == UIInterfaceOrientationPortrait );
 }
 */
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(void)onSingleTap{
    

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_viewToolbar.hidden) {
        [UIView transitionWithView:_viewToolbar duration:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _viewToolbar.transform = CGAffineTransformMakeTranslation(0, _viewToolbar.frame.size.height);
        }
         
                        completion:^(BOOL finished) {
                            [_viewToolbar setHidden:YES];
                        }
         ];
    }else{
        [_viewToolbar setHidden:NO];
        [UIView transitionWithView:_viewToolbar duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            _viewToolbar.transform = CGAffineTransformMakeTranslation(0, 0);
                        }
         
                        completion:^(BOOL finished) {
                        }
         ];
    }
}
@end
