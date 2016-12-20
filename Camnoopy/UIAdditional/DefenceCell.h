

#import <UIKit/UIKit.h>

@class DefenceCell;
@protocol UIDefenceCellDelegate <NSObject>
@optional
-(void)defenceCell:(DefenceCell *)defenceCell section:(NSInteger)section row:(NSInteger)row;
@end

@interface DefenceCell : UITableViewCell

@property(nonatomic, strong) UIButton *leftButton;
@property(nonatomic, strong) UILabel *indexLabel;
@property(nonatomic, strong) UIImageView *delImageView;
@property(nonatomic, strong) UILabel *learnCodeLabel;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (strong, nonatomic) UIActivityIndicatorView *progressView2;

@property(nonatomic, strong) NSString *index;
@property(nonatomic) BOOL isSelectedButton;

@property (assign) BOOL isLeftButtonHidden;
@property (assign) BOOL isDelImageViewHidden;
@property (assign) BOOL isLearnCodeLabelHidden;
@property (assign) BOOL isProgressViewHidden;
@property (assign) BOOL isProgressViewHidden2;

@property(nonatomic) NSInteger section;
@property(nonatomic) NSInteger row;
@property(nonatomic, assign) id<UIDefenceCellDelegate> delegate;

-(void)setLeftButtonHidden:(BOOL)hidden;
-(void)setDelImageViewHidden:(BOOL)hidden;
-(void)setLearnCodeLabelHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;
-(void)setProgressViewHidden2:(BOOL)hidden;

@end
