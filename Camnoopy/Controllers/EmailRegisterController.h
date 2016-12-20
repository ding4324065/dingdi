

#import <UIKit/UIKit.h>
#define ALERT_TAG_REGISTER_SUCCESS 0
@class MBProgressHUD;
@interface EmailRegisterController : UIViewController<UIAlertViewDelegate>
@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UITextField *field2;
@property (nonatomic, strong) UITextField *field3;

@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
