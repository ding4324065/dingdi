
/*报警设置*/
#import <UIKit/UIKit.h>
#import "P2PSwitchCell.h"
#import "P2PSecurityCell.h"
#import "P2PEmailSettingCell.h"
@class Contact;
@class RadioButton;
@class MBProgressHUD;
#define ALERT_TAG_UNBIND_ALARM_ID 0
@interface AlarmSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,SwitchCellDelegate,SavePressDelegate,EmailSettingCellDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) P2PSecurityCell *textCell;  
@property(strong, nonatomic) Contact *contact;

@property(strong, nonatomic) UISwitch *alarmSwitch;//报警开关
@property(strong, nonatomic) UISwitch *motionSwitch;//移动侦测开关
@property(strong, nonatomic) UISwitch *buzzerSwitch;//蜂鸣器开关
@property(strong, nonatomic) UISwitch *humanInfraredSwitch;//人体红外开关
@property(strong, nonatomic) UISwitch *wiredAlarmInputSwitch;//有线报警输入开关
@property(strong, nonatomic) UISwitch *wiredAlarmOutputSwitch;//有线报警输出开关
@property(strong, nonatomic) UISwitch *temperatureSetSwitch;//温度上下限开关
@property(strong, nonatomic) UISwitch *soundAlarmSwitch;//声音报警开关
@property(strong, nonatomic) UITextField *field1;
@property (strong,nonatomic) UIView * alphaView;
@property (strong,nonatomic) UIView * ModifyPasswordView;//更改密码
@property (strong,nonatomic) UITextField * OldPWtextView;//旧密码
@property (strong,nonatomic) UIView * UnBindView;
@property (strong,nonatomic) UIView * BindView;//绑定邮箱
@property (strong,nonatomic) UITextField * BindEmailtextView;


@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;
@property (strong, nonatomic) RadioButton *radio3;

@property(assign) BOOL isFirstLoadingCompolete;//首次完全加载
@property(assign) BOOL isLoadingAlarmState;//报警状态
@property(assign) BOOL isLoadingBindId;//绑定id
@property(assign) BOOL isLoadingBindEmail;//绑定邮箱
@property(assign) BOOL isLoadingMotionDetect;//移动侦测
@property(assign) BOOL isLoadingBuzzer;//蜂鸣器
@property(assign) BOOL isLoadingHumanInfrared;//人体红外开关
@property(assign) BOOL isLoadingWiredAlarmInput;//有线报警输入开关
@property(assign) BOOL isLoadingWiredAlarmOutput;//有线报警输出开关
//@property(assign) BOOL isLoadingModifyEmail;
@property(assign) BOOL isLoadingTempOrHumi;
@property(assign) BOOL isLoadingSoundAlarm;//声音报警
@property(assign) BOOL isLoadingMotionLevel;//移动侦测灵敏度

@property(assign) NSInteger alarmState; //报警状态
@property(assign) NSInteger lastAlarmState;//最后报警状态
@property(assign) NSInteger buzzerState;//蜂鸣器状态
@property(assign) NSInteger lastBuzzerState;//最后蜂鸣器状态
@property(assign) NSInteger motionState;//移动侦测状态
@property(assign) NSInteger lastMotionState;//最后移动侦测状态
@property(assign) NSInteger humanInfraredState;    //人体红外
@property(assign) NSInteger lastHumanInfraredState;
@property(assign) NSInteger wiredAlarmInputState;//有线报警输入状态
@property(assign) NSInteger lastWiredAlarmInputState;
@property(assign) NSInteger wiredAlarmOutputState;//有线报警输出状态
@property(assign) NSInteger lastWiredAlarmOutputState;
//@property(assign) NSInteger temperatureNum;//温度上下限
//@property(assign) NSInteger humidityNum;//湿度上下限
@property(assign) NSInteger setTHLimitValue;//设置温湿度上下限
@property(assign) NSInteger temperatureNumState;
@property(assign) NSInteger lastTemperatureNumState;
@property(assign) NSInteger soundAlarmState;//声音报警
@property(assign) NSInteger lastSoundAlarmState;
@property(assign) NSInteger motionLevel;//移动侦测灵敏度
@property(assign) NSInteger lastMotionLevel;

/*已处理*/
@property(nonatomic) int isSMTP;
@property(nonatomic) int isRightPwd;
@property(nonatomic) int isEmailVerified;
@property(strong, nonatomic) NSString *bindEmail;
@property(strong, nonatomic) NSString *smtpServer;
@property(nonatomic) int smtpPort;
@property(strong, nonatomic) NSString *smtpUser;
@property(strong, nonatomic) NSString *smtpPwd;
@property(nonatomic) int encryptType;
@property(nonatomic) int reserve;


@property(strong, nonatomic) NSString * lastSetBindEmail;
@property (strong, nonatomic) NSString * nowTemperature;//温度
@property (strong,nonatomic) NSString * nowHumidity;//湿度
@property (strong, nonatomic)NSString * temperatureMin;//温度下限
@property (strong, nonatomic)NSString * temperatureMax;//温度上限
@property (strong, nonatomic)NSString *humidityMin;//湿度下限
@property (strong, nonatomic)NSString *humidityMax;//湿度上限

@property(strong, nonatomic) NSMutableArray *bindIds;
@property(strong, nonatomic) NSMutableArray *lastSetBindIds;
@property(assign) NSInteger selectedUnbindAccountIndex;
@property(assign) NSInteger maxBindIdCount;

@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property (nonatomic) BOOL isSupportHI_WI_WO;
@property (nonatomic) BOOL isTemperatureMin;
@property (nonatomic) BOOL isTemperatureMax;
@property (nonatomic) BOOL isHumidityMin;
@property (nonatomic) BOOL isHumidityMax;
@property (nonatomic) BOOL isSupeortTH;
@property (nonatomic) BOOL isSupeortWiredIO;//支持有线报警输入输出
/*未处理*/
@property(assign) BOOL isRefreshAlarmEmail;
@property(assign) BOOL isNotVerifiedEmail;

@end


