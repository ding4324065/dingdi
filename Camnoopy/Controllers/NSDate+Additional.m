//
//  NSDate+Additional.m
//  MysOpen
//
//  Created by  on 12-6-11.
//  Copyright (c) 2012年 raysharp. All rights reserved.
//

#import "NSDate+Additional.h"

@implementation NSDate(MysCustomer)

+ (NSInteger)maxDayOfMonth:(NSInteger)month inYear:(NSInteger)year
{
#if __x86_64__
    NSDate *date = [NSDate dateFromString:[NSString stringWithFormat:@"%04ld-%02ld-%02d", year, month, 1]  withFormat:@"yyyy-MM-dd"];
#else
    NSDate *date = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-%02d-%02d", year, month, 1]  withFormat:@"yyyy-MM-dd"];
#endif
    
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return range.length;
}

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)format
{
    //yyyy-MM-dd HH:mm:ss
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:dateString];
#if !__has_feature(objc_arc)
    [formatter release];
#endif
    
    
    return date;
}

- (NSString *)stringWithFormat:(NSString *)format
{
#if !__has_feature(objc_arc)
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
#else
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
#endif
    //[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

- (NSDateComponents *)dateComponents
{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
    //[formatter release];
#if !__has_feature(objc_arc)
    [calendar release];
#endif
    return comps;
}

- (NSInteger)year
{
    return [self dateComponents].year;
}

- (NSInteger)month
{
    return [self dateComponents].month;
}

- (NSInteger)day
{
    return [self dateComponents].day;
}

- (NSInteger)hour
{
    return [self dateComponents].hour;
}

- (NSInteger)minute
{
    return [self dateComponents].minute;
}

- (NSInteger)second
{
    return [self dateComponents].second;
}

- (NSUInteger)dayOfWeek
{
    return [self dateComponents].weekday;
}
@end
