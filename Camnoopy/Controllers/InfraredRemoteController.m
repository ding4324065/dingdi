

#import "InfraredRemoteController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "YAudioStreamPlayer.h"
#import "YButton.h"
#import "Toast+UIView.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@interface InfraredRemoteController ()

@end

@implementation InfraredRemoteController
-(void)dealloc{
    [self.wifiPwdField release];
    [self.devicePwdField release];
    [self.ssidField release];
    [self.inputView release];
    [self.setWifiView release];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    MainController *mainController = [AppDelegate sharedDefault].mainController;
//    [mainController setBottomBarHidden:YES];
    [[YAudioStreamPlayer sharedDefault] start];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[YAudioStreamPlayer sharedDefault] stop];
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

#define INFRARED_BUTTON_WIDTH_HEIGHT ([UIScreen mainScreen].bounds.size.height <= 480 ? 54.0:64.0)
#define INFRARED_BUTTON_HORIZONTAL_MARGIN ([UIScreen mainScreen].bounds.size.height <= 480 ? 80:100)
#define INFRARED_BUTTON_VERTICAL_MARGIN ([UIScreen mainScreen].bounds.size.height <= 480 ? 80:100)
#define SET_WIFI_BUTTON_WIDTH ([UIScreen mainScreen].bounds.size.height <= 480 ? 150:200)
#define SET_WIFI_BUTTON_HEIGHT ([UIScreen mainScreen].bounds.size.height <= 480 ? 56:76)


