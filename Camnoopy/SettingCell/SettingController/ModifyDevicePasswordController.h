

#import <UIKit/UIKit.h>
#import "Utils.h"
@class Contact;
@class MBProgressHUD;
@interface ModifyDevicePasswordController : UIViewController <UITextFieldDelegate>
@property(strong, nonatomic) Contact *contact;
@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UITextField *field2;
@property (nonatomic, strong) UITextField *field3;
@property (strong, nonatomic) NSString *lastSetOriginPassowrd;
@property (strong, nonatomic) NSString *lastSetNewPassowrd;
@property (strong, nonatomic) MBProgressHUD *progressAlert;


@property(strong, nonatomic) UIView *pwdStrengthView;//password strength2
@property(strong, nonatomic) UILabel *redLabelPrompt;
@property(strong, nonatomic) UIView *contentView;
@property(assign) BOOL isIntoHereOfClickWeakPwd;
@end
