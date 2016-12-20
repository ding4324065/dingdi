
#define BIND_EMAIL_AFTER_INPUT_PASSWORD 5
#define LEFT_BAR_BTN_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50:25)
#define LEFT_BAR_BTN_MARGIN (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 30:15)

#define RIGHT_BAR_BTN_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 40:20)
#define RIGHT_BAR_BTN_MARGIN (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10:5)
#import "AccountController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"

#import "AccountCell.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "ModifyLoginPasswordController.h"
#import "MBProgressHUD.h"
#import "NetManager.h"
#import "Toast+UIView.h"
#import "BindPhoneController.h"
#import "ModifyLoginPasswordResult.h"
#import "ChooseCountryController.h"
@interface AccountController ()

@end

@implementation AccountController

-(void)dealloc{
    [self.progressAlert release];
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
    if(self.tableView){
        [self.tableView reloadData];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
 
    /*
     *移除对键盘将要显示、收起的监听
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self sheetviewhiden];//页面消失后，收起自定义类似弹框
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
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar.leftButton setHidden:NO];
    [topBar setLeftButtonIcon:[UIImage imageNamed:@"open_menu.png"]];
    [topBar.leftButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"account_information",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height/2, width, height/2)];
    backgroundView.image = [UIImage imageNamed:@"about_bk.png"];
    [self.view addSubview:backgroundView];
    
    self.view.layer.contents = (id)[UIImage imageNamed:@"background.png"].CGImage;
    
    
//    UIButton * BackBtn = [[UIButton alloc] init];
//    BackBtn.frame = CGRectMake(LEFT_BAR_BTN_MARGIN, LEFT_BAR_BTN_MARGIN + 17, LEFT_BAR_BTN_WIDTH, LEFT_BAR_BTN_WIDTH);
//    UIImage* img = [UIImage imageNamed:@"menuback.png"];
//    [BackBtn setImage:img forState:UIControlStateNormal];
//    [BackBtn addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:BackBtn];
//    [BackBtn release];
//    
//    UILabel * Backlabel = [[UILabel alloc] initWithFrame:CGRectMake(BackBtn.frame.origin.x+BackBtn.frame.size.width+5, BackBtn.frame.origin.y+5, 40, BackBtn.frame.size.height-5*2)];
//    Backlabel.backgroundColor = [UIColor clearColor];
//    Backlabel.text = NSLocalizedString(@"back", nil);
//    Backlabel.textColor = [UIColor whiteColor];
//    Backlabel.userInteractionEnabled = YES;
//    [Backlabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackPress)]];
//    [self.view addSubview:Backlabel];
//    [Backlabel release];
    
    UIView * bluebar = [[UIView alloc] initWithFrame:CGRectMake(0, height/2 - 20, width, 50)];
    bluebar.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0f];
    [self.view addSubview:bluebar];
    [bluebar release];
    
    UIImageView * phoneimg = [[UIImageView alloc] initWithFrame:CGRectMake(width/5, height/2 - 50, 60, 60)];
    phoneimg.layer.borderWidth = 1;
    phoneimg.layer.borderColor = [[UIColor whiteColor] CGColor];
    phoneimg.layer.cornerRadius = 30.0;
    phoneimg.clipsToBounds = YES;
    phoneimg.alpha = 0.8f;
    phoneimg.image = [UIImage imageNamed:@"myaccount.png"];
    phoneimg.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:phoneimg];
    [phoneimg release];
    
    UILabel * accountlabel = [[UILabel alloc] initWithFrame:CGRectMake(phoneimg.frame.origin.x+phoneimg.frame.size.width+10, bluebar.frame.origin.y+5, BAR_BUTTON_HEIGHT*2, 30)];
    accountlabel.textAlignment = NSTextAlignmentLeft;
    accountlabel.backgroundColor = XBGAlpha;
    [accountlabel setFont:XFontBold_14];
    LoginResult *loginResult = [UDManager getLoginInfo];
    accountlabel.text = loginResult.contactId;
    [self.view addSubview:accountlabel];
    [accountlabel release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, height/2 + 30, width, height/2)  style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
}
#pragma mark 自定义类似弹框
-(void)sheetViewinit{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIView * alphaView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    alphaView.backgroundColor = XBlack_128;
    [self.view addSubview:alphaView];
    self.alphaView = alphaView;
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, height/2+50)];
    view.backgroundColor = XWhite;
    //view.alpha = 0.3f;
    [alphaView addSubview:view];
    self.ModifyPasswordView = view;
    self.ModifyPasswordView.layer.contents = (id)[UIImage imageNamed:@"about_bk.png"].CGImage;
    [view release];
    [alphaView release];
    
#pragma mark - 修改登录密码
    UIView * headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    headview.backgroundColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    [self.ModifyPasswordView addSubview:headview];
    
    UILabel * headnamelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, width - 10, 30)];
    headnamelabel.backgroundColor = [UIColor clearColor];
    headnamelabel.textAlignment = NSTextAlignmentCenter;
    headnamelabel.textColor = XWhite;
    headnamelabel.text = NSLocalizedString(@"modify_password", nil);
    [self.ModifyPasswordView addSubview:headnamelabel];
    
    UIButton * DownBtn = [[UIButton alloc] init];
    DownBtn.frame = CGRectMake(width - 40, 5, 40, 34);
    UIImageView *downImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 20, 20)];
    downImage.image = [UIImage imageNamed:@"ic_down.png"];
    [DownBtn addSubview:downImage];
    [DownBtn addTarget:self action:@selector(sheetviewhiden) forControlEvents:UIControlEventTouchUpInside];
    [self.ModifyPasswordView addSubview:DownBtn];
    [DownBtn release];
    [downImage release];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT, width - 30, TEXT_FIELD_HEIGHT)];
    field1.textAlignment = NSTextAlignmentLeft;
    field1.backgroundColor = [UIColor whiteColor];
    field1.placeholder = NSLocalizedString(@"input_original_password", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.secureTextEntry = YES;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field1.keyboardType = UIKeyboardTypeDefault;
    //field1.delegate = self;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [field1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.OldPWtextView = field1;
    [self.ModifyPasswordView addSubview:field1];
    [field1 release];
    
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT + field1.frame.size.height + 5, width - 30, TEXT_FIELD_HEIGHT)];
    field2.textAlignment = NSTextAlignmentLeft;
    field2.backgroundColor = [UIColor whiteColor];
    field2.placeholder = NSLocalizedString(@"input_new_password", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.secureTextEntry = YES;
    field2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field2.keyboardType = UIKeyboardTypeDefault;
    //field2.delegate = self;
    [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [field2 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.NewPWtextView = field2;
    [self.ModifyPasswordView addSubview:field2];
    [field2 release];
    
    UITextField *field3 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT + field1.frame.size.height*2 + 10, width - 30, TEXT_FIELD_HEIGHT)];
    field3.textAlignment = NSTextAlignmentLeft;
    field3.backgroundColor = [UIColor whiteColor];
    field3.placeholder = NSLocalizedString(@"confirm_input", nil);
    field3.borderStyle = UITextBorderStyleRoundedRect;
    field3.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field3.returnKeyType = UIReturnKeyDone;
    field3.secureTextEntry = YES;
    field3.keyboardType = UIKeyboardTypeDefault;
    //field3.delegate = self;
    [field3 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [field3 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.ConfirmPWtextView = field3;
    [self.ModifyPasswordView addSubview:field3];
    [field3 release];
    
    //    UILabel * linelabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 40+TEXT_FIELD_HEIGHT, width, 1)];
    //    linelabel1.backgroundColor = XBlack;
    //    [self.ModifyPasswordView addSubview:linelabel1];
    //    [linelabel1 release];
    //
    //    UILabel * linelabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 40+TEXT_FIELD_HEIGHT*2, width, 1)];
    //    linelabel2.backgroundColor = XBlack;
    //    [self.ModifyPasswordView addSubview:linelabel2];
    //    [linelabel2 release];
    //确定按钮
    UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"new_button.png"] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    [button setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame=CGRectMake(20, NAVIGATION_BAR_HEIGHT + field1.frame.size.height*4, width-2*20, 34);
    [button addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [self.ModifyPasswordView addSubview:button];
    
    
    
}
-(void)UnBindViewinit{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    UIView * alphaView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    alphaView.backgroundColor = XBlack_128;
    [self.view addSubview:alphaView];
    self.alphaView = alphaView;
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, height/2+50)];
    view.backgroundColor = XWhite;
    [alphaView addSubview:view];
    self.UnBindView = view;
    self.UnBindView.layer.contents = (id)[UIImage imageNamed:@"about_bk.png"].CGImage;
    [view release];
    [alphaView release];
    
#pragma mark - 修改邮箱
    UIView * headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    headview.backgroundColor = [UIColor colorWithRed:3.0/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0f];
    [self.UnBindView addSubview:headview];
    
    UILabel * headnamelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, width-10, 30)];
    headnamelabel.backgroundColor = [UIColor clearColor];
    headnamelabel.textAlignment = NSTextAlignmentCenter;
    headnamelabel.textColor = XWhite;
    if (self.isUnBindEmail)
    {
        headnamelabel.text = NSLocalizedString(@"unbind_email", nil);
    }
    else
    {
        headnamelabel.text = NSLocalizedString(@"unbind_phone", nil);
    }
    [self.UnBindView addSubview:headnamelabel];
    
    UIButton * DownBtn = [[UIButton alloc] init];
    DownBtn.frame = CGRectMake(width - 40, 5, 40, 34);
    UIImageView *downImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 20, 20)];
    downImage.image = [UIImage imageNamed:@"ic_down.png"];
    [DownBtn addSubview:downImage];
    [DownBtn addTarget:self action:@selector(sheetviewhiden) forControlEvents:UIControlEventTouchUpInside];
    [self.UnBindView addSubview:DownBtn];
    [DownBtn release];
    [downImage release];
    
    
    UILabel * unbindlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, width, 60)];
    unbindlabel.textAlignment = NSTextAlignmentCenter;
    LoginResult *loginResult = [UDManager getLoginInfo];
    if (self.isUnBindEmail) {
        unbindlabel.frame = CGRectMake(0, 0, 0, 0);
        
        UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT, width - 30, TEXT_FIELD_HEIGHT)];
        field1.textAlignment = NSTextAlignmentLeft;
        LoginResult *loginResult = [UDManager getLoginInfo];
        field1.text = loginResult.email;
        field1.borderStyle = UITextBorderStyleRoundedRect;
        field1.returnKeyType = UIReturnKeyDone;
        field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [field1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.BindEmailtextView = field1;
        [self.UnBindView addSubview:field1];
        [field1 release];
        
        
        
        //下一步按钮
        UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"new_button.png"] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
        [button setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.frame=CGRectMake(20, NAVIGATION_BAR_HEIGHT * 2, width-2*20, 34);
        [button addTarget:self action:@selector(onBindEmailbtnclick) forControlEvents:UIControlEventTouchUpInside];
        [self.UnBindView addSubview:button];
        
        //解除邮箱绑定小按钮
        UIButton * button2 =[UIButton buttonWithType:UIButtonTypeCustom];
        [button2 setBackgroundImage:[UIImage imageNamed:@"alarm_dec.png"] forState:UIControlStateNormal];
        button2.titleLabel.textAlignment = NSTextAlignmentCenter;
        button2.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
        //[button2 setTitle:NSLocalizedString(@"UNbind", nil) forState:UIControlStateNormal];
        [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button2.frame=CGRectMake(width - 30 - (TEXT_FIELD_HEIGHT-20), self.BindEmailtextView.frame.origin.y + 5, TEXT_FIELD_HEIGHT - 10, TEXT_FIELD_HEIGHT - 10);
        [button2 addTarget:self action:@selector(UnBindbtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.UnBindView addSubview:button2];
    }else{
        unbindlabel.text = [NSString stringWithFormat:@"+%@-%@",loginResult.countryCode,loginResult.phone];
#pragma mark - 解除手机绑定按钮
        UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"delete_device_btn.png"] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
        [button setTitle:NSLocalizedString(@"UNbind", nil) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.frame=CGRectMake(20, NAVIGATION_BAR_HEIGHT*2, width-2*20, TEXT_FIELD_HEIGHT);
        [button addTarget:self action:@selector(UnBindbtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.UnBindView addSubview:button];
    }
    [self.UnBindView addSubview:unbindlabel];
    
}
-(void)BindViewinit{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    UIView * alphaView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    alphaView.backgroundColor = XBlack_128;
    [self.view addSubview:alphaView];
    self.alphaView = alphaView;
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, height/2+50)];
    view.backgroundColor = XWhite;
    [alphaView addSubview:view];
    self.BindView = view;
    self.BindView.layer.contents = (id)[UIImage imageNamed:@"about_bk.png"].CGImage;
    [view release];
    [alphaView release];
    
#pragma mark - 邮箱绑定和手机绑定
    UIView * headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    headview.backgroundColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    [self.BindView addSubview:headview];
    
    UILabel * headnamelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, width-10, 30)];
    headnamelabel.backgroundColor = [UIColor clearColor];
    headnamelabel.textAlignment = NSTextAlignmentCenter;
    headnamelabel.textColor = XWhite;
    if (self.isBindEmail) {
        headnamelabel.text = NSLocalizedString(@"bind_email", nil);
    }else{
        headnamelabel.text = NSLocalizedString(@"bind_phone", nil);
    }
    [self.BindView addSubview:headnamelabel];
    
    UIButton * DownBtn = [[UIButton alloc] init];
    DownBtn.frame = CGRectMake(width - 40, 5, 40, 34);
    UIImageView *downImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 20, 20)];
    downImage.image = [UIImage imageNamed:@"ic_down.png"];
    [DownBtn addSubview:downImage];
    [DownBtn addTarget:self action:@selector(sheetviewhiden) forControlEvents:UIControlEventTouchUpInside];
    [self.BindView addSubview:DownBtn];
    [DownBtn release];
    [downImage release];
    
    if (self.isBindEmail) {
        
        UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT, width - 30, TEXT_FIELD_HEIGHT)];
        field1.textAlignment = NSTextAlignmentLeft;
        field1.placeholder = NSLocalizedString(@"input_email", nil);
        field1.borderStyle = UITextBorderStyleRoundedRect;
        field1.returnKeyType = UIReturnKeyDone;
        field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [field1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.BindEmailtextView = field1;
        [self.BindView addSubview:field1];
        [field1 release];
        
        
        //邮箱绑定按钮
        UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"new_button.png"] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
        [button setTitle:NSLocalizedString(@"bind_email", nil) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.frame=CGRectMake(20, NAVIGATION_BAR_HEIGHT + field1.frame.size.height + 20, width-2*20, 34);
        [button addTarget:self action:@selector(onBindEmailbtnclick) forControlEvents:UIControlEventTouchUpInside];
        [self.BindView addSubview:button];
    }else{
        UIView * maskview = [[UIView alloc] initWithFrame:CGRectMake(0, 40, width, self.BindView.frame.size.height-40)];
        BindPhoneController *bindPhoneController = [[BindPhoneController alloc] init];
        bindPhoneController.accountController = self;
        bindPhoneController.delegate = self;
        self.bindphonecontroller = bindPhoneController;
        [maskview addSubview:bindPhoneController.view];
        [bindPhoneController release];
        [self.BindView addSubview:maskview];
        [maskview release];
    }
    
}
-(void)BindPhonebtnclick:(UIButton *)button{
    button.backgroundColor = XWhite;
    ChooseCountryController *chooseCountryController = [[ChooseCountryController alloc] init];
    chooseCountryController.bindPhoneController = self.bindphonecontroller;
    [self presentViewController:chooseCountryController animated:YES completion:nil];
    [chooseCountryController release];
}
-(void)BindUp{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    self.BindView.frame = CGRectMake(0, height-height/2-50, width, height/2+50);
    
    self.alphaView.frame = CGRectMake(0, 0, width, height);
    
    [UIView setAnimationDelegate:self];
    // 动画完毕后调用animationFinished
    [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    [UIView commitAnimations];
}
-(void)UnBindUp{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    self.UnBindView.frame = CGRectMake(0, height-height/2-50, width, height/2+50);
    
    self.alphaView.frame = CGRectMake(0, 0, width, height);
    
    [UIView setAnimationDelegate:self];
    // 动画完毕后调用animationFinished
    [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    [UIView commitAnimations];
}
-(void)animationstart{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    self.ModifyPasswordView.frame = CGRectMake(0, height-height/2-50, width, height/2+50);
    
    self.alphaView.frame = CGRectMake(0, 0, width, height);
    
    [UIView setAnimationDelegate:self];
    // 动画完毕后调用animationFinished
    [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    [UIView commitAnimations];
}

#pragma mark - 点击收起操作框按钮后调用
-(void)sheetviewhiden{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
        self.ModifyPasswordView.frame = CGRectMake(0, height, width, height/2+50);
        self.UnBindView.frame = CGRectMake(0, height, width, height/2+50);
        self.BindView.frame = CGRectMake(0, height, width, height/2+50);
        //    self.alphaView.frame = CGRectMake(0, height, width, height);
        [self.BindEmailtextView resignFirstResponder];
        [UIView setAnimationDelegate:self];
        // 动画完毕后调用animationFinished
        [UIView setAnimationDidStopSelector:@selector(animationFinished)];
        [UIView commitAnimations];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            usleep(600000);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.alphaView setHidden:YES];
                
            });
        });
    });
    [self.view endEditing:YES];
}

-(void)animationFinished{
    //NSLog(@"动画结束!");
    
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

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, -CUSTOM_VIEW_HEIGHT_SHORT);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

-(void)onKeyBoardWillHide:(NSNotification*)notification{
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}
-(void)UnBindbtnClick{
    if (self.isUnBindEmail) {
        UIAlertView *unBindEmailAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_unbind_email", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
        unBindEmailAlert.tag = ALERT_TAG_UNBIND_EMAIL;
        [unBindEmailAlert show];
        [unBindEmailAlert release];
    }else{
        UIAlertView *unBindEmailAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_unbind_phone", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
        unBindEmailAlert.tag = ALERT_TAG_UNBIND_PHONE;
        [unBindEmailAlert show];
        [unBindEmailAlert release];
    }
}
-(void)onBindEmailbtnclick{
    NSString *email = self.BindEmailtextView.text;
    
    if(!email||!email.length>0){
        [self.view makeToast:NSLocalizedString(@"input_email", nil)];
        return;
    }
    
    if(email.length<5||email.length>100){
        [self.view makeToast:NSLocalizedString(@"email_length_error", nil)];
        return;
    }
    //    if ([email rangeOfString:@"@"].location == NSNotFound) {
    //        [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
    //        return;
    //    }else if ([email rangeOfString:@"."].location == NSNotFound){
    //        [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
    //        return;
    //    }else{
    NSArray *arr1 = [email componentsSeparatedByString:@"@"];
    if (arr1.count!=2) {
        [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
        return;
    }else{
        NSString * str = arr1[1];
        if (str.length>3) {
            NSArray * arr2 = [arr1[1] componentsSeparatedByString:@"."];
            if (arr2.count!=2) {
                [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
                return;
            }
        }else{
            [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
            return;
        }
    }
    //    }
    [self.BindEmailtextView resignFirstResponder];
    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    inputAlert.tag = BIND_EMAIL_AFTER_INPUT_PASSWORD;
    [inputAlert show];
    [inputAlert release];
    
}
-(void)onSavePress{
    NSString *originalPassword = self.OldPWtextView.text;
    NSString *newPassword = self.NewPWtextView.text;
    NSString *confirmPassword = self.ConfirmPWtextView.text;
    
    if(!originalPassword||!originalPassword.length>0){
        [self.view makeToast:NSLocalizedString(@"input_original_password", nil)];
        return;
    }
    
    if(!newPassword||!newPassword.length>0){
        [self.view makeToast:NSLocalizedString(@"input_new_password", nil)];
        return;
    }
    
    if(newPassword.length>100){
        [self.view makeToast:NSLocalizedString(@"password_too_long", nil)];
        return;
    }
    
    if(!confirmPassword||!confirmPassword.length>0){
        [self.view makeToast:NSLocalizedString(@"confirm_input", nil)];
        return;
    }
    
    if(![newPassword isEqualToString:confirmPassword]){
        [self.view makeToast:NSLocalizedString(@"two_passwords_not_match", nil)];
        return;
    }
    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    [self.OldPWtextView resignFirstResponder];
    [self.NewPWtextView resignFirstResponder];
    [self.ConfirmPWtextView resignFirstResponder];
    [self sheetviewhiden];
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    [[NetManager sharedManager] modifyLoginPasswordWithUserName:loginResult.contactId sessionId:loginResult.sessionId oldPwd:originalPassword newPwd:newPassword rePwd:confirmPassword callBack:^(id JSON){
        [self.progressAlert hide:YES];
        ModifyLoginPasswordResult *modifyLoginPasswordResult = (ModifyLoginPasswordResult*)JSON;
        
        
        switch(modifyLoginPasswordResult.error_code){
            case NET_RET_MODIFY_LOGIN_PASSWORD_SUCCESS:
            {
                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                loginResult.sessionId = modifyLoginPasswordResult.sessionId;
                [UDManager setLoginInfo:loginResult];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    sleep(1.0);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self sheetviewhiden];
                        [self.tableView reloadData];
                    });
                });
                
            }
                break;
            case NET_RET_MODIFY_LOGIN_PASSWORD_NOT_MATCH:
            {
                [self.view makeToast:NSLocalizedString(@"two_passwords_not_match", nil)];
            }
                break;
            case NET_RET_MODIFY_LOGIN_PASSWORD_ORIGINAL_PASSWORD_ERROR:
            {
                [self.view makeToast:NSLocalizedString(@"original_password_error", nil)];
            }
                break;
            default:
            {
                [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"unknown_error", nil),modifyLoginPasswordResult.error_code]];
            }
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    if(section==0){
    //        return 3;
    //    }else if(section==1){
    //        return 1;
    //    }else{
    //        return 0;
    //    }
    return 4;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"AccountCell";
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[AccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        [cell setBackgroundColor:XBGAlpha];
    }
    
    int row = indexPath.row;
    
    [cell setRightIcon:@"ic_black_up.png"];
    cell.backgroundColor = XWhite;
    LoginResult *loginResult = [UDManager getLoginInfo];
    if(row==0){
        [cell setLabelText:NSLocalizedString(@"account", nil)];
        [cell setIsHiddenRightIcon:YES];
        [cell setIsHiddenRightLabel:NO];
        [cell setRightText:loginResult.contactId];
    }else if(row==1){
        [cell setLabelText:NSLocalizedString(@"email", nil)];
        [cell setIsHiddenRightIcon:NO];
        [cell setIsHiddenRightLabel:NO];
        [cell setRightText:loginResult.email];
    }else if(row==2){
        [cell setLabelText:NSLocalizedString(@"phone_number", nil)];
        [cell setIsHiddenRightIcon:NO];
        [cell setIsHiddenRightLabel:NO];
        if(loginResult.countryCode&&loginResult.countryCode.length>0&&loginResult.phone&&loginResult.phone.length>0){
            [cell setRightText:[NSString stringWithFormat:@"+%@-%@",loginResult.countryCode,loginResult.phone]];
        }else{
            [cell setRightText:@""];
        }
    }
    else
    {
        [cell setLabelText:NSLocalizedString(@"modify_login_password", nil)];
        [cell setIsHiddenRightIcon:YES];
        [cell setIsHiddenRightLabel:YES];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.isUnBindEmail = NO;
    self.isBindEmail = NO;
    LoginResult *loginResult = [UDManager getLoginInfo];
    if(indexPath.row==1){
        if(loginResult.email&&loginResult.email.length>0){
            self.isUnBindEmail = YES;
            [self UnBindViewinit];
            [self UnBindUp];
        }else{
            self.isBindEmail = YES;
            [self BindViewinit];
            [self BindUp];
        }
    }else if(indexPath.row==2){
        if(loginResult.phone&&loginResult.phone.length>0){
            [self UnBindViewinit];
            [self UnBindUp];
        }else{
            [self BindViewinit];
            [self BindUp];
        }
    }else if(indexPath.row==3){
        [self sheetViewinit];
        [self animationstart];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_UNBIND_EMAIL:
        {
            if(buttonIndex==1){
                
                UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                inputAlert.tag = ALERT_TAG_UNBIND_EMAIL_AFTER_INPUT_PASSWORD;
                [inputAlert show];
                [inputAlert release];
            }
        }
            break;
        case ALERT_TAG_UNBIND_EMAIL_AFTER_INPUT_PASSWORD:
        {
            if(buttonIndex==1){
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                [self sheetviewhiden];
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                LoginResult *loginResult = [UDManager getLoginInfo];
                [[NetManager sharedManager] setAccountInfo:loginResult.contactId password:inputPwd phone:loginResult.phone email:@"" countryCode:loginResult.countryCode phoneCheckCode:@"" flag:@"2" sessionId:loginResult.sessionId callBack:^(id JSON){
                    [self.progressAlert hide:YES];
                    NSInteger error_code = [JSON integerValue];
                    switch (error_code) {
                        case NET_RET_SET_ACCOUNT_SUCCESS:
                        {
                            loginResult.email = @"";
                            [UDManager setLoginInfo:loginResult];
                            [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                            [self sheetviewhiden];
                            [self.tableView reloadData];
                            
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PASSWORD_ERROR:
                        {
                            [self.view makeToast:NSLocalizedString(@"password_error", nil)];
                        }
                            break;
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
        case ALERT_TAG_UNBIND_PHONE:
        {
            if(buttonIndex==1){
                
                UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                //                UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                inputAlert.tag = ALERT_TAG_UNBIND_PHONE_AFTER_INPUT_PASSWORD;
                [inputAlert show];
                [inputAlert release];
            }
        }
            break;
        case ALERT_TAG_UNBIND_PHONE_AFTER_INPUT_PASSWORD:
        {
            if(buttonIndex==1){
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                [self sheetviewhiden];
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                LoginResult *loginResult = [UDManager getLoginInfo];
                [[NetManager sharedManager] setAccountInfo:loginResult.contactId password:inputPwd phone:@"" email:loginResult.email countryCode:@"" phoneCheckCode:@"" flag:@"1" sessionId:loginResult.sessionId callBack:^(id JSON){
                    [self.progressAlert hide:YES];
                    NSInteger error_code = [JSON integerValue];
                    switch (error_code) {
                        case NET_RET_SET_ACCOUNT_SUCCESS:
                        {
                            loginResult.phone = @"";
                            loginResult.countryCode = @"";
                            [UDManager setLoginInfo:loginResult];
                            [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                            [self sheetviewhiden];
                            [self.tableView reloadData];
                            
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PASSWORD_ERROR:
                        {
                            [self.view makeToast:NSLocalizedString(@"password_error", nil)];
                        }
                            break;
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
        case BIND_EMAIL_AFTER_INPUT_PASSWORD:
        {
            if(buttonIndex==1){
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                [self sheetviewhiden];
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                NSString *email = self.BindEmailtextView.text;
                LoginResult *loginResult = [UDManager getLoginInfo];
                [[NetManager sharedManager] setAccountInfo:loginResult.contactId password:inputPwd phone:loginResult.phone email:email countryCode:loginResult.countryCode phoneCheckCode:@"" flag:@"2" sessionId:loginResult.sessionId callBack:^(id JSON){
                    [self.progressAlert hide:YES];
                    NSInteger error_code = [JSON integerValue];
                    switch (error_code) {
                        case NET_RET_SET_ACCOUNT_SUCCESS:
                        {
                            loginResult.email = email;
                            [UDManager setLoginInfo:loginResult];
                            [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                sleep(1.0);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self sheetviewhiden];
                                    [self.tableView reloadData];
                                });
                            });
                            
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PASSWORD_ERROR:
                        {
                            [self.view makeToast:NSLocalizedString(@"password_error", nil)];
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_EMAIL_USED:
                        {
                            [self.view makeToast:NSLocalizedString(@"email_used", nil)];
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_EMAIL_FORMAT_ERROR:
                        {
                            [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
                        }
                            break;
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}

-(void)onBackPress{
    MainContainer * maincontainer = [AppDelegate sharedDefault].mainController;
    [maincontainer showLeftMenu:YES];
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
