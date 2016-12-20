

#import <Foundation/Foundation.h>
#pragma mark - 修改登录密码的结果
@interface ModifyLoginPasswordResult : NSObject
@property (strong, nonatomic) NSString* sessionId;
@property (nonatomic) int error_code;
@end
