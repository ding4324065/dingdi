//
//  MainSettingCell.m
//  Camnoopy
//
//  Created by 卡努比 on 16/7/1.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "MainSettingCell.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Utils.h"
@implementation MainSettingCell

- (void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
    [self.newDeviceIconView release];
    [self.rightIconView release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.contentView.frame.size.width;
    CGFloat cellHeight = self.contentView.frame.size.height;
 
    if(!self.leftLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, cellHeight/4, 100, cellHeight/2)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftLabelText;
        [self.contentView addSubview:textLabel];
        self.leftLabelView = textLabel;
        [textLabel release];
        
    }
    else
    {
        self.leftLabelView.frame = CGRectMake(30, cellHeight/4, 100, cellHeight/2);
        self.leftLabelView.textAlignment = NSTextAlignmentLeft;
        self.leftLabelView.textColor = XBlack;
        self.leftLabelView.backgroundColor = XBGAlpha;
        [self.leftLabelView setFont:XFontBold_16];
        self.leftLabelView.text = self.leftLabelText;
        [self.contentView addSubview:self.leftLabelView];
    }

    //设备检查更新
    CGFloat labelTextWidth = [Utils getStringWidthWithString:NSLocalizedString(@"device_update", nil) font:XFontBold_16 maxWidth:cellWidth];
    //图片的宽、高
    
    
    if (!self.newDeviceIconView) {
        UIImageView *updateImg1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftLabelView.frame.origin.x+5.0, cellHeight/4, 30, cellHeight/2)];
        updateImg1.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *image1 = [UIImage imageNamed:self.newDeviceIcon];
        updateImg1.image = image1;
        [self.contentView addSubview:updateImg1];
        self.newDeviceIconView = updateImg1;
        [updateImg1 release];
        
    }else{
        self.newDeviceIconView.frame = CGRectMake(self.leftLabelView.frame.origin.y+5, cellHeight/4, 30, cellHeight/2);
        self.newDeviceIconView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *newDeviceIcon = [UIImage imageNamed:self.newDeviceIcon];
        self.newDeviceIconView.image = newDeviceIcon;
        [self.contentView addSubview:self.newDeviceIconView];
    }
    
    
    if (!self.rightIconView) {
        UIImageView *rightIconView = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth - 60, cellHeight/4, 30, cellHeight/2)];
        rightIconView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *rightIconImg = [UIImage imageNamed:self.rightIcon];
        rightIconView.image = rightIconImg;
        [self.contentView addSubview:rightIconView];
        self.rightIconView = rightIconView;
        [rightIconView release];
        
    }else{
        self.rightIconView.frame = CGRectMake(cellWidth - 60, cellHeight/4, 30, cellHeight/2);
        self.rightIconView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *rightIconImg = [UIImage imageNamed:self.rightIcon];
        self.rightIconView.image = rightIconImg;
        [self.contentView addSubview:self.rightIconView];
    }
}

- (void)setLeftLabelTextHidden:(BOOL)hidden{
    self.isleftLabelTextHidden = hidden;
    if(self.leftLabelView){
        [self.leftLabelView setHidden:hidden];
    }
}

- (void)setUpdateImg:(BOOL)hidden{
    self.isupdateImgHidden = hidden;
    if (self.newDeviceIconView) {
        [self.newDeviceIconView setHighlighted:hidden];
    }
}
- (void)setRightImg:(BOOL)hidden{
    self.isrightImgHidden = hidden;
    if (self.rightIconView) {
        [self.rightIconView setHighlighted:hidden];
    }
}

@end
