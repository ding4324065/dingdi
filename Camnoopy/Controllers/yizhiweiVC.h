//
//  yizhiweiVC.h
//  Camnoopy
//
//  Created by 卡努比 on 16/11/2.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@class Contact;

@interface yizhiweiVC : UIViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) Contact *contact;

@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger index1;
@property (nonatomic) NSInteger index2;

@property (nonatomic) NSInteger group;
@property (nonatomic) NSInteger item;
@property (nonatomic) NSInteger preNum;

@property (nonatomic,strong) NSString *text;

@property (nonatomic, copy) void (^MyBlock)(NSString *text, NSInteger index, NSInteger group);

@property (nonatomic) int Num;
@property (nonatomic, strong) NSMutableArray *array;
@end
