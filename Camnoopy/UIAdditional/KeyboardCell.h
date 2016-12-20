

#import <UIKit/UIKit.h>

@interface KeyboardCell : UITableViewCell
@property (nonatomic, strong) NSString *leftText;
@property (nonatomic, strong) NSString *rightText;

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@end
