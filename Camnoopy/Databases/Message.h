

#import <Foundation/Foundation.h>
#define MESSAGE_STATE_NO_READ 0
#define MESSAGE_STATE_READED 1
#define MESSAGE_STATE_SENDING 2
#define MESSAGE_STATE_SEND_FAILURE 3
#pragma mark - 消息
@interface Message : NSObject
@property (nonatomic) int row;
@property (strong, nonatomic) NSString *fromId;
@property (strong, nonatomic) NSString *toId;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *time;
@property (nonatomic) int state;
@property (nonatomic) int flag;

@end
