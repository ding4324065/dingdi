
//红外遥控
#import <UIKit/UIKit.h>
#import "YButton.h"
@interface InfraredRemoteController : UIViewController<YButtonDelegate>
@property (nonatomic,strong) UITextField *wifiPwdField;
@property (nonatomic,strong) UITextField *devicePwdField;
@property (nonatomic,strong) UITextField *ssidField;
@property (nonatomic,strong) UIButton *setWifiView;

@property (nonatomic,strong) UIView *inputView;
@end
