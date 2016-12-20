
/*录像设置界面*/

#import <UIKit/UIKit.h>
#import "P2PRecordTimeCell.h"
#import "P2PSecurityCell.h"
#import "CyclePickerView.h"
#import "MXSCycleScrollView.h"
#import "MXSCycleScrollView3.h"
@class Contact;
@class RadioButton;
@class PlanTimePickView;
@class MBProgressHUD;
@interface RecordSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,P2PRecordTimeCellDelegate,SavePressDelegate,UIActionSheetDelegate,MXSCycleScrollView3Delegate,MXSCycleScrollView3Datasource>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;
    
@property(assign) BOOL isFirstCompoleteLoadRecordType;
@property(assign) BOOL isLoadingRecordType;
@property(assign) BOOL isLoadingRecordTime;
@property(assign) BOOL isLoadingRecordPlanTime;
@property(assign) BOOL isSetRecordModel;

@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;
@property (strong, nonatomic) RadioButton *radio3;
@property (strong, nonatomic) UIView *selectView;
@property (strong, nonatomic) UIView *alphaView;

@property(assign) NSInteger recordType;
@property(assign) NSInteger lastRecordType;

@property(assign) NSInteger recordTime;
@property(assign) NSInteger lastRecordTime;

@property(assign) NSInteger planTime;
@property(assign) NSInteger lastPlanTime;

@property (strong, nonatomic) NSString *selectType;

@property (strong,nonatomic) RadioButton *radioRecordType1;
@property (strong,nonatomic) RadioButton *radioRecordType2;
@property (strong,nonatomic) RadioButton *radioRecordType3;

@property (strong,nonatomic) RadioButton *radioRecordTime1;
@property (strong,nonatomic) RadioButton *radioRecordTime2;
@property (strong,nonatomic) RadioButton *radioRecordTime3;

@property (strong,nonatomic) PlanTimePickView *planPicker1;
@property (strong,nonatomic) PlanTimePickView *planPicker2;

@property (strong,nonatomic) UIDatePicker *datePicker1;
@property (strong,nonatomic) UIDatePicker *datePicker2;

@property (strong,nonatomic) NSString *startTimeString;
@property (strong,nonatomic) NSString *endTimeString;
@property (strong,nonatomic) NSString * timestring;

@property(assign) NSInteger remoteRecordState;
@property(assign) NSInteger lastRemoteRecordState;
@property(assign) BOOL isLoadingRemoteRecord;
@property(assign) BOOL isSetRemoteRecordState;

@property(nonatomic,strong)CyclePickerView * cycleview;
@property(nonatomic,strong)MXSCycleScrollView3 * beginhour;
@property(nonatomic,strong)MXSCycleScrollView3 * beginmin;
@property(nonatomic,strong)MXSCycleScrollView3 * endhour;
@property(nonatomic,strong)MXSCycleScrollView3 * endmin;
@property(nonatomic,strong)UIView * timepicker;
@property (nonatomic,strong)UIView * timefootlview;
@property(nonatomic,strong)MBProgressHUD * progressAlert;
@end
