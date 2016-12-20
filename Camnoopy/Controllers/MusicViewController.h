//
//  MusicViewController.h
//  Camnoopy
//
//  Created by 卡努比 on 16/5/3.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableview;
@property (nonatomic, strong)NSMutableArray *musicArray;

@property (nonatomic, retain) NSDictionary *names;
@property (nonatomic, retain) NSArray *keys;

//4.定义block
@property(nonatomic ,strong)void (^block)(NSString *str);
@end
