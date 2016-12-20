//
//  AddContactNextController.m
//  Camnoopy
//
//  Created by guojunyi on 14-4-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AddContactNextController.h"
#import "TopBar.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "FListManager.h"
#import "MainController.h"
#import "Toast+UIView.h"
#import "ContactDAO.h"//多出的
#import "UDManager.h"
#import "LoginResult.h"
#import "Utils.h"//缺少的
#import "RecommendInfo.h"//缺少的
#import "RecommendInfoDAO.h"//缺少的
#import "QRCodeNextController.h"
#import "MD5Manager.h"
@interface AddContactNextController ()
{
    UILabel *_textLable;
}
@end

#define SAVE_BTN_WIDTH 45
#define ALERT_TAG_DELETE 0

@implementation AddContactNextController
-(void)dealloc{
    [self.contactId release];
    [self.storeID release];//缺少的
    [self.contactNameField release];
    [self.contactPasswordField release];
    [self.modifyContact release];
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

#pragma mark - 用Wi-Fi添加设备时，需要注释掉，不然会崩
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.hideDeleteBtn isEqualToString:@"hideDeleteBtn"])//Wi-Fi设置成功后进入的，隐藏删除按钮
    {
        self.deleteBtn.hidden = YES;
        //温馨提示
        _textLable = [[UILabel alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT*3 + 10, self.contactPasswordField.frame.size.width, 80)];
        _textLable.lineBreakMode = NSLineBreakByWordWrapping;
//        温馨提示:初次使用请及时修改默认密码，以免造成隐私泄露
        _textLable.text = NSLocalizedString(@"addDevice_warm_tips", nil);
        _textLable.font = XFontBold_16;
        _textLable.numberOfLines = 4;
        _textLable.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_textLable];
        [_textLable release];
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
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
//    导航栏
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:self.modifyContact.contactId];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    //删除按钮
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [deleteBtn setTitle:NSLocalizedString(@"delete", nil) forState:UIControlStateNormal];
    //    deleteBtn.titleLabel.font = XFontBold_14;
    self.deleteBtn.frame = CGRectMake(width - SAVE_BTN_WIDTH - 5, 20, SAVE_BTN_WIDTH, 45);
    UIImage *deleteBtnBackImg = [UIImage imageNamed:@"delete"];
    deleteBtnBackImg = [deleteBtnBackImg stretchableImageWithLeftCapWidth:deleteBtnBackImg.size.width*0.5 topCapHeight:deleteBtnBackImg.size.height*0.5];
    
    UIImage *deleteBtnBackImg_p = [UIImage imageNamed:@"delete"];
    deleteBtnBackImg_p = [deleteBtnBackImg_p stretchableImageWithLeftCapWidth:deleteBtnBackImg_p.size.width*0.5 topCapHeight:deleteBtnBackImg_p.size.height*0.5];
    
    [self.deleteBtn setBackgroundImage:deleteBtnBackImg forState:UIControlStateNormal];
    [self.deleteBtn setBackgroundImage:deleteBtnBackImg_p forState:UIControlStateHighlighted];
    [self.deleteBtn addTarget:self action:@selector(onDeletePress) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:self.deleteBtn];
    
    
    //多出的
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake((self.view.frame.size.width-300)/2, self.view.frame.size.height-50, 300, 34)];
    UIImage *bottomButton1Image = [UIImage imageNamed:@"new_button.png"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"new_button.png"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [saveButton setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [saveButton setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    [self.view addSubview:saveButton];
    
    [self.view setBackgroundColor:XBgColor];
    
    //多出的
    //设备ID
    UITextField *field0 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+80, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field0.layer.borderWidth = 1;
        field0.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field0.layer.cornerRadius = 5.0;
    }
    
    field0.textAlignment = NSTextAlignmentLeft;
    field0.placeholder = NSLocalizedString(@"input_contact_id", nil);
    field0.borderStyle = UITextBorderStyleRoundedRect;
    field0.returnKeyType = UIReturnKeyDone;
    field0.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field0.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field0.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field0 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:field0];
    self.contactIdField = field0;
    [field0 release];
    
    //设备Name
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_contact_name", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    if(self.isModifyContact){
        field1.text = self.modifyContact.contactName;
    }else if(self.isInFromQRCodeNextController || self.isInFromLocalDeviceList){//缺少的
        field1.text = [NSString stringWithFormat:@"Cam%@",self.contactId];
    }
    [self.view addSubview:field1];
    self.contactNameField = field1;
    [field1 release];
    
    //设备密码
    if([self.contactId characterAtIndex:0]!='0'){
        UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 80+NAVIGATION_BAR_HEIGHT+20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
        
        if(CURRENT_VERSION>=7.0){
            field2.layer.borderWidth = 1;
            field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
            field2.layer.cornerRadius = 5.0;
        }
        field2.textAlignment = NSTextAlignmentLeft;
        field2.placeholder = NSLocalizedString(@"input_contact_password", nil);
        field2.borderStyle = UITextBorderStyleRoundedRect;
        field2.returnKeyType = UIReturnKeyDone;
        field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
        field2.secureTextEntry = YES;
        if(self.isModifyContact){
            field2.text = self.modifyContact.contactPassword;
        }
        [self.view addSubview:field2];
        self.contactPasswordField = field2;
        [field2 release];
    }
    
    if (self.inType == 0)
    {//inType == 0表示 “修改”进入此界面
        self.contactIdField.hidden = YES;//隐藏device ID Field
        self.contactIdField.text = self.contactId;
        self.contactNameField.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
        self.contactPasswordField.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+80, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
        
    }
    else
    {//inType == 1表示 “手动添加”进入此界面
        self.contactIdField.hidden = NO;
        self.contactNameField.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
        self.contactPasswordField.frame =CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 80+NAVIGATION_BAR_HEIGHT+20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

-(void)onBackPress{
    if(self.isPopRoot){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)onDeletePress{
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_delete", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    deleteAlert.tag = ALERT_TAG_DELETE;
    [deleteAlert show];
    [deleteAlert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_DELETE:
        {
            if(buttonIndex==1){
                [[FListManager sharedFList] delete:self.modifyContact];
                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                
                [self onBackPress];
            }
        }
            break;
    }
}


-(void)onSavePress{
    
    if (self.isInFromManuallAdd) {//手动添加，判断id的有效性
        if(!self.contactIdField||!self.contactIdField.text.length>0){
            [self.view makeToast:NSLocalizedString(@"input_contact_id", nil)];
            return;
        }
        
        for (NSInteger i = 0; i < self.contactIdField.text.length; i++) {
            if ([self.contactIdField.text characterAtIndex:i] < '0' || [self.contactIdField.text characterAtIndex:i] > '9') {
                [self.view makeToast:NSLocalizedString(@"device_id_zero_format_error", nil)];
                return;
            }
        }
        if([self.contactIdField.text characterAtIndex:0]=='0'){
            [self.view makeToast:NSLocalizedString(@"device_id_zero_format_error", nil)];
            return;
        }
        
        if(self.contactIdField.text.length>9){
            [self.view makeToast:NSLocalizedString(@"id_too_long", nil)];
            return;
        }
        
        
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:self.contactIdField.text];
        
        if(contact!=nil){
            [self.view makeToast:NSLocalizedString(@"contact_already_exists", nil)];
            return;
        }
    }
    
    if(!self.contactNameField||!self.contactNameField.text.length>0){
        [self.view makeToast:NSLocalizedString(@"input_contact_name", nil)];
        return;
    }
    
    if([self.contactId characterAtIndex:0]!='0'){
        if(!self.contactPasswordField||!self.contactPasswordField.text.length>0){
            [self.view makeToast:NSLocalizedString(@"input_contact_password", nil)];
            return;
        }
    }
    
    
    if(self.isModifyContact){
        self.modifyContact.contactName = self.contactNameField.text;
        if([self.contactId characterAtIndex:0]!='0')
        {
            NSString *password = self.contactPasswordField.text;
            if([password characterAtIndex:0]=='0')
            {
//                设备密码必须是非\'0\'开头
                [self.view makeToast:NSLocalizedString(@"password_zero_format_error", nil)];
                return;
            }
            
            if(password.length>100)
            {
//                设备密码长度不能超过100个字符
                [self.view makeToast:NSLocalizedString(@"device_password_too_long", nil)];
                return;
            }
            
            
            self.modifyContact.contactPassword = [Utils GetTreatedPassword:password];
        }
//        更新modifyContact
        [[FListManager sharedFList] update:self.modifyContact];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
        Contact *contact = [[Contact alloc] init];
        contact.contactId = self.contactIdField.text;//不同self.contactId;
        contact.contactName = self.contactNameField.text;
        
        if([self.contactId characterAtIndex:0]!='0'){
            
            NSString *password = self.contactPasswordField.text;
            if([password characterAtIndex:0]=='0'){
                [self.view makeToast:NSLocalizedString(@"password_zero_format_error", nil)];
                return;
            }
            
            if(password.length>100){
                [self.view makeToast:NSLocalizedString(@"device_password_too_long", nil)];
                return;
            }
            
            contact.contactPassword = [Utils GetTreatedPassword:password];
            contact.contactType = CONTACT_TYPE_UNKNOWN;
        }else{
            contact.contactType = CONTACT_TYPE_PHONE;
        }
        [[FListManager sharedFList] insert:contact];
        
        [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
        [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
        
        //多出的
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSLog(@"loginuDID：%@",loginResult.contactId);
        NSMutableArray *dataArray = [NSMutableArray arrayWithObjects:loginResult.contactId, nil];
        [[P2PClient sharedClient] setBindAccountWithId:contact.contactId password:contact.contactPassword datas:dataArray];
        //多出的
        
        [contact release];
        
        //缺少的
        [self onlySaveStoreIDtoLacalOnceForDeviceSettedPassword];//保存商城ID
        
        if (self.inType == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else if (self.inType == 1){
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
        
    }
}





#pragma mark - save storeID
-(void)onlySaveStoreIDtoLacalOnceForDeviceSettedPassword{
    //get storeID from local
    NSString *localStoreID = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreID"];
    
    //self.storeID == nil 表示手动添加，没有storeID
    if (!localStoreID && self.storeID) {//only save storeID to local once
        //save storeID
        [[NSUserDefaults standardUserDefaults] setObject:self.storeID forKey:@"StoreID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //upload storeID parameter to server
        [self uploadStoreIDtoServerWithStoreID:self.storeID];
        
        //need to save launch image when first save storeID
        [self getLaunchImageInfoFirstWithStoreID:self.storeID];
        
        //第一次添加设备,主动请求5条推荐消息,并保存本地
        //[self getRecommendInfoListWithStoreID:self.storeID];
    }
}

//取服务器的数据  获取推荐内容列表
-(void)getRecommendInfoListWithStoreID:(NSString *)storeID{
    
    LoginResult * login = [UDManager getLoginInfo];
    NSInteger userID = login.contactId.integerValue | 0x80000000;
    NSString *sessionID = login.sessionId;
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.231/Business/Seller/RecommendInfo.ashx?UserID=%d&SessionID=%@&StoreID=%@&PageIndex=1&PageSize=5",userID,sessionID,storeID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue ] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ((!error)) {//发送请求成功
            NSError *parseError;
            id dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            
            int error_code = [[dictionary objectForKey:@"error_code"] intValue];
            if (error_code == 0) {//成功获取到数据
                NSString *RL = [dictionary objectForKey:@"RL"];
                
                NSArray *array = [RL componentsSeparatedByString:@";"];
                
                for(NSString *record in array){
                    if([record isEqualToString:@""]){
                        continue;
                    }
                    
                    NSArray *detailArray = [record componentsSeparatedByString:@","];
                    RecommendInfo * recommendInfo = [[RecommendInfo alloc] init];
                    
                    for (int i = 0; i < detailArray.count; i++) {
                        switch (i) {
                            case 0://database key
                            {
                                recommendInfo.messageID = [detailArray[i] integerValue];
                            }
                                break;
                            case 1:
                            {
                                NSString *title = [Utils getNormalStringByDecodedBase64String:detailArray[i]];
                                recommendInfo.titleString = title;
                            }
                                break;
                            case 2:
                            {
                                NSString *content = [Utils getNormalStringByDecodedBase64String:detailArray[i]];
                                recommendInfo.contentString = content;
                            }
                                break;
                            case 3:
                            {
                                recommendInfo.imageURLString = detailArray[i];
                            }
                                break;
                            case 4:
                            {
                                NSString *imageLinkURLString = [Utils getNormalStringByDecodedBase64String:detailArray[i]];
                                recommendInfo.imageLinkURLString = imageLinkURLString;
                            }
                                break;
                            case 5:
                            {
                                //预览ID
                            }
                                break;
                            case 6:
                            {
                                recommendInfo.timeString = detailArray[i];
                            }
                                break;
                            case 7:
                            {
                                //状态
                            }
                                break;
                        }
                    }
                    recommendInfo.isRead = NO;//YES表示已读
                    
                    //数据库的主键是唯一的，与主键相同的数据当然也插入不了。
                    RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
                    [recoDAO insert:recommendInfo];
                    [recoDAO release];
                    [recommendInfo release];
                }
            }else{//获取数据失败
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self.view makeToast:NSLocalizedString(@"get_data_fail", nil)];
                });
            }
            
        }else{//发送请求失败
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.view.window makeToast:NSLocalizedString(@"send_request_fail", nil)];
            });
        }
    }];
}

