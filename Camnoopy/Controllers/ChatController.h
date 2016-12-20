

#import <UIKit/UIKit.h>
@class Contact;
#define ALERT_TAG_CLEAR 0
@interface ChatController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) UIButton *hideKeyBoardButton;
@property (strong, nonatomic) UITextField *messageField;
@end
