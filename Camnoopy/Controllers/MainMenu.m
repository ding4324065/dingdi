//
//  MainMenu.m
//  Camnoopy
//
//  Created by wutong on 15-1-6.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//


#import "MainMenu.h"
#import "Constants.h"
#import "LoginResult.h"
#import "UDManager.h"

@implementation MainMenu

- (void)initComponents
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    
    //account image label
    UIImage* img1 = [UIImage imageNamed:@"mainContainer0"];
    UIImageView* _imageViewAccount = [[UIImageView alloc]initWithImage:img1];
    _imageViewAccount.frame = CGRectMake(25, 40, 50, 50);
    //[self addSubview:_imageViewAccount];
    [_imageViewAccount release];
    
    UIButton * AccountBtn = [[UIButton alloc] init];//个人信息按钮
    AccountBtn.frame = CGRectMake(25, 40, 50, 50);
    UIImage* img = [UIImage imageNamed:@"mainContainer0"];
    [AccountBtn setImage:img forState:UIControlStateNormal];
    [AccountBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, AccountBtn.bounds.size.width - AccountBtn.bounds.size.height)];
    AccountBtn.showsTouchWhenHighlighted = YES;
    AccountBtn.tag = 9;
    [AccountBtn addTarget:self action:@selector(onBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:AccountBtn];
    [AccountBtn release];
    
    UILabel* _labelAccount = [[UILabel alloc]init];
    _labelAccount.backgroundColor = [UIColor clearColor];
    _labelAccount.frame = CGRectMake(90, 60, 100, 20);
    LoginResult *loginResult = [UDManager getLoginInfo];
    if([loginResult.contactId isEqual:@"0517400"])
    {
    //匿名登录
        _labelAccount.text = NSLocalizedString(@"anonymous", nil);
    }
    else
    {
        _labelAccount.text = loginResult.contactId;
    }
    [_labelAccount setTextColor:[UIColor blackColor]];
    [_labelAccount setFont:XFontBold_18];
    [self addSubview:_labelAccount];
    [_labelAccount release];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSArray *arrayString = [[NSArray alloc] initWithObjects:NSLocalizedString(@"contact",nil),
                                NSLocalizedString(@"playback",nil),
                                NSLocalizedString(@"screenshot",nil),
                                NSLocalizedString(@"alarm_history",nil),
                                NSLocalizedString(@"mainmenu_alarmset",nil),
//                                NSLocalizedString(@"setting",nil),
                                NSLocalizedString(@"mainmenu_help", nil),
                                NSLocalizedString(@"about_us", nil),
                                NSLocalizedString(@"logout",nil),nil];
        for (int i=0; i<8; i++)
        {
            UIButton* btn = [[UIButton alloc]init];
            int xPos=0, yPos=0;
            if (i != 7)
            {
                xPos = 35;
                yPos = (i<6)?(110+40*i):(110+40*i+20);
            }
            else
            {
                xPos = 10;
                yPos = frame.size.height - 40;
            }
            btn.frame =  CGRectMake(xPos, yPos, 150, 25);
            //侧滑的图片和文字
            if (i >=5) {
                 NSString* sImgName = [NSString stringWithFormat:@"mainContainer%d",i+2];
            }
            NSString* sImgName = [NSString stringWithFormat:@"mainContainer%d",i+1];
            UIImage* img = [UIImage imageNamed:sImgName];
            [btn setImage:img forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            NSString* text = [arrayString objectAtIndex:i];
            [btn setTitle:text forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn layoutIfNeeded];
            
            //        CGSize size = [text sizeWithFont:font];
            
            //btn.titleLabel.frame = CGRectMake(20, 0, 20, 20);
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, btn.bounds.size.width - btn.bounds.size.height)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width + btn.bounds.size.height - btn.bounds.size.width, 0, 0)];
            btn.showsTouchWhenHighlighted = YES;
            btn.tag = i;
            [btn addTarget:self action:@selector(onBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [btn release];
        }
        
        //line
        UIView* _imageViewLine1 = [[UIView alloc] init];
        _imageViewLine1.frame = CGRectMake(35, 340, 150, 1);
        _imageViewLine1.backgroundColor = [UIColor blackColor];
        _imageViewLine1.alpha = 0.1;
        _imageViewLine1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_imageViewLine1];
        [_imageViewLine1 release];
        
        //line
        UIImage* img2 = [UIImage imageNamed:@"mainContainer11"];
        UIImageView* _imageViewLine2 = [[UIImageView alloc] initWithImage:img2];
        _imageViewLine2.frame = CGRectMake(100, frame.size.height - 50, 10, 45);
        [self addSubview:_imageViewLine2];
        [_imageViewLine2 release];

    }
    else
    {
        NSArray *arrayString = [[NSArray alloc] initWithObjects:NSLocalizedString(@"contact",nil),
                                NSLocalizedString(@"playback",nil),
                                NSLocalizedString(@"screenshot",nil),
                                NSLocalizedString(@"alarm_history",nil),
                                NSLocalizedString(@"mainmenu_alarmset",nil),
                                NSLocalizedString(@"setting",nil),
                                NSLocalizedString(@"mainmenu_help", nil),
                                NSLocalizedString(@"about_us", nil),
                                NSLocalizedString(@"logout",nil),nil];
        for (int i=0; i<9; i++)
        {
            UIButton* btn = [[UIButton alloc]init];
            int xPos=0, yPos=0;
            if (i != 8)
            {
                xPos = 35;
                yPos = (i<7)?(110+40*i):(110+40*i+20);
            }
            else
            {
                xPos = 10;
                yPos = frame.size.height - 40;
            }
            btn.frame =  CGRectMake(xPos, yPos, 150, 25);
            //侧滑的图片和文字
            NSString* sImgName = [NSString stringWithFormat:@"mainContainer%d",i+1];
            UIImage* img = [UIImage imageNamed:sImgName];
            [btn setImage:img forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            NSString* text = [arrayString objectAtIndex:i];
            [btn setTitle:text forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn layoutIfNeeded];
            
            //        CGSize size = [text sizeWithFont:font];
            
            //btn.titleLabel.frame = CGRectMake(20, 0, 20, 20);
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, btn.bounds.size.width - btn.bounds.size.height)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, btn.titleLabel.bounds.size.width + btn.bounds.size.height - btn.bounds.size.width, 0, 0)];
            btn.showsTouchWhenHighlighted = YES;
            btn.tag = i;
            [btn addTarget:self action:@selector(onBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [btn release];
        }
        
        //line
        UIView* _imageViewLine1 = [[UIView alloc] init];
        _imageViewLine1.frame = CGRectMake(35, 380, 150, 1);
        _imageViewLine1.backgroundColor = [UIColor blackColor];
        _imageViewLine1.alpha = 0.1;
        _imageViewLine1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_imageViewLine1];
        [_imageViewLine1 release];
        
        //line
        UIImage* img2 = [UIImage imageNamed:@"mainContainer11"];
        UIImageView* _imageViewLine2 = [[UIImageView alloc] initWithImage:img2];
        _imageViewLine2.frame = CGRectMake(100, frame.size.height - 50, 10, 45);
        [self addSubview:_imageViewLine2];
        [_imageViewLine2 release];

    }

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initComponents];
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

- (void)onBtnAction:(id)sender
{
    [_delegate OnMenuBtnAction:[sender tag]];
}

@end
