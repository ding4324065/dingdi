

#import <Foundation/Foundation.h>
#pragma mark - 得到报警记录结果
@interface GetAlarmRecordResult : NSObject

@property (nonatomic) int error_code;
@property (nonatomic,strong) NSArray *alarmRecord;

@end
