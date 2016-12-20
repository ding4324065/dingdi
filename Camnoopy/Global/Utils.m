
#import "Utils.h"
#import "ContactDAO.h"
#import "LocalDevice.h"
#import "MD5Manager.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "Constants.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>
#include <net/if.h>
#import <netinet/in.h>
#import <CommonCrypto/CommonCrypto.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Contact.h"
#import <CommonCrypto/CommonCrypto.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation Utils
+(UILabel*)getTopBarTitleView{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    return label;
}

+(NSDateComponents*)getNowDateComponents{
    NSDate *now = [NSDate date];
//创建或初始化
    NSCalendar *calendar = [NSCalendar currentCalendar];
//    通过已定义的日历对象，获取某个时间点的NSDateComponents表示，并设置需要表示哪些信息
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    return dateComponent;
}

+(NSDateComponents*)getDateComponentsByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    return dateComponent;
}

+(long)getCurrentTimeInterval{
//    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
//   
//    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
//    NSDate *localDate = [[NSDate date] dateByAddingTimeInterval:interval];
    long timeInterval = [[NSDate date] timeIntervalSince1970];
    return timeInterval;
}

+(NSString*)getDeviceTimeByIntValue:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute{
    NSString *monStr = nil;
    NSString *dayStr = nil;
    NSString *hourStr = nil;
    NSString *minStr = nil;
    if(month>=10){
        monStr = [NSString stringWithFormat:@"%i",month];
    }else{
        monStr = [NSString stringWithFormat:@"0%i",month];
    }
    
    if(day>=10){
        dayStr = [NSString stringWithFormat:@"%i",day];
    }else{
        dayStr = [NSString stringWithFormat:@"0%i",day];
    }
    
    if(hour>=10){
        hourStr = [NSString stringWithFormat:@"%i",hour];
    }else{
        hourStr = [NSString stringWithFormat:@"0%i",hour];
    }
    
    if(minute>=10){
        minStr = [NSString stringWithFormat:@"%i",minute];
    }else{
        minStr = [NSString stringWithFormat:@"0%i",minute];
    }
    return [NSString stringWithFormat:@"%i-%@-%@ %@:%@",year,monStr,dayStr,hourStr,minStr];
}

+(NSString*)getPlanTimeByIntValue:(NSInteger)planTime{
    NSInteger minute_to = planTime&0xff;
    NSInteger minute_from = (planTime>>8)&0xff;
    NSInteger hour_to = (planTime>>16)&0xff;
    NSInteger hour_from = (planTime>>24)&0xff;
    
    NSString *minute_to_str = @"00";
    NSString *minute_from_str = @"00";
    NSString *hour_to_str = @"00";
    NSString *hour_from_str = @"00";
    
    if(minute_to<10){
        minute_to_str = [NSString stringWithFormat:@"0%i",minute_to];
    }else{
        minute_to_str = [NSString stringWithFormat:@"%i",minute_to];
    }
    
    if(minute_from<10){
        minute_from_str = [NSString stringWithFormat:@"0%i",minute_from];
    }else{
        minute_from_str = [NSString stringWithFormat:@"%i",minute_from];
    }
    
    if(hour_to<10){
        hour_to_str = [NSString stringWithFormat:@"0%i",hour_to];
    }else{
        hour_to_str = [NSString stringWithFormat:@"%i",hour_to];
    }
    
    if(hour_from<10){
        hour_from_str = [NSString stringWithFormat:@"0%i",hour_from];
    }else{
        hour_from_str = [NSString stringWithFormat:@"%i",hour_from];
    }
    
    return [NSString stringWithFormat:@"%@:%@-%@:%@",hour_from_str,minute_from_str,hour_to_str,minute_to_str];
}

+(CGFloat)getStringWidthWithString:(NSString *)string font:(UIFont*)font maxWidth:(CGFloat)maxWidth{
    CGSize sizeToFit = [string sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return sizeToFit.width;
}

+(CGFloat)getStringHeightWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth{
    CGSize sizeToFit = [string sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return sizeToFit.height;
}
+(NSString*)getPlaybackTime:(UInt64)time{
    UInt64 hh = time/3600;
    UInt64 mm = (time/60)%60;
    UInt64 ss = time%60;
    
    NSString *hhStr = @"00";
    NSString *mmStr = @"00";
    NSString *ssStr = @"00";
    
    if(hh<10){
        hhStr = [NSString stringWithFormat:@"0%llu",hh];
    }else{
        hhStr = [NSString stringWithFormat:@"%llu",hh];
    }
    
    if(mm<10){
        mmStr = [NSString stringWithFormat:@"0%llu",mm];
    }else{
        mmStr = [NSString stringWithFormat:@"%llu",mm];
    }
    
    if(ss<10){
        ssStr = [NSString stringWithFormat:@"0%llu",ss];
    }else{
        ssStr = [NSString stringWithFormat:@"%llu",ss];
    }
    
    return [NSString stringWithFormat:@"%@:%@:%@",hhStr,mmStr,ssStr];
}


+(NSDate*)dateFromString:(NSString *)dateString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *destDate = [formatter dateFromString:dateString];
    return destDate;
}

+(NSDate*)dateFromString2:(NSString *)dateString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *destDate = [formatter dateFromString:dateString];
    return destDate;
}

