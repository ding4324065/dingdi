
/*个人信息相关*/
#import <UIKit/UIKit.h>

@interface AccountCell : UITableViewCell


@property (strong, nonatomic) NSString *rightIcon;
@property (strong, nonatomic) NSString *labelText;
@property (strong, nonatomic) NSString *rightText;
@property (strong, nonatomic) UILabel *textLabelView;
@property (strong, nonatomic) UILabel *rightLabelView;

@property (strong, nonatomic) UIImageView *rightIconView;

@property (nonatomic) BOOL isHiddenRightIcon;
@property (nonatomic) BOOL isHiddenRightLabel;
@end
