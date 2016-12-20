

#import "KeyBoardController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "P2PClient.h"
#import "P2PCallController.h"
#import "AutoNavigation.h"
#import "Toast+UIView.h"
#import "ContactDAO.h"
#import "KeyboardCell.h"
#import "Contact.h"
#import "FListManager.h"
#import "Contact.h"
@interface KeyBoardController ()

@end

@implementation KeyBoardController

-(void)dealloc{
    [self.inputLabel release];
    [self.tableView release];
    [self.contacts release];
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
    if(self.tableView){
        [self.tableView reloadData];
    }
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


#define KEY_BOARD_BTN_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 85:45)
#define TABLE_ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 68:40)
-(void)initComponent{
   
    
    NSArray *array = @[@"ic_keyboard_one.png",
                       @"ic_keyboard_two.png",
                       @"ic_keyboard_three.png",
                       @"ic_keyboard_four.png",
                       @"ic_keyboard_five.png",
                       @"ic_keyboard_six.png",
                       @"ic_keyboard_seven.png",
                       @"ic_keyboard_eight.png",
                       @"ic_keyboard_nine.png",
                       @"ic_keyboard_add.png",
                       @"ic_keyboard_zero.png",
                       @"ic_keyboard_del.png"];
    [self.view setBackgroundColor:XBgColor];
    
//    UIImage *backImg = [UIImage imageNamed:@"bg_keyboard_view.png"];
//
//    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
//    backImageView.image = backImg;
//    [self.view addSubview:backImageView];
//    [backImageView release];
    
    CGRect rect = [AppDelegate getScreenSize:NO isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    CGFloat height = rect.size.height-TAB_BAR_HEIGHT;
    
    DLog(@"%f:%f",rect.size.width,rect.size.height);

    
    for(int i = 0;i<6;i++){
        if(i==0){
            UIImageView *inputBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, height-KEY_BOARD_BTN_HEIGHT*(6-i)-(5-i), width, KEY_BOARD_BTN_HEIGHT)];
            inputBar.image = [UIImage imageNamed:@"bg_keyboard_input_bar.png"];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, KEY_BOARD_BTN_HEIGHT)];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"";
            label.textColor = XWhite;
            label.backgroundColor = XBGAlpha;
            [label setFont:XFontBold_18];
            self.inputLabel = label;
            [label release];
            [inputBar addSubview:self.inputLabel];
            [self.view addSubview:inputBar];
            [inputBar release];
            
            
        }else if(i==5){
            //monitor button
            UIButton *monitorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, height-KEY_BOARD_BTN_HEIGHT, (width-1)/2, KEY_BOARD_BTN_HEIGHT)];
            
            monitorBtn.tag = 12;
            [monitorBtn addTarget:self action:@selector(onKeyboardPress:) forControlEvents:UIControlEventTouchUpInside];
            [monitorBtn setBackgroundImage:[UIImage imageNamed:@"bg_keyboard2.png"] forState:UIControlStateNormal];
            [monitorBtn setBackgroundImage:[UIImage imageNamed:@"bg_keyboard2_p.png"] forState:UIControlStateHighlighted];
            UIImageView *monitor_icon_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (width-1)/2, KEY_BOARD_BTN_HEIGHT)];
            
            UIImage *monitor_icon = [UIImage imageNamed:@"ic_keyboard_monitor.png"];
            monitor_icon_view.image = monitor_icon;
            monitor_icon_view.contentMode = UIViewContentModeScaleAspectFit;
            [monitorBtn addSubview:monitor_icon_view];
            [self.view addSubview:monitorBtn];
            [monitor_icon_view release];
            
            //video button
            UIButton *videoBtn = [[UIButton alloc] initWithFrame:CGRectMake((width-1)/2+1, height-KEY_BOARD_BTN_HEIGHT, (width-1)/2, KEY_BOARD_BTN_HEIGHT)];
            videoBtn.tag = 13;
            [videoBtn addTarget:self action:@selector(onKeyboardPress:) forControlEvents:UIControlEventTouchUpInside];
            [videoBtn setBackgroundImage:[UIImage imageNamed:@"bg_keyboard2.png"] forState:UIControlStateNormal];
            [videoBtn setBackgroundImage:[UIImage imageNamed:@"bg_keyboard2_p.png"] forState:UIControlStateHighlighted];
            UIImageView *video_icon_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (width-1)/2, KEY_BOARD_BTN_HEIGHT)];
            
            UIImage *video_icon = [UIImage imageNamed:@"ic_keyboard_video.png"];
            video_icon_view.image = video_icon;
            video_icon_view.contentMode = UIViewContentModeScaleAspectFit;
            [videoBtn addSubview:video_icon_view];
            [self.view addSubview:videoBtn];
            [video_icon_view release];

        }else{
            for(int j=0;j<3;j++){
                CGFloat margin_left = 0;
                if(j==0){
                    margin_left = 0;
                }else if(j==1){
                    margin_left = (width-2)/3 + 1;
                }else if(j==2){
                    margin_left = (width-2)/3*2 + 2;
                }
                UIButton *itemBtn = [[UIButton alloc] initWithFrame:CGRectMake(margin_left, height-KEY_BOARD_BTN_HEIGHT*(6-i)-(5-i), (width-2)/3, KEY_BOARD_BTN_HEIGHT)];
                
                itemBtn.tag = (i-1)*3+j;
                [itemBtn addTarget:self action:@selector(onKeyboardPress:) forControlEvents:UIControlEventTouchUpInside];
                [itemBtn setBackgroundImage:[UIImage imageNamed:@"bg_keyboard.png"] forState:UIControlStateNormal];
                [itemBtn setBackgroundImage:[UIImage imageNamed:@"bg_keyboard_p.png"] forState:UIControlStateHighlighted];
                
                UIImageView *itemBtn_icon_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (width-2)/3, KEY_BOARD_BTN_HEIGHT)];
                
                
                UIImage *item_icon = [UIImage imageNamed:[array objectAtIndex:(i-1)*3+j]];
                itemBtn_icon_view.image = item_icon;
                itemBtn_icon_view.contentMode = UIViewContentModeScaleAspectFit;
                [itemBtn addSubview:itemBtn_icon_view];
                [self.view addSubview:itemBtn];
                [itemBtn_icon_view release];
            }
        }
        
        
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height-KEY_BOARD_BTN_HEIGHT*6) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.contacts = [NSArray arrayWithArray:[[FListManager sharedFList] getContacts]];
    
    return [self.contacts count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TABLE_ITEM_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"AccountCell";
    KeyboardCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[KeyboardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    Contact *contact = [self.contacts objectAtIndex:indexPath.row];
    
    [cell setLeftText:contact.contactName];
    [cell setRightText:contact.contactId];
    
    UIImage *backImg = [UIImage imageNamed:@"bg_keyboard_view.png"];
    UIImage *backImg_p = [UIImage imageNamed:@"bg_normal_cell_p.png"];
    UIImageView *backImageView = [[UIImageView alloc] init];
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    
    [backImageView release];
    [backImageView_p release];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Contact *contact = [self.contacts objectAtIndex:indexPath.row];
    self.inputLabel.text = contact.contactId;
}

-(void)onKeyboardPress:(id)sender{
    NSString *inputStr = self.inputLabel.text;
    UIButton *button = (UIButton*)sender;
    switch(button.tag){
        case 0:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"1"];
        }
            break;
        case 1:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"2"];
        }
            break;
        case 2:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"3"];
        }
            break;
        case 3:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"4"];
        }
            break;
        case 4:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"5"];
        }
            break;
        case 5:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"6"];
        }
            break;
        case 6:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"7"];
        }
            break;
        case 7:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"8"];
        }
            break;
        case 8:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"9"];
        }
            break;
        case 9:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"+"];
        }
            break;
        case 10:
        {
            self.inputLabel.text = [inputStr stringByAppendingString:@"0"];
        }
            break;
        case 11:
        {
            if(inputStr.length>0){
                self.inputLabel.text = [inputStr substringWithRange:NSMakeRange(0, inputStr.length-1)];
            }
        }
            break;
        case 12:
        {
            if(inputStr.length==0){
                [self.view makeToast:NSLocalizedString(@"input_monitor_id", nil)];
                return;
            }
            ContactDAO *contactDAO = [[ContactDAO alloc] init];
            Contact *contact = [contactDAO isContact:inputStr];
            if(contact!=nil){
                MainContainer *mainController = [AppDelegate sharedDefault].mainController;
                mainController.contactName = contact.contactName;
                [mainController setUpCallWithId:inputStr password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
            }else{
                UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                inputAlert.tag = ALERT_TAG_MONITOR;
                [inputAlert show];
                [inputAlert release];
            }
        }
            break;
        case 13:
        {
            if(inputStr.length==0){
                [self.view makeToast:NSLocalizedString(@"input_call_id", nil)];
                return;
            }
            MainContainer *mainController = [AppDelegate sharedDefault].mainController;
            [mainController setUpCallWithId:inputStr password:@"0" callType:P2PCALL_TYPE_VIDEO];
        }
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_MONITOR:
            if(buttonIndex == 1){
                NSString *inputStr = self.inputLabel.text;
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                
                NSString *inputPwd = passwordField.text;
                if(!inputPwd||inputPwd.length==0){
                    [self.view makeToast:NSLocalizedString(@"input_device_password", nil)];
                    return;
                }
                MainContainer *mainController = [AppDelegate sharedDefault].mainController;
                mainController.contactName = inputStr;
                [mainController setUpCallWithId:inputStr password:inputPwd callType:P2PCALL_TYPE_MONITOR];

            }
            break;
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
@end