-(void)uploadStoreIDtoServerWithStoreID:(NSString *)storeID{
    
    LoginResult * login = [UDManager getLoginInfo];
    NSInteger userID = login.contactId.integerValue | 0x80000000;
    NSString *sessionID = login.sessionId;
    NSString *setStoreIDURLString = [NSString stringWithFormat:@"http://192.168.1.231/AppInfo/SetStoreID.ashx?UserID=%d&SessionID=%@&StoreID=%@",userID,sessionID,storeID];
    NSURL * setStoreIDURL = [NSURL URLWithString:setStoreIDURLString];
    NSURLRequest * request = [NSURLRequest requestWithURL:setStoreIDURL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue ] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ((!error)) {//成功获取到数据
            NSError *parseError;
            id dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            
            int error_code = [[dictionary objectForKey:@"error_code"] intValue];
            if (error_code == 0) {
                //表示设置成功
            }else{
                //表示设置失败
            }
            
        }else{//发送请求失败
            dispatch_async(dispatch_get_main_queue(), ^{
                //                [self.view.window makeToast:NSLocalizedString(@"send_request_fail", nil)];
            });
        }
    }];
}

-(void)getLaunchImageInfoFirstWithStoreID:(NSString *)storeID{
    
    LoginResult * login = [UDManager getLoginInfo];
    NSInteger userID = login.contactId.integerValue | 0x80000000;
    NSString *sessionID = login.sessionId;
    NSString *launchURLString = [NSString stringWithFormat:@"http://192.168.1.231/AppInfo/getappstartinfo.ashx?UserID=%d&SessionID=%@&StoreID=%@",userID,sessionID,storeID];
    NSURL * launchURL = [NSURL URLWithString:launchURLString];
    NSURLRequest * request = [NSURLRequest requestWithURL:launchURL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue ] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ((!error)) {//发送请求成功
            NSError *parseError;
            id dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            
            int error_code = [[dictionary objectForKey:@"error_code"] intValue];
            if (error_code == 0) {//成功获取到数据
                NSString *serverFlag = [dictionary objectForKey:@"Index"];
                
                //save flag
                [[NSUserDefaults standardUserDefaults] setObject:serverFlag forKey:@"AppStartInfoFlag"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //save launch image
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dictionary objectForKey:@"ImageSrc"]]];
                [Utils saveAppLaunchImageFileWithFlag:serverFlag imageData:imageData];
                
                //save launch imageLink
                NSString *imageLinkString = [Utils getNormalStringByDecodedBase64String:[dictionary objectForKey:@"Link"]];
                [[NSUserDefaults standardUserDefaults] setObject:imageLinkString forKey:@"Link"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else{//获取数据失败
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self.view makeToast:NSLocalizedString(@"get_data_fail", nil)];
                });
            }
            
        }else{//发送请求失败
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self.window makeToast:NSLocalizedString(@"启动界面更新失败", nil)];
            //            });
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.view makeToast:NSLocalizedString(@"send_request_fail", nil)];
            });
        }
    }];
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