+(NSString*)stringFromDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *destString = [formatter stringFromDate:date];
    return destString;
}

+(NSString*)stringFromDate2:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *destString = [formatter stringFromDate:date];
    return destString;
}

+(NSString*)convertTimeByInterval:(NSString*)timeInterval{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setTimeZone:[NSTimeZone defaultTimeZone]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval.intValue];

    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [format stringFromDate:date];
    [format release];
    return time;
}

+(NSArray*)getScreenShotFilesWithContactId:(NSString*)contactId
{
    NSMutableArray *imgFiles = [NSMutableArray arrayWithCapacity:0];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *shotPath = [NSString stringWithFormat:@"%@/screenshot/%@",rootPath,loginResult.contactId];
    
    NSString* searchPath = shotPath;
    if (contactId != nil) {
        searchPath = [NSString stringWithFormat:@"%@/%@", shotPath, contactId];
    }
    
    NSArray *files = [manager subpathsAtPath:searchPath];
    for(NSString *str in files)
    {
        if([str hasSuffix:@".png"])
        {
            [imgFiles addObject:str];
        }
    }
    return imgFiles;
}



+(void)saveScreenshotFileWithUserId:(NSString*)userId contactId:(NSString*)contactId data:(NSData*)data{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    long timeInterval = [Utils getCurrentTimeInterval];
    NSString *savePath = [NSString stringWithFormat:@"%@/screenshot/%@/%@",rootPath,userId,contactId];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:savePath]){
        [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [data writeToFile:[NSString stringWithFormat:@"%@/%ld.png",savePath,timeInterval] atomically:YES];
}


+(NSString*)getScreenshotFilePathWithName:(NSString *)fileName contactId:(NSString*)contactId{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *filePath;
    if (contactId == nil)
    {
        filePath = [NSString stringWithFormat:@"%@/screenshot/%@/%@",rootPath,loginResult.contactId,fileName];
    }
    else
    {
        filePath = [NSString stringWithFormat:@"%@/screenshot/%@/%@/%@",rootPath,loginResult.contactId,contactId,fileName];
    }
    return filePath;
}


+(NSString*)getHeaderFilePathWithId:(NSString *)contactId{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *filePath = [NSString stringWithFormat:@"%@/screenshot/tempHead/%@/%@.png",rootPath,loginResult.contactId,contactId];
    return filePath;
}

+(void)saveHeaderFileWithId:(NSString*)contactId data:(NSData*)data{
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
//    long timeInterval = [Utils getCurrentTimeInterval];
    NSString *savePath = [NSString stringWithFormat:@"%@/screenshot/tempHead/%@",rootPath,loginResult.contactId];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:savePath]){
        [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    DLog(@"savePath:%@",savePath);
    [data writeToFile:[NSString stringWithFormat:@"%@/%@.png",savePath,contactId] atomically:YES];
}

+(void)playMusicWithName:(NSString *)name type:(NSString *)type{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)([NSURL fileURLWithPath:soundPath]), &sound);
    AudioServicesPlaySystemSound(sound);
    //AudioServicesDisposeSystemSoundID(sound);
}

+(NSMutableArray*)getRecordFilesWithContactId:(NSString*)contactId
{
    NSMutableArray *recordFiles = [NSMutableArray arrayWithCapacity:0];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *recordPath = [NSString stringWithFormat:@"%@/record/%@",rootPath,loginResult.contactId];
    
    NSString* searchPath = recordPath;
    if (contactId != nil) {
        searchPath = [NSString stringWithFormat:@"%@/%@", recordPath, contactId];
    }
    
    NSArray *files = [manager subpathsAtPath:searchPath];
    for(NSString *str in files)
    {
        if([str hasSuffix:@".mp4"])
        {
            [recordFiles addObject:str];
        }
    }
    return recordFiles;
}


