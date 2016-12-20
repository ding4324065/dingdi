//
//  IconButton.m
//  Camnoopy
//
//  Created by wutong on 15-1-14.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "IconButton.h"

@implementation IconButton

- (void)dealloc
{
    [self.localDevice release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
