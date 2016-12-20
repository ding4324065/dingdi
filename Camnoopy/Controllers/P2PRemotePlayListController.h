//
//  P2PRemotePlayListController.h
//  Camnoopy
//
//  Created by wutong on 15-1-26.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
/*远程录像列表*/
#import <UIKit/UIKit.h>

@interface P2PRemotePlayListController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *contacts;
@end
