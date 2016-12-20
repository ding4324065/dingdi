

#import <UIKit/UIKit.h>
#pragma mark - 登陆结果
@interface LoginResult : NSObject<NSCoding>
//联系人id
@property (strong, nonatomic) NSString* contactId;
//密码1
@property (strong, nonatomic) NSString* rCode1;
//密码2
@property (strong, nonatomic) NSString* rCode2;
//手机
@property (strong, nonatomic) NSString* phone;
//email
@property (strong, nonatomic) NSString* email;
//身份证
@property (strong, nonatomic) NSString* sessionId;
//国家代码
@property (strong, nonatomic) NSString* countryCode;
//错误代码
@property (nonatomic) int error_code;
@end
