//
//  MainAddContactControllerEx.m
//  Camnoopy
//
//  Created by wutong on 15-1-17.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "MainAddContactControllerEx.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "TopBar.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Toast+UIView.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "FListManager.h"
#import "AddByManualController.h"
#import "QRCodeController.h"
#import "QRCodeSetWIFIController.h"


@interface MainAddContactControllerEx ()
{
    int _currentShowIndex;
    UIView* _mainView;
    UIButton *_btnScan;//雷达添加按钮
    UIButton *_btnManual;//手动添加按钮
    UIButton *_btnQRCode;//二維碼配置Wi-Fi按鈕

    UILabel *_lable;
}
@end


@implementation MainAddContactControllerEx

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
    
}



-(void)initComponent{
//    [self.view setBackgroundColor:XBgColor];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"add_device",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
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
    
#pragma mark -  三个按钮
    //智能Wi-Fi按鈕
    _btnScan = [[UIButton alloc]initWithFrame:CGRectMake(width/5, height/4 , width/2 + 30, 90)];
    _btnScan.backgroundColor = XWhite;
    [_btnScan.layer setCornerRadius:15.0]; //设置矩形四个圆角半径
    [_btnScan setTitle:NSLocalizedString(@"add_Wi-Fi", nil) forState:UIControlStateNormal];
    [_btnScan setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnScan setImage:[UIImage imageNamed:@"ConfigurationWiFi.png"] forState:UIControlStateNormal];
    [_btnScan addTarget:self action:@selector(btnClickedWiFi) forControlEvents:UIControlEventTouchUpInside];
    [_btnScan setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:_btnScan];
    [_btnScan release];
    
    
    //手动添加按钮
    _btnManual = [[UIButton alloc]initWithFrame:CGRectMake(width/5, height/2 , width/2 + 30, 90)];
    _btnManual.backgroundColor = XWhite;
    [_btnManual.layer setCornerRadius:15.0]; //设置矩形四个圆角半径
    [_btnManual setTitle:NSLocalizedString(@"add_manual", nil) forState:UIControlStateNormal];
    [_btnManual setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnManual setImage:[UIImage imageNamed:@"AddByManual.png"] forState:UIControlStateNormal];
    [_btnManual addTarget:self action:@selector(btnClickedManual) forControlEvents:UIControlEventTouchUpInside];
    [_btnManual setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:_btnManual];
    [_btnManual release];
    
    //二維碼配置Wi-Fi按鈕
    _btnQRCode = [UIButton buttonWithType:UIButtonTypeSystem];
//    _btnQRCode.frame = CGRectMake(width - 233, height - 30, 230, 30);
    _btnQRCode.frame = CGRectMake(0, height - 30, width, 30);
    [_btnQRCode setTitle:NSLocalizedString(@"qrcode", nil) forState:UIControlStateNormal];
    _btnQRCode.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//对齐方式
    _btnQRCode.backgroundColor = [UIColor lightGrayColor];
    [_btnQRCode addTarget:self action:@selector(btnClickedQRCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnQRCode];
}


//返回按钮
-(void)onBackPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnClickedWiFi
{

    QRCodeController *QRController = [[QRCodeController alloc]init];
    [self.navigationController pushViewController:QRController animated:YES];
    [QRController release];
}



-(void)btnClickedManual
{
    
    AddByManualController *addByManualController = [[AddByManualController alloc]init];
    [self.navigationController pushViewController:addByManualController animated:YES];
    [addByManualController release];
    
}

-(void)btnClickedQRCode
{
    QRCodeSetWIFIController *qecodeController = [[QRCodeSetWIFIController alloc] init];
    [self.navigationController pushViewController:qecodeController animated:YES];
    [qecodeController release];
}


@end
