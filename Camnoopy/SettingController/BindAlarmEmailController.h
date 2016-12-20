//
//  BindAlarmEmailController.h
//  Gviews
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@class  MBProgressHUD;
@class AlarmSettingController;
@interface BindAlarmEmailController : UIViewController

@property (strong, nonatomic) AlarmSettingController *alarmSettingController;
@property (strong, nonatomic) NSString *lastSetBindEmail;
@property (strong, nonatomic) Contact *contact;
@property (nonatomic, strong) UITextField *field1;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
