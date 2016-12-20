

#import "BindPhoneController.h"
#import "Constants.h"
#import "TopBar.h"
#import "MBProgressHUD.h"
#import "Utils.h"
#import "NetManager.h"
#import "AppDelegate.h"
#import "ChooseCountryController.h"
#import "Toast+UIView.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "BindPhoneController2.h"
#import "AccountController.h"
#import "LoginController.h"
#import "PhoneRegisterController.h"
@interface BindPhoneController ()

@end

@implementation BindPhoneController

-(void)dealloc{
    [self.field1 release];
    [self.progressAlert release];
    [self.countryCode release];
    [self.countryName release];
    [self.accountController release];
    [self.loginController release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
//    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    if (self.isRegister) {
        TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
        [topBar setBackButtonHidden:NO];
        [topBar setRightButtonHidden:NO];
        [topBar setRightButtonText:NSLocalizedString(@"next", nil)];
        [topBar.rightButton addTarget:self action:@selector(onNextPress) forControlEvents:UIControlEventTouchUpInside];
        [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
        if(self.isRegister){
            [topBar setTitle:NSLocalizedString(@"register_account",nil)];
        }else{
            [topBar setTitle:NSLocalizedString(@"bind_phone",nil)];
        }
        [self.view addSubview:topBar];
        [topBar release];
    }
    
    /*
     *chooseCountryBtn
     *点击时，进入下一个界面，可以进行国家选择
     */
    UIButton *chooseCountryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.isRegister) {
        chooseCountryBtn.frame =CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    }else{
        chooseCountryBtn.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    }
    chooseCountryBtn.layer.cornerRadius = 2.0;
    chooseCountryBtn.layer.borderWidth = 1.0;
    chooseCountryBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    chooseCountryBtn.backgroundColor = XWhite;
    [chooseCountryBtn addTarget:self action:@selector(onChooseCountryPress:) forControlEvents:UIControlEventTouchUpInside];
    [chooseCountryBtn addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
    [chooseCountryBtn addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
    [chooseCountryBtn addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    [chooseCountryBtn addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    
    
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
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+TEXT_FIELD_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if (!self.isRegister) {
        field1.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20+TEXT_FIELD_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    }
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_phone", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.keyboardType = UIKeyboardTypeNumberPad;
   // field1.delegate = self;//神经病才会这样写
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [field1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.field1 = field1;
    [self.view addSubview:field1];
    [field1 release];
    
    UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"new_button.png"] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    [button setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame=CGRectMake(20,field1.frame.size.height+field1.frame.origin.y+10, width-2*20, 34);
    [button addTarget:self action:@selector(onNextPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    //[button release];
    /*
     *第三方类MBProgressHUD
     *在此的作用是什么？
     */
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}
#pragma mark 输入框限制
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 64) {
        textField.text = [textField.text substringToIndex:64];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return [self validateNumber:string];
}


- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

-(void)onBackPress{
    if (self.isRegister) {
       [self.navigationController popViewControllerAnimated:YES];
    }else{
       [self.accountController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)onNextPress{
    NSString *phone = self.field1.text;
    
    if(!phone||!phone.length>0){
        [self.view makeToast:NSLocalizedString(@"input_phone", nil)];
        return;
    }
    
    if(phone.length<6||phone.length>15){
        [self.view makeToast:NSLocalizedString(@"phone_length_error", nil)];
        return;
    }
    
    if([self.countryCode isEqualToString:@"86"]){
        if (self.isRegister) {
            self.progressAlert.dimBackground = YES;
            [self.progressAlert show:YES];
        }else{
            self.accountController.progressAlert.dimBackground = YES;
            [self.accountController.progressAlert show:YES];
            [self.accountController sheetviewhiden];
        }
        [[NetManager sharedManager] getPhoneCodeWithPhone:phone countryCode:self.countryCode callBack:^(id JSON) {
            [self.progressAlert hide:YES];
            NSInteger error_code = [JSON integerValue];
            switch(error_code){
                case NET_RET_GET_PHONE_CODE_SUCCESS:
                {
                    BindPhoneController2 *bindPhoneController2 = [[BindPhoneController2 alloc] init];
                    bindPhoneController2.countryCode = self.countryCode;
                    bindPhoneController2.phoneNumber = phone;
                    bindPhoneController2.isRegister = self.isRegister;
                    bindPhoneController2.loginController = self.loginController;
                    bindPhoneController2.accountController = self.accountController;
                    if (self.isRegister) {
                        [self.navigationController pushViewController:bindPhoneController2 animated:YES];
                    }else{
                        [self.accountController.progressAlert hide:YES];
                        [self.accountController presentModalViewController:bindPhoneController2 animated:YES];
                    }
                    
                    [bindPhoneController2 release];
                }
                    break;
                case NET_RET_GET_PHONE_CODE_PHONE_USED:
                {
                    if (self.isRegister) {
                        [self.view makeToast:NSLocalizedString(@"phone_used", nil)];
                    }else{
                        [self.accountController.progressAlert hide:YES];
                        [self.accountController.view makeToast:NSLocalizedString(@"phone_used", nil)];
                    }
                }
                    break;
                case NET_RET_GET_PHONE_CODE_FORMAT_ERROR:
                {
                    if (self.isRegister) {
                        [self.view makeToast:NSLocalizedString(@"phone_format_error", nil)];
                    }else{
                        [self.accountController.progressAlert hide:YES];
                        [self.accountController.view makeToast:NSLocalizedString(@"phone_format_error", nil)];
                    }
                }
                    break;
                case NET_RET_GET_PHONE_CODE_TOO_TIMES:
                {
                    if (self.isRegister) {
                        [self.view makeToast:NSLocalizedString(@"get_phone_code_too_times", nil)];
                    }else{
                        [self.accountController.progressAlert hide:YES];
                        [self.accountController.view makeToast:NSLocalizedString(@"get_phone_code_too_times", nil)];
                    }
                }
                    break;
                default:
                {
                    if (self.isRegister) {
                        [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"unknown_error", nil),error_code]];
                    }else{
                        [self.accountController.progressAlert hide:YES];
                        [self.accountController.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"unknown_error", nil),error_code]];
                    }
                }
                    break;
            }
        }];
    }else{
        if(self.isRegister){
            PhoneRegisterController *phoneRegisterController = [[PhoneRegisterController alloc] init];
            phoneRegisterController.loginController = self.loginController;
            phoneRegisterController.phone = phone;
            phoneRegisterController.countryCode = self.countryCode;
            phoneRegisterController.phoneCode = @"";
            [self.navigationController pushViewController:phoneRegisterController animated:YES];
            [phoneRegisterController release];
        }else{
            UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
            inputAlert.tag = ALERT_TAG_BIND_PHONEs_AFTER_INPUT_PASSWORD;
            [inputAlert show];
            [inputAlert release];
        }
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_BIND_PHONEs_AFTER_INPUT_PASSWORD:
        {
            if(buttonIndex==1){
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                NSString *phone = self.field1.text;
                LoginResult *loginResult = [UDManager getLoginInfo];
                [[NetManager sharedManager] setAccountInfo:loginResult.contactId password:inputPwd phone:phone email:loginResult.email countryCode:self.countryCode phoneCheckCode:@"" flag:@"1" sessionId:loginResult.sessionId callBack:^(id JSON){
                    [self.progressAlert hide:YES];
                    NSInteger error_code = [JSON integerValue];
                    switch (error_code) {
                        case NET_RET_SET_ACCOUNT_SUCCESS:
                        {
                            loginResult.phone = phone;
                            loginResult.countryCode = self.countryCode;
                            [UDManager setLoginInfo:loginResult];
                            [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                sleep(1.0);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.navigationController popViewControllerAnimated:YES];
                                });
                            });
                            
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PASSWORD_ERROR:
                        {
                            [self.view makeToast:NSLocalizedString(@"password_error", nil)];
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PHONE_USED:
                        {
                            [self.view makeToast:NSLocalizedString(@"phone_used", nil)];
                            break;
                        }
                        default:
                        {
                            [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"unknown_error", nil),error_code]];
                        }
                            break;
                    }
                }];
            }
        }
            break;
            
            
            
    }
}

-(void)lightButton:(UIView*)view{
    view.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    view.backgroundColor = XWhite;
}

#pragma mark - 调用时，进入国家选择界面
-(void)onChooseCountryPress:(UIButton*)button{
    [self normalButton:button];
    ChooseCountryController *chooseCountryController = [[ChooseCountryController alloc] init];
    chooseCountryController.bindPhoneController = self;
    if (self.isRegister) {
        [self presentViewController:chooseCountryController animated:YES completion:nil];
    }else{
        [self.accountController presentViewController:chooseCountryController animated:YES completion:nil];
    }
    [chooseCountryController release];
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
@end
