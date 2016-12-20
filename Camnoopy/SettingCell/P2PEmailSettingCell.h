
@protocol EmailSettingCellDelegate <NSObject>

@optional
-(void)havetapLeftIconView:(NSInteger)section androw:(NSInteger)row;

@end
#import <UIKit/UIKit.h>

@interface P2PEmailSettingCell : UITableViewCell

@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) UILabel *leftLabelView;

@property (strong, nonatomic) NSString *rightLabelText;
@property (strong, nonatomic) UILabel *rightLabelView;

@property (strong, nonatomic) NSString *leftIcon;
@property (strong, nonatomic) UIImageView *leftIconView;
    
@property (strong, nonatomic) NSString *rightIcon;
@property (strong, nonatomic) UIImageView *rightIconView;

@property (assign,nonatomic) NSInteger section;
@property (assign,nonatomic) NSInteger row;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (strong,nonatomic)id<EmailSettingCellDelegate>delegate;
@property (assign) BOOL isLeftLabelHidden;
@property (assign) BOOL isRightLabelHidden;
@property (assign) BOOL isLeftIconHidden;
@property (assign) BOOL isRightIconHidden;
    
@property (assign) BOOL isProgressViewHidden;



-(void)setRightLabelHidden:(BOOL)hidden;
-(void)setLeftIconHidden:(BOOL)hidden;
-(void)setRightIconHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;
-(void)setLeftLabelHidden:(BOOL)hidden;
@end
