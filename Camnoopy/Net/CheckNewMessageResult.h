
#pragma mark - 检查新的消息结果
#import <Foundation/Foundation.h>

@interface CheckNewMessageResult : NSObject
@property (nonatomic) BOOL isNewContactMessage;
@property (nonatomic) int error_code;
@end
