

#import <UIKit/UIKit.h>
#import "YProgressView.h"

@class LocalDevice;
@interface TempContactCell : UITableViewCell
@property (strong, nonatomic) UIButton *headView;
@property (strong, nonatomic) UIImageView *typeView;
@property (strong, nonatomic) UILabel *nameLabel;


@property (strong, nonatomic) UIButton *defenceStateView;
@property (strong, nonatomic) LocalDevice *localDevice;
@end
