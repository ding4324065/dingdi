

#import <UIKit/UIKit.h>

#import "P2PClient.h"
#import "AutoTabBarController.h"

@protocol MainControllerDelegate <NSObject>

@optional
- (void)P2PClientReady:(NSDictionary*)info;
@end

@interface MainController : AutoTabBarController<P2PClientDelegate>
@property (nonatomic) BOOL isShowP2PView;
@property (nonatomic,strong) NSString * contactName;
@property (nonatomic, assign) id<MainControllerDelegate,UITabBarControllerDelegate> delegate;

-(void)setUpCallWithId:(NSString*)contactId password:(NSString*)password callType:(P2PCallType)type;

-(void)setUpCallWithId:(NSString*)contactId address:(NSString*)address password:(NSString*)password callType:(P2PCallType)type;

-(void)dismissP2PView;
-(void)dismissP2PView:(void (^)())callBack;
@end
