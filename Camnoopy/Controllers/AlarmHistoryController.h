
//报警纪录
#import <UIKit/UIKit.h>
@class  MBProgressHUD;

@interface AlarmHistoryController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *alarmHistory;

@property (strong, nonatomic) MBProgressHUD *progressAlert;

@end
