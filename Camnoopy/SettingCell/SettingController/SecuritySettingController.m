

#import "SecuritySettingController.h"
#import "P2PClient.h"
#import "Constants.h"
#import "Toast+UIView.h"
#import "P2PSettingCell.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "ModifyDevicePasswordController.h"
#import "ModifyVisitorPasswordController.h"
#import "P2PSwitchCell.h"
#import "P2PSecurityCell.h"
#import "FListManager.h"
#import "Utils.h"
#import "MD5Manager.h"
@interface SecuritySettingController ()

@end

@implementation SecuritySettingController

-(void)dealloc{
    [self.tableView release];
    [self.contact release];
    [self.lastSetOriginPassowrd release];
    [self.lastSetNewPassowrd release];
    [self.textCell1 release];
    [self.textCell2 release];
    [self.textCell3 release];
    [self.textCell4 release];
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
    DLog(@"%@",self.contact.contactPassword);
    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!self.isFirstLoadingCompolete){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
        self.isFirstLoadingCompolete = !self.isFirstLoadingCompolete;
    }
}


- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_SET_DEVICE_PASSWORD:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                

                self.contact.contactPassword = [Utils GetTreatedPassword:self.lastSetNewPassowrd];
                [[FListManager sharedFList] update:self.contact];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
            
        case RET_SET_VISITOR_PASSWORD:
        {
            
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        
    }
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_GET_NPC_SETTINGS:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get npc settings");
                    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
                }
            });
            DLog(@"ACK_RET_GET_NPC_SETTINGS:%i",result);
        }
            break;
            
        case ACK_RET_SET_DEVICE_PASSWORD:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"original_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend set device password");
                    [[P2PClient sharedClient] setDevicePasswordWithId:self.contact.contactId password:self.lastSetOriginPassowrd newPassword:self.lastSetNewPassowrd];
                }
            });
            DLog(@"ACK_RET_SET_DEVICE_PASSWORD:%i",result);
        }
            break;
            
        case ACK_RET_SET_VISITOR_PASSWORD:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend set visitor password");
                    [[P2PClient sharedClient] setVisitorPasswordWithId:self.contact.contactId password:self.contact.contactPassword newPassword:self.textCell4.leftTextFieldView.text];
                }
            });
            
            DLog(@"ACK_RET_SET_VISITOR_PASSWORD:%i",result);
        }
            break;
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

