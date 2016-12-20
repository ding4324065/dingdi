//
//  scanAlertviewTip.m
//  Camnoopy
//
//  Created by wutong on 15-1-29.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "scanAlertviewTip.h"

@implementation scanAlertviewTip

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initComponents];
    }
    return self;
}

-(void)initComponents
{
    self.alpha = 0.95;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    int width = screenSize.width;
    
    int leftBackInterval = 15;
    int leftTipInterval = 30;
    int backHeight = 200;
    int backWith = width - leftBackInterval*2;
    int btnHeight = 30;
    
    UIView* backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width-leftBackInterval*2, backHeight)];
    backView.center = self.center;
    backView.backgroundColor = [UIColor whiteColor];
    [backView.layer setBorderWidth:2.0];//画线的宽度
    [backView.layer setBorderColor:[UIColor blackColor].CGColor];//颜色
    [backView.layer setCornerRadius:15.0];//圆角
    [backView.layer setMasksToBounds:YES];
    [self addSubview:backView];
    [backView release];
//提示
    NSString* strTitle = NSLocalizedString(@"scan_tip", nil);
    UIFont* font = [UIFont boldSystemFontOfSize:16.0];
    CGSize size = [strTitle sizeWithAttributes:@{NSFontAttributeName: font}];
//    CGSize size = [strTitle sizeWithFont:font];
    UILabel* lableTitle = [[UILabel alloc] initWithFrame:CGRectMake(backWith/2-size.width/2, 10, size.width, size.height)];
    [lableTitle setFont:font];
    lableTitle.text = strTitle;
    [backView addSubview:lableTitle];
    [lableTitle release];
    //Wifi密码错误
//    设备目前不支持5G路由器
//    路由器DHCP功能没有开启
    NSArray* arrayTip = [NSArray arrayWithObjects:NSLocalizedString(@"scan_error01", nil), NSLocalizedString(@"scan_error02", nil), NSLocalizedString(@"scan_error03", nil), nil];
    for (int i=0; i<3; i++) {
        NSString* strTip = [arrayTip objectAtIndex:i];
        UIFont* font = [UIFont systemFontOfSize:12.0];
        CGSize size = [strTip sizeWithAttributes:@{NSFontAttributeName: font}];
//        CGSize size = [strTip sizeWithFont:font];

        UILabel* lableTip = [[UILabel alloc] initWithFrame:CGRectMake(leftTipInterval, 50+30*i, size.width, size.height)];
        [lableTip setFont:font];
        lableTip.text = strTip;
        [backView addSubview:lableTip];
        [lableTip release];
        
        UIImage* img = [UIImage imageNamed:@"scanTip"];
        UIImageView* imgView = [[UIImageView alloc]initWithImage:img];
        imgView.frame = CGRectMake(10, 51+30*i, 15, 15);
        [backView addSubview:imgView];
        [imgView release];
    }
//     取消
    UIButton* btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(0, backHeight-btnHeight, backWith/2, btnHeight)];
    [btnCancel setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor colorWithRed:3.0/255.0 green:114/255.0 blue:252.0/255.0 alpha:1] forState:UIControlStateNormal];
    [btnCancel.layer setBorderWidth:1.0];//画线的宽度
    [btnCancel addTarget:self action:@selector(onCancelPress) forControlEvents:UIControlEventTouchDown];
    [backView addSubview:btnCancel];
    [btnCancel release];
//再试一次
    UIButton* btnTryAgain = [[UIButton alloc]initWithFrame:CGRectMake(backWith/2-1, backHeight-btnHeight, backWith/2+1, btnHeight)];
    [btnTryAgain setTitle:NSLocalizedString(@"scan_tryagain", nil) forState:UIControlStateNormal];
    [btnTryAgain setTitleColor:[UIColor colorWithRed:3.0/255.0 green:114/255.0 blue:252.0/255.0 alpha:1] forState:UIControlStateNormal];
    [btnTryAgain.layer setBorderWidth:1.0];//画线的宽度
    [btnTryAgain addTarget:self action:@selector(onTryAgainPress) forControlEvents:UIControlEventTouchDown];
    [backView addSubview:btnTryAgain];
    [btnTryAgain release];

}

#pragma mark 按钮响应
- (void)onCancelPress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertTipClickCancel)])
    {
        [self.delegate alertTipClickCancel];
    }
}

- (void)onTryAgainPress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertTipClickCancel)])
    {
        [self.delegate alertTipClickTryAgain];
    }
}
@end
