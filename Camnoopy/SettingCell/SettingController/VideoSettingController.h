
/*媒体设置界面*/
#import <UIKit/UIKit.h>
#import "P2PSwitchCell.h"
@class Contact;
@class RadioButton;
@class  MBProgressHUD;
@interface VideoSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,SwitchCellDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;
@property (strong, nonatomic) UIView *selectView;
@property (strong, nonatomic) UIView *alphaView;
@property(strong, nonatomic) RadioButton *radio1;
@property(strong, nonatomic) RadioButton *radio2;

@property(assign) BOOL isInitNpcSettings;
@property(assign) NSInteger videoType;
@property(assign) NSInteger lastSetVideoType;
@property(assign) NSInteger lastSetVideoVolume;
@property(assign) NSInteger videoVolume;

@property(assign) BOOL isVideoFormatLoading;
@property(assign) BOOL isVideoVolumeLoading;

@property (strong,nonatomic) UISwitch *imageInversionSwitch;
@property (nonatomic) BOOL isLoadingImageInversion;
@property(assign) NSInteger imageInversionState;
@property (assign) NSInteger lastImageInversionState;
//支持图像反转
@property (nonatomic) BOOL isSupportImageInversion;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
