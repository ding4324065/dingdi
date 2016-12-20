

#import <UIKit/UIKit.h>
#import "P2PSecurityCell.h"
#import "DeviceWiFi.h"
#import "WifiListViewController.h"
#define ALERT_TAG_NET_TYPE1 0
#define ALERT_TAG_NET_TYPE2 1
#define ALERT_TAG_CHANGE_WIFI 2
#define ALERT_TAG_INPUT_WIFI_PASSWORD 3
@class Contact;
@class RadioButton;
@class  MBProgressHUD;
@interface NetSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,SavePressDelegate,devicewifidelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;
@property (strong, nonatomic) UIView *selectView;
@property (strong, nonatomic) UIView *alphaView;

@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;
@property (strong, nonatomic) NSString *selectType;
@property (assign) NSInteger selectedIndex;

@property (assign)BOOL isAutoGetIp;
@property (strong,nonatomic) DeviceWiFi * nowwifi;

@property(assign) NSInteger netType;
@property(assign) NSInteger lastNetType;

@property(assign) BOOL isLoadingNetType;
@property(assign) BOOL isLoadingWifiList;

@property (strong,nonatomic) RadioButton *radioNetType1;
@property (strong,nonatomic) RadioButton *radioNetType2;
@property (strong,nonatomic)  UIButton * netbtn;
@property (strong,nonatomic)  UIButton * wifibtn;
@property (strong,nonatomic)  UIView * bline;

@property (assign) NSInteger currentWifiIndex;
@property (assign) NSInteger wifiCount;
@property (strong,nonatomic) NSMutableArray *names;
@property (strong,nonatomic) NSMutableArray *types;
@property (strong,nonatomic) NSMutableArray *strengths;

@property (assign) NSInteger selectWifiIndex;
@property (retain,nonatomic) NSString *lastSetWifiPassword;
@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property (strong,nonatomic) UITextField * iptextfiled;
@property (strong,nonatomic) UITextField * getwaytextfiled;
@property (strong,nonatomic) UITextField * submasktextfiled;
@property (strong,nonatomic) UITextField * dnstextfiled;
@property (assign,nonatomic) BOOL ishavewifilist;
@property (strong,nonatomic) NSMutableArray * wifilist;
@property (strong,nonatomic)NSMutableArray * lastwifilist;
@property (copy,nonatomic) NSString * ip;
@property (copy,nonatomic) NSString * getway;
@property (copy,nonatomic) NSString * subnetmask;
@property (copy,nonatomic) NSString * dns;

@property (assign,nonatomic) unsigned int lastsetIp;
@property (assign,nonatomic) unsigned int lastsetSub;
@property (assign,nonatomic) unsigned int lastsetGet;
@property (assign,nonatomic) unsigned int lastsetDns;
@end
