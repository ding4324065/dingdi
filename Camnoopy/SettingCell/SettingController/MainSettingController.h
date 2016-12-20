
#pragma mark - 设置主界面
#import <UIKit/UIKit.h>
@class Contact;
@class  MBProgressHUD;
@interface MainSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong, nonatomic) Contact *contact;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UIView *progressMaskView;
@property (strong, nonatomic) UILabel *progressLabel;

@property(strong, nonatomic) UITableView *tableView;
//YES表示在当前界面，用户向设备发送了远程消息请求
@property (nonatomic) BOOL isSendRomoteMessageInCurrentInterface;//设备检查更新
@property (strong,nonatomic)NSTimer * timer;

@property (strong, nonatomic) NSString *curVersion;
@property (strong, nonatomic) NSString *upgVersion;


//设备重启 控制参数记录
@property(nonatomic,assign) int lastValue;
@property(nonatomic,assign) int lastTime;
@end
