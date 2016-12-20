//
//  DefenceDao.m
//  2cu
//
//  Created by wutong on 15-6-9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "DefenceDao.h"
#import "UDManager.h"
#import "LoginResult.h"

@implementation DefenceDao
-(id)init{
    if([super init]){
        if([self openDB]){
            char *errMsg;
            if(sqlite3_exec(self.db, [[self getCreateTableString] UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK){
                NSString* es = [NSString stringWithUTF8String:errMsg];
                NSLog(@"Table defence failed to create， %@", es);
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
    return @"CREATE TABLE IF NOT EXISTS Defence(ID INTEGER PRIMARY KEY AUTOINCREMENT,activeUser Text,contactId Text,defencearea integer,item integer,name Text)";

//    return @"CREATE TABLE IF NOT EXISTS Alarm(ID INTEGER PRIMARY KEY AUTOINCREMENT,activeUser Text,deviceId Text,alarmTime Text,alarmType integer,alarmGroup integer,alarmItem integer)";

//    return @"CREATE TABLE IF NOT EXISTS Defence(ID INTEGER PRIMARY KEY AUTOINCREMENT,activeUser Text,contactId Text,group integer,item integer,name Text)";
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

-(BOOL)insert:(NSString*)contactId group:(int)group item:(int)item text:(NSString*)text
{
    if(![UDManager isLogin]){
        return NO;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    char *errMsg;
    BOOL result = NO;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"INSERT INTO Defence(activeUser,contactId,defencearea,item,name) VALUES(\"%@\",\"%@\",\"%d\",\"%d\",\"%@\")",loginResult.contactId,contactId,group,item,text];
        
        if(sqlite3_exec(self.db, [SQL UTF8String], NULL, NULL, &errMsg)==SQLITE_OK){
            result = YES;
        }else{
            NSString* es = [NSString stringWithUTF8String:errMsg];
            NSLog(@"Failed to insert Contact, error=%@", es);
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
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM Defence WHERE ACTIVEUSER = \"%@\" AND CONTACTID = \"%@\"",loginResult.contactId,contactId];
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
-(BOOL)deleteContent:(NSString *)contactId group:(int)group item:(int)item text:(NSString *)text
{
    if (![UDManager isLogin]) {
        return NO;
    }
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    char *errMsg;
    BOOL result = NO;
    if ([self openDB]) {
        NSString *SQL = [NSString stringWithFormat:@"delete form Defence where activeUser = \"%@\" AND contactId =\"%@\" AND defencearea= \"%d\" AND item = \"%d\" AND name = \"%@\"",loginResult.contactId, contactId, group, item, text];
        if (sqlite3_exec(self.db, [SQL UTF8String], NULL, NULL, &errMsg)) {
            result = YES;
        }else{
            NSString *es = [NSString stringWithUTF8String:errMsg];
            NSLog(@"Failed to delete Contact, error=%@", es);
            sqlite3_free(errMsg);
            result = NO;
            
        }
        [self closeDB];
    }
    return result;
    
    
    
}
-(NSString*)getItemName:(NSString *)contactId group:(int)group item:(int)item
{
    if(![UDManager isLogin]){
        return nil;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString* name = nil;
    sqlite3_stmt *statement;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"SELECT name FROM Defence WHERE ACTIVEUSER = \"%@\" AND CONTACTID = \"%@\" AND defencearea = \"%d\" AND item = \"%d\"",loginResult.contactId,contactId,group,item];
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)==SQLITE_OK){
            while(sqlite3_step(statement)==SQLITE_ROW){
                name = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
            }
        }else{
            NSLog(@"Failed to find Contact:%s",sqlite3_errmsg(self.db));
        }
        
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return name;
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
-(BOOL)update:(NSString*)contactId group:(int)group item:(int)item text:(NSString*)text
{
    if(![UDManager isLogin]){
        return NO;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    sqlite3_stmt *statement;
    BOOL result = YES;
    if([self openDB]){
        NSString *SQL = [NSString stringWithFormat:@"UPDATE Defence SET name = \"%@\" WHERE activeUser = \"%@\" AND contactId = \"%@\" AND defencearea = \"%d\" AND item = \"%d\"",text,loginResult.contactId,contactId,group,item];
        if(sqlite3_prepare_v2(self.db, [SQL UTF8String], -1, &statement, NULL)!=SQLITE_OK){
            NSLog(@"Failed to update Contact:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        
        if(sqlite3_step(statement)!=SQLITE_DONE){
            NSLog(@"Failed to update Contact:%s",sqlite3_errmsg(self.db));
            result = NO;
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        [self closeDB];
    }
    
    return result;
}


@end
