/*给设备配置Wi-Fi成功后进入*/
#import <UIKit/UIKit.h>
@class Contact;
@class MBProgressHUD;
@interface CreateInitPasswordController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UITextField *contactNameField;
@property (strong, nonatomic) UITextField *contactPasswordField;
@property (strong, nonatomic) UITextField *confirmPasswordField;

@property (retain, nonatomic) NSString *contactId;
@property (retain, nonatomic) NSString *storeID;//缺少的

@property (strong, nonatomic) NSString *lastSetPassword;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) NSString *address;
@property (nonatomic) BOOL isPopRoot;

@property (strong,nonatomic) NSString *contactIp;//added a code here

@end
