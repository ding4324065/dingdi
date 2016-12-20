

#import <Foundation/Foundation.h>

#define  DWORD        unsigned int
#define  BYTE         unsigned char

enum
{
    password_weak,
    password_middle,
    password_strong,
    password_null
};

@interface Utils:NSObject
+(UILabel*)getTopBarTitleView;
+(long)getCurrentTimeInterval;
+(NSString*)convertTimeByInterval:(NSString*)timeInterval;
+(NSArray*)getScreenShotFilesWithUserId:(NSString*)userId contactId:(NSString*)contactId;//没有
+(NSArray*)getScreenShotFilesWithContactId:(NSString*)contactId;
+(NSString*)getScreenshotFilePathWithName:(NSString *)fileName contactId:(NSString*)contactId;

+(void)saveScreenshotFileWithUserId:(NSString*)userId contactId:(NSString*)contactId data:(NSData*)data;
+(NSString*)getScreenshotFilePathWithName:(NSString *)fileName userId:(NSString*)userId contactId:(NSString*)contactId;//没有

+(void)saveHeaderFileWithId:(NSString*)contactId data:(NSData*)data;
+(NSString*)getHeaderFilePathWithId:(NSString*)contactId;

+(NSDateComponents*)getNowDateComponents;
+(NSDateComponents*)getDateComponentsByDate:(NSDate*)date;
+(NSString*)getPlaybackTime:(UInt64)time;
+(NSDate*)dateFromString:(NSString*)dateString;
+(NSDate*)dateFromString2:(NSString*)dateString;
+(NSString*)stringFromDate:(NSDate*)date;
+(NSString*)stringFromDate2:(NSDate*)date;

+(long long int)getInterfaceBytes;
+(NSString*)getDeviceTimeByIntValue:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;

+(NSString*)getPlanTimeByIntValue:(NSInteger)planTime;

+(CGFloat)getStringWidthWithString:(NSString*)string font:(UIFont*)font maxWidth:(CGFloat)maxWidth;
+(CGFloat)getStringHeightWithString:(NSString*)string font:(UIFont*)font maxWidth:(CGFloat)maxWidth;

+(void)playMusicWithName:(NSString*)name type:(NSString*)type;

+(void)vEncVal:(BYTE *)pbBuf size:(DWORD)dwSize;

+(NSString*)getAlarmtextByType:(long)iAlarmType;
+(NSString*)defaultDefenceName:(int)group;
+(NSMutableArray*)getCaptureInfoFromPath:(NSString*)path;
+(NSMutableArray*)getRecordFilesWithContactId:(NSString*)contactId;
+(BOOL)IsNeedEncrypt:(NSString *)sPassword;
+(NSString*)getRecordInfoFromName:(NSString*)name;
+(NSString*)getRecordPathWithContactId:(NSString*)contactId;

+(BOOL)IsGetPhotoAlbumAuthorization;

+(int)pwdStrengthWithPwd:(NSString *)sPassword;

+(NSString*)GetTreatedPassword:(NSString*)sPassword;

+(NSMutableArray*)getNewDevicesFromLan:(NSArray*)lanDevicesArray;

+( NSInteger)getInterfaceBytesstring :(NSInteger)ss;
+(long long int)getInterfaceBytes;

@end

@interface NSString(Utils)


- (NSString *)getMd5_32Bit_String;
- (BOOL) isValidateNumber;

-(BYTE)charToInt;

@end
