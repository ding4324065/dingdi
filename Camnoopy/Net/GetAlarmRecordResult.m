

#import "GetAlarmRecordResult.h"

@implementation GetAlarmRecordResult

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:self.error_code forKey:@"error_code"];
    [aCoder encodeObject:self.alarmRecord forKey:@"alarmRecord"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.error_code = [aDecoder decodeIntForKey:@"error_code"];
        self.alarmRecord = [aDecoder decodeObjectForKey:@"alarmRecord"];
    }
    return self;
}

@end
