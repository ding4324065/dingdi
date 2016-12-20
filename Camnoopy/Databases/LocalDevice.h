

#import <Foundation/Foundation.h>
#pragma mark - 本地设备
@interface LocalDevice : NSObject
@property (strong, nonatomic) NSString *contactId;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger contactType;
@property (strong, nonatomic) NSString *address;
@property (nonatomic) double lanTimeInterval;//检查超时
@property (nonatomic) NSInteger isSupportRtsp;
@end
