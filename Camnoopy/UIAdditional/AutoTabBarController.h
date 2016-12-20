

#import <UIKit/UIKit.h>
#import "BottomBar.h"
@interface AutoTabBarController : UITabBarController
@property (strong, nonatomic) BottomBar *bottomBar;

-(void)setBottomBarHidden:(BOOL)isHidden;
@end
