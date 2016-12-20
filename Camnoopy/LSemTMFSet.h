//
//  lark7618.h
//  lark7618
//
//  Created by TTS on 15/10/9.
//  Copyright © 2015年 TTS. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "GCDAsyncSocket.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "sys/utsname.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <objc/runtime.h>
static  int INITSDK_ERRCOE_ENABLE =0x01;//能正常使用SDK
static  int INITSDK_ERRCOE_OVERLOAD=0xA0;//认证设备数量超限
static  int INITSDK_ERRCOE_UNENABLE=0xA1;//授权验证不通过
static  int INITSDK_INVAILDDATA=-3;//初始化传入了非法的参数
static  int INITSDK_ERRCOE_WIFIDISABLE=-2;//WIFI不可用
static  int INITSDK_ERRCOE_NOINIT=-1;//没有初始化SDK
static  int  HTTP_CODE_ERRTOTALDEVICE=50008;	     //认证设备数量超限
static  int  INITSDK_OVERDUE=50009;	     //超过使用期限

static  int  INITSDK_LICENSE_FORBIDDEN=50006;	     //禁止license
/* 配置结果的数据类型 */
typedef NS_ENUM(NSInteger,EMTMFErrcodeType){
    EMTMFErrcodeType_SUCESS = 0x01,//配置成功
    EMTMFErrcodeType_FAILED = 0x02//配置失败
} ;

@protocol LSemTMFSetDelegate <NSObject>

@optional
/**
 * 功能：获取配置是否成功的错误码
 */
- (void)didSetWifiResultErrcode:(EMTMFErrcodeType*)errcode content:(NSString*)content;
/**
 * 功能：emTMF发送完成后会调用该函数
 */
- (void)didFSKSendingComplete;
/**
 *功能：SDK不能正常使用的错误吗和原因
 */
-(void)didSDKErrcode:(int) errCode errMsg:(NSString*)errMsg;

@end


@interface LSemTMFSet : NSObject
@property (nonatomic, retain, nonnull) id<LSemTMFSetDelegate> delegate;

/** 获取单例 */
+ (nullable instancetype)sharedInstance;

/**
 将SSID和密码以声波的方式发送出去
 @param ssid WI-FI网络名
 @param password Wi-Fi网络的密码
 @note ssid长度不可为0，password的长度可以为0
 */
- (void)sendWiFiSet:(nonnull NSString *)SSID password:(nonnull NSString *)psw;
/**
 得到播放的时长
 @param ssid WI-FI网络名
 @param password Wi-Fi网络的密码
 @note ssid长度不可为0，password的长度可以为0
 */
-(int)getPlayTime:(nonnull NSString *)SSID password:(nonnull NSString *)psw;
/**
 得到当前初始化SDK的错误码
 */
-(int)getCurInitSDKCode;
/**
 停止发送FSK声波
 */
- (void)stopSend;
/**
 在听到设备发出“接收成功”的提示后调用此方法，对设备进行连接超时限制
 */
-(void)startConnectTimeOutListener:(long)waittime;
/**
 取消掉联网失败的计时器
 */
-(void)cancleConnectTimer;
/**
 退出EMTMF配置做的操作
 */
-(void)exitEMTMFSDK;

/**
 初始化SDK
 manufactrurer  产品信息
 client         客户信息
 productModel   产品型号
 license        License信息
 */
-(int)initSDK:(nonnull NSString*)manufactrurer client:(nonnull NSString*)client productModel:(nonnull NSString*)productModel license:(nonnull NSString*)license;
@end



