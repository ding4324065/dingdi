//
//  LocalDeviceListController.h
//  Camnoopy
//
//  Created by 卡努比 on 16/5/18.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalDeviceListController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic)NSArray *newDevicesArray;
@end
