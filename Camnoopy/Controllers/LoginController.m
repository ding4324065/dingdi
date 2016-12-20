

#import "LoginController.h"
#import "Constants.h"
#import "Utils.h"
#import "Toast+UIView.h"
#import "NetManager.h"
#import "MBProgressHUD.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "AccountResult.h"
#import "Toast+UIView.h"
#import "ChooseCountryController.h"
#import "EmailRegisterController.h"
#import "CheckNewMessageResult.h"
#import "GetContactMessageResult.h"
#import "Message.h"
#import "MessageDAO.h"
#import "FListManager.h"
#import "ContactDAO.h"
#import "NewRegisterController.h"

enum
{
    loginType_id,
    loginType_email,
    loginType_phone,
    loginType_unknown
};
#define Remember_PWD_User_Btn 1001
#define Remember_PWD_Phone_Btn 1002
@interface LoginController ()
{
    BOOL _isShowingRememberPwdPrompt;
}
@end

@implementation LoginController

-(void)dealloc{
    [self.usernameField1 release];
    [self.passwrodField1 release];
    [self.progressAlert release];
    [self.lastRegisterId release];
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    /*
     *设置通知监听者，监听键盘的显示、收起通知
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    /*
     *将已经存在的注册ID显示在用户名区
     */
    self.usernameField1.text = [[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME];
    
    /*
     回话错误，重新登陆
     */
    if(self.isSessionIdError){
        self.isSessionIdError = !self.isSessionIdError;
        [self.view makeToast:NSLocalizedString(@"session_error", nil) duration:2.0 position:@"center"];
        
    }
    
    //check P2PVerfyCode
    if(self.isP2PVerifyCodeError){
        self.isP2PVerifyCodeError = !self.isP2PVerifyCodeError;
        NSString *codeError = [NSString stringWithFormat:@"%@(46)",NSLocalizedString(@"id_internal_error", nil)];
        [self.view makeToast:codeError duration:2.0 position:@"center"];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    /*
     *移除对键盘将要显示、收起的监听
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
     *初始化用户登录的类型，分别是邮箱登录、手机号登录
     *0表示邮箱登录；1表示手机号登录
     */
    [self initComponent];
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 *设置登录按钮的 iPhone和iPad的高度
 */
#define LOGIN_BTN_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:38)
#define SEGMENT_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:38)
/*
 *设置注册图标的 宽 和 高
 */
#define REGISTER_ICON_WIDTH_AND_HEIGHT 24
/*
 *设置匿名登录按钮的 iPhone、iPad高 和 宽
 */
#define ANONYMOUS_BTN_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50:30)
#define ANONYMOUS_BTN_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100:100)

-(void)initComponent{
    /*
     *第三方类MBProgressHUD:
     *没有理解这个语句的意义
     *类MBProgressHUD的作用是什么？
     */
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIImageView* imageViewBg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    UIImage* imgBg = [UIImage imageNamed:@"about_bk"];
    [imageViewBg setImage:imgBg];
    [self.view addSubview:imageViewBg];
    [imageViewBg release];
    
    UIImageView* imgViewAcount=[[UIImageView alloc]initWithFrame:CGRectMake(width/2-30, 50, 70, 70)];
    UIImage* imgAccount = [UIImage imageNamed:@"mainContainer0"];
    [imgViewAcount setImage:imgAccount];
    [self.view addSubview:imgViewAcount];
    [imgViewAcount release];
    
    
    
    UIView *mainView1 = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+60, width, height-NAVIGATION_BAR_HEIGHT-60)];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(5, 20, width - 10, TEXT_FIELD_HEIGHT*1.2)];
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_username", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [mainView1 addSubview:field1];
    self.usernameField1 = field1;
    [field1 release];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(5, 20+TEXT_FIELD_HEIGHT*1.2, width - 10, TEXT_FIELD_HEIGHT*1.2)];
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = NSLocalizedString(@"input_password", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    field2.secureTextEntry = YES;
    field2.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_PWD"];//记住用户的登录密码

    [mainView1 addSubview:field2];
    self.passwrodField1 = field2;
    [field2 release];
    
    
    //增加一个按钮，根据用户的需求，是否要记住密码
    UIButton *rememberPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rememberPwdBtn.frame = CGRectMake(self.passwrodField1.frame.size.width-self.passwrodField1.frame.size.height, 0.0, self.passwrodField1.frame.size.height, self.passwrodField1.frame.size.height);
    rememberPwdBtn.tag = Remember_PWD_User_Btn;
    [rememberPwdBtn addTarget:self action:@selector(btnClickToRememberOrNot:) forControlEvents:UIControlEventTouchUpInside];
    //按钮图片
    //图片与按钮框上、右、下、左之间的距离
    CGFloat space_btnImg_BtnBorder = 10.0;
    //图片的宽、高
    CGFloat btnImg_wh = rememberPwdBtn.frame.size.height-space_btnImg_BtnBorder*2;
    UIImageView *btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(space_btnImg_BtnBorder, space_btnImg_BtnBorder, btnImg_wh, btnImg_wh)];
    NSString *rememberUserPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_PWD"];
    if (rememberUserPwd && rememberUserPwd.length>0) {
        self.isRememberUserPWD = YES;
        btnImageView.image = [UIImage imageNamed:@"ic_remember_pwd.png"];
    }else{
        self.isRememberUserPWD = NO;
        btnImageView.image = [UIImage imageNamed:@"ic_unremember_pwd.png"];
    }
    [rememberPwdBtn addSubview:btnImageView];
    [self.passwrodField1 addSubview:rememberPwdBtn];
    
    
    /* 登陆button */
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    loginBtn.frame = CGRectMake(5, TEXT_FIELD_HEIGHT*2+20*3, width - 10, LOGIN_BTN_HEIGHT);
    loginBtn.backgroundColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    [loginBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    [loginBtn addTarget:self action:@selector(onLoginPress:) forControlEvents:UIControlEventTouchUpInside];
    [mainView1 addSubview:loginBtn];
    
    //忘记密码
    CGFloat forgetLabelWidth1 = [Utils getStringWidthWithString:NSLocalizedString(@"forget_password", nil) font:XFontBold_14 maxWidth:width];
    UIButton *forgetButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetButton1.frame = CGRectMake(10, mainView1.frame.size.height - 40, forgetLabelWidth1, TEXT_FIELD_HEIGHT);
    UILabel *forgetLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, forgetButton1.frame.size.width, forgetButton1.frame.size.height)];
    forgetLabel1.textAlignment = NSTextAlignmentRight;
    forgetLabel1.textColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    forgetLabel1.backgroundColor = XBGAlpha;
    forgetLabel1.text = NSLocalizedString(@"forget_password", nil);
    forgetLabel1.font = XFontBold_14;
    [forgetButton1 addSubview:forgetLabel1];
    [forgetLabel1 release];
    [forgetButton1 addTarget:self action:@selector(onForgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [mainView1 addSubview:forgetButton1];
    
    //注册
    CGFloat registLabelWidth = [Utils getStringWidthWithString:NSLocalizedString(@"new_account_register", nil) font:XFontBold_14 maxWidth:width];
    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registButton.frame = CGRectMake(mainView1.frame.size.width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT-registLabelWidth, mainView1.frame.size.height - 40, registLabelWidth, TEXT_FIELD_HEIGHT);
    UILabel *registLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,registButton.frame.size.width,registButton.frame.size.height)];
    registLabel.textAlignment = NSTextAlignmentRight;
    registLabel.textColor =  [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    registLabel.backgroundColor = XBGAlpha;
    registLabel.text = NSLocalizedString(@"new_account_register", nil);
    registLabel.font = XFontBold_14;
    [registButton addSubview:registLabel];
    [registLabel release];
    [registButton addTarget:self action:@selector(onRegisterPress) forControlEvents:UIControlEventTouchUpInside];
    [mainView1 addSubview:registButton];
    
    
    self.mainView1 = mainView1;
    [self.view addSubview:mainView1];
    [mainView1 release];
    
    
    [self.view addSubview:self.progressAlert];
    
    
    //记住用户的登录密码
    //点击记住或不记住按钮时，弹出的提示
    CGFloat rememberPwdPrompt_w = 180.0;
    CGFloat rememberPwdPrompt_h = 80.0;
    //图标宽、高
    CGFloat imageViewPrompt_wh = 20.0;
    //文字宽、高
    CGFloat labelPrompt_w = [Utils getStringWidthWithString:NSLocalizedString(@"un_rem_pass", nil) font:XFontBold_16 maxWidth:width];
    CGFloat labelPrompt_h = [Utils getStringHeightWithString:NSLocalizedString(@"un_rem_pass", nil) font:XFontBold_16 maxWidth:width];
    CGFloat space = (rememberPwdPrompt_h-imageViewPrompt_wh-labelPrompt_h)/3;
    
    UIView *rememberPwdPrompt = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-rememberPwdPrompt_w)/2, (self.view.frame.size.height-rememberPwdPrompt_h)/3, rememberPwdPrompt_w, rememberPwdPrompt_h)];
    rememberPwdPrompt.backgroundColor = UIColorFromRGBA(0x00000090);
    rememberPwdPrompt.layer.cornerRadius = 5.0;
    rememberPwdPrompt.layer.borderColor = UIColorFromRGB(0x444242).CGColor;
    rememberPwdPrompt.layer.borderWidth = 2.0;
    [self.view addSubview:rememberPwdPrompt];
    self.rememberPwdPrompt = rememberPwdPrompt;
    [self.rememberPwdPrompt setHidden:YES];
    _isShowingRememberPwdPrompt = NO;
    [rememberPwdPrompt release];
    //图标提示
    UIImageView *imageViewPrompt = [[UIImageView alloc] initWithFrame:CGRectMake((self.rememberPwdPrompt.frame.size.width-imageViewPrompt_wh)/2, space, imageViewPrompt_wh, imageViewPrompt_wh)];
    [rememberPwdPrompt addSubview:imageViewPrompt];
    [imageViewPrompt release];
    //文字提示
    UILabel *labelPrompt = [[UILabel alloc] initWithFrame:CGRectMake((self.rememberPwdPrompt.frame.size.width-labelPrompt_w)/2, space*2+imageViewPrompt_wh, labelPrompt_w, labelPrompt_h)];
    labelPrompt.backgroundColor = XBGAlpha;
    labelPrompt.font = XFontBold_16;
    labelPrompt.textColor = UIColorFromRGB(0x52a0e0);
    labelPrompt.textAlignment = NSTextAlignmentCenter;
    [rememberPwdPrompt addSubview:labelPrompt];
    [labelPrompt release];

    
}

