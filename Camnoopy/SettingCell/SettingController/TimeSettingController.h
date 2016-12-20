/*时间设置界面*/

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "P2PSecurityCell.h"

#import "CyclePickerView.h"
@class Contact;
//@class MyPickerView;
@class MytestPickerView;
@class TimezoneView;
@interface TimeSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,SavePressDelegate,CyclePickerViewDelegate,CyclePickerViewDatasource,MXSCycleScrollViewDatasource,MXSCycleScrollViewDelegate>
@property(strong, nonatomic) Contact *contact;
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) UIDatePicker *datePicker;
@property(strong, nonatomic) NSString *dateString;
@property(nonatomic,strong)CyclePickerView * cycleview;
@property(nonatomic,strong)MXSCycleScrollView * timezoneview;
@property (nonatomic,strong)UIView * headlabelview;         //年月日时分
@property(nonatomic,strong)UILabel *timezoneLable;

@property(strong, nonatomic) NSString *time;
@property(nonatomic) DeviceDate lastSetDate;
@property(nonatomic) DeviceDate date;

@property (nonatomic) NSInteger timezone;           //用这个值来刷新title
@property (nonatomic) NSInteger lastSetTimezone;    //把设置的值保存在这个值里
@property (nonatomic) BOOL isSupportTimezone;
@property (nonatomic) BOOL isIndiaTimezone;

@end
