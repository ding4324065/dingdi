
//录像设置 录像模式
#import <UIKit/UIKit.h>
@class RadioButton;
@interface P2PRecordTypeCell : UITableViewCell
@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;
@property (strong, nonatomic) RadioButton *radio3;

@property (assign) NSInteger selectedIndex;
@end
