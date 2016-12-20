
#pragma mark - 报警账户
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@class Contact;
@class AlarmSettingController;


@interface AlarmAccountController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;
@property(strong, nonatomic) MBProgressHUD *progressAlert;

@property(assign) BOOL isFirstLoadingCompolete;
@property(assign) BOOL isLoadingBindId;

@property(strong, nonatomic) NSMutableArray *bindIds;
@property(strong, nonatomic) NSMutableArray *lastSetBindIds;
@property(assign) NSInteger selectedUnbindAccountIndex;
@property(assign) NSInteger maxBindIdCount;

@property (strong, nonatomic) AlarmSettingController *alarmSettingController;



@end
