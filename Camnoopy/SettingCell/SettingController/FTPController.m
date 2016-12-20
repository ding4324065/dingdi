//
//  FTPController.m
//  Camnoopy
//
//  Created by 卡努比 on 16/5/24.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "FTPController.h"
#import "Constants.h"
#import "Contact.h"
#import "TopBar.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "P2PClient.h"
#import "mesg.h"
@interface FTPController ()

@end

#define MARGIN_LEFT_RIGHT 5.0
@implementation FTPController

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //write code here...
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    /*
     *设置通知监听者，监听键盘的显示、收起通知
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];//delete
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];//delete
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //write code here ...
    /*
     *移除对键盘将要显示、收起的监听
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];//delete
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];//delete
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[P2PClient sharedClient] getFTPWithId:self.contact.contactId password:self.contact.contactPassword];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch (key) {
        case RET_SET_FTP:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            if (result == MESG_SET_OK) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [[P2PClient sharedClient] getFTPWithId:self.contact.contactId password:self.contact.contactPassword];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
            }else if (result == 106){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"FTP_format_error", nil)];
                });
            }else if(result == 107){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"FTP_format_error", nil)];
                });
            }
        }
            break;
        case RET_GET_FTP:{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.serverAddress = [parameter valueForKey:@"hostname"];
                self.serverAddressTextField.text = self.serverAddress;
                
                self.serverPort = [[parameter valueForKey:@"svrport"] intValue];
                self.ServerPortTextField.text = [NSString stringWithFormat:@"%d",self.serverPort];
                
                self.userName = [parameter valueForKey:@"usrname"];
                self.userNameTextField.text = self.userName;
                
                self.passWord = [parameter valueForKey:@"passwd"];
                self.passWordTextField.text = self.passWord;
                
                self.usrflag = [[parameter valueForKey:@"usrflag"] boolValue];
                if (self.usrflag) {
                    self.FTPSwitch.on = YES;
                }else{
                    self.FTPSwitch.on = NO;
                }
            });
        }
            break;
            
        default:
            break;
    }
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch (key) {
        case ACK_RET_SET_FTP:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == 1) {
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"FTP_format_error", nil)];
                }
                else if (result == 2){
                    [[P2PClient sharedClient] setFTPWithId:self.contact.contactId password:self.contact.contactPassword hostname:self.serverAddress usrname:self.userName FTPPassword:self.passWord svrport:self.serverPort usrflagtaye:self.usrflag];
                }
            });
        }
            break;
        case ACK_RET_GET_FTP:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"FTP_format_error", nil)];
                }else if(result==2){
                    DLog(@"resend get alarm email");
                    [[P2PClient sharedClient] getFTPWithId:self.contact.contactId password:self.contact.contactPassword];
                }
            });
        }
            break;
            
        default:
            break;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initComponet];
}

- (void)initComponet
{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonText:NSLocalizedString(@"save", nil)];
    [topBar.rightButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"FTP", nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    //手动配置view
    UIView *manualView = [[UIView alloc] initWithFrame:CGRectMake(0.0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    manualView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:manualView];
    self.manualView = manualView;
    [manualView release];
    
    //指示器
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.manualView] autorelease];
    self.progressAlert.labelText = NSLocalizedString(@"validating",nil);
    [self.view addSubview:self.progressAlert];
    [self.progressAlert release];
    //服务器地址
    UITextField *serverAddressTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, 20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        serverAddressTextField.layer.borderWidth = 1;
        serverAddressTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        serverAddressTextField.layer.cornerRadius = 5.0;
    }
//    删除按钮
    serverAddressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    serverAddressTextField.textAlignment = NSTextAlignmentLeft;
    serverAddressTextField.placeholder = NSLocalizedString(@"please_server_address", nil);
    serverAddressTextField.font = XFontBold_16;
    //borderStyle               //设置文本框风格： UITextBorderStyleNone(无任何边框),
//                                              UITextBorderStyleLine(线性边框),
//                                              UITextBorderStyleBezel(阴影效果边框),
//                                              UITextBorderStyleRoundedRect(圆角边框
    serverAddressTextField.borderStyle = UITextBorderStyleRoundedRect;
    //设置renturnKey按键类型
    serverAddressTextField.returnKeyType = UIReturnKeyDone;
    
    serverAddressTextField.text = self.serverAddress;
    //设置是否有自动修改提示：UITextAutocorrectionTypeDefault、NO、
    serverAddressTextField.autocorrectionType = UITextAutocapitalizationTypeNone;
    
    serverAddressTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.manualView addSubview:serverAddressTextField];
    
    //左边的view
    CGFloat serverAddressLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"server_address", nil) font:XFontBold_16 maxWidth:width];
    UILabel *serverAddressLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, serverAddressLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    serverAddressLeftLabel.backgroundColor = [UIColor clearColor];
    serverAddressLeftLabel.text = NSLocalizedString(@"server_address", nil);
    serverAddressLeftLabel.textAlignment = NSTextAlignmentLeft;
    serverAddressLeftLabel.font = XFontBold_16;
    serverAddressTextField.leftView = serverAddressLeftLabel;
    serverAddressTextField.leftViewMode = UITextFieldViewModeAlways;
    [serverAddressLeftLabel release];
    serverAddressTextField.delegate = self;
    self.serverAddressTextField = serverAddressTextField;
    [serverAddressTextField release];
    
    
    
    
    //端口
    UITextField *ServerPortTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.serverAddressTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        ServerPortTextField.layer.borderWidth = 1;
        ServerPortTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        ServerPortTextField.layer.cornerRadius = 5.0;
    }
    ServerPortTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    ServerPortTextField.textAlignment = NSTextAlignmentLeft;
    ServerPortTextField.placeholder = NSLocalizedString(@"please_port_number", nil);
    ServerPortTextField.font = XFontBold_16;
    ServerPortTextField.borderStyle = UITextBorderStyleRoundedRect;
    ServerPortTextField.returnKeyType = UIReturnKeyDone;
    ServerPortTextField.text = [NSString stringWithFormat:@"%d",self.serverPort];
    ServerPortTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    ServerPortTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.manualView addSubview:ServerPortTextField];
    //左边的view
    CGFloat ServerPortLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"port_number", nil) font:XFontBold_16 maxWidth:width];
    UILabel *ServerPortLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, ServerPortLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    ServerPortLeftLabel.backgroundColor = [UIColor clearColor];
    ServerPortLeftLabel.text = NSLocalizedString(@"port_number", nil);
    ServerPortLeftLabel.textAlignment = NSTextAlignmentLeft;
    ServerPortLeftLabel.font = XFontBold_16;
    ServerPortTextField.leftView = ServerPortLeftLabel;
    ServerPortTextField.leftViewMode = UITextFieldViewModeAlways;
    [ServerPortLeftLabel release];
    ServerPortTextField.delegate = self;
    self.ServerPortTextField = ServerPortTextField;
    [ServerPortTextField release];
    
    
    //名称
    UITextField *userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.ServerPortTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        userNameTextField.layer.borderWidth = 1;
        userNameTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        serverAddressTextField.layer.cornerRadius = 5.0;
    }
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userNameTextField.textAlignment = NSTextAlignmentLeft;
    userNameTextField.placeholder = NSLocalizedString(@"please_sever_name", nil);
    userNameTextField.font = XFontBold_16;
    userNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    userNameTextField.returnKeyType = UIReturnKeyDone;
    userNameTextField.text = self.userName;
    userNameTextField.autocorrectionType = UITextAutocapitalizationTypeNone;
    userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.manualView addSubview:userNameTextField];
    
    //左边的view
    CGFloat userNameLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"sever_name", nil) font:XFontBold_16 maxWidth:width];
    UILabel *userNameLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, userNameLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    userNameLeftLabel.backgroundColor = [UIColor clearColor];
    userNameLeftLabel.text = NSLocalizedString(@"sever_name", nil);
    userNameLeftLabel.textAlignment = NSTextAlignmentLeft;
    userNameLeftLabel.font = XFontBold_16;
    userNameTextField.leftView = userNameLeftLabel;
    userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    [userNameLeftLabel release];
    userNameTextField.delegate = self;
    self.userNameTextField = userNameTextField;
    [userNameTextField release];
    //
    //密码
    UITextField *passWordTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.userNameTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        passWordTextField.layer.borderWidth = 1;
        passWordTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        passWordTextField.layer.cornerRadius = 5.0;
    }
    passWordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passWordTextField.textAlignment = NSTextAlignmentLeft;
    passWordTextField.placeholder = NSLocalizedString(@"please_sever_password", nil);
    passWordTextField.font = XFontBold_16;
    passWordTextField.text = self.passWord;
    passWordTextField.borderStyle = UITextBorderStyleRoundedRect;
    passWordTextField.returnKeyType = UIReturnKeyDone;
    passWordTextField.autocorrectionType = UITextAutocapitalizationTypeNone;
    passWordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.manualView addSubview:passWordTextField];
    
    //左边的view
    CGFloat passWordLeftLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"sever_password", nil) font:XFontBold_16 maxWidth:width];
    UILabel *passWordLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, passWordLeftLabelWidth+5.0, TEXT_FIELD_HEIGHT)];
    passWordLeftLabel.backgroundColor = [UIColor clearColor];
    passWordLeftLabel.text = NSLocalizedString(@"sever_password", nil);
    passWordLeftLabel.textAlignment = NSTextAlignmentLeft;
    passWordLeftLabel.font = XFontBold_16;
    passWordTextField.leftView = passWordLeftLabel;
    passWordTextField.leftViewMode = UITextFieldViewModeAlways;
    [passWordLeftLabel release];
    passWordTextField.delegate = self;
    self.passWordTextField = passWordTextField;
    [passWordTextField release];
   
    //开启/关闭
    UIImageView *FTPimg = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.passWordTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    FTPimg.image = [UIImage imageNamed:@"whrite_bar_background"];
    FTPimg.layer.cornerRadius = 6.0;
    FTPimg.layer.masksToBounds = YES;
    FTPimg.backgroundColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    FTPimg.userInteractionEnabled = YES;
    [self.manualView addSubview:FTPimg];
    [FTPimg release];
    
    UILabel *FTPLable = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT,0 , MARGIN_LEFT_RIGHT*30, TEXT_FIELD_HEIGHT)];
    FTPLable.text = NSLocalizedString(@"FTP_lable", nil);
    FTPLable.font = XFontBold_16;
    FTPLable.textAlignment = NSTextAlignmentLeft;
    FTPLable.backgroundColor = [UIColor clearColor];
    self.FTPLable = FTPLable;
    [FTPimg addSubview:FTPLable];
    [FTPLable release];
    
    UISwitch *FTPSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(width - 80, TEXT_FIELD_HEIGHT/2-MARGIN_LEFT_RIGHT*3, width-TEXT_FIELD_HEIGHT*2, MARGIN_LEFT_RIGHT*2)];
    [FTPSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    self.FTPSwitch = FTPSwitch;
    [FTPimg addSubview:FTPSwitch];
    [FTPSwitch release];
}
- (void)switchAction: (UISwitch *)FTPSwitch
{
    self.usrflag = FTPSwitch.on;
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)onSavePress
{
    if (!self.serverAddressTextField.text || (!self.serverAddressTextField.text.length) > 0) {
        [self.view makeToast:NSLocalizedString(@"smtp_not_empty", nil)];
        return;
    }
    if (!self.ServerPortTextField.text || (!self.ServerPortTextField.text.length) > 0 ) {
        [self.view makeToast:NSLocalizedString(@"port_not_empty", nil)];
        return;
    }
    if (!self.userNameTextField.text || (!self.userNameTextField.text.length) > 0) {
        [self.view makeToast:NSLocalizedString(@"username_not_empty", nil)];
        return;
    }
    if (!self.passWordTextField.text || (!self.passWordTextField.text.length) > 0) {
        [self.view makeToast:NSLocalizedString(@"possword_not_empty", nil)];
        return;
    }
    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    
    self.serverAddress = self.serverAddressTextField.text;
    self.userName =self.userNameTextField.text;
    self.passWord = self.passWordTextField.text;
    self.serverPort = [self.ServerPortTextField.text intValue];
    [[P2PClient sharedClient] setFTPWithId:self.contact.contactId password:self.contact.contactPassword hostname:self.serverAddress usrname:self.userName FTPPassword:self.passWord svrport:self.serverPort usrflagtaye:self.usrflag];
}

#pragma mark return键
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(UITextField *)getCurrentEditingTextField{
    //获取正处于编辑状态的UITextField
    if (self.serverAddressTextField.editing) {
        return self.serverAddressTextField;
        
    }else if (self.ServerPortTextField.editing){
        return self.ServerPortTextField;
        
    }else if (self.userNameTextField.editing){
        return self.userNameTextField;
        
    }else if (self.passWordTextField.editing){
        return self.passWordTextField;
        
    }
    return nil;
}

-(void)onKeyBoardWillShow:(NSNotification*)notification{//delete
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //获取正处于编辑状态的UITextField
    UITextField *currentEditingTextField = [self getCurrentEditingTextField];
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGFloat offset1 = self.view.frame.size.height-(currentEditingTextField.frame.origin.y+currentEditingTextField.frame.size.height+NAVIGATION_BAR_HEIGHT);
                        CGFloat finalOffset;
                        if(offset1-rect.size.height<0){
                            finalOffset = rect.size.height-offset1+20;
                        }else {
                            if(offset1-rect.size.height>=20){
                                finalOffset = 0;
                            }else{
                                finalOffset = 20-(offset1-rect.size.height);
                            }
                            
                        }
                        self.view.transform = CGAffineTransformMakeTranslation(0, -finalOffset);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark 键盘将要收起时，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{//delete
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark - 屏幕竖屏
-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationPortrait );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
