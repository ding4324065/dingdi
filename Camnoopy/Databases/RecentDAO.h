

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@class Recent;
#define DB_NAME @"Gviews.sqlite"
#pragma mark - 最近的数据访问对象
@interface RecentDAO : NSObject
@property (nonatomic) sqlite3 *db;


-(BOOL)insert:(Recent*)recent;
-(NSMutableArray*)findAll;
-(BOOL)delete:(Recent*)recent;
-(BOOL)clear;
@end


