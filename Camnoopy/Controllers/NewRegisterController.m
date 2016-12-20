//
//  NewRegisterController.m
//  Camnoopy
//
//  Created by Jie on 14/12/6.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "NewRegisterController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "EmailRegisterController.h"
#import "Utils.h"
#import "Toast+UIView.h"
#import "NetManager.h"
#import "BindPhoneController2.h"
#import "PhoneRegisterController.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "RegisterResult.h"

@interface NewRegisterController ()
{
    UIButton* _chooseCountryBtn;
}
@end

@implementation NewRegisterController

-(void)dealloc
{
    [self.leftLabel release];
    [self.rightLabel release];
    [self.fieldPhoneNumber release];
    [self.countryCode release];
    [self.countryName release];
    
    [self.fieldEmail1 release];
    [self.fieldEmail2 release];
    [self.fieldEmail3 release];
    
    [self.progressAlert release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initComponent];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!self.countryCode||!self.countryCode.length>0){
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        if([language hasPrefix:@"zh"]){
            self.countryCode = @"86";
            self.countryName = NSLocalizedString(@"china", nil);
        }else{
            self.countryCode = @"1";
            self.countryName = NSLocalizedString(@"america", nil);
        }
        
        
        
    }
    
    self.leftLabel.text = [NSString stringWithFormat:@"+%@",self.countryCode];
    self.rightLabel.text = self.countryName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define SEGMENT_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:38)
#define LOGIN_BTN_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:38)


-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"new_account_register",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"phone_register", nil),NSLocalizedString(@"email_register", nil)]];
    [segment addTarget:self action:@selector(onLoginTypeChange:) forControlEvents:UIControlEventValueChanged];
    segment.frame = CGRectMake(5, NAVIGATION_BAR_HEIGHT+20, width - 10, SEGMENT_HEIGHT);
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    segment.tintColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    segment.selectedSegmentIndex = self.registerType;
    [self.view addSubview:segment];
    [segment release];
    
    
    /* 下一步button */
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    nextBtn.frame = CGRectMake(5, height - LOGIN_BTN_HEIGHT - 5, width - 10, LOGIN_BTN_HEIGHT);
    [nextBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    nextBtn.backgroundColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    [nextBtn addTarget:self action:@selector(onNextPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    
    int intervalY = SEGMENT_HEIGHT + 20;
    //手机注册控件
    UIButton *chooseCountryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    chooseCountryBtn.frame =CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, intervalY+NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    chooseCountryBtn.layer.cornerRadius = 2.0;
    chooseCountryBtn.layer.borderWidth = 1.0;
    chooseCountryBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    chooseCountryBtn.backgroundColor = XWhite;
    [chooseCountryBtn addTarget:self action:@selector(onChooseCountryPress:) forControlEvents:UIControlEventTouchUpInside];
    _chooseCountryBtn = chooseCountryBtn;
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, chooseCountryBtn.frame.size.width/3, chooseCountryBtn.frame.size.height)];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.backgroundColor = XBGAlpha;
    leftLabel.textColor = XBlack;
    leftLabel.font = XFontBold_16;
    self.leftLabel = leftLabel;
    [leftLabel release];
    [chooseCountryBtn addSubview:self.leftLabel];
    
    UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(chooseCountryBtn.frame.size.width/3, 1, 0.5, chooseCountryBtn.frame.size.height-2)];
    separator.backgroundColor = [UIColor grayColor];
    [chooseCountryBtn addSubview:separator];
    [separator release];
    
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(chooseCountryBtn.frame.size.width/3+0.5, 0, chooseCountryBtn.frame.size.width/3*2-0.5, chooseCountryBtn.frame.size.height)];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.backgroundColor = XBGAlpha;
    rightLabel.textColor = XBlack;
    rightLabel.font = XFontBold_16;
    self.rightLabel = rightLabel;
    [rightLabel release];
    [chooseCountryBtn addSubview:self.rightLabel];
    
    [self.view addSubview: chooseCountryBtn];
    
    UITextField *fieldPhoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, intervalY+NAVIGATION_BAR_HEIGHT+20+TEXT_FIELD_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        fieldPhoneNumber.layer.borderWidth = 1;
        fieldPhoneNumber.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        fieldPhoneNumber.layer.cornerRadius = 5.0;
    }
    fieldPhoneNumber.textAlignment = NSTextAlignmentLeft;
    fieldPhoneNumber.placeholder = NSLocalizedString(@"input_phone", nil);
    fieldPhoneNumber.borderStyle = UITextBorderStyleRoundedRect;
    fieldPhoneNumber.returnKeyType = UIReturnKeyDone;
    fieldPhoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    fieldPhoneNumber.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    fieldPhoneNumber.autocapitalizationType = UITextAutocapitalizationTypeNone;
    fieldPhoneNumber.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [fieldPhoneNumber addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [fieldPhoneNumber addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    fieldPhoneNumber.delegate = self;
    self.fieldPhoneNumber = fieldPhoneNumber;
    [self.view addSubview:fieldPhoneNumber];
    [fieldPhoneNumber release];
    
    //邮箱注册控件
    UITextField *fieldEmail1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, intervalY+NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        fieldEmail1.layer.borderWidth = 1;
        fieldEmail1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        fieldEmail1.layer.cornerRadius = 5.0;
    }
    fieldEmail1.textAlignment = NSTextAlignmentLeft;
    fieldEmail1.placeholder = NSLocalizedString(@"input_email", nil);
    fieldEmail1.borderStyle = UITextBorderStyleRoundedRect;
    fieldEmail1.returnKeyType = UIReturnKeyDone;
    fieldEmail1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    fieldEmail1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [fieldEmail1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.fieldEmail1 = fieldEmail1;
    [self.view addSubview:fieldEmail1];
    [fieldEmail1 release];
    
    UITextField *fieldEmail2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, intervalY+NAVIGATION_BAR_HEIGHT + 20 + TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        fieldEmail2.layer.borderWidth = 1;
        fieldEmail2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        fieldEmail2.layer.cornerRadius = 5.0;
    }
    fieldEmail2.textAlignment = NSTextAlignmentLeft;
    fieldEmail2.placeholder = NSLocalizedString(@"input_password", nil);
    fieldEmail2.borderStyle = UITextBorderStyleRoundedRect;
    fieldEmail2.returnKeyType = UIReturnKeyDone;
    fieldEmail2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    fieldEmail2.secureTextEntry = YES;
    fieldEmail2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [fieldEmail2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.fieldEmail2 = fieldEmail2;
    [self.view addSubview:fieldEmail2];
    [fieldEmail2 release];
    
    UITextField *fieldEmail3 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, intervalY + NAVIGATION_BAR_HEIGHT + 20 + TEXT_FIELD_HEIGHT*2, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        fieldEmail3.layer.borderWidth = 1;
        fieldEmail3.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        fieldEmail3.layer.cornerRadius = 5.0;
    }
    fieldEmail3.textAlignment = NSTextAlignmentLeft;
    fieldEmail3.placeholder = NSLocalizedString(@"confirm_input", nil);
    fieldEmail3.borderStyle = UITextBorderStyleRoundedRect;
    fieldEmail3.returnKeyType = UIReturnKeyDone;
    fieldEmail3.secureTextEntry = YES;
    fieldEmail3.autocapitalizationType = UITextAutocapitalizationTypeNone;
    fieldEmail3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [fieldEmail3 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.fieldEmail3 = fieldEmail3;
    [self.view addSubview:fieldEmail3];
    [fieldEmail3 release];
    
    //显示
    [self showPageIndex:0];
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];

}

