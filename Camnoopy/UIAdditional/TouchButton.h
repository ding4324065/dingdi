

#import <UIKit/UIKit.h>
@class TouchButton;
@protocol TouchButtonDelegate <NSObject>

@optional
-(void)onBegin:(TouchButton*)touchButton widthTouches:(NSSet*)touches withEvent:(UIEvent *)event;
-(void)onCancelled:(TouchButton*)touchButton widthTouches:(NSSet*)touches withEvent:(UIEvent *)event;
-(void)onEnded:(TouchButton*)touchButton widthTouches:(NSSet*)touches withEvent:(UIEvent *)event;
-(void)onMoved:(TouchButton*)touchButton widthTouches:(NSSet*)touches withEvent:(UIEvent *)event;
@end

@interface TouchButton : UIButton


@property (nonatomic, assign) id<TouchButtonDelegate> delegate;
- (void)setDelegate:(id<TouchButtonDelegate>)delegate;
@end


