//
//  PlaybackTypeController.m
//  Camnoopy
//
//  Created by Lio on 16/3/2.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "PlaybackTypeController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "TopBar.h"
#import "P2PRemotePlayListController.h"
#import "MainAddContactControllerEx.h"
#import "P2PLocalPlayListController.h"

@interface PlaybackTypeController ()
{
    int _currentShowIndex;
    UIView* _mainView;
    UIButton *_btnTFCard;
    UIButton *_btnCellphone;
    
    UILabel *_lable;
}
@end

@implementation PlaybackTypeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initComponent];
}

-(void)initComponent{
    //    [self.view setBackgroundColor:XBgColor];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width; 
    CGFloat height = rect.size.height;
//    导航栏
//    录像回放
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"playback",nil)];
//    返回按钮
    [topBar setLeftButtonHidden:NO];
    [topBar setLeftButtonIcon:[UIImage imageNamed:@"open_menu.png"]];
    [topBar.leftButton addTarget:self action:@selector(onMenuPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    //background view －－ 背景
    UIImageView* imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    UIImage* img = [UIImage imageNamed:@"about_bk"];
    [imageView setImage:img];
    [self.view addSubview:imageView];
    [imageView release];
    
    _mainView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    [_mainView setHidden:YES];
    [self.view addSubview:_mainView];
    [_mainView release];
    
#pragma mark -  按钮
    //远程录像按鈕
    _btnTFCard = [[UIButton alloc]initWithFrame:CGRectMake(width/6 - 10, height/4, width/2 + width/6 + 20, 90)];
    _btnTFCard.backgroundColor = XWhite;
    [_btnTFCard.layer setCornerRadius:15.0]; //设置矩形四个圆角半径
    [_btnTFCard setTitle:NSLocalizedString(@"playback_TFCard", nil) forState:UIControlStateNormal];
    [_btnTFCard setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnTFCard setImage:[UIImage imageNamed:@"ic_playback_remote.png"] forState:UIControlStateNormal];
    [_btnTFCard addTarget:self action:@selector(btnClickedTFCard) forControlEvents:UIControlEventTouchUpInside];
    [_btnTFCard setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:_btnTFCard];
    [_btnTFCard release];
    
    
    //本地录像按钮
    _btnCellphone = [[UIButton alloc]initWithFrame:CGRectMake(width/6 - 10, height/2, width/2 + width/6 + 20, 90)];
    _btnCellphone.backgroundColor = XWhite;
    [_btnCellphone.layer setCornerRadius:15.0]; //设置矩形四个圆角半径
    [_btnCellphone setTitle:NSLocalizedString(@"playback_cellphone", nil) forState:UIControlStateNormal];
    [_btnCellphone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnCellphone setImage:[UIImage imageNamed:@"ic_playback_cellphone.png"] forState:UIControlStateNormal];
    [_btnCellphone addTarget:self action:@selector(btnClickedCellphone) forControlEvents:UIControlEventTouchUpInside];
    [_btnCellphone setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:_btnCellphone];
    [_btnCellphone release];
    
}

//导航返回事件
-(void)onMenuPress
{
//    接收返回页面的消息
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_LEFTMENU_CMD object:self];
    });
}
//远程录像按钮
-(void)btnClickedTFCard
{
    P2PRemotePlayListController *remotePlayController = [[P2PRemotePlayListController alloc]init];
    [self presentViewController:remotePlayController animated:YES completion:nil];
    [remotePlayController release];
    
}

//本地录像按钮
-(void)btnClickedCellphone
{
    P2PLocalPlayListController *localPlayController = [[P2PLocalPlayListController alloc]init];
    [self presentViewController:localPlayController animated:YES completion:nil];
    [localPlayController release];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