#define INPUT_VIEW_WIDTH 288
#define INPUT_VIEW_HEIGHT 182
#define INPUT_VIEW_FIELD_HEIGHT 36
-(void)initComponent{

    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
//    红外遥控
    [topBar setTitle:NSLocalizedString(@"infrared_remote",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
   
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+(height-NAVIGATION_BAR_HEIGHT)/3, width, (height-NAVIGATION_BAR_HEIGHT)/3*2)];
    
    
    YButton *topButton = [[YButton alloc] initWithFrame:CGRectMake((bottomView.frame.size.width-INFRARED_BUTTON_WIDTH_HEIGHT)/2, (bottomView.frame.size.height-INFRARED_BUTTON_VERTICAL_MARGIN-INFRARED_BUTTON_WIDTH_HEIGHT*2)/2, INFRARED_BUTTON_WIDTH_HEIGHT, INFRARED_BUTTON_WIDTH_HEIGHT)];
    topButton.delegate = self;
    topButton.tag = 0;
    topButton.image = [NSString stringWithFormat:@"%@",@"ic_infrared_top_p.png"];
    topButton.image_p = [NSString stringWithFormat:@"%@",@"ic_infrared_top.png"];
    [bottomView addSubview:topButton];
    [topButton release];
    
    YButton *bottomButton = [[YButton alloc] initWithFrame:CGRectMake((bottomView.frame.size.width-INFRARED_BUTTON_WIDTH_HEIGHT)/2, (bottomView.frame.size.height-INFRARED_BUTTON_VERTICAL_MARGIN-INFRARED_BUTTON_WIDTH_HEIGHT*2)/2+INFRARED_BUTTON_VERTICAL_MARGIN+INFRARED_BUTTON_WIDTH_HEIGHT, INFRARED_BUTTON_WIDTH_HEIGHT, INFRARED_BUTTON_WIDTH_HEIGHT)];
    bottomButton.delegate = self;
    bottomButton.tag = 1;
    bottomButton.image = [NSString stringWithFormat:@"%@",@"ic_infrared_bottom_p.png"];
    bottomButton.image_p = [NSString stringWithFormat:@"%@",@"ic_infrared_bottom.png"];
    [bottomView addSubview:bottomButton];
    [bottomButton release];
    
    YButton *leftButton = [[YButton alloc] initWithFrame:CGRectMake((bottomView.frame.size.width-INFRARED_BUTTON_HORIZONTAL_MARGIN-INFRARED_BUTTON_WIDTH_HEIGHT*2)/2, (bottomView.frame.size.height-INFRARED_BUTTON_WIDTH_HEIGHT)/2, INFRARED_BUTTON_WIDTH_HEIGHT, INFRARED_BUTTON_WIDTH_HEIGHT)];
    leftButton.delegate = self;
    leftButton.tag = 2;
    leftButton.image = [NSString stringWithFormat:@"%@",@"ic_infrared_left_p.png"];
    leftButton.image_p = [NSString stringWithFormat:@"%@",@"ic_infrared_left.png"];
    [bottomView addSubview:leftButton];
    [leftButton release];
    
    YButton *rightButton = [[YButton alloc] initWithFrame:CGRectMake((bottomView.frame.size.width-INFRARED_BUTTON_HORIZONTAL_MARGIN-INFRARED_BUTTON_WIDTH_HEIGHT*2)/2+INFRARED_BUTTON_HORIZONTAL_MARGIN+INFRARED_BUTTON_WIDTH_HEIGHT, (bottomView.frame.size.height-INFRARED_BUTTON_WIDTH_HEIGHT)/2, INFRARED_BUTTON_WIDTH_HEIGHT, INFRARED_BUTTON_WIDTH_HEIGHT)];
    rightButton.delegate = self;
    rightButton.tag = 3;
    
    rightButton.image = [NSString stringWithFormat:@"%@",@"ic_infrared_right_p.png"];
    rightButton.image_p = [NSString stringWithFormat:@"%@",@"ic_infrared_right.png"];
    [bottomView addSubview:rightButton];
    [rightButton release];

    [self.view addSubview:bottomView];
    [bottomView release];
    
    YButton *setWifiButton = [[YButton alloc] initWithFrame:CGRectMake((width-SET_WIFI_BUTTON_WIDTH)/2, ((height-NAVIGATION_BAR_HEIGHT)/3-SET_WIFI_BUTTON_HEIGHT)/2+NAVIGATION_BAR_HEIGHT, SET_WIFI_BUTTON_WIDTH, SET_WIFI_BUTTON_HEIGHT)];
    setWifiButton.delegate = self;
    setWifiButton.tag = 4;
    
    setWifiButton.image = [NSString stringWithFormat:@"%@",@"bg_infrared_set_wifi_p.png"];
    setWifiButton.image_p = [NSString stringWithFormat:@"%@",@"bg_infrared_set_wifi.png"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, setWifiButton.frame.size.width, setWifiButton.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = XWhite;
    label.font = XFontBold_18;
    label.text = NSLocalizedString(@"set_wifi", nil);
    [setWifiButton addSubview:label];
    [label release];
    [self.view addSubview:setWifiButton];
    [setWifiButton release];
    
    
    
    UIButton *setWifiView = [[UIButton alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    [setWifiView addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventTouchUpInside];
    self.setWifiView = setWifiView;
//    UITapGestureRecognizer *singleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onKeyBoardDown:)];
//    [singleTapG setNumberOfTapsRequired:1];
//    [self.setWifiView addGestureRecognizer:singleTapG];
    
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake((setWifiView.frame.size.width-INPUT_VIEW_WIDTH)/2, (setWifiView.frame.size.height-INPUT_VIEW_HEIGHT)/2, INPUT_VIEW_WIDTH, INPUT_VIEW_HEIGHT)];
    inputView.layer.cornerRadius = 2.0;
    inputView.layer.borderColor = [UIColorFromRGB(0x000000) CGColor];
    inputView.backgroundColor = UIColorFromRGBA(0x00000080);
    inputView.layer.borderWidth = 1.0;
    inputView.layer.masksToBounds = YES;
    [setWifiView addSubview:inputView];
    
    
    
    UITextField *ssidField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, inputView.frame.size.width-20, INPUT_VIEW_FIELD_HEIGHT)];
    ssidField.textAlignment = NSTextAlignmentLeft;
    ssidField.backgroundColor = XWhite;
    ssidField.borderStyle = UITextBorderStyleNone;
    ssidField.returnKeyType = UIReturnKeyDone;
    ssidField.placeholder = NSLocalizedString(@"input_ssid", nil);
    ssidField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    ssidField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    ssidField.layer.borderWidth = 1;
    ssidField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    ssidField.layer.cornerRadius = 5.0;
    [ssidField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.ssidField = ssidField;
    [inputView addSubview:ssidField];
    [ssidField release];
    
    UITextField *wifiPwdField = [[UITextField alloc] initWithFrame:CGRectMake(10, ssidField.frame.origin.y+ssidField.frame.size.height+10, inputView.frame.size.width-20, INPUT_VIEW_FIELD_HEIGHT)];
    wifiPwdField.textAlignment = NSTextAlignmentLeft;
    wifiPwdField.backgroundColor = XWhite;
    wifiPwdField.borderStyle = UITextBorderStyleNone;
    wifiPwdField.returnKeyType = UIReturnKeyDone;
    wifiPwdField.secureTextEntry = YES;
    wifiPwdField.placeholder = NSLocalizedString(@"input_wifi_password", nil);
    wifiPwdField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    wifiPwdField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    wifiPwdField.layer.borderWidth = 1;
    wifiPwdField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    wifiPwdField.layer.cornerRadius = 5.0;
    [wifiPwdField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.wifiPwdField = wifiPwdField;
    
    UITextField *devicePwdField = [[UITextField alloc] initWithFrame:CGRectMake(10, wifiPwdField.frame.origin.y+ssidField.frame.size.height+10, inputView.frame.size.width-20, INPUT_VIEW_FIELD_HEIGHT)];
    devicePwdField.textAlignment = NSTextAlignmentLeft;
    devicePwdField.backgroundColor = XWhite;
    devicePwdField.borderStyle = UITextBorderStyleNone;
    devicePwdField.returnKeyType = UIReturnKeyDone;
    devicePwdField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    devicePwdField.placeholder = NSLocalizedString(@"input_device_password", nil);
    devicePwdField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    devicePwdField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    devicePwdField.layer.borderWidth = 1;
    devicePwdField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
    devicePwdField.layer.cornerRadius = 5.0;
    [devicePwdField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.devicePwdField = devicePwdField;
    
    
    [inputView addSubview:wifiPwdField];
    [wifiPwdField release];
    [inputView addSubview:devicePwdField];
    [devicePwdField release];
    
    
    UIButton *leftInputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftInputButton.frame = CGRectMake(0, devicePwdField.frame.origin.y+devicePwdField.frame.size.height+10, inputView.frame.size.width/2, inputView.frame.size.height-devicePwdField.frame.origin.y-devicePwdField.frame.size.height-10);
    [leftInputButton setTitle:NSLocalizedString(@"set", nil) forState:UIControlStateNormal];
    [leftInputButton addTarget:self action:@selector(onLeftInputButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [leftInputButton addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
    [leftInputButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
    [leftInputButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    [leftInputButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    [inputView addSubview:leftInputButton];
    
    UIButton *rightInputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightInputButton.frame = CGRectMake(leftInputButton.frame.size.width, leftInputButton.frame.origin.y, leftInputButton.frame.size.width, leftInputButton.frame.size.height);
    [rightInputButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [rightInputButton addTarget:self action:@selector(onRightInputButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [rightInputButton addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
    [rightInputButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
    [rightInputButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    [rightInputButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    [inputView addSubview:rightInputButton];
    self.inputView = inputView;
    [inputView release];
    
    [self.view addSubview:setWifiView];
    [setWifiView release];
    
    [self.setWifiView setHidden:YES];
    
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onKeyBoardWillShow:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DLog(@"%f",rect.size.height);
//    CGRect windowRect = [AppDelegate getScreenSize:YES isHorizontal:NO];
//    CGFloat width = windowRect.size.width;
//    CGFloat height = windowRect.size.height;
    
    [UIView transitionWithView:self.inputView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGFloat offset1 = self.setWifiView.frame.size.height-(self.inputView.frame.origin.y+self.inputView.frame.size.height);
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
                        self.inputView.transform = CGAffineTransformMakeTranslation(0, -finalOffset);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

-(void)onKeyBoardWillHide:(NSNotification*)notification{
    DLog(@"onKeyBoardWillHide");

    DLog(@"%f",rect.size.height);
    
    [UIView transitionWithView:self.inputView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.inputView.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

-(void)onKeyBoardDown:(id)sender{
    //[sender resignFirstResponder];
    [self.ssidField resignFirstResponder];
    [self.wifiPwdField resignFirstResponder];
    [self.devicePwdField resignFirstResponder];
}

-(void)lightButton:(UIView*)view{
    view.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    view.backgroundColor = [UIColor clearColor];
}

-(void)onLeftInputButtonPress:(id)sender{
    [self normalButton:sender];
    NSString *ssid = self.ssidField.text;
    NSString *wifiPwd = self.wifiPwdField.text;
    NSString *devicePwd = self.devicePwdField.text;
    
    if(ssid.length<=0){
        [self.view makeToast:NSLocalizedString(@"input_ssid", nil)];
        return;
    }
    [[YAudioStreamPlayer sharedDefault] playWIFI:ssid wifiPassword:wifiPwd devicePassword:devicePwd];
    
}

-(void)onRightInputButtonPress:(id)sender{
    [self normalButton:sender];
    [self onKeyBoardDown:sender];
    self.setWifiView.backgroundColor = [UIColor clearColor];
    [UIView transitionWithView:self.setWifiView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.setWifiView.transform = CGAffineTransformMakeScale(0.6, 0.6);
                        self.setWifiView.alpha = 0.4;
                    }
                    completion:^(BOOL Finished){
                        [self.setWifiView setHidden:YES];
                    }
     ];
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}

-(void)onYButtonClick:(YButton *)yButton{
    if(yButton.tag==4){
        NSDictionary *ifs = [self fetchSSIDInfo];
        NSLog(@"ifs:%@",ifs);
        NSString *ssid = [ifs objectForKey:@"SSID"];
        NSLog(@"ssid：%@",ssid);
        if(nil==ssid){
            self.ssidField.text = @"";
        }else{
            self.ssidField.text = ssid;
        }
        [self.setWifiView setHidden:NO];
        self.setWifiView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        self.setWifiView.alpha = 0.4;
        
        [UIView transitionWithView:self.setWifiView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            self.setWifiView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                            self.setWifiView.alpha = 1.0;
                        }
                        completion:^(BOOL Finished){
                            self.setWifiView.backgroundColor = UIColorFromRGBA(0x00000080);
                        }
         ];
        
    }
}

-(void)onYButtonDown:(YButton *)yButton{
    switch (yButton.tag) {
        case 0:
        {
            [[YAudioStreamPlayer sharedDefault] playCmd:3];
        }
            break;
        case 1:
        {
            [[YAudioStreamPlayer sharedDefault] playCmd:4];
        }
            break;
        case 2:
        {
            [[YAudioStreamPlayer sharedDefault] playCmd:1];
        }
            break;
        case 3:
        {
            [[YAudioStreamPlayer sharedDefault] playCmd:2];
        }
            break;
        default:
            break;
    }
}


-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    
    return (interface == UIInterfaceOrientationPortrait )||(interface==UIInterfaceOrientationPortraitUpsideDown);
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait||UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown;
}
@end
