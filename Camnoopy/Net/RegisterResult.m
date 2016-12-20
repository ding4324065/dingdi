

#import "RegisterResult.h"

@implementation RegisterResult
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.contactId forKey:@"contactId"];
    [aCoder encodeInt:self.error_code forKey:@"error_code"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.contactId = [aDecoder decodeObjectForKey:@"contactId"];
        self.error_code = [aDecoder decodeIntForKey:@"error_code"];
    }
    return self;
}
@end
