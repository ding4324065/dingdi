//
//  MyPickTitleView.m
//  Camnoopy
//
//  Created by Jie on 15/1/17.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "MyPickTitleView.h"
#import "IDJPickerView.h"
#import "Constants.h"

@implementation MyPickTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.picker = [[IDJPickerView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) dataLoop:NO];
        self.picker.delegate = self;
        self.picker.selectedCenterView.hidden = YES;
        [self.picker setleftViewHidden:YES];
        [self.picker setLin1Ishidden:YES];
        [self.picker setLin2Ishidden:YES];
        [self addSubview:_picker];
    }
    return self;
}


-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    [_picker setFrame:CGRectMake(0, 0, frame.size.width-10, frame.size.height)];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

//指定每一列的滚轮上的Cell的个数
- (NSUInteger)numberOfCellsInScroll:(NSUInteger)scroll {
    switch (scroll) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

//指定每一列滚轮所占整体宽度的比例，以:分隔
- (NSString *)scrollWidthProportion {
    return @"1:1:1:1:1";
}

//指定有多少个Cell显示在可视区域
- (NSUInteger)numberOfCellsInVisible {
    return 1;
}

//为指定滚轮上的指定位置的Cell设置内容
- (void)viewForCell:(NSUInteger)cell inScroll:(NSUInteger)scroll reusingCell:(UITableViewCell *)tc {
    tc.textLabel.textAlignment=NSTextAlignmentCenter;
    tc.selectionStyle=UITableViewCellSelectionStyleNone;
    [tc.textLabel setFont:[UIFont systemFontOfSize:18.0]];
    switch (scroll) {
        case 0:{
            
            tc.textLabel.text=@"年";
            break;
        }
        case 1:{
            
            tc.textLabel.text=@"月";
            break;
        }
        case 2:{
            
            tc.textLabel.text=@"日";
            break;
        }
        case 3:{
            
            tc.textLabel.text=@"时";
            break;
        }
        case 4:{
            
            tc.textLabel.text=@"分";
            break;
        }
            
        default:
            break;
    }
}

//设置选中条的位置
- (NSUInteger)selectionPosition {
    return 0;
}

- (void)didSelectCell:(NSUInteger)cell inScroll:(NSUInteger)scroll {
    DLog(@"nothing");
}



@end
