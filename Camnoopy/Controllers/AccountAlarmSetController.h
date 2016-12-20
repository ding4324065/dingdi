//
//  AccountAlarmSetController.h
//  Camnoopy
//
//  Created by 高琦 on 15/3/19.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
/*报警管理页面*/
#import <UIKit/UIKit.h>
#import "Contact.h"
#import "P2PRecordTimeCell.h"
#import "P2PSecurityCell.h"
#import "CyclePickerView.h"
#import "MXSCycleScrollView.h"
#import "MXSCycleScrollView3.h"
#import "P2PEmailSettingCell.h"
@interface AccountAlarmSetController : UIViewController<UITableViewDataSource,UITableViewDelegate,SavePressDelegate,UIActionSheetDelegate,MXSCycleScrollViewDelegate,MXSCycleScrollViewDatasource,UITextFieldDelegate>
@property (strong,nonatomic) UITableView * tableView;
@property (strong,nonatomic) NSMutableArray * shieldingIdArr;

@property (strong, nonatomic) UIView *alphaView;        //大背景图
@property(strong,nonatomic)UIView * BindView;           //小背景图

@property(nonatomic,strong)CyclePickerView * cycleview;

@property(nonatomic,strong)MXSCycleScrollView * timezoneview;
@property(nonatomic,strong)UIView * timepicker;
@property(strong,nonatomic)UITextField * shieldIDtextView;

@property(assign,nonatomic)NSInteger delsection;
@property(assign,nonatomic)NSInteger delrow;
@property (assign,nonatomic) NSInteger settime;
@end
