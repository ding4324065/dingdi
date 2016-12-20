

#import <UIKit/UIKit.h>
@class ScreenshotCell;
@protocol ScreenshotCellDelegate <NSObject>

@optional
-(void)onItemClick:(ScreenshotCell*)screenshotCell row:(NSInteger)row index:(NSInteger)index;
-(void)onItemLongPress:(ScreenshotCell*)screenshotCell row:(NSInteger)row index:(NSInteger)index;
@end

@interface ScreenshotCell : UITableViewCell
@property (assign) NSInteger row;
@property (strong, nonatomic) NSString *filePath1;
@property (strong, nonatomic) NSString *filePath2;
@property (retain, nonatomic) UIButton *backButton1;
@property (retain, nonatomic) UIButton *backButton2;

@property (copy, nonatomic) NSString* text1;
@property (copy, nonatomic) NSString* text2;

@property (nonatomic, assign) BOOL isHiddenMask1;
@property (nonatomic, assign) BOOL isHiddenMask2;

@property (nonatomic, assign) id<ScreenshotCellDelegate> delegate;

@end