-(void)onBackPress{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onLoginTypeChange:(UISegmentedControl*)control{
    
    self.registerType = control.selectedSegmentIndex;
    [self showPageIndex:control.selectedSegmentIndex];
}

-(void)showPageIndex:(NSInteger)index
{
    _chooseCountryBtn.hidden = (index != 0);
    self.fieldPhoneNumber.hidden = (index != 0);
    
    self.fieldEmail1.hidden = (index == 0);
    self.fieldEmail2.hidden = (index == 0);
    self.fieldEmail3.hidden = (index == 0);
}

-(void)onNextPress{
    if (self.registerType==0) {
        [self onNextPhone];
    }else{
        [self onNextEmail];
    }
}

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

-(void)onChooseCountryPress:(UIButton*)button{
    ChooseCountryController *chooseCountryController = [[ChooseCountryController alloc] init];
    chooseCountryController.registerController = self;
    [self presentViewController:chooseCountryController animated:YES completion:nil];
    [chooseCountryController release];
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == _fieldPhoneNumber) {
        NSString* text = textField.text;
        for (int i=0; i<text.length; i++) {
            NSString* temp = [text substringWithRange:NSMakeRange(i,1)];
            if (![temp isValidateNumber]) {
                textField.text = [text substringWithRange:NSMakeRange(0,i)];
                return;
            }
        }
    }
    
    if (textField == _fieldPhoneNumber) {
        if (textField.text.length > 64) {
            textField.text = [textField.text substringToIndex:64];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _fieldPhoneNumber) {
        return [string isValidateNumber];
    }
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)onNextPhone{
    NSString *phone = self.fieldPhoneNumber.text;
    [self.fieldPhoneNumber resignFirstResponder];
    
    if(!phone||!phone.length>0){
        [self.view makeToast:NSLocalizedString(@"input_phone", nil)];
        return;
    }
    
    if(phone.length<6||phone.length>15){
        [self.view makeToast:NSLocalizedString(@"phone_length_error", nil)];
        return;
    }
    
    if([self.countryCode isEqualToString:@"86"]){
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];

        [[NetManager sharedManager] getPhoneCodeWithPhone:phone countryCode:self.countryCode callBack:^(id JSON) {
            [self.progressAlert hide:YES];
            NSInteger error_code = [JSON integerValue];
            switch(error_code){
                case NET_RET_GET_PHONE_CODE_SUCCESS:
                {
                    BindPhoneController2 *bindPhoneController2 = [[BindPhoneController2 alloc] init];
                    bindPhoneController2.countryCode = self.countryCode;
                    bindPhoneController2.phoneNumber = phone;
                    bindPhoneController2.isRegister = YES;
                    [self.navigationController pushViewController:bindPhoneController2 animated:YES];
                    [bindPhoneController2 release];
                }
                    break;
                case NET_RET_GET_PHONE_CODE_PHONE_USED:
                {
                    [self.view makeToast:NSLocalizedString(@"phone_used", nil)];
                }
                    break;
                case NET_RET_GET_PHONE_CODE_FORMAT_ERROR:
                {
                    [self.view makeToast:NSLocalizedString(@"phone_format_error", nil)];
                }
                    break;
                case NET_RET_GET_PHONE_CODE_TOO_TIMES:
                {
                    [self.view makeToast:NSLocalizedString(@"get_phone_code_too_times", nil)];
                }
                    break;
                default:
                {
                    [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"modify_failure", nil),error_code]];
                }
                    break;
            }
        }];
    }else{
        PhoneRegisterController *phoneRegisterController = [[PhoneRegisterController alloc] init];
        phoneRegisterController.phone = phone;
        phoneRegisterController.countryCode = self.countryCode;
        phoneRegisterController.phoneCode = @"";
        [self.navigationController pushViewController:phoneRegisterController animated:YES];
        [phoneRegisterController release];
    }
}

