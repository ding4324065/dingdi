

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "YProgressView.h"
#import "MBProgressHUD.h"
#import "Utils.h"
@protocol OnClickDelegate
-(void)onClick:(NSInteger)position contact:(Contact*)contact tag:(NSInteger)tag;

@end
@class Contact;
@interface ContactCell : UITableViewCell

@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) Contact *contact;

@property (strong, nonatomic) NSString *curVersion;
@property (strong, nonatomic) NSString *upgVersion;
@property (nonatomic) BOOL isCancelUpdateDeviceOk;
@property (strong, nonatomic) UIButton *headView;       //最后一帧照片/默认图片
@property (strong, nonatomic) UIImageView *typeView;
@property (strong, nonatomic) UIImageView *stateView;   //播放图标/闪电图标
@property (strong, nonatomic) UILabel *nameLabel;       //text1215071
@property (strong, nonatomic) UILabel *stateLabel;
@property (strong, nonatomic) UIView *topView;          //顶部黑色工具条
@property (strong, nonatomic) UIView *topMaskView;      //顶部渐变黑条

@property (strong, nonatomic) UIButton *updateDeviceBtn;
@property (strong, nonatomic) UIButton *initDeviceButton;
@property (strong, nonatomic) UIButton *weakPwdButton;
@property (strong, nonatomic) UIButton *defenceStateView; //布防
@property (strong, nonatomic) UIButton *settingView;   //设置
@property (strong, nonatomic) UIButton *modifyView;   //修改
@property (strong, nonatomic) YProgressView *defenceProgressView;   //布防-正在查询

@property (strong, nonatomic) UIImageView *messageCountView;//通知浏览次数

@property (strong, nonatomic) id<OnClickDelegate> delegate;
@property (nonatomic) NSInteger position;

@end
