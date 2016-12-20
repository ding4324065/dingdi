

#import <UIKit/UIKit.h>
@class Contact;
@class MBProgressHUD;
@interface ModifyVisitorPasswordController : UIViewController<UITextFieldDelegate>
@property(strong, nonatomic) Contact *contact;
@property (nonatomic, strong) UITextField *field1;

@property (strong, nonatomic) NSString *lastSetNewPassowrd;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
