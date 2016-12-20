

#import <Foundation/Foundation.h>
#pragma mark - 账户的结果
@interface AccountResult : NSObject
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* countryCode;
@property (nonatomic) int error_code;
@end
