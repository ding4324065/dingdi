

#import <UIKit/UIKit.h>

@interface P2PSettingCell : UITableViewCell

@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) NSString *rightLabelText;

@property (strong, nonatomic) UILabel *leftLabelView;
@property (strong, nonatomic) UILabel *rightLabelView;

@property (strong, nonatomic) UIView *customView;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (assign) BOOL isCustomViewHidden;
@property (assign) BOOL isLeftLabelHidden;
@property (assign) BOOL isRightLabelHidden;
@property (assign) BOOL isProgressViewHidden;

-(void)setLeftLabelHidden:(BOOL)hidden;
-(void)setRightLabelHidden:(BOOL)hidden;
-(void)setCustomViewHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;
@end
