//
//  QRCodeSetWIFIController.h
//  Yoosee
//
//  Created by gwelltime on 15-3-12.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
//二维码配置Wi-Fi第一个界面
#import <UIKit/UIKit.h>

@interface QRCodeSetWIFIController : UIViewController
@property (nonatomic,strong) UITextField *ssidField;
@property (nonatomic,strong) UITextField *pwdField;
@property (nonatomic,strong) UIImageView *qrcodeImage;
@end
