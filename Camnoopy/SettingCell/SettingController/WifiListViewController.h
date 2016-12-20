//
//  WifiListViewController.h
//  Camnoopy
//
//  Created by 高琦 on 15/1/30.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
#define ALERT_TAG_CHANGE_WIFI 2
#define ALERT_TAG_INPUT_WIFI_PASSWORD 3
#import <UIKit/UIKit.h>
#import "UDPManager.h"
#import "DeviceWiFi.h"
@class GCDAsyncUdpSocket;
@class Contact;
@class  MBProgressHUD;
@protocol devicewifidelegate <NSObject>

@optional
-(void)setdevicewifisecuss:(DeviceWiFi *)nowwifi;
@end

@interface WifiListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UDPGetWifiListdelegate,UIAlertViewDelegate,UDPSetWifidelegate>
@property (strong,nonatomic) id<devicewifidelegate>delegate;
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;
@property (assign) NSInteger selectedIndex;
@property(assign) BOOL isLoadingWifiList;
@property(assign) NSInteger wifilistcount;

@property (assign) NSInteger currentWifiIndex;
@property (assign) NSInteger wifiCount;

@property (assign) NSInteger nowcontactwifi;
@property (strong,nonatomic) NSMutableArray *names;
@property (strong,nonatomic) NSMutableArray *types;
@property (strong,nonatomic) NSMutableArray *strengths;

@property (strong,nonatomic) NSMutableArray * wifilist;
@property (strong,nonatomic) NSMutableArray * lastwifilist;
@property (assign) NSInteger selectWifiIndex;
@property (retain,nonatomic) NSString *lastSetWifiPassword;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (assign,nonatomic) BOOL isgivenwifi;
@property (strong,nonatomic)NSMutableArray * givenwifi;
@property (strong,nonatomic)NSMutableArray * givenlastwifi;
//socket
@property (retain, nonatomic) NSMutableDictionary *sotypes;
@property (retain, nonatomic) NSMutableDictionary *flags;
@property (retain, nonatomic) NSMutableDictionary *addresses;
@end