#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
//    键盘的位置和大小
    NSDictionary *userInfo = [notification userInfo];
//    获取键盘结束的位置
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DLog(@"%f",rect.size.height);
    //    CGRect windowRect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    //    CGFloat width = windowRect.size.width;
    //    CGFloat height = windowRect.size.height;
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGFloat offset1 = self.mainView1.frame.size.height-(self.passwrodField1.frame.origin.y+self.passwrodField1.frame.size.height);
                        CGFloat finalOffset = 0;
                        if (offset1-rect.size.height<20) {
                            finalOffset =  20-(offset1-rect.size.height);
                        }
                        
                        self.view.transform = CGAffineTransformMakeTranslation(0, -finalOffset);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark 键盘将要收起时，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{
    DLog(@"onKeyBoardWillHide");
    
    DLog(@"%f",rect.size.height);
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

-(void)onProgressAlertExit{
    sleep(1.5);
    [self.view makeToast:NSLocalizedString(@"user_unexist", nil)];
}

-(void)lightButton:(UIView*)view{
    view.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    view.backgroundColor = XWhite;
}

-(void)onForgetPassword:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cloudlinks.cn/pw/"]];//域名更改(忘记密码)
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://6sci.com.cn/pw/"]];
}

#pragma mark - 点击登录按钮
-(void)onLoginPress:(id)sender
{
    NSString *username = self.usernameField1.text;
    NSString *password = self.passwrodField1.text;
    
    /*
     *根据用户输入的信息完整程度，给出相应的提示
     */
    if(!username||!username.length>0)
    {
        [self.view makeToast:NSLocalizedString(@"unInputUsername", nil)];
        return;
    }
    
    //检查username的合法性
    int loginType = [self GetType:[username UTF8String]];
    if (loginType_id == loginType) {
        if (![self checkUserID:[username UTF8String]]) {
            loginType = loginType_unknown;
        }
    }
    else if (loginType_email == loginType) {
        if (![self checkEmail:[username UTF8String]]) {
            loginType = loginType_unknown;
        }
    }
    else if (loginType_phone == loginType) {
        if (![self checkPhoneNo:[username UTF8String]]) {
            loginType = loginType_unknown;
        }
    }
    
    if (loginType_unknown == loginType) {
        self.progressAlert.dimBackground = YES;
        [self.progressAlert showWhileExecuting:@selector(onProgressAlertExit) onTarget:self withObject:Nil animated:YES];
        return;
    }
    
    
    if(!password||!password.length>0)
    {
        [self.view makeToast:NSLocalizedString(@"unInputPassword", nil)];
        return;
    }
    
    //----
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
//    [self.progressAlert setLabelText:NSLocalizedString(@"logining_to_webserver", nil)];
    
    NSString* loginName = username;
    if (loginType_id == loginType) {
        NSInteger iUsername = username.integerValue | 0x80000000;
        loginName = [NSString stringWithFormat:@"%d",(int)iUsername];
    }
    
    [[NetManager sharedManager] loginWithUserName:loginName password:password token:[AppDelegate sharedDefault].token callBack:^(id result)
     {
         LoginResult *loginResult = (LoginResult*)result;
         [self.progressAlert hide:YES];
         //记住用户的登录密码
         if (self.isRememberUserPWD) {
             //用户登录时，则记下用户的登录密码；用于下次登录时，不用再输入PWD
             [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"USER_PWD"];
         }else{
             [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"USER_PWD"];
         }
         switch(loginResult.error_code)
         {
             case NET_RET_LOGIN_SUCCESS:
             {
                 if (CURRENT_VERSION<9.3) {
                     
                     if(CURRENT_VERSION>=8.0)
                     {
                         //8.0以后使用这种方法来注册推送通知
                         
                         UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
                         [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                         
                         [[UIApplication sharedApplication] registerForRemoteNotifications];
                         
                     }
                     else
                     {
                         [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
                     }
                 }
                 
                 AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
                 del.iAlarmLogCount = 0;
                 
                 
                 [UDManager setIsLogin:YES];
                 [UDManager setLoginInfo:loginResult];
                 [[NSUserDefaults standardUserDefaults] setObject:username forKey:USER_NAME];
                 MainContainer* mainController = [[MainContainer alloc]init];
                 self.view.window.rootViewController = mainController;
                 [[AppDelegate sharedDefault] setMainController:mainController];
                 [mainController release];
                 
                 [[AppDelegate sharedDefault] reRegisterForRemoteNotifications];
                 
                 if (loginType != loginType_phone)
                 {
                     [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
                         AccountResult *accountResult = (AccountResult*)JSON;
                         loginResult.email = accountResult.email;
                         loginResult.phone = accountResult.phone;
                         loginResult.countryCode = accountResult.countryCode;
                         [UDManager setLoginInfo:loginResult];
                     }];
                 }
             }
                 break;
                 
             case NET_RET_LOGIN_USER_UNEXIST:
             {
                 [self.view makeToast:NSLocalizedString(@"user_unexist", nil)];
             }
                 break;
                 
             case NET_RET_LOGIN_PWD_ERROR:
             {
                 [self.view makeToast:NSLocalizedString(@"password_error", nil)];
             }
                 break;
                 
             case NET_RET_UNKNOWN_ERROR:
             {
                 [self.view makeToast:NSLocalizedString(@"login_failure", nil)];
             }
                 break;
                 
             default:
             {
                 [self.view makeToast:NSLocalizedString(@"login_failure", nil)];
             }
                 break;
         }
     }];
}

-(void)onRegisterPress{
    
    NewRegisterController *newRegisterController = [[NewRegisterController alloc]init];
    [self.navigationController pushViewController:newRegisterController animated:YES];
    [newRegisterController release];
    
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

-(int)GetType:(const char*)szText
{
    int iCount = 0;
    //检查email
    const char* pCH = szText;
    BOOL fgHadEmailSyb = FALSE;
    BOOL fgHadDot = FALSE;
    BOOL fgHadAddSym = FALSE;
    BOOL fgHadSubSym = FALSE;
    while(1)
    {
        if (*pCH == 0)
            break;
        
        if (*pCH == '@')
            fgHadEmailSyb = TRUE;
        if (*pCH == '.')
            fgHadDot = TRUE;
        if (*pCH == '-')
            fgHadAddSym = TRUE;
        if (*pCH == '+')
            fgHadSubSym = TRUE;
        pCH++;
        iCount++;
    }
    if (fgHadEmailSyb && fgHadDot)
    {
        return loginType_email;
    }
    
    if (fgHadAddSym && fgHadSubSym)
    {
        return loginType_phone;
    }
    
    if (iCount > 9)
    {
        return loginType_phone;
    }
    else
    {
        if (*szText == '0')
        {
            return loginType_id;
        }
        else
        {
            return loginType_phone;
        }
    }
    
    return loginType_unknown;
}

-(BOOL) checkUserID:(const char *) pUser
{
    if (*pUser != '0')
    {
        return FALSE;
    }
    if (strlen(pUser)>9)
    {
        return FALSE;
    }
    
    const char* pCH = pUser;
    while(1)
    {
        if (*pCH == 0)
            break;
        
        if (*pCH > '9' || *pCH < '0')
            return FALSE;
        
        pCH++;
    }
    
    return TRUE;
}

-(BOOL) checkEmail:(const char *) pUser
{
    BOOL fgHadEmailSyb = FALSE;
    BOOL fgHadDot = FALSE;
    
    //.在@前面出现-非法
    const char* pCH = pUser;
    while(1)
    {
        if (*pCH == 0)
            break;
        
        if (*pCH == '@')
        {
            fgHadEmailSyb = TRUE;
        }
        if (*pCH == '.')
        {
            if (fgHadEmailSyb == FALSE)
            {
                return FALSE;
            }
            fgHadDot = TRUE;
        }
        pCH++;
    }
    
    if (!fgHadDot || !fgHadDot)
        return FALSE;
    
    
    return TRUE;
}

-(BOOL) checkPhoneNo:(const char *) pUser
{
    const char* pCH = pUser;
    BOOL fgHadAddSym = FALSE;
    BOOL fgHadSubSym = FALSE;
    int nPosSub = 0;
    int nPosAdd = 0;
    int nIndex = 0;
    
    //只允许出现1~9 + -
    while(1)
    {
        if (*pCH == 0)
            break;
        
        if ((*pCH <= '9' && *pCH >= '0') || *pCH == '+' || *pCH == '-')
        {
            if(*pCH == '+')
            {
                nPosAdd = nIndex;
                fgHadAddSym = TRUE;
            }
            
            if (*pCH == '-')
            {
                nPosSub = nIndex;
                fgHadSubSym = TRUE;
            }
        }
        else
        {
            return FALSE;
        }
        
        nIndex++;
        pCH++;
    }
    
    // +-一定要同时出现
    if ((fgHadSubSym && !fgHadAddSym) || (!fgHadSubSym && fgHadAddSym))
        return FALSE;
    
    //-在+后面
    if (fgHadSubSym && fgHadAddSym && nPosSub < nPosAdd)
        return FALSE;
    
    //-前最多4位，后最多15位
    if (nPosSub >= 6)
    {
        return FALSE;
    }
    
    int lengthNumber = strlen(pUser) - (nPosSub+1);
    if (lengthNumber > 15)
        return FALSE;
    
    return TRUE;
}

#pragma mark - 显示记住或不记住密码提示
-(void)showRememberPwdPrompt:(BOOL)isRememberPwd{//记住用户的登录密码
    UIImageView *imageViewPrompt = [[self.rememberPwdPrompt subviews] objectAtIndex:0];
    UILabel *labelPrompt = [[self.rememberPwdPrompt subviews] objectAtIndex:1];
    if (isRememberPwd) {
        imageViewPrompt.image = [UIImage imageNamed:@"ic_remember_pwd.png"];
        labelPrompt.text = NSLocalizedString(@"rem_pass", nil);
    }else{
        imageViewPrompt.image = [UIImage imageNamed:@"ic_unremember_pwd.png"];
        labelPrompt.text = NSLocalizedString(@"un_rem_pass", nil);
    }
    [self.rememberPwdPrompt setHidden:NO];
    _isShowingRememberPwdPrompt = YES;
    
    
    self.rememberPwdPrompt.transform = CGAffineTransformMakeScale(1, 0.1);
    [UIView transitionWithView:self.rememberPwdPrompt duration:0.1 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGAffineTransform transform1 = CGAffineTransformScale(self.rememberPwdPrompt.transform, 1, 10);
                        self.rememberPwdPrompt.transform = transform1;
                    }
                    completion:^(BOOL finished){
                        usleep(800000);
                        [UIView transitionWithView:self.rememberPwdPrompt duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                                        animations:^{
                                            
                                            CGAffineTransform transform1 = CGAffineTransformScale(self.rememberPwdPrompt.transform, 1, 0.1);
                                            self.rememberPwdPrompt.transform = transform1;
                                        }
                                        completion:^(BOOL finished){
                                            [self.rememberPwdPrompt setHidden:YES];
                                            _isShowingRememberPwdPrompt = NO;
                                        }
                         ];
                    }
     ];
}


#pragma mark - 是否要记住登录密码
-(void)btnClickToRememberOrNot:(UIButton *)button{//记住用户的登录密码
    if (_isShowingRememberPwdPrompt) {
        return;
    }
    
    if (button.tag == Remember_PWD_User_Btn) {
        UIImageView *btnImageView = [[button subviews] objectAtIndex:0];
        
        if (self.isRememberUserPWD) {
            //表示不记住用户的登录密码
            self.isRememberUserPWD = NO;
            btnImageView.image = [UIImage imageNamed:@"ic_unremember_pwd.png"];
            [self showRememberPwdPrompt:NO];
        }else{
            //记住登录密码
            self.isRememberUserPWD = YES;
            btnImageView.image = [UIImage imageNamed:@"ic_remember_pwd.png"];
            [self showRememberPwdPrompt:YES];
        }
    }else{
        UIImageView *btnImageView2 = [[button subviews] objectAtIndex:0];
        
        if (self.isRememberPhonePWD) {
            //表示不记住用户的登录密码
            self.isRememberPhonePWD = NO;
            btnImageView2.image = [UIImage imageNamed:@"ic_unremember_pwd.png"];
            [self showRememberPwdPrompt:NO];
        }else{
            //记住登录密码
            self.isRememberPhonePWD = YES;
            btnImageView2.image = [UIImage imageNamed:@"ic_remember_pwd.png"];
            [self showRememberPwdPrompt:YES];
        }
    }
}

@end
