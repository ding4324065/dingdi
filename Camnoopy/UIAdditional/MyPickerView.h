

#import <UIKit/UIKit.h>
#import "IDJPickerView.h"
#import "Constants.h"
@protocol ReloadTimeSettingDelegate
-(void)reloadTimeSetting;
@end


@interface MyPickerView : UIView<IDJPickerViewDelegate>
@property (nonatomic, strong) IDJPickerView *picker;
@property(nonatomic) DeviceDate date;
@property (assign) id<ReloadTimeSettingDelegate> delegate;
@end
