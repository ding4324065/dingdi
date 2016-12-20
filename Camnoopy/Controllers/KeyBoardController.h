

#import <UIKit/UIKit.h>
#define ALERT_TAG_MONITOR 0
@interface KeyBoardController : UIViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UILabel *inputLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (retain, nonatomic) NSArray *contacts;
@end
