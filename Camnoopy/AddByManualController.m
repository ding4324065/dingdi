//
//  AddByManualController.m
//  Camnoopy
//
//  Created by Lio on 15/5/15.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "AddByManualController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Toast+UIView.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "FListManager.h"
#import "ContactController.h"
#import "MD5Manager.h"
#import "Utils.h"

@interface AddByManualController ()

{
    UITextField* _fieldDevID;
    UITextField* _fieldDevName;
    UITextField* _fieldDevPwd;
    UILabel *_textLable;
}
@end

@implementation AddByManualController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initComponent];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
}

-(void)initComponent
{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
   // CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
//    手动添加设备
    [topBar setTitle:NSLocalizedString(@"addByManual",nil)];
    [self.view addSubview:topBar];
    [topBar release];

    
    _fieldDevID = [[UITextField alloc]initWithFrame:CGRectMake(10, NAVIGATION_BAR_HEIGHT + 38, width-20, 40)];
    _fieldDevID.placeholder = NSLocalizedString(@"input_contact_id", nil);
    _fieldDevID.backgroundColor = [UIColor whiteColor];
    _fieldDevID.returnKeyType = UIReturnKeyDone;
    _fieldDevID.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _fieldDevID.font = XFontBold_16;
    [_fieldDevID setBorderStyle:UITextBorderStyleRoundedRect];
    [_fieldDevID addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_fieldDevID addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_fieldDevID];
    [_fieldDevID release];
    
    _fieldDevName = [[UITextField alloc]initWithFrame:CGRectMake(10, NAVIGATION_BAR_HEIGHT + 80, width-20, 40)];
    _fieldDevName.placeholder = NSLocalizedString(@"input_contact_name", nil);
    _fieldDevName.backgroundColor = [UIColor whiteColor];
    _fieldDevName.returnKeyType = UIReturnKeyDone;
    _fieldDevName.font = XFontBold_16;
    [_fieldDevName setBorderStyle:UITextBorderStyleRoundedRect];
    [_fieldDevName addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_fieldDevName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_fieldDevName];
    [_fieldDevName release];
    
    _fieldDevPwd = [[UITextField alloc]initWithFrame:CGRectMake(10, NAVIGATION_BAR_HEIGHT + 122, width-20, 40)];
    _fieldDevPwd.placeholder = NSLocalizedString(@"input_contact_password", nil);
    _fieldDevPwd.backgroundColor = [UIColor whiteColor];
    _fieldDevPwd.returnKeyType = UIReturnKeyDone;
    _fieldDevPwd.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [_fieldDevPwd setBorderStyle:UITextBorderStyleRoundedRect];
    _fieldDevPwd.secureTextEntry = YES;
    _fieldDevPwd.font = XFontBold_16;
    [_fieldDevPwd addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_fieldDevPwd addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_fieldDevPwd setSecureTextEntry:YES];
    [self.view addSubview:_fieldDevPwd];
    [_fieldDevPwd release];
//    保存
    UIButton *btnSave = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-300)/2, NAVIGATION_BAR_HEIGHT*4, 300, 34)];
    [btnSave setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    UIImage *saveButtonBackImg = [UIImage imageNamed:@"new_button.png"];
    saveButtonBackImg = [saveButtonBackImg stretchableImageWithLeftCapWidth:saveButtonBackImg.size.width*0.5 topCapHeight:saveButtonBackImg.size.height*0.5];
    UIImage *saveButtonBackImg_p = [UIImage imageNamed:@"new_button.png"];
    saveButtonBackImg_p = [saveButtonBackImg_p stretchableImageWithLeftCapWidth:saveButtonBackImg_p.size.width*0.5 topCapHeight:saveButtonBackImg_p.size.height*0.5];
    [btnSave setBackgroundImage:saveButtonBackImg forState:UIControlStateNormal];
    [btnSave setBackgroundImage:saveButtonBackImg_p forState:UIControlStateHighlighted];

    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//title color
    btnSave.showsTouchWhenHighlighted = YES;
    [btnSave addTarget:self action:@selector(onClickSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSave];
    [btnSave release];
    
    //温馨提示
    _textLable = [[UILabel alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT*4 + btnSave.frame.size.height, _fieldDevPwd.frame.size.width, 80)];
    _textLable.lineBreakMode = NSLineBreakByWordWrapping;
//    温馨提示:初次使用请及时修改默认密码，以免造成隐私泄露
    _textLable.text = NSLocalizedString(@"addDevice_warm_tips", nil);
    _textLable.font = XFontBold_16;
    _textLable.numberOfLines = 4;
    _textLable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_textLable];
    [_textLable release];
}


//返回按钮
-(void)onBackPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

//响应回车键
-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    
    if (textField.text.length > 32) {
        textField.text = [textField.text substringToIndex:32];
    }
    
}



-(void)onClickSave:(id)sender
{
    if(!_fieldDevID||!(_fieldDevID.text.length>0)){
//        请输入设备ID"
        [self.view makeToast:NSLocalizedString(@"input_contact_id", nil)];
        return;
    }
    
    if([_fieldDevID.text characterAtIndex:0]=='0'){
//        设备ID必须是非\'0\'开头的数字组合
        [self.view makeToast:NSLocalizedString(@"device_id_zero_format_error", nil)];
        return;
    }
    
    if(_fieldDevID.text.length>9){
//        ID号不能超过9个字符
        [self.view makeToast:NSLocalizedString(@"id_too_long", nil)];
        return;
    }
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:_fieldDevID.text];
    if(contact!=nil){
//        设备已存在
        [self.view makeToast:NSLocalizedString(@"contact_already_exists", nil)];
        return;
    }
    
    if(!_fieldDevName||!_fieldDevName.text.length>0){
//        请输入设备名称
        [self.view makeToast:NSLocalizedString(@"input_contact_name", nil)];
        return;
    }
    
    if(!_fieldDevPwd||!_fieldDevPwd.text.length>0){
//        请输入设备密码
        [self.view makeToast:NSLocalizedString(@"input_contact_password", nil)];
        return;
    }
    
    NSString *password = _fieldDevPwd.text;
    if([password characterAtIndex:0]=='0')
    {
//        设备密码必须是非\'0\'开头";//改了
        [self.view makeToast:NSLocalizedString(@"password_zero_format_error", nil)];
        return;
    }
    
    if(password.length>100)
    {
//        设备密码长度不能超过10个字符
        [self.view makeToast:NSLocalizedString(@"device_password_too_long", nil)];
        return;
    }
    
    //---------------------
    Contact *contactNew = [[Contact alloc] init];
    contactNew.contactId = [_fieldDevID text];
    contactNew.contactName = [_fieldDevName text];
    
        
    contactNew.contactPassword = [Utils GetTreatedPassword:password];
//    其他场景
    contactNew.contactType = CONTACT_TYPE_UNKNOWN;
    
    [[FListManager sharedFList] insert:contactNew];
    [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contactNew.contactId]];
    [[P2PClient sharedClient] getDefenceState:contactNew.contactId password:contactNew.contactPassword];
    [contact release];
//    返回主视图
    [self.navigationController popToRootViewControllerAnimated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
