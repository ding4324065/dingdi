//
//  MyPickTitleView.h
//  Camnoopy
//
//  Created by Jie on 15/1/17.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDJPickerView.h"

@interface MyPickTitleView : UIView<IDJPickerViewDelegate>

@property (nonatomic, strong) IDJPickerView *picker;

@end
