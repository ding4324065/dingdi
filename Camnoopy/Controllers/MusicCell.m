//
//  MusicCell.m
//  Camnoopy
//
//  Created by 卡努比 on 16/5/3.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "MusicCell.h"
#import "Constants.h"

@implementation MusicCell
#define LEFT_LABEL_WIDTH 100
#define PROGRESS_WIDTH_HEIGHT 32

#define SWITCH_WIDTH ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? 72:49)
#define SWITCH_HEIGHT 31
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat cellWidth = self.contentView.frame.size.width;
    CGFloat cellHeight = self.contentView.frame.size.height;
    
        self.nameLab.frame = CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        self.nameLab.textAlignment = NSTextAlignmentLeft;
        self.nameLab.textColor = XBlack;
        self.nameLab.backgroundColor = XBGAlpha;
        [self.nameLab setFont:XFontBold_16];
//        self.nameLab.text = self.leftLableText;
        [self.contentView addSubview:self.nameLab];
        
    

        self.nameLab1.frame = CGRectMake(_nameLab.frame.size.width+30+10,0,LEFT_LABEL_WIDTH,BAR_BUTTON_HEIGHT);
        self.nameLab1.textAlignment = NSTextAlignmentLeft;
        self.nameLab1.textColor = XBlack;
        self.nameLab1.backgroundColor = XBGAlpha;
        [self.nameLab1 setFont:XFontBold_16];
//        self.nameLab1.text = self.centerLableText;
        [self.contentView addSubview:self.nameLab1];
        

    _imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLab1.frame.size.width+_nameLab.frame.size.width+30+10+20, 0, SWITCH_WIDTH, SWITCH_HEIGHT)];
    [self.contentView addSubview:_imgIcon];

}

-(void)decShceldID{
    if ([self.delegate respondsToSelector:@selector(musictapLeftIconView:androw:)]) {
        [self.delegate musictapLeftIconView:self.section androw:self.row];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
