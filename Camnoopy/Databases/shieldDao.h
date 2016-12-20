//
//  shieldDao.h
//  2cu
//
//  Created by wutong on 15-6-9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
#pragma mark - 屏蔽数据访问对象
#import <Foundation/Foundation.h>
#import "sqlite3.h"


#define DB_NAME @"Gviews.sqlite"
@interface shieldDao : NSObject
@property (nonatomic) sqlite3 *db;

-(BOOL)insert:(NSString*)contactId;
-(BOOL)deleteContent:(NSString *)contactId;
-(NSMutableArray*)findAll;
-(BOOL)isShield:(NSString *)contactId;
@end
