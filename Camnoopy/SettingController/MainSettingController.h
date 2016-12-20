//
//  MainSettingController.h
//  Gviews
//
//  Created by guojunyi on 14-5-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@class  MBProgressHUD;
#define ALERT_TAG_UPDATE 0
@interface MainSettingController : UIViewController
@property(strong, nonatomic) Contact *contact;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UIView *progressMaskView;
@property (strong, nonatomic) UILabel *progressLabel;


@end
