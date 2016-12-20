//
//  DefenceSettingController.h
//  2cu
//
//  Created by 高琦 on 15/2/9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@class Contact;
@interface DefenceSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;
@end