#pragma mark - 异或加密
+(void)vEncVal:(BYTE *)pbBuf size:(DWORD)dwSize
{
    if(pbBuf == NULL)return;
    int i = 0;
    for(;i < dwSize;++i)
    {
        if(i == dwSize - 1)
        {
            pbBuf[i] ^= pbBuf[0];
        }
        else
        {
            pbBuf[i] ^= pbBuf[i+1];
        }
        
    }
}

+(NSString*)getAlarmtextByType:(long)iAlarmType
{
    NSMutableArray *arrayText = [NSMutableArray arrayWithCapacity:0];
    [arrayText addObject:@""];
    [arrayText addObject:NSLocalizedString(@"extern_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"motion_dect_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"emergency_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"debug_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"ext_line_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"low_vol_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"pir_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"defence_enable_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"defence_disable_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"battery_low_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"parameters_upload_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"temperature_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"somebody_visit", nil)];
    [arrayText addObject:NSLocalizedString(@"keypress_alarm", nil)];
    [arrayText addObject:NSLocalizedString(@"record_failed_alarm", nil)];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:@""];
    [arrayText addObject:NSLocalizedString(@"sound_alarm", nil)];

    NSString* text = [arrayText objectAtIndex:iAlarmType];
    return text;
}

+(NSString*)defaultDefenceName:(int)group
{
    NSArray* nameArray = [NSArray arrayWithObjects:
                          NSLocalizedString(@"remote", nil),
                          NSLocalizedString(@"hall", nil),
                          NSLocalizedString(@"window", nil),
                          NSLocalizedString(@"balcony", nil),
                          NSLocalizedString(@"bedroom", nil),
                          NSLocalizedString(@"kitchen", nil),
                          NSLocalizedString(@"courtyard", nil),
                          NSLocalizedString(@"door_lock", nil),
                          NSLocalizedString(@"other", nil), nil];
    return [nameArray objectAtIndex:group];
}

+(NSMutableArray*)getCaptureInfoFromPath:(NSString*)path
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:2];
    NSRange range1 = [path rangeOfString:@"/"];
    NSRange range2 = [path rangeOfString:@"."];
    
    NSString* contactId = [path substringWithRange:NSMakeRange(0,range1.location)];
    NSString* date = [path substringWithRange:NSMakeRange(range1.location+1,range2.location-range1.location-1)];
    NSString* dateText = [Utils convertTimeByInterval:date];
    
    [array addObject:contactId];
    [array addObject: dateText];
    return array;
}

+(NSString*)getRecordPathWithContactId:(NSString*)contactId {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    long timeInterval = [Utils getCurrentTimeInterval];
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *dirName = [NSString stringWithFormat:@"%@/record/%@/%@",rootPath, loginResult.contactId, contactId];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirName isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *savePath = [NSString stringWithFormat:@"%@/%ld.mp4",dirName, timeInterval];
    return savePath;
}

+(NSString*)getRecordInfoFromName:(NSString*)name
{
    NSRange range = [name rangeOfString:@"."];
    NSString* dataInfo = [name substringWithRange:NSMakeRange(0, range.location)];
    NSString* dateText = [Utils convertTimeByInterval:dataInfo];
    return dateText;
}

+(BOOL)IsGetPhotoAlbumAuthorization
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    NSLog(@"authStatus = %d", (int)authStatus);
    return (authStatus == ALAuthorizationStatusAuthorized);
}

+(int)pwdStrengthWithPwd:(NSString *)sPassword{
    if ([sPassword length] == 0) {
        return password_null;
    }
    if ([sPassword length] <6) {
        return password_weak;
    }
    
    const char* szBuffer = [sPassword UTF8String];
    BOOL isIncludeNumber = NO;
    BOOL isIncludeLowerLetter = NO;
    BOOL isIncludeUpperLetter = NO;
    BOOL isIncludeOther = NO;
    for (int i=0; i<strlen(szBuffer); i++) {
        char ch = szBuffer[i];
        if (ch >= '0' && ch <= '9') {
            isIncludeNumber = YES;
        }
        else if (ch >= 'a' && ch <= 'z') {
            isIncludeLowerLetter = YES;
        }
        else if (ch >= 'A' && ch <= 'Z')
        {
            isIncludeUpperLetter = YES;
        }
        else
        {
            isIncludeOther = YES;
        }
    }
    
    //如果没有数字或者字母，返回弱密码
    if (!isIncludeNumber || !(isIncludeUpperLetter || isIncludeLowerLetter)) {
        return password_weak;
    }
    
    //2种是弱密码，3种及以上是强密码
    int dwCountCase = 0;
    if (isIncludeNumber) {
        dwCountCase ++;
    }
    if (isIncludeLowerLetter) {
        dwCountCase ++;
    }
    if (isIncludeUpperLetter) {
        dwCountCase ++;
    }
    if (isIncludeOther) {
        dwCountCase ++;
    }
    if (dwCountCase == 2) {
        return password_middle;
    }
    return password_strong;
}

