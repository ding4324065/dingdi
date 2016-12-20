

#import <UIKit/UIKit.h>

@interface TopBar : UIView
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) UIButton *rightButton2;
@property (strong, nonatomic) UIImageView *rightButtonIconView;
@property (strong, nonatomic) UIImageView *rightButtonIconView2;
@property (strong, nonatomic) UIImageView *leftButtonIconView;
@property (strong, nonatomic) UILabel *leftButtonLabel;
@property (strong, nonatomic) UILabel *rightButtonLabel;
@property (strong, nonatomic) UILabel *rightButtonLabel2;
-(void)setTitle:(NSString*)title;
-(void)setBackButtonHidden:(BOOL)hidden;
-(void)setLeftButtonHidden:(BOOL)hidden;
-(void)setRightButtonHidden:(BOOL)hidden;
-(void)setRightButtonHidden2:(BOOL)hidden;
-(void)setLeftButtonIcon:(UIImage*)img;
-(void)setRightButtonIcon:(UIImage*)img;
-(void)setRightButtonIcon2:(UIImage*)img;
-(void)setRightButtonText:(NSString*)text;

- (id)initWithFrame:(CGRect)frame;
@end
