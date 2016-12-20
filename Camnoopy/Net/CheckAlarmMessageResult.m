

#import "CheckAlarmMessageResult.h"

@implementation CheckAlarmMessageResult
-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeBool:self.isNewAlarmMessage forKey:@"isNewAlarmMessage"];
    [aCoder encodeInt:self.error_code forKey:@"error_code"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.isNewAlarmMessage = [aDecoder decodeBoolForKey:@"isNewAlarmMessage"];
        self.error_code = [aDecoder decodeIntForKey:@"error_code"];
    }
    return self;
}
@end
