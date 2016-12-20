//
//  DeviceWiFi.h
//  Camnoopy
//
//  Created by 高琦 on 15/2/2.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
#pragma mark - 无线设备
#import <Foundation/Foundation.h>

@interface DeviceWiFi : NSObject
@property (nonatomic,copy)NSString * wifiname;
@property (nonatomic,assign)NSInteger  encryptType;
@property (nonatomic,assign)NSInteger sigLevel;
@end
