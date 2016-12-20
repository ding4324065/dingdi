//
//  DefenceMagnetic1Cell.m
//  Camnoopy
//
//  Created by 卡努比 on 16/8/29.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "DefenceMagnetic1Cell.h"

@implementation DefenceMagnetic1Cell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *iconImage = [[UIImageView alloc] init];
//        iconImage.image = [UIImage imageNamed:@"family_type"];
        [self.contentView addSubview:iconImage];
        self.iconImage = iconImage;
        UILabel *lab = [[UILabel alloc]init];
        lab.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:lab];
        self.lab = lab;
        UIImageView *iconImage1 = [[UIImageView alloc] init];
        //        iconImage.image = [UIImage imageNamed:@"family_type"];
        [self.contentView addSubview:iconImage1];
        self.iconImage1 = iconImage1;
        UILabel *lab1 = [[UILabel alloc]init];
        lab1.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:lab1];
        self.lab1 = lab1;
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.iconImage.frame = CGRectMake(5, 0, 30, 30);
    self.lab.frame = CGRectMake(40, 0, 130, 30);
    
    self.iconImage1.frame = CGRectMake(200, 0, 30, 30);
    self.lab1.frame = CGRectMake(100, 0, 50, 30);
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
