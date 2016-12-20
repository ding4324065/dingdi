

#import <UIKit/UIKit.h>
#import "P2PClient.h"
@interface P2PCallController : UIViewController
@property (nonatomic) BOOL isReject;
@property (nonatomic) BOOL isAccept;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *contactName;
@end
