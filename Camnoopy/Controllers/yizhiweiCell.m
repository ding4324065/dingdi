//
//  yizhiweiCell.m
//  Camnoopy
//
//  Created by 卡努比 on 16/10/26.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "yizhiweiCell.h"

@implementation yizhiweiCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *lab = [[UILabel alloc] init];
        lab.font = [UIFont systemFontOfSize:16];
        lab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lab];
        self.leftLab = lab;
        
        UIImageView *img = [[UIImageView alloc] init];
        [self.contentView addSubview:img];
        self.img = img;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.leftLab.frame = CGRectMake(5, 0, 150, 40);
    self.img.frame = CGRectMake(200, 0, 30, 40);
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
