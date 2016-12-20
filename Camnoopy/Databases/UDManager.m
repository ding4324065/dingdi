//
//  UDManager.m
//  Camnoopy
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "UDManager.h"
#import "LoginResult.h"
@implementation UDManager


//存
+(void)setIsLogin:(BOOL)isLogin{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    [manager setBool:isLogin forKey:kIsLogin];
    [manager synchronize];
}

//取
+(BOOL)isLogin{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    return [manager boolForKey:kIsLogin];
}

+(void)setLoginInfo:(LoginResult *)loginResult{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSArray *array = [[NSArray alloc] initWithObjects:loginResult,nil];
    
    [manager setObject:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:kLoginInfo];
    [manager synchronize];
    [array release];
}

+(LoginResult*)getLoginInfo{
    LoginResult *result = nil;
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSData *data = [manager objectForKey:kLoginInfo];
    if(data!=nil){
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        result = [array objectAtIndex:0];
    }
    return result;
}



+(void)setEmail:(NSString*)email{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        [manager setValue:email forKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kEmail]];
        [manager synchronize];
    }
}


+(NSString*)getEmail{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        return [manager stringForKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kEmail]];
    }else{
        return nil;
    }
    
}



+(void)setPhone:(NSString*)phone{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        [manager setValue:phone forKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kPhone]];
        [manager synchronize];
    }
}


+(NSString*)getPhone{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        return [manager stringForKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kPhone]];
    }else{
        return nil;
    }
    
}


@end
