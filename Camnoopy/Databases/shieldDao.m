//
//  shieldDao.m
//  2cu
//
//  Created by wutong on 15-6-9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "shieldDao.h"
#import "UDManager.h"
#import "LoginResult.h"

@implementation shieldDao
-(id)init{
    if([super init]){
        if([self openDB]){
            char *errMsg;
            if(sqlite3_exec(self.db, [[self getCreateTableString] UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
                NSString* es = [NSString stringWithUTF8String:errMsg];
                NSLog(@"Table shield failed to create， %@", es);
                sqlite3_free(errMsg);
            }
            [self closeDB];
        }
    }
    return self;
}

-(NSString*)dbPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:DB_NAME];
    return path;
}

-(NSString *)getCreateTableString{
    return @"CREATE TABLE IF NOT EXISTS shield(ID INTEGER PRIMARY KEY AUTOINCREMENT,activeUser Text,contactId Text)";
}

-(BOOL)openDB{
    BOOL result = NO;
    if(sqlite3_open([[self dbPath] UTF8String], &_db)==SQLITE_OK){
        result = YES;
    }else{
        result = NO;
        NSLog(@"Failed to open database");
    }
    
    return result;
};

-(BOOL)closeDB{
    if(sqlite3_close(self.db)==SQLITE_OK){
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)insert:(NSString*)contactId
{
    if(![UDManager isLogin]){
        return NO;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    char *errMsg;
    BOOL result = NO;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"INSERT INTO shield(activeUser,contactId) VALUES(\"%@\",\"%@\")",loginResult.contactId,contactId];
        
        if(sqlite3_exec(self.db, [SQL UTF8String], NULL, NULL, &errMsg)==SQLITE_OK){
            result = YES;
        }else{
            NSString* es = [NSString stringWithUTF8String:errMsg];
            NSLog(@"Failed to insert shield, error=%@", es);
            sqlite3_free(errMsg);
            result = NO;
        }
        
        [self closeDB];
        
    }
    return result;
}

-(BOOL)deleteContent:(NSString *)contactId{
    if(![UDManager isLogin]){
        return NO;
    }
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM shield WHERE ACTIVEUSER = \"%@\" AND CONTACTID = \"%@\"",loginResult.contactId,contactId];
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to delete Contact:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to delete Contact:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}

-(NSMutableArray*)findAll{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if(![UDManager isLogin]){
        return array;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    sqlite3_stmt *statement;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"SELECT CONTACTID FROM shield WHERE ACTIVEUSER = \"%@\"",loginResult.contactId];
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                NSString* contactId = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
                [array addObject:contactId];
            }
        }else{
            NSLog(@"Failed to find Contact:%s",sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return array;
}

-(BOOL)isShield:(NSString *)contactId
{
    if(![UDManager isLogin]){
        return NO;
    }
    
    BOOL ret = NO;
    LoginResult *loginResult = [UDManager getLoginInfo];
    sqlite3_stmt *statement;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"SELECT CONTACTID FROM shield WHERE ACTIVEUSER = \"%@\" AND CONTACTID = \"%@\" ",loginResult.contactId,contactId];
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                ret = YES;
                break;
            }
        }else{
            NSLog(@"Failed to find Contact:%s",sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return ret;
}
/*
 return @"CREATE TABLE IF NOT EXISTS Defence(
 ID INTEGER PRIMARY KEY AUTOINCREMENT,
 activeUser Text,
 contactId Text,
 group integer,
 item integer,
 name Text
 )";
 */


@end
