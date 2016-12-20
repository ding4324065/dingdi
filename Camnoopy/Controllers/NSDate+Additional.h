//
//  NSDate+Additional.h
//  MysOpen
//
//  Created by  on 12-6-11.
//  Copyright (c) 2012年 raysharp. All rights reserved.
//

//#import <Foundation/Foundation.h>

@interface NSDate(MysCustomer)

+ (NSInteger)maxDayOfMonth:(NSInteger)month inYear:(NSInteger)year;

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)format;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSDateComponents *)dateComponents;
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)hour;
- (NSInteger)minute;
- (NSInteger)second;
- (NSUInteger)dayOfWeek;

@end
