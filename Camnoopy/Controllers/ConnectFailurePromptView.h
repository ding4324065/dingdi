//
//  ConnectFailurePromptView.h
//  Camnoopy
//
//  Created by gwelltime on 15-3-13.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
//智能添加设备不成功界面
#import <UIKit/UIKit.h>

@protocol ConnectFailurePromptViewDelegate <NSObject>
@required
-(void)connectOnceAgainButtonClick;
-(void)connectFailurePromptViewSetWifiToAddDeviceByQR;//set wifi to add device by qr

@end

@interface ConnectFailurePromptView : UIView
@property(nonatomic, assign) id<ConnectFailurePromptViewDelegate> delegate;

@end
