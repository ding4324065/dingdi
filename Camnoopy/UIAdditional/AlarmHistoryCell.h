

#import <UIKit/UIKit.h>

@interface AlarmHistoryCell : UITableViewCell

@property (strong, nonatomic) UILabel *deviceLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UILabel *deviceLabelText;
@property (strong, nonatomic) UILabel *typeLabelText;

@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *alarmTime;
@property (nonatomic) int alarmType;

@end
