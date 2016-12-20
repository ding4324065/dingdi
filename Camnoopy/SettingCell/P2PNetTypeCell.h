

#import <UIKit/UIKit.h>
@class RadioButton;
@interface P2PNetTypeCell : UITableViewCell
@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;

@property (assign) NSInteger selectedIndex;
@end
