
/*个人信息界面*/
#import <UIKit/UIKit.h>

#define ALERT_TAG_UNBIND_EMAIL 0
#define ALERT_TAG_UNBIND_EMAIL_AFTER_INPUT_PASSWORD 1

#define ALERT_TAG_UNBIND_PHONE 2
#define ALERT_TAG_UNBIND_PHONE_AFTER_INPUT_PASSWORD 3
#import "BindPhoneController.h"
@class MBProgressHUD;
@interface AccountController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,BindPhonedelegate,UITextFieldDelegate>
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) UITableView *tableView;
@property (strong,nonatomic) UIView * alphaView;
@property (strong,nonatomic) UIView * ModifyPasswordView;
@property (strong,nonatomic) UIView * UnBindView;
@property (strong,nonatomic) UIView * BindView;
@property (strong,nonatomic) UITextField * OldPWtextView;
@property (strong,nonatomic) UITextField * NewPWtextView;
@property (strong,nonatomic) UITextField * ConfirmPWtextView;
@property (strong,nonatomic) UITextField * BindEmailtextView;
@property (strong,nonatomic) BindPhoneController * bindphonecontroller;
@property (assign) BOOL isModifyPW;
@property (assign) BOOL isUnBindEmail;
@property (assign) BOOL isBindEmail;
-(void)sheetviewhiden;
@end
