
/*远程录像第二个界面*/
#import <UIKit/UIKit.h>
#import "P2PClient.h"
@class  Contact;
@interface P2PPlaybackController : UIViewController<UITableViewDataSource,UITableViewDelegate,P2PPlaybackDelegate>
@property(strong, nonatomic) Contact *contact;
@property(nonatomic) BOOL isInitSearch;
@property(strong, nonatomic) UIImageView *layerView;
@property(strong, nonatomic) UIView *searchBarView;
@property(retain, nonatomic) NSMutableArray *playbackFiles;
@property(retain, nonatomic) NSMutableArray *playbackSize;
@property(retain, nonatomic) NSMutableArray *timesData;
@property(retain, nonatomic) NSMutableArray *dayOneFiles;
@property(retain, nonatomic) NSMutableArray *dayThreeFiles;
@property(retain, nonatomic) NSMutableArray *dayMonthFiles;
@property(retain, nonatomic) NSMutableArray *customFiles;

@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) UIView *searchMaskView;
@property(strong, nonatomic) UIView *movieView;
@property(strong, nonatomic) NSString *nextStartTime;
@property(strong, nonatomic) NSString *startTime;
@property(strong, nonatomic) NSString *endTime;

@property (strong, nonatomic) UIButton *startTimeBtn;
@property (strong, nonatomic) UIButton *endTimeBtn;
@property (nonatomic) NSInteger selectedTimeTag;
@property (nonatomic) NSInteger selectedLabel;
@property (strong, nonatomic) UIView *customView;
@property (strong, nonatomic) UILabel *startTimeLabel;
@property (strong, nonatomic) UILabel *endTimeLabel;
@property (nonatomic) BOOL isShowCustomView;

@property (nonatomic) BOOL isChangePlaybackItem;//视频回放修复

@property (strong, nonatomic)UIView* selectView;

@end
