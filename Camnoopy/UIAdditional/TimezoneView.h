

#import <UIKit/UIKit.h>
#import "IDJPickerView.h"
#import "Constants.h"
@protocol TimezoneViewDelegate <NSObject>

@optional
-(void)onTimezoneChange:(NSInteger)timezone;
@end

@interface TimezoneView : UIView
@property (nonatomic, strong) IDJPickerView *picker;
@property (nonatomic) NSInteger timezone;
@property (nonatomic, assign) id<TimezoneViewDelegate> delegate;
@end
