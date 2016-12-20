

#import <UIKit/UIKit.h>

@interface P2PVideoVolumeSettingCell : UITableViewCell

@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) UILabel *leftLabelView;

@property (strong, nonatomic) UIView *customView;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (assign) BOOL isCustomViewHidden;
@property (assign) BOOL isLeftLabelHidden;
@property (assign) BOOL isProgressViewHidden;

-(void)setLeftLabelHidden:(BOOL)hidden;
-(void)setCustomViewHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;

@property (assign) NSInteger volumeValue;
@end
