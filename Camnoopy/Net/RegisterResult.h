

#import <Foundation/Foundation.h>
#pragma mark - 注册结果
@interface RegisterResult : NSObject
@property (strong, nonatomic) NSString* contactId;
@property (nonatomic) int error_code;
@end
