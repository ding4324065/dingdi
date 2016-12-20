
//选择国家
#import <UIKit/UIKit.h>
#import "SortBar.h"
@class BindPhoneController;
@class LoginController;
@class NewRegisterController;

@interface ChooseCountryController : UIViewController<UITableViewDataSource,UITableViewDelegate,SortBarDelegate>
@property (strong,nonatomic) BindPhoneController *bindPhoneController;
@property (strong,nonatomic) LoginController *loginController;
@property (strong,nonatomic) NewRegisterController *registerController;

@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *countrys_zh;
@property (strong,nonatomic) NSArray *countrys_en;
@property (strong,nonatomic) NSArray *countrys;
@property (strong,nonatomic) NSArray *datas;

@property (strong,nonatomic) UILabel *promptView;
@end
