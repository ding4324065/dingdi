
//修改登录密码
#import <UIKit/UIKit.h>
@class MBProgressHUD;

@interface ModifyLoginPasswordController : UIViewController
@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UITextField *field2;
@property (nonatomic, strong) UITextField *field3;


@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
