//
//  SysSettingsViewController.h
//  Camnoopy
//
//  Created by 卡努比 on 16/4/19.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2PSwitchCell.h"
#import "MusicCell.h"
#import "P2PEmailSettingCell.h"
@interface SysSettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate,
MusicCellDelegate, EmailSettingCellDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *datas;
@property(nonatomic,strong) NSMutableArray *shows;
@property(nonatomic,strong) NSMutableArray *musicArray;
@property (strong,nonatomic) UISwitch *imageInversionSwitch;
@property(assign) NSInteger VibrationsStart;
@property(assign) NSInteger  OpenvoiceState;
@property (assign,nonatomic) int  alarmtype;
//震动启动
@property(assign) BOOL isVibrationsStart;
//声音开启
@property(assign) BOOL isOpenvoice;
@property (assign) NSInteger lastVibrationsStart;
@property (assign) NSInteger lastOpenvoice;
@property(assign) BOOL isFirstLoadingCompolete;//首次完全加载

@property(assign) BOOL isLoadingBindEmail;//绑定邮箱
@property(strong, nonatomic) NSString *bindEmail;
@end
