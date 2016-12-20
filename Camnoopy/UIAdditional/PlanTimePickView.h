

#import <UIKit/UIKit.h>
#import "IDJPickerView.h"
#import "Constants.h"
@interface PlanTimePickView : UIView<IDJPickerViewDelegate>
@property (nonatomic, strong) IDJPickerView *picker;
@property(nonatomic) DeviceDate date;
@end
