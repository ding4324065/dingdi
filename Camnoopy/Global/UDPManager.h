//
//  UDPManager.h
//  Camnoopy
//
//  Created by wutong on 15-1-13.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalDevice.h"

@protocol UDPScanDelegate <NSObject>
-(void)onFoundLanDevice:(LocalDevice *)localDevice;
@end

@protocol UDPGetWifiListdelegate <NSObject>
@optional
- (void)receiveWifiList:(NSDictionary *)dictionary;
@end

@protocol UDPSetWifidelegate <NSObject>
@optional
- (void)setWifiSuccess;
@end

typedef  int32_t  SWL_socket_t;
#define  SWL_INVALID_SOCKET   -1
#define MAX_COMMAND_SIZE    1024

@interface UDPManager : NSObject
{
    SWL_socket_t _socketSender;
    SWL_socket_t _socketRecevier;
    int _localPort;
    BOOL _isReceving;
     BOOL _isConditionOK;
}

//局域网搜索
@property (retain, nonatomic) NSMutableDictionary *LanlDevices;
@property (assign) id<UDPScanDelegate> delegateUDPScan;
//设置wifi
@property (retain,nonatomic) NSMutableDictionary * WifiListDevices;
@property (assign) id<UDPGetWifiListdelegate>getwifidelegate;
@property (assign) id<UDPSetWifidelegate>setwifidelegate;
@property (assign)BOOL issetwifisuccess;
@property (assign)BOOL isgetwifilist;

+ (id)sharedDefault;
//局域网搜索
- (void)ScanLanDevice;
- (NSArray*)getLanDevices;
//wifi设置
- (void)GetWifiList;
- (void)SetWifiInfo:(NSInteger)enctype andssid:(NSString *)ssid andpassword:(NSString *)password;
- (void)quitWifiSet;
@end
