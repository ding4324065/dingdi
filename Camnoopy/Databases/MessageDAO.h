

#import <Foundation/Foundation.h>
#import "Message.h"
#import "sqlite3.h"
#define DB_NAME @"Gviews.sqlite"
#pragma mark - 消息数据访问对象
@interface MessageDAO : NSObject
@property (nonatomic) sqlite3 *db;


-(BOOL)insert:(Message*)recent;
-(NSMutableArray*)findAllWithId:(NSString*)contactId;
-(BOOL)delete:(Message*)recent;
-(BOOL)clearWithId:(NSString*)contactId;

-(BOOL)updateMessageStateWithFlag:(NSInteger)flag state:(NSInteger)state;
-(BOOL)update:(Message*)message;
@end
