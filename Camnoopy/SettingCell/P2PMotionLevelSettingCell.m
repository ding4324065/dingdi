//
//  P2PMotionLevelSettingCell.m
//  Camnoopy
//
//  Created by Lio on 16/1/26.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "P2PMotionLevelSettingCell.h"
#import "Constants.h"
@implementation P2PMotionLevelSettingCell

-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
    [self.customView release];
    [self.progressView release];
    [self.slider release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#define LEFT_LABEL_WIDTH 50
#define PROGRESS_WIDTH_HEIGHT 32
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth1 = self.contentView.frame.size.width;
    CGFloat cellHeight1 = self.contentView.frame.size.height;
    
    if(!self.leftLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LEFT_LABEL_WIDTH + 50, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftLabelText;
        [self.contentView addSubview:textLabel];
        self.leftLabelView = textLabel;
        [textLabel release];
        [self.leftLabelView setHidden:self.isLeftLabelHidden];
    }else{
        self.leftLabelView.text = self.leftLabelText;
        [self.leftLabelView setHidden:self.isLeftLabelHidden];
    }
    
    if(!self.customView){
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(30,5, cellWidth1-30*2, cellHeight1-5*2)];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 20, customView.frame.size.width + 20, customView.frame.size.height)];
        slider.maximumValue = 4;//可调节范围
        slider.tintColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
        [customView addSubview:slider];
        self.slider = slider;
        [slider release];
        self.customView = customView;
        [customView release];
        [self.contentView addSubview:self.customView];
        
        [self.customView setHidden:self.isCustomViewHidden];
    }else{
        self.customView.frame = CGRectMake(30,5, cellWidth1-30*2, cellHeight1-5*2);
        self.slider.frame = CGRectMake(0, 20, self.customView.frame.size.width, self.customView.frame.size.height);
        [self.contentView addSubview:self.customView];
        [self.customView setHidden:self.isCustomViewHidden];
    }
    
    if(!self.progressView){
        UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        progressView.frame = CGRectMake(cellWidth1-30-PROGRESS_WIDTH_HEIGHT, (cellHeight1-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
        [self.contentView addSubview:progressView];
        [progressView startAnimating];
        self.progressView = progressView;
        [progressView release];
        [self.progressView setHidden:self.isProgressViewHidden];
    }else{
        [self.progressView startAnimating];
        [self.progressView setHidden:self.isProgressViewHidden];
    }
    
    [self.slider setValue:self.volumeValue];
}

-(void)setProgressViewHidden:(BOOL)hidden{
    self.isProgressViewHidden = hidden;
    if(self.progressView){
        [self.progressView setHidden:hidden];
    }
}

-(void)setLeftLabelHidden:(BOOL)hidden{
    self.isLeftLabelHidden = hidden;
    if(self.leftLabelView){
        [self.leftLabelView setHidden:hidden];
    }
}

-(void)setCustomViewHidden:(BOOL)hidden{
    self.isCustomViewHidden = hidden;
    if(self.customView){
        [self.customView setHidden:hidden];
    }
}

@end
