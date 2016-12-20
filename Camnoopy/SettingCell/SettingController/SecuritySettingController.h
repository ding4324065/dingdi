

#import <UIKit/UIKit.h>
#import "P2PSecurityCell.h"
#import "MBProgressHUD.h"
@class Contact;
@interface SecuritySettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,SavePressDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;

@property(strong, nonatomic) P2PSecurityCell *textCell1;
@property(strong, nonatomic) P2PSecurityCell *textCell2;
@property(strong, nonatomic) P2PSecurityCell *textCell3;
@property(strong, nonatomic) P2PSecurityCell *textCell4;
@property (strong, nonatomic) NSString *lastSetOriginPassowrd;
@property (strong, nonatomic) NSString *lastSetNewPassowrd;

@property(assign) BOOL isFirstLoadingCompolete;

@property (strong, nonatomic) MBProgressHUD *progressAlert;

@end
