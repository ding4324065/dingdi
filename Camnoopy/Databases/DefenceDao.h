//
//  DefenceDao.h
//  2cu
//
//  Created by wutong on 15-6-9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"


#define DB_NAME @"Gviews.sqlite"
#define DEFENCE_TABLE @"Defence"
#pragma mark - 布防数据访问对象
@interface DefenceDao : NSObject
@property (nonatomic) sqlite3 *db;

-(BOOL)insert:(NSString*)contactId group:(int)group item:(int)item text:(NSString*)text;
-(BOOL)deleteContent:(NSString *)contactId;
-(BOOL)update:(NSString*)contactId group:(int)group item:(int)item text:(NSString*)text;
-(NSString*)getItemName:(NSString *)contactId group:(int)group item:(int)item;
-(BOOL)deleteContent:(NSString *)contactId group:(int)group item:(int)item text:(NSString*)text;
@end
