//
//  AlarmPushController.h
//  Camnoopy
//
//  Created by 高琦 on 15/3/12.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//


//报警显示动画界面
#import <UIKit/UIKit.h>

#import "sqlite3.h"
@interface AlarmPushController : UIViewController<UIAlertViewDelegate>
@property (assign,nonatomic) int  alarmtype;
@property (strong,nonatomic) UIImageView * touchbtnview;
@property (strong,nonatomic) UIImageView * downlineview;
@property (strong,nonatomic) UIImageView * acceptview;
@property (strong,nonatomic) UIImageView * rejectview;
@property (assign)BOOL isshow;
@property (assign)BOOL iscanmove;
@property (assign)BOOL isbreathe;
@property (assign,nonatomic)CGRect touchbtnframe;
@property (assign,nonatomic)CGRect touchlineframe;
@property (assign,nonatomic)CGFloat trans;
@property (strong,nonatomic)NSTimer * timer;
@property(copy,nonatomic)NSString * contactId;
@property(copy,nonatomic)NSString *contactPassWord;
//这两个变量跟门磁报警（外部报警）相关
@property (assign)NSInteger group;
@property (assign)NSInteger item;
@property (nonatomic) NSInteger index;

@property (nonatomic, strong)NSString *musicName;
@end
