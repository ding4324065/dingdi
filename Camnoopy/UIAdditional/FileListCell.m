//
//  FileListCell.m
//  2cu
//
//  Created by wutong on 15-6-29.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "FileListCell.h"

@implementation FileListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (!self.initGesture) {
        self.initGesture = YES;
        
        UILongPressGestureRecognizer* longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressClick:)];
        [longPressGes setMinimumPressDuration:1.0f];
        [self.contentView addGestureRecognizer:longPressGes];
        [longPressGes release];
    }
}

-(void)longPressClick:(UILongPressGestureRecognizer* )ges{
    
    switch (ges.state) {
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"long press end");
        }
            break;
        case UIGestureRecognizerStateBegan:
        {
            if (self.delegate) {
                [self.delegate onLongPress:self.row];
            }
        }
            break;
        default:
            break;
    }
}
@end
