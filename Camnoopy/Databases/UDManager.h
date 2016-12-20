

#import <Foundation/Foundation.h>
@class LoginResult;
#define kIsLogin @"isLogin"
#define kLoginInfo @"kLoginInfo"

#define kEmail @"email"
#define kPhone @"phone"


#pragma mark - 用户数据管理
@interface UDManager : NSObject

//判断是否登录
+(void)setIsLogin:(BOOL)isLogin;
+(BOOL)isLogin;
//获取登录的资料
+(void)setLoginInfo:(LoginResult*)loginResult;
+(LoginResult*)getLoginInfo;
//获取email
+(void)setEmail:(NSString*)email;
+(NSString*)getEmail;
//获取手机号
+(void)setPhone:(NSString*)phone;
+(NSString*)getPhone;



@end

