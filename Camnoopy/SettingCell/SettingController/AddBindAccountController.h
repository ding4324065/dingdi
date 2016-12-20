
//test svn
//绑定帐号
#import <UIKit/UIKit.h>
@class Contact;
@class  MBProgressHUD;
@class  AlarmSettingController;
@interface AddBindAccountController : UIViewController

@property(strong, nonatomic) NSMutableArray *lastSetBindIds;
@property (strong, nonatomic) Contact *contact;
@property (nonatomic, strong) UITextField *field1;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) AlarmSettingController *alarmSettingController;
@end
