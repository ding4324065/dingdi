

#import "AccountResult.h"

@implementation AccountResult

#pragma mark - 保存文件时调用
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.countryCode forKey:@"countryCode"];
    [aCoder encodeInt:self.error_code forKey:@"error_code"];
}
#pragma mark - 读取文件时调用；
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.countryCode = [aDecoder decodeObjectForKey:@"countryCode"];
        self.error_code = [aDecoder decodeIntForKey:@"error_code"];
    }
    return self;
}
@end
