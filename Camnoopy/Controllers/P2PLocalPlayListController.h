//
//  P2PLocalPlayListController.h
//  Camnoopy
//
//  Created by Lio on 16/3/3.
//  Copyright © 2016年 guojunyi. All rights reserved.
//
/*本地录像列表*/
#import <UIKit/UIKit.h>

@interface P2PLocalPlayListController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *contacts;
@end
