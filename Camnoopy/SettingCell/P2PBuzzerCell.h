
//蜂鸣器
#import <UIKit/UIKit.h>
@class RadioButton;
@interface P2PBuzzerCell : UITableViewCell
@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) UILabel *leftLabelView;

@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;
@property (strong, nonatomic) RadioButton *radio3;

@property (assign) NSInteger selectedIndex;
@end