

#import <UIKit/UIKit.h>

@interface BottomBar : UIView
@property (strong,nonatomic) NSMutableArray *items;
@property (strong,nonatomic) NSMutableArray *backViews;
@property (strong,nonatomic) NSMutableArray *iconViews;
@property (nonatomic) NSInteger selectedIndex;
-(void)updateItemIcon:(NSInteger)willSelectedIndex;
@end
