
/*智能摄像机界面*/
#import <UIKit/UIKit.h>
#import "P2PClient.h"
#import <AVFoundation/AVFoundation.h>
#import "TouchButton.h"
#import "OpenGLView.h"
#import "Contact.h"
//#import "P2PMonitorControllerFull.h"
#import "TopBar.h"

#define ALERT_TAG_CLEAR 0
#define ALERT_TAG_LEARN 1      //学习遥控
#define ALERT_TAG_NAME 2
#define ALERT_TAG_LEARN_SENSOR 3  //学习门磁
#define ALERT_TAG_DOORBELL 4     //门铃
@class MBProgressHUD;
@class YProgressView;
@interface P2PMonitorController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate,TouchButtonDelegate,OpenGLViewDelegate,UIScrollViewDelegate,P2PClientDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@property (strong,nonatomic) TopBar * topbar;
@property (nonatomic, strong) OpenGLView *remoteView;
@property (nonatomic, strong) NSMutableArray *defenceArray;//在cell上显示的数据

@property(strong,nonatomic) NSMutableArray *switchStatusData;

@property (nonatomic, assign)NSInteger time1;
@property (nonatomic,assign)NSInteger time2;
@property (nonatomic,strong) UIView *canvasView;    //render的背景视图
@property (assign,nonatomic) CGRect canvasframe;

@property (strong, nonatomic) UIView *talkingTipView;        //对讲提示视图
@property (assign,nonatomic) CGRect talkingTipframe;
@property (strong, nonatomic) UILabel * viewerCountLable1;    //当前观看人数
@property (strong, nonatomic) UILabel * viewerCountLable;    //当前观看人数
@property (assign,nonatomic) CGRect viewerCountFrame;
@property (assign,nonatomic) CGRect viewerCountFrame1;
@property (assign,nonatomic) CGRect connectingTipViewframe;
@property (strong,nonatomic) YProgressView * connectingTipView;   //蓝色转动的连接提示视图

@property (strong,nonatomic) UIView *resolutionViewFull;    //分辨率
@property (strong,nonatomic) UIButton *resolutionbtnFull;

@property (strong,nonatomic) UIView * toolbarFull;        //全屏时显示在右边的工具条
@property (nonatomic) BOOL isShowToolbarFull;

@property (strong,nonatomic) Contact * contact;

@property (strong,nonatomic) UIScrollView * screenshotView;     //中间显示4张图片的容器

@property (strong,nonatomic) UIScrollView * fullShotimgScrollView;  //全屏显示图片的容器
@property (strong,nonatomic) UILabel * shottopLabel;        //指示当前显示的图片序号

@property (strong,nonatomic) UIScrollView * controllerMenu;
@property (strong,nonatomic) UIScrollView * nowShowfullScrollView;

@property (strong,nonatomic) UIButton * recordbtn;
@property (strong,nonatomic) UIButton * recordbtnFull;

@property (strong, nonatomic) UIScrollView *mainScrollView;//监控下面的主滚动视图
@property (strong, nonatomic) UITableView *tableView;//报警设备列表

@property (assign,nonatomic) BOOL isRecording;
@property (assign,nonatomic) BOOL isRender;
@property (nonatomic) BOOL isReject;

@property (assign,nonatomic) BOOL isfullScreen;
@property (assign,nonatomic) BOOL isRenderViewStretch;

@property (assign,nonatomic) BOOL isInitRender;     //判断从文件夹退出来，第二次加载
@property (assign,nonatomic) BOOL isNoSound;        //已经静音了
//@property (assign, nonatomic)BOOL isPinchGR;        //使用缩放手势时
@property(assign) BOOL isSetting;
@property (nonatomic) BOOL isTalking;

@property (nonatomic) int presetTag;   //预置位tag

@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property(assign) int dwCurGroup;               //正在操作的分区
@property(assign) int dwCurItem;                //正在操作第几行
@property(assign) int dwlastOperation;          //正在执行的操作
@property(assign) int learnedDeviceNum;         //已经学习对码的设备数
@property(assign) BOOL isLoadDefenceArea;
@property (assign, nonatomic) BOOL isSettingSensor;  //学习门磁对码
@property (assign, nonatomic) BOOL isSettingRemote;  //学习遥控对码
@property(strong,nonatomic) NSMutableArray *defenceStatusData;   //对码学习情况
@property (nonatomic,strong) NSMutableArray *nameArray;
//@property(strong,nonatomic) NSMutableArray *switchStatusData;
@property (strong, nonatomic) UIAlertView *nameAlertView;//学习成功后给已学习的设备命名
@property (strong, nonatomic) UITextField *nameTF;//用于接收用户输入的名字

@property(assign) BOOL isLoadDefenceSwitch;
@property(assign) BOOL isNotSurportDefenceSwitch;
@property(nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic, strong) NSMutableArray *dataArray1;
@property(nonatomic, strong) NSMutableArray *dataArraycount;

@property(strong,nonatomic) NSMutableArray *statusData;
@property (strong, nonatomic) NSString *defenceName;//alertView中輸入的名字
@property (nonatomic,strong) NSMutableArray *namearray;
@property(assign) int dwItemModify;             //记录当前修改名称的channel

//GPIO 口控制参数记录
@property(nonatomic) int lastGroup;
@property(nonatomic) int lastPin;
@property(nonatomic) int lastValue;
@property(nonatomic) int *lastTime;

@property(strong,nonatomic)UIView * inputView;              //小背景视图
@property (strong,nonatomic)UIView * inputalphaView;        //大背景视图
@property(strong,nonatomic)UITextField * namechangeView;    //text edit
@property(strong,nonatomic)UILabel * titleLable;            //title lable

@property (assign, nonatomic) int cardint;
@property (assign, nonatomic) int cardint1;
@property (assign, nonatomic) int key;
@property (assign, nonatomic) BOOL isyuzhiwei;
@property (strong, nonatomic) UIButton *yuzhiweib;

@property (nonatomic, strong)UITextField *text3;
@property (nonatomic, strong)UITextField *text1;
@property (nonatomic, strong)UITextField *text2;
@property (nonatomic, strong)UITextField *text4;
@property (nonatomic, strong)NSString *sss;
@property (nonatomic, assign)NSInteger index;
@property(strong,nonatomic)UIView * v;
@property (nonatomic, assign)NSInteger index1;

@property (nonatomic) BOOL isdelete;
@property(nonatomic) int alarmType;
@property(nonatomic) int presetNumber;
@property(nonatomic) BOOL isReturnData;

@property (nonatomic, strong) NSMutableArray *yuzhiweiArray;
@property (nonatomic, strong) NSMutableArray *array;

@property(nonatomic) int Num;



@end
