

#import <Foundation/Foundation.h>
#define STATE_ONLINE 1  //在线
#define STATE_OFFLINE 0 //不在线

#define CONTACT_TYPE_UNKNOWN 0  //场景（未知）类型
#define CONTACT_TYPE_NPC 2      //电话机（可视）
#define CONTACT_TYPE_PHONE 3    //电话；耳机，听筒
#define CONTACT_TYPE_DOORBELL 5 //门铃
#define CONTACT_TYPE_IPC 7      //网络摄像机器（摇头）


#define DEFENCE_STATE_OFF 0    //布防关闭
#define DEFENCE_STATE_ON 1     //布防打开
#define DEFENCE_STATE_LOADING 2//布防加载
#define DEFENCE_STATE_WARNING_PWD 3//布防警告—当前
#define DEFENCE_STATE_WARNING_NET 4//布防警告－网络
#define DEFENCE_STATE_NO_PERMISSION 5//布防不允许
#pragma mark - 联系
@interface Contact : NSObject
@property (nonatomic) int row;
//联系人id
@property (strong, nonatomic) NSString *contactId;
//联系人名字
@property (strong, nonatomic) NSString *contactName;
//密码
@property (strong, nonatomic) NSString *contactPassword;
//联系人类型
@property (nonatomic) NSInteger contactType;
//在线状态
@property (nonatomic) NSInteger onLineState;
//消息数量
@property (nonatomic) NSInteger messageCount;
//布防状态
@property (nonatomic) NSInteger defenceState;
//是否点击布防状态按钮
@property (nonatomic) BOOL isClickDefenceStateBtn;

@property (nonatomic) BOOL isGettingOnLineState;//isGettingOnLineState

@property (nonatomic) BOOL isNewVersionDevice;//设备检查更新
@property (strong, nonatomic) NSString *deviceCurVersion;//设备检查更新
@property (strong, nonatomic) NSString *deviceUpgVersion;//设备检查更新
@property (nonatomic) NSInteger result_sd_server;//设备检查更新
@end
