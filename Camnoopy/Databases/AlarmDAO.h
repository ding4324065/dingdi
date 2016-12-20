

#import <Foundation/Foundation.h>
#import "Alarm.h"
#import "sqlite3.h"
#define DB_NAME @"Gviews.sqlite"
#pragma mark -报警数据访问对象
@interface AlarmDAO : NSObject
@property (nonatomic) sqlite3 *db;


-(BOOL)insert:(Alarm*)alarm;
-(NSMutableArray*)findAll;
-(BOOL)delete:(Alarm*)alarm;
-(BOOL)clear;

@end
