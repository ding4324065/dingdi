

#import <UIKit/UIKit.h>

@interface YProgressView : UIView
@property (nonatomic) CGFloat angle;
@property (nonatomic) BOOL isStartAnim;
@property (nonatomic,strong) UIImageView *backgroundView;

-(void)start;
-(void)stop;

@end
