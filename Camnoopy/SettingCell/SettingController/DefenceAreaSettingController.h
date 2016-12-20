/*防区设置页面-->暂时没有使用到*/

#import <UIKit/UIKit.h>
#import "DefenceCell.h"
#define ALERT_TAG_CLEAR 0
#define ALERT_TAG_LEARN 1
@class Contact;
@class  MBProgressHUD;

@interface DefenceAreaSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIDefenceCellDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;


@property(assign) NSInteger selectedIndex;

@property(nonatomic, strong) NSMutableArray *dataArray;
@property(strong,nonatomic) NSMutableArray *statusData;
@property(strong,nonatomic) NSMutableArray *switchStatusData;

@property(assign) BOOL isLoadDefenceArea;
@property(assign) BOOL isLoadDefenceSwitch;
@property(assign) BOOL isNotSurportDefenceSwitch;

@property(nonatomic) BOOL isNotRightPWD;
@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property(assign) NSInteger lastSetGroup;
@property(assign) NSInteger lastSetItem;
@property(assign) NSInteger lastSetType;

@property(assign) NSInteger lastSetSwitchGroup;
@property(assign) NSInteger lastSetSwitchItem;
@property(assign) NSInteger lastSetSwitchType;

@property(assign) BOOL isSetting;
@end
