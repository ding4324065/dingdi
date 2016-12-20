//
//  likageDao.h
//  Camnoopy
//
//  Created by 卡努比 on 16/10/28.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

#define DB_NAME @"Gviews.sqlite"
#define LIKAGE_TABLE @"likage"

@interface likageDao : NSObject
@property (nonatomic) sqlite3 *db;



@end
