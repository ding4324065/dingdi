

#import <Foundation/Foundation.h>
#import "sqlite3.h"
@class Contact;
#define DB_NAME @"Gviews.sqlite"
#define kContactDBVersion @"kContactDBVersion"
#define CONTACT_DB_VERSION 1
#pragma mark - 联系数据访问对象
@interface ContactDAO : NSObject
@property (nonatomic) sqlite3 *db;

-(BOOL)insert:(Contact*)contact;
-(NSMutableArray*)findAll;
-(BOOL)delete:(Contact*)recent;
-(BOOL)update:(Contact*)contact;
-(Contact*)isContact:(NSString*)contactId;
@end
