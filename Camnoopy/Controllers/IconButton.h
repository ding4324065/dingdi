//
//  IconButton.h
//  Camnoopy
//
//  Created by wutong on 15-1-14.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalDevice.h"

@interface IconButton : UIButton
@property (nonatomic)NSInteger index;
@property (nonatomic, retain) LocalDevice* localDevice;
@end
