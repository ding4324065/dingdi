//
//  ScanViewController.h
//  Camnoopy
//
//  Created by wutong on 15-1-8.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
//界面暂时没有
#import <UIKit/UIKit.h>
#import "UDPManager.h"
#import "MBProgressHUD.h"
#import "scanAlertviewAdd.h"
#import "scanAlertviewTip.h"

@protocol QuitDelegate <NSObject>
-(void)setQuit:(BOOL)bQuit;
@end

@interface ScanViewController : UIViewController<UDPScanDelegate, scanAlertAddDelegate, scanAlertTipDelegate>
@property (strong, nonatomic) NSString* wifiName;
@property (strong, nonatomic) NSString* wifiPwd;

@property (assign) id<QuitDelegate> delegateQuit;

@end
