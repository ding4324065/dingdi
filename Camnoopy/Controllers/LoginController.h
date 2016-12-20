

#import <UIKit/UIKit.h>
@class MBProgressHUD;

@interface LoginController : UIViewController

@property (strong, nonatomic) UIView *mainView1;
@property (strong, nonatomic) UITextField *usernameField1;
@property (strong, nonatomic) UITextField *passwrodField1;

@property (strong, nonatomic) MBProgressHUD *progressAlert;



@property (nonatomic) BOOL isSessionIdError;

@property (nonatomic) BOOL isP2PVerifyCodeError;//check P2PVerfyCode

@property (strong,nonatomic) NSString *lastRegisterId;
//YES表示记住用户的登录密码；NO表示不记住登录密码
@property (nonatomic) BOOL isRememberUserPWD;//记住用户的登录密码
//YES表示记住用户的登录密码；NO表示不记住登录密码
@property (nonatomic) BOOL isRememberPhonePWD;//记住用户的登录密码
@property (strong, nonatomic) UIView *rememberPwdPrompt;//记住用户的登录密码
@end
