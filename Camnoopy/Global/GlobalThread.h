

#import <Foundation/Foundation.h>

@interface GlobalThread : NSObject
//是否运行
@property (nonatomic) BOOL isRun;
//是否暂停
@property (nonatomic) BOOL isPause;
+(GlobalThread *)sharedThread:(BOOL)isRelease;
-(void)kill;
-(void)start;
@end
