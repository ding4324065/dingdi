

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

@property (assign,nonatomic) NSString *leftIcon;
@property (assign,nonatomic) NSString *rightIcon;
@property (assign,nonatomic) NSString *labelText;

@property (strong, nonatomic) UIImageView *leftIconView;
@property (strong, nonatomic) UIImageView *leftIconView_p;

@property (strong, nonatomic) UILabel *textLabelView;
@property (strong, nonatomic) UILabel *textLabelView_p;

@property (strong, nonatomic) UIImageView *rightIconView;
@property (strong, nonatomic) UIImageView *rightIconView_p;


@property (strong,nonatomic) NSString *newsDeviceIcon;//设备检查更新
@property (strong, nonatomic) UIImageView *newsDeviceIconView;//设备检查更新

@end
