
//查看截图
#import <UIKit/UIKit.h>
#import "ScreenshotCell.h"
#import "Contact.h"
#import "FileListCell.h"
@class Stack;

@interface ScreenshotController : UIViewController<UITableViewDataSource,UITableViewDelegate,ScreenshotCellDelegate,UIAlertViewDelegate ,OnFileListCellDelegate>
@property (retain, nonatomic) NSMutableArray *screenshotFiles;

@property(strong, nonatomic) Contact *contact;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) BOOL isShowDetail;                    //全屏查看图片
@property (strong,nonatomic)UIScrollView * detailImgScroll;
@property (strong,nonatomic) UILabel * shottopLabel;
@property (assign, nonatomic) NSInteger selectedRow;
@property (strong, nonatomic)UIView* selectView;
@property (strong, nonatomic) NSMutableArray *imageArr;
@property (strong, nonatomic)NSString *filePath;
-(void)ReloadLanguage;
@end