-(void)initComponent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"security_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    //[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.contact.contactType==CONTACT_TYPE_IPC) {
        return 2;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0)
    {
        return 5;
    }
    else
    {
        return 3;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return BAR_BUTTON_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PSettingCell";
    static NSString *identifier2 = @"P2PSecurityCell";

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UITableViewCell *cell = nil;
    
    if(section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if(cell==nil){
            cell = [[[P2PSecurityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
            [cell setBackgroundColor:XWhite];
        }
        
        P2PSecurityCell *securityCell = (P2PSecurityCell*)cell;
        securityCell.delegate = self;
        [securityCell setSection:indexPath.section];
        [securityCell setRow:indexPath.row];
    }
    else if(section==1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PSecurityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XWhite];
        }
        
        P2PSecurityCell *securityCell = (P2PSecurityCell*)cell;
        securityCell.delegate = self;
        [securityCell setSection:indexPath.section];
        [securityCell setRow:indexPath.row];
    }
    
    switch (section) {
        case 0:
        {
            if(row==0){
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                settingCell.userInteractionEnabled = NO;
                [settingCell setMiddleLabelHidden:NO];
                [settingCell setLeftLabelHidden:YES];
                [settingCell setMiddleButtonHidden:YES];
                [settingCell setMiddleLabelText:NSLocalizedString(@"modify_manager_password", nil)];
            }else if(row == 1){
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                self.textCell1 = settingCell;

                [settingCell setMiddleLabelHidden:YES];
                [settingCell setLeftLabelHidden:NO];
                [settingCell setMiddleButtonHidden:YES];
                [settingCell setLeftTextFieldText:NSLocalizedString(@"input_original_password", nil)];
            }else if(row == 2){
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                self.textCell2 = settingCell;

                [settingCell setMiddleLabelHidden:YES];
                [settingCell setLeftLabelHidden:NO];
                [settingCell setMiddleButtonHidden:YES];
                [settingCell setLeftTextFieldText:NSLocalizedString(@"input_new_password", nil)];
            }else if(row == 3){
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                self.textCell3 = settingCell;

                [settingCell setMiddleLabelHidden:YES];
                [settingCell setLeftLabelHidden:NO];
                [settingCell setMiddleButtonHidden:YES];
                [settingCell setLeftTextFieldText:NSLocalizedString(@"confirm_input", nil)];
            }else{
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                //settingCell.userInteractionEnabled = NO;
                [settingCell setMiddleLabelHidden:YES];
                [settingCell setLeftLabelHidden:YES];
                [settingCell setMiddleButtonHidden:NO];
            }
        }
            break;
        case 1:
        {
            if(row==0){
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                settingCell.userInteractionEnabled = NO;
                [settingCell setMiddleLabelHidden:NO];
                [settingCell setLeftLabelHidden:YES];
                [settingCell setMiddleButtonHidden:YES];
                [settingCell setMiddleLabelText:NSLocalizedString(@"modify_visitor_password", nil)];
            }else if (row == 1){
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                self.textCell4 = settingCell;
                
                [settingCell setMiddleLabelHidden:YES];
                [settingCell setLeftLabelHidden:NO];
                [settingCell setMiddleButtonHidden:YES];
                [settingCell setLeftTextFieldText:NSLocalizedString(@"input_new_password", nil)];
            }else{
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                //settingCell.userInteractionEnabled = NO;
                [settingCell setMiddleLabelHidden:YES];
                [settingCell setLeftLabelHidden:YES];
                [settingCell setMiddleButtonHidden:NO];
            }
            
        }
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)savePress:(NSInteger)section row:(NSInteger)row{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    if (section == 0)
    {
        NSString *originalPassword = self.textCell1.leftTextFieldView.text;
        NSString *newPassword = self.textCell2.leftTextFieldView.text;
        NSString *confirmPassword = self.textCell3.leftTextFieldView.text;

        if(!originalPassword||!(originalPassword.length>0)){
            [self.view makeToast:NSLocalizedString(@"input_original_password", nil)];
            return;
        }
        
//        if([predicate evaluateWithObject:originalPassword]==NO){
//            [self.view makeToast:NSLocalizedString(@"password_number_format_error", nil)];
//            return;
//        }
        
        if(!newPassword||!newPassword.length>0){
            [self.view makeToast:NSLocalizedString(@"input_new_password", nil)];
            return;
        }
        
        
//        if([predicate evaluateWithObject:newPassword]==NO){
//            [self.view makeToast:NSLocalizedString(@"password_number_format_error", nil)];
//            return;
//        }
        
        if([newPassword characterAtIndex:0]=='0'){
            [self.view makeToast:NSLocalizedString(@"password_zero_format_error", nil)];
            return;
        }
        
        if(newPassword.length>100){
            [self.view makeToast:NSLocalizedString(@"device_password_too_long", nil)];
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
        self.lastSetNewPassowrd = newPassword;
        self.lastSetOriginPassowrd = originalPassword;
        [[P2PClient sharedClient] setDevicePasswordWithId:self.contact.contactId password:originalPassword newPassword:newPassword];
    }
    else if (section == 1)
    {
        NSString *newPassword = self.textCell4.leftTextFieldView.text;
        
        if(!newPassword||!(newPassword.length)>0)
        {
            [self.view makeToast:NSLocalizedString(@"input_new_visitor_password", nil)];
            return;
        }
        
//        if([predicate evaluateWithObject:newPassword]==NO){
//            [self.view makeToast:NSLocalizedString(@"password_number_format_error", nil)];
//            return;
//        }
        
        if([newPassword characterAtIndex:0]=='0'){
            [self.view makeToast:NSLocalizedString(@"password_zero_format_error", nil)];
            return;
        }
        
        if(newPassword.length>100){
            [self.view makeToast:NSLocalizedString(@"device_password_too_long", nil)];
            return;
        }
        
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
        [self.textCell1.leftTextFieldView resignFirstResponder];
        [self.textCell2.leftTextFieldView resignFirstResponder];
        [self.textCell3.leftTextFieldView resignFirstResponder];
        [self.textCell4.leftTextFieldView resignFirstResponder];
        
        newPassword = [Utils GetTreatedPassword:newPassword];
        [[P2PClient sharedClient] setVisitorPasswordWithId:self.contact.contactId password:self.contact.contactPassword newPassword:newPassword];
    }
}

#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    if (self.textCell4.leftTextFieldView.editing) {
        NSDictionary *userInfo = [notification userInfo];
        CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        DLog(@"%f",rect.size.height);
        

        [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            CGFloat offset1 = self.view.frame.size.height-(self.textCell4.frame.origin.y+self.textCell4.frame.size.height);
                            CGFloat finalOffset;
                            if(offset1-rect.size.height<0){
                                if (self.textCell4.frame.origin.y>self.view.frame.size.height) {
                                    finalOffset = rect.size.height - self.textCell4.frame.size.height;
                                }else{
                                    finalOffset = rect.size.height-offset1+self.textCell4.frame.size.height;
                                }
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
}

#pragma mark 键盘将要收起时，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
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
