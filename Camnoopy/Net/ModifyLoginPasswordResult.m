

#import "ModifyLoginPasswordResult.h"

@implementation ModifyLoginPasswordResult
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.sessionId forKey:@"sessionId"];
    [aCoder encodeInt:self.error_code forKey:@"error_code"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.sessionId = [aDecoder decodeObjectForKey:@"sessionId"];
        self.error_code = [aDecoder decodeIntForKey:@"error_code"];
    }
    return self;
}
@end
