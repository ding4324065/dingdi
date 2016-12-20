

#import <Foundation/Foundation.h>

@interface YAudioStreamPlayer : NSObject
@property (nonatomic) BOOL isPlay;
+ (YAudioStreamPlayer *)sharedDefault;
-(BOOL)start;
-(void)stop;
-(void)playCmd:(NSInteger)cmd;
-(void)playWIFI:(NSString*)ssid wifiPassword:(NSString*)wifiPassword devicePassword:(NSString*)devicePassword;
@end