-(void)onNextEmail
{
    NSString *email = self.fieldEmail1.text;
    NSString *password = self.fieldEmail2.text;
    NSString *confirmPassword = self.fieldEmail3.text;
    
    if(!email||!email.length>0){
        [self.view makeToast:NSLocalizedString(@"input_email", nil)];
        return;
    }
    
    if(email.length<5||email.length>100){
        [self.view makeToast:NSLocalizedString(@"email_length_error", nil)];
        return;
    }
    
    if(!password||!password.length>0){
        [self.view makeToast:NSLocalizedString(@"input_password", nil)];
        return;
    }
    
    if(password.length>100){
        [self.view makeToast:NSLocalizedString(@"password_too_long", nil)];
        return;
    }
    
    if(!confirmPassword||!confirmPassword.length>0){
        [self.view makeToast:NSLocalizedString(@"confirm_input", nil)];
        return;
    }
    
    if(![password isEqualToString:confirmPassword]){
        [self.view makeToast:NSLocalizedString(@"two_passwords_not_match", nil)];
        return;
    }
    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    
    [[NetManager sharedManager] registerWithVersionFlag:@"1" email:email countryCode:@"" phone:@"" password:password repassword:confirmPassword phoneCode:@"" callBack:^(id JSON) {
        
        [self.progressAlert hide:YES];
        RegisterResult *registerResult = (RegisterResult*)JSON;
        
        
        switch(registerResult.error_code){
            case NET_RET_REGISTER_SUCCESS:
            {
                NSString* newID = [NSString stringWithFormat:@"%@",registerResult.contactId];
                [[NSUserDefaults standardUserDefaults] setObject:newID forKey:USER_NAME];
                
                UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"register_success_prompt", nil) message:[NSString stringWithFormat:@"ID:%@",registerResult.contactId] delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
                promptAlert.tag = ALERT_TAG_REGISTER_SUCCESS;
                [promptAlert show];
                [promptAlert release];
            }
                break;
            case NET_RET_REGISTER_EMAIL_FORMAT_ERROR:
            {
                [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
            }
                break;
            case NET_RET_REGISTER_EMAIL_USED:
            {
                [self.view makeToast:NSLocalizedString(@"email_used", nil)];
            }
                break;
                
            default:
            {
                [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"modify_failure", nil),registerResult.error_code]];
            }
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_REGISTER_SUCCESS:
        {
            if(buttonIndex==0){
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
            break;
    }
}

@end
