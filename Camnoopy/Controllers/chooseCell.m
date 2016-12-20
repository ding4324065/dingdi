//
//  chooseCell.m
//  Camnoopy
//
//  Created by 卡努比 on 16/4/27.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "chooseCell.h"

@implementation chooseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
//        textLabel.textAlignment = NSTextAlignmentLeft;
//        textLabel.textColor = XBlack;
//        textLabel.backgroundColor = XBGAlpha;
//        [textLabel setFont:XFontBold_16];
//        textLabel.text = self.leftLabelText;
//        [self.contentView addSubview:textLabel];
//        self.leftLabelView = textLabel;
//        [textLabel release];
//        _leftLable = [UILabel alloc] initWithFrame:CGRectMake(30, 0, <#CGFloat width#>, <#CGFloat height#>)

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
