

#import <Foundation/Foundation.h>
#pragma mark - 检查报警信息结果
@interface CheckAlarmMessageResult : NSObject
@property (nonatomic) BOOL isNewAlarmMessage;
@property (nonatomic) int error_code;
@end
