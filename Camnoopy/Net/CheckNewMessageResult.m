

#import "CheckNewMessageResult.h"

@implementation CheckNewMessageResult
-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeBool:self.isNewContactMessage forKey:@"isNewContactMessage"];
    [aCoder encodeInt:self.error_code forKey:@"error_code"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.isNewContactMessage = [aDecoder decodeBoolForKey:@"isNewContactMessage"];
        self.error_code = [aDecoder decodeIntForKey:@"error_code"];
    }
    return self;
}
@end
