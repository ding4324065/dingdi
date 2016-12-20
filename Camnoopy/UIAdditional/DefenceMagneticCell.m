//
//  DefenceMagneticCell.m
//  Camnoopy
//
//  Created by 高琦 on 15/2/10.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "DefenceMagneticCell.h"
#import "Constants.h"
#import "AppDelegate.h"
#define SWITCH_WIDTH ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? 30:21)
#define SWITCH_HEIGHT 31
@implementation DefenceMagneticCell
-(void)dealloc{
    [self.addbutton release];
    [self.defenceswitch release];
    [self.progressView release];
    [self.controllerView release];
    [super dealloc];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
#define LEFT_BUTTON_WIDTH 30
#define INDEX_LABEL_WIDTH 20
#define LEARN_CODE_WIDTH 100
#define PROGRESS_WIDTH_HEIGHT 32
-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat cellWidth = self.frame.size.width;
    CGFloat cellHeight = self.frame.size.height;
    
    if (!self.addbutton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(cellWidth-50, 0, cellHeight, cellHeight);
        button.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        [button setImage:[UIImage imageNamed:@"+"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        [self.contentView addSubview:button];
        self.addbutton = button;
    }
    if (!self.addbutton1) {
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = CGRectMake(cellWidth-200, 0, cellHeight, cellHeight);
//        button1.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
//        button1.backgroundColor = [UIColor redColor];
//        [button1 setImage:[UIImage imageNamed:@"+"] forState:UIControlStateNormal];
//        [button1 addTarget:self action:@selector(buttonClick1:) forControlEvents:UIControlEventTouchUpInside];
        button1.hidden = YES;
        [self.contentView addSubview:button1];
        self.addbutton1 = button1;
    }
    if (!self.addLable) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth-150, 0, cellHeight, cellHeight)];
        lab.font = [UIFont systemFontOfSize:16];
        lab.hidden = YES;
        [self.contentView addSubview:lab];
        self.addLable = lab;
    }
//
    
    if (!self.controllerView) {
        CGRect rect = CGRectInset(CGRectMake(cellWidth-50, 0, cellHeight, cellHeight), 3.0f, 3.0f);
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:rect];
        imageView.image = [UIImage imageNamed:@"defenceFlag"];
        imageView.hidden = YES;
        [self.contentView addSubview:imageView];
        self.controllerView = imageView;
        [imageView release];
    }
    
    if (!self.defenceswitch) {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(cellWidth-50, (cellHeight-SWITCH_HEIGHT)/2, SWITCH_WIDTH, SWITCH_HEIGHT)];
        [switchView addTarget:self action:@selector(onSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
        switchView.hidden = YES;
        [self.contentView addSubview:switchView];
        self.defenceswitch = switchView;
        [switchView release];
    }
    
    if (!self.defenimage) {
        UIImageView *defenimage = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-60, (cellHeight-SWITCH_HEIGHT)/6, cellHeight, cellHeight)];
        defenimage.contentMode = UIViewContentModeScaleAspectFill;
        defenimage.clipsToBounds = YES;
        defenimage.hidden = YES;
        defenimage.image = [UIImage imageNamed:@"check23"];
        [self.contentView addSubview:defenimage];
        self.defenimage = defenimage;
        [defenimage release];
    }
    
    if(!self.progressView){
        UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        progressView.frame = CGRectMake(cellWidth-30, 0, LEFT_BUTTON_WIDTH, BAR_BUTTON_HEIGHT);
        [self.contentView addSubview:progressView];
        [progressView startAnimating];
        self.progressView = progressView;
        [progressView release];
    }
}

-(void)onSwitchValueChange:(UISwitch *)myswitch{
    if (self.delegate){
        [self.delegate defenceCell:self section:self.group row:self.item status:4];
    }
}

-(void)buttonClick:(UIButton *)button{
    if (self.delegate) {
        [self.delegate defenceCell:self section:self.group row:self.item status:3];
    }
}

- (void)setAddbuttonHidden:(BOOL)hidden{
    self.addbutton.hidden = hidden;
}

- (void)setAddbutton1Hidden:(BOOL)hidden{
    self.addbutton1.hidden = hidden;
}
-(void)setAddLableHidden:(BOOL)hidden{
    self.addLable.hidden = hidden;
}

- (void)setDefenceswitchHidden:(BOOL)hidden{
    self.defenceswitch.hidden = hidden;
}
-(void)setProgressViewHidden:(BOOL)hidden{
    [self.progressView setHidden:hidden];
}

- (void)setDefenimageWithHidden:(BOOL)hidden
{
    self.defenimage.hidden = hidden;
}
-(void)setContollerViewHidden:(BOOL)hidden
{
    [self.controllerView setHidden:hidden];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
        return YES;
}

@end








