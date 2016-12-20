//
//  alertButton.m
//  Camnoopy
//
//  Created by wutong on 15-1-27.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "scanAlertViewAdd.h"
#import "Constants.h"
#import "Toast+UIView.h"
#import "Contact.h"
#import "FListManager.h"
#import "P2PClient.h"

@implementation scanAlertViewAdd

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)dealloc
{
    [self.textFieldName release];
    [self.textFieldPassword release];
    [self.progressAlert release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDelegate:(id)delegate localDevice:(LocalDevice*)localDevice
{
    self.delegate = delegate;
    self.localDevice = localDevice;
    
    
    [self initComponents];
   
}

-(void)initComponents
{
    BOOL setPassword = !_localDevice.flag;
    self.alpha = 0.95;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    int width = screenSize.width;
    int height = screenSize.height;

    int leftInterval = 20;
    int topInterval = 90;
    int tipHeight = 0;
    int confirmHeight = 0;
    
    if (setPassword) {
        topInterval = 60;
        tipHeight = 40;
        confirmHeight = 40;
    }
    
    UIImageView* imageView= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width-leftInterval*2, height-topInterval*2)];
    imageView.center = self.center;
    UIImage* img = [UIImage imageNamed:@"about_bk"];
    [imageView setImage:img];
    [imageView.layer setBorderWidth:2.0];//画线的宽度
    [imageView.layer setBorderColor:[UIColor blackColor].CGColor];//颜色
    [imageView.layer setCornerRadius:15.0];//圆角
    [imageView.layer setMasksToBounds:YES];
    [self addSubview:imageView];
    [imageView release];
    
    UIImage* img1 = [UIImage imageNamed:@"mainContainer0"];
    UIImageView* imageAccount = [[UIImageView alloc]initWithImage:img1];
    imageAccount.frame = CGRectMake(width/2-25, topInterval+30, 50, 50);
    [self addSubview:imageAccount];
    [imageAccount release];
    
    UILabel* labelAccount = [[UILabel alloc]init];
    labelAccount.text = _localDevice.contactId;
    [labelAccount setTextColor:[UIColor blackColor]];
    [labelAccount setFont:XFontBold_16];
    CGSize size = [labelAccount.text sizeWithFont:XFontBold_16];
    labelAccount.frame = CGRectMake(width/2-size.width/2, topInterval+85, 100, 20);
    [self addSubview:labelAccount];
    [labelAccount release];

    UILabel* lableIp = [[UILabel alloc]init];
    lableIp.text = _localDevice.address;
    [lableIp setTextColor:[UIColor blackColor]];
    [lableIp setFont:XFontBold_12];
    size = [lableIp.text sizeWithFont:XFontBold_12];
    lableIp.frame = CGRectMake(width/2-size.width/2, topInterval+105, 100, 15);
    [self addSubview:lableIp];
    [lableIp release];

    
    if (setPassword) {
        UILabel* labelTip = [[UILabel alloc]initWithFrame:CGRectMake(leftInterval+15, topInterval+120, width-30-leftInterval*2, 40)];
        labelTip.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
        labelTip.numberOfLines = 0;
        labelTip.font = [UIFont systemFontOfSize: 12.0];
        labelTip.textColor = [UIColor redColor];
        [labelTip setText:NSLocalizedString(@"create_init_password_prompt", nil)];
        [self addSubview:labelTip];
        [labelTip release];
    }
    
    UITextField* fieldName = [[UITextField alloc]initWithFrame:CGRectMake(leftInterval+10, topInterval+tipHeight+125, width-20-leftInterval*2, 40)];
    fieldName.placeholder = NSLocalizedString(@"input_contact_name", nil);
    [fieldName setText:[NSString stringWithFormat:@"Cam%@", _localDevice.contactId]];
    fieldName.backgroundColor = [UIColor whiteColor];
    fieldName.returnKeyType = UIReturnKeyDone;
    [fieldName setBorderStyle:UITextBorderStyleRoundedRect];
    fieldName.font = XFontBold_16;
    [fieldName addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self addSubview:fieldName];
    self.textFieldName = fieldName;
    [fieldName release];
    
    UITextField* fieldPassword = [[UITextField alloc]initWithFrame:CGRectMake(leftInterval+10, topInterval+tipHeight+165, width-20-leftInterval*2, 40)];
    fieldPassword.placeholder = NSLocalizedString(@"input_contact_password", nil);
    fieldPassword.backgroundColor = [UIColor whiteColor];
    fieldPassword.returnKeyType = UIReturnKeyDone;
    fieldPassword.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [fieldPassword setBorderStyle:UITextBorderStyleRoundedRect];
    fieldPassword.font = XFontBold_16;
    fieldPassword.secureTextEntry = YES;
    [fieldPassword addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self addSubview:fieldPassword];
    self.textFieldPassword = fieldPassword;
    [fieldPassword release];
    
    if (setPassword) {
        _textFieldPasswordConfirm = [[UITextField alloc]initWithFrame:CGRectMake(leftInterval+10, topInterval+tipHeight+205, width-20-leftInterval*2, 40)];
        _textFieldPasswordConfirm.placeholder = NSLocalizedString(@"confirm_input", nil);
        _textFieldPasswordConfirm.backgroundColor = [UIColor whiteColor];
        _textFieldPasswordConfirm.returnKeyType = UIReturnKeyDone;
        _textFieldPasswordConfirm.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [_textFieldPasswordConfirm setBorderStyle:UITextBorderStyleRoundedRect];
        _textFieldPasswordConfirm.secureTextEntry = YES;
        [_textFieldPasswordConfirm addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [self addSubview:_textFieldPasswordConfirm];
        [_textFieldPasswordConfirm release];
    }
    
    //btnOK
    UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOK.frame = CGRectMake(width/2-120, topInterval+tipHeight+confirmHeight+225, 110, 30);
    [btnOK setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    [btnOK.layer setCornerRadius:15.0]; //设置矩形四个圆角半径
    btnOK.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:126.0/255.0 blue:240.0/255.0 alpha:1.0];
    [btnOK setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//title color
    btnOK.tag = 101;
    btnOK.showsTouchWhenHighlighted = YES;
    [btnOK addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnOK];
    
    //btnCancel
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(width/2+10, topInterval+tipHeight+confirmHeight+225, 110, 30);
    [btnCancel setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [btnCancel.layer setCornerRadius:15.0]; //设置矩形四个圆角半径
    btnCancel.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:126.0/255.0 blue:240.0/255.0 alpha:1.0];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//title color
    [btnCancel addTarget:self action:@selector(onCancelPress) forControlEvents:UIControlEventTouchUpInside];
    btnCancel.tag = 102;
    btnCancel.showsTouchWhenHighlighted = YES;
    [self addSubview:btnCancel];
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self] autorelease];
    [self addSubview:self.progressAlert];
    
    [self exChangeOut:self dur:0.5];
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

- (void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    
    [changeOutView.layer addAnimation:animation forKey:nil];
}

#pragma mark 检查数据合法性
-(BOOL)checkForAddLocalDevice
{
    NSString* name = _textFieldName.text;
    NSString* pwd = _textFieldPassword.text;
    if(!name.length>0){
        [self makeToast:NSLocalizedString(@"input_contact_name", nil)];
        return NO;
    }
    
    if([_localDevice.contactId characterAtIndex:0]!='0'){
        if(!pwd.length>0){
            [self makeToast:NSLocalizedString(@"input_contact_password", nil)];
            return NO;
        }
        
        if([pwd characterAtIndex:0]=='0'){
            [self makeToast:NSLocalizedString(@"password_zero_format_error", nil)];
            return NO;
        }
        
        if(pwd.length>100)
        {
            [self makeToast:NSLocalizedString(@"device_password_too_long", nil)];
            return NO;
        }
    }
    return YES;
}

-(BOOL)checkForInitPassword
{
    NSString *newPassword = _textFieldPassword.text;
    NSString *confirmPassword = _textFieldPasswordConfirm.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    
    if(!_textFieldName||!_textFieldName.text.length>0){
        [self makeToast:NSLocalizedString(@"input_contact_name", nil)];
        return NO;
    }
    
    if(!newPassword||!newPassword.length>0){
        [self makeToast:NSLocalizedString(@"input_contact_password", nil)];
        return NO;
    }
    
    if([predicate evaluateWithObject:newPassword]==NO){
        [self makeToast:NSLocalizedString(@"password_number_format_error", nil)];
        return NO;
    }
    
    if([newPassword characterAtIndex:0]=='0'){
        [self makeToast:NSLocalizedString(@"password_zero_format_error", nil)];
        return NO;
    }
    
    if(newPassword.length>100){
        [self makeToast:NSLocalizedString(@"device_password_too_long", nil)];
        return NO;
    }
    
    
    if(!confirmPassword||!confirmPassword.length>0){
        [self makeToast:NSLocalizedString(@"confirm_input", nil)];
        return NO;
    }
    
    if(![newPassword isEqualToString:confirmPassword]){
        [self makeToast:NSLocalizedString(@"two_passwords_not_match", nil)];
        return NO;
    }

    return YES;
}

#pragma mark 按钮响应
-(void)onSavePress
{
    if (self.localDevice.flag)      //设备已经初始化过密码
    {
        if (![self checkForAddLocalDevice]) {
            return;
        }
        
        NSString* name = [_textFieldName text];
        NSString* pwd = [_textFieldPassword text];
        
        Contact *contact = [[Contact alloc] init];
        contact.contactId = _localDevice.contactId;
        contact.contactName = name;
        
        if([_localDevice.contactId characterAtIndex:0]!='0')
        {
            contact.contactPassword = pwd;
            contact.contactType = CONTACT_TYPE_UNKNOWN;
        }
        else
        {
            contact.contactType = CONTACT_TYPE_PHONE;
        }
        [[FListManager sharedFList] insert:contact];
        [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
        [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
        
        [contact release];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(alertAddClickOK:deviceName:)])
        {
            [self.delegate alertAddClickOK:_localDevice deviceName:name];
        }
    }
    else
    {
        if (![self checkForInitPassword]) {
            return;
        }
        
        NSString* pwd = _textFieldPassword.text;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(setInitPasswrod:pwd:)])
        {
            [self.delegate setInitPasswrod:self.localDevice.contactId pwd:pwd];
        }
    }
}

-(void)onCancelPress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertAddClickCancel)])
    {
        [self.delegate alertAddClickCancel];
    }
}


@end