+(BOOL)IsNeedEncrypt:(NSString *)sPassword
{
    if ([sPassword length] == 0)
    {
        return NO;
    }
    
    BOOL isPureNumber = YES;
    const char* szBuffer = [sPassword UTF8String];
    for (int i=0; i<strlen(szBuffer); i++) {
        char ch = szBuffer[i];
        if (ch < '0' || ch > '9') {
            isPureNumber = NO;
            break;
        }
    }
    
    if (!isPureNumber) {
        return YES;
    }
    else
    {
        if ([sPassword length] >= 10) {
            return YES;
        }
    }
    
    return NO;
}

+(NSString*)GetTreatedPassword:(NSString*)sPassword
{
    BOOL isNeedEncrypt = [Utils IsNeedEncrypt:sPassword];
    if (isNeedEncrypt) {
        unsigned int ret = [MD5Manager GetTreatedPassword:[sPassword UTF8String]];
        sPassword = [NSString stringWithFormat:@"0%d", ret];
    }
    if (sPassword.intValue == 0) {
        sPassword = @"294136";
    }
    return sPassword;
}

+(NSMutableArray*)getNewDevicesFromLan:(NSArray*)lanDevicesArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    
    
    for (int i=0; i<[lanDevicesArray count]; i++) {
        LocalDevice *localDevice = [lanDevicesArray objectAtIndex:i];
        
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:localDevice.contactId];
        [contactDAO release];
        if(nil==contact){
            [array addObject:localDevice];
        }
    }
    
    return array;
}


//2.WIFI流量统计功能
+( NSInteger)getInterfaceBytesstring :(NSInteger)ss
{
    return bytesToAvaiUnit(ss);
}


+(long long int)getInterfaceBytes {
    
    struct ifaddrs *ifa_list = 0, *ifa;
    
    if (getifaddrs(&ifa_list) == -1) {
        
        return 0;
        
    }
    
    uint32_t iBytes = 0;
    
    uint32_t oBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        
        if (AF_LINK != ifa->ifa_addr->sa_family)
            
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            
            continue;
        
        if (ifa->ifa_data == 0)
            
            continue;
        
        /* Not a loopback device. */
        
        if (strncmp(ifa->ifa_name, "lo", 2))
            
        {
            
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            
            oBytes += if_data->ifi_obytes;
            
            //            NSLog(@"%s :iBytes is %d, oBytes is %d",
            
            //                  ifa->ifa_name, iBytes, oBytes);
            
        }
        
    }
    
    freeifaddrs(ifa_list);
    
    return iBytes+oBytes;
    
}

//以上获取的数据可以通过以下方式进行单位转换

NSString *bytesToAvaiUnit(int bytes) {
    
    if(bytes < 1024)  // B
    {
        
        return [NSString stringWithFormat:@"%dB", bytes];
        
    }
    
    else if(bytes >= 1024 && bytes < 1024 * 1024) // KB
    {
        
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
        
    }
    
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) // MB
    {
        
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
        
    }else  // GB
    {
        
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
        
    }
}

@end

@implementation NSString (Utils)

- (NSString *)getMd5_32Bit_String{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return [result lowercaseString];
}


- (BOOL) isValidateNumber{
    const char *cvalue = [self UTF8String];
    int len = strlen(cvalue);
    for (int i = 0; i < len; i++) {
        if (!(cvalue[i] >= '0' && cvalue[i] <= '9')) {
            return FALSE;
        }
    }
    return TRUE;
}

#pragma mark - 16进制字符串转为10进制
-(BYTE)charToInt{
    int a,b;
    for (int i=0; i < self.length; i++) {
        char ch = [self characterAtIndex:i];
        int tem;
        if (ch>='0' && ch<='9') tem=ch-'0';
        else if(ch>='a' && ch<='f')tem=ch-'a'+10;
        else if(ch>='A' && ch<='F') tem=ch-'A'+10;
        
        if (i==0) {
            a = tem;
        }else{
            b = tem;
        }
    }
    BYTE result = (BYTE)(a*16 + b);
    return result;
}




@end

