//
//  FTPController.h
//  Camnoopy
//
//  Created by 卡努比 on 16/5/24.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@class MBProgressHUD;
@class AlarmSettingController;
@interface FTPController : UIViewController <UITextViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) MBProgressHUD *progressAlert;

@property (nonatomic, assign) int serverPort;//服务器端口
@property (nonatomic, strong) NSString *serverAddress;//服务器地址
@property (nonatomic, strong) NSString *userName;//名字
@property (nonatomic, strong) NSString *passWord;//密码

@property (strong, nonatomic) AlarmSettingController *alarmSettingController;
@property (nonatomic, strong) UITextField *serverAddressTextField;//服务器地址
@property (nonatomic, strong) UITextField *ServerPortTextField;   //服务器端口
@property (nonatomic, strong) UITextField *userNameTextField;     //名字
@property (nonatomic, strong) UITextField *passWordTextField;     //密码
@property (nonatomic, strong) UIView *manualView;
@property (nonatomic, strong) UILabel *FTPLable ;
@property (nonatomic, strong) UISwitch *FTPSwitch;
@property (nonatomic, assign) BOOL usrflag;

@end
