//
//  DefenceDoorMagneticController.h
//  2cu
//
//  Created by 高琦 on 15/2/9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefenceCell.h"
#import "DefenceMagneticCell.h"
#define ALERT_TAG_CLEAR 0
#define ALERT_TAG_LEARN 1
@class TopBar;
@class Contact;
@class  MBProgressHUD;
@class RadioButton;

@interface DefenceDoorMagneticController: UIViewController
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;

@property(assign) int dwCurGroup;
@property(strong,nonatomic) NSMutableArray *defenceStatusData;
@property(strong,nonatomic) NSMutableArray *switchStatusData;

@property(strong,nonatomic)UIView * inputView;              //小背景视图
@property (strong,nonatomic)UIView * inputalphaView;        //大背景视图
@property(strong,nonatomic)UITextField * namechangeView;    //text edit
@property(strong,nonatomic)UILabel * titleLable;            //title lable

@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property(assign) BOOL isSetting;
@property(strong,nonatomic)TopBar * mytopbar;

@property(assign) int dwCurItem;                //正在操作第几行
@property(assign) int dwlastOperation;          //正在执行的操作
@property(assign) int dwOrignialValue;          //操作之前的值，用于操作失败时还原控件状态

@property (nonatomic,strong) NSMutableArray *namearray;
@property(assign) int dwItemModify;             //记录当前修改名称的channel

@property(assign) int index;
@property(assign) int alralType;

@property(assign) BOOL isLoadDefenceArea;
@property(assign) BOOL isLoadDefenceSwitch;
@property(assign) BOOL isNotSurportDefenceSwitch;

@property (nonatomic,strong) NSString *presetLable;
@property (nonatomic) NSInteger presetInt;
@property (nonatomic) NSInteger item;
@property (nonatomic) NSInteger item1;

@property (nonatomic, strong) NSMutableArray *dataarray;
@property (nonatomic, strong) NSMutableArray *dataarray1;

@end
