

#import <UIKit/UIKit.h>
@class MyPickerView;
@class MyPickTitleView;
@class MytestPickerView;
@class GQCycleViewController;
#import "CyclePickerView.h"
@interface P2PTimeSettingCell : UITableViewCell

@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) NSString *rightLabelText;
@property (strong, nonatomic) NSString *middleLabelText;

@property (strong, nonatomic) UILabel *leftLabelView;
@property (strong, nonatomic) UILabel *rightLabelView;
@property (strong, nonatomic) UILabel *middleLabelView;

//@property (strong, nonatomic) MyPickerView *customView;
//@property (strong,nonatomic)MytestPickerView * customView;
@property (strong,nonatomic)CyclePickerView * customView;
//@property (strong, nonatomic) MyPickTitleView *titleView;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (assign) BOOL isCustomViewHidden;
@property (assign) BOOL isLeftLabelHidden;
@property (assign) BOOL isRightLabelHidden;
@property (assign) BOOL isMiddleLabelHidden;
@property (assign) BOOL isProgressViewHidden;
@property (assign) BOOL isTitleViewHidden;

-(void)setLeftLabelHidden:(BOOL)hidden;
-(void)setRightLabelHidden:(BOOL)hidden;
-(void)setMiddleLabelHidden:(BOOL)hidden;
-(void)setCustomViewHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;
-(void)setTitleViewHidden:(BOOL)hidden;
@end
