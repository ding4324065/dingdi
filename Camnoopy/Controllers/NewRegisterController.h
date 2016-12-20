//
//  NewRegisterController.h
//  Camnoopy
//
//  Created by Jie on 14/12/6.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//
/*新用户注册界面*/
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ChooseCountryController.h"

@interface NewRegisterController : UIViewController<UITextFieldDelegate>

@property (assign) NSInteger registerType;

@property (strong,nonatomic) UILabel *leftLabel;
@property (strong,nonatomic) UILabel *rightLabel;
@property (nonatomic, strong) UITextField *fieldPhoneNumber;
@property (strong,nonatomic) NSString *countryCode;
@property (strong,nonatomic) NSString *countryName;

@property (nonatomic, strong) UITextField *fieldEmail1;
@property (nonatomic, strong) UITextField *fieldEmail2;
@property (nonatomic, strong) UITextField *fieldEmail3;

@property (strong, nonatomic) MBProgressHUD *progressAlert;

@end
