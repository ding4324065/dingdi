

#import <Foundation/Foundation.h>
#pragma mark - 得到联系消息结果
@interface GetContactMessageResult : NSObject
@property (nonatomic) BOOL hasNext;
@property (nonatomic) int error_code;
@property (nonatomic, strong) NSString *contactId;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *time;
@property (nonatomic) NSInteger flag;
@end
