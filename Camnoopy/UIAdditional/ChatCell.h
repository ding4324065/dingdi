

#import <UIKit/UIKit.h>
@class Message;
@interface ChatCell : UITableViewCell

@property (strong, nonatomic) Message *message;


@property (strong, nonatomic) UIImageView *headerView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *messageView;


@end
