

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "MainContainer.h"
#import <UserNotifications/UserNotifications.h>
#import "sqlite3.h"
#define NET_WORK_CHANGE @"NET_WORK_CHANGE"
#define ALERT_TAG_ALARMING 0
#define ALERT_TAG_MONITOR 1
@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainContainer *mainController;
@property (nonatomic) NetworkStatus networkStatus;
+(CGRect)getScreenSize:(BOOL)isNavigation isHorizontal:(BOOL)isHorizontal;
+(AppDelegate*)sharedDefault;
@property (nonatomic ,strong)NSString *name;
@property (strong, nonatomic) NSString *token;
@property (nonatomic) int iCurrentShowAlarmType;
@property (copy, nonatomic) NSString* currentShowAlarmId;
@property (nonatomic) BOOL isShowAlarmTip;

@property (strong, nonatomic) NSString *alarmContactId;
@property (nonatomic) long lastShowAlarmTimeInterval;
@property (nonatomic) NSInteger presetNumber;
+(NSString*)getAppVersion;
@property (nonatomic) BOOL isGoBack;
@property (nonatomic) sqlite3 *db;
@property (nonatomic) BOOL isDoorBellAlarm;//在监控界面使用,区分门铃推送，其他推送

@property (nonatomic) int iAlarmLogCount;

-(void)reRegisterForRemoteNotifications;

@end
