

#import <Foundation/Foundation.h>
#pragma mark - 报警
@interface Alarm : NSObject

@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *alarmTime;
@property (nonatomic) int alarmType;
@property (nonatomic) int alarmGroup;
@property (nonatomic) int alarmItem;
@property (nonatomic) int row;
@property (nonatomic, strong) NSString * msgIndex;

@end
