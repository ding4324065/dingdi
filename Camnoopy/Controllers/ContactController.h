
//我的摄像机
#import <UIKit/UIKit.h>
#import "ContactCell.h"
@class MBProgressHUD;

#define ALERT_TAG_DELETE 0

#define kOperatorViewTag 15236
#define kBarViewTag 32536
#define kButtonsViewTag 32533

#define kOperatorBtnTag_WeakPwd 23587
#define kOperatorBtnTag_Chat 23581
#define kOperatorBtnTag_Message 23582
#define kOperatorBtnTag_Modify 23583
#define kOperatorBtnTag_Monitor 23584
#define kOperatorBtnTag_Playback 23585
#define kOperatorBtnTag_Control 23586

@class  Contact;
@interface ContactController : UIViewController<UITableViewDataSource,UITableViewDelegate,OnClickDelegate ,UISearchResultsUpdating, UISearchControllerDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *contacts;
@property (retain, nonatomic) NSMutableArray *localDevices;
@property (nonatomic) BOOL isInitPull;
@property (strong, nonatomic) NSIndexPath *curDelIndexPath;

@property (strong, nonatomic) UIView *netStatusBar;
@property (strong, nonatomic) UIButton *localDevicesView;
@property (strong, nonatomic) UILabel *localDevicesLabel;
@property (nonatomic) CGFloat tableViewOffset;
@property (nonatomic,strong) UIView *emptyView;
@property(strong, nonatomic) Contact *contact;
@property (strong, nonatomic) MBProgressHUD *checkingAlert;
@property (strong, nonatomic) Contact *selectedContact;

@property (nonatomic, strong) UISearchController *search;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (strong, nonatomic) MBProgressHUD *progressAlert;//设备检查更新
@property (assign) BOOL isShowProgressAlert;
@property (strong, nonatomic) UIView *progressMaskView;//设备检查更新
@property (strong, nonatomic) UILabel *progressLabel;//设备检查更新
@property (strong, nonatomic) UIView *progressView;//设备检查更新
@property (strong,nonatomic)NSTimer * timer;
@end
