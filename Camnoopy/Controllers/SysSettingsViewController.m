//
//  SysSettingsViewController.m
//  Camnoopy
//
//  Created by 卡努比 on 16/4/19.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "SysSettingsViewController.h"
#import "Contact.h"
#import "TopBar.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "MainController.h"
#import "P2PSwitchCell.h"
#import "MusicViewController.h"
#import "mesg.h"
#import "Toast+UIView.h"
#import "P2PEmailSettingCell.h"

#define CELL_ID     @"cellID"
@interface SysSettingsViewController ()
//4.定义block
//@property(nonatomic ,strong)void (^block)(NSString *str);
@property(nonatomic, strong)TopBar* _topBar;
@property (nonatomic,strong)UIView *view1;
@property (nonatomic, strong) NSString *musicName;
@end

@implementation SysSettingsViewController



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    self.VibrationsStart= [manager integerForKey:@"VibrationsStart"];
    self.OpenvoiceState = [manager integerForKey:@"OpenvoiceState"];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
//    self.VibrationsStart= [manager integerForKey:@"VibrationsStart"];
//    self.OpenvoiceState = [manager integerForKey:@"OpenvoiceState"];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCompent];
}

- (void)initCompent
{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar.leftButton setHidden:NO];
    [topBar setLeftButtonIcon:[UIImage imageNamed:@"open_menu.png"]];
    [topBar.leftButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"setting",nil)];
    topBar = topBar;
    [self.view addSubview:topBar];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.scrollEnabled = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier11 = @"P2PSwitchCell";
    static NSString *identifier3 = @"P2PEmailSettingCell";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier11];
    if (indexPath.section== 0) {
        if(cell==nil){
            cell = [[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier11];
            [cell setBackgroundColor:XWhite];
        }
        
        P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
        cell2.delegate = self;
        cell2.indexPath = indexPath;
        cell2.switchView = self.imageInversionSwitch;
        [cell2 setLeftLabelText:NSLocalizedString(@"alarm_vibration", nil)];
        if (self.isVibrationsStart) {
            [cell2 setProgressViewHidden:YES];
            [cell2 setSwitchViewHidden:YES];
        }
        else{
            [cell2 setProgressViewHidden:YES];
            [cell2 setSwitchViewHidden:NO];
            if(self.VibrationsStart == SETTING_VALUE_VIBRATION_STATE_ON)
            {
                cell2.on = YES;
            }
            else
            {
                cell2.on = NO;
            }
        }
        
    }
    else if (indexPath.section == 1) {
        if(cell==nil){
            cell = [[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier11];
            [cell setBackgroundColor:XWhite];
        }
        
        P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
        cell2.delegate = self;
        cell2.indexPath = indexPath;
        cell2.switchView = self.imageInversionSwitch;
        [cell2 setLeftLabelText:NSLocalizedString(@"alarm_bell", nil)];
        
        if (self.isOpenvoice) {
            [cell2 setProgressViewHidden:YES];
            [cell2 setSwitchViewHidden:YES];
        }
        else{
            [cell2 setProgressViewHidden:YES];
            [cell2 setSwitchViewHidden:NO];
            if(self.OpenvoiceState == SETTING_VALUE_MUSIZ_STATE_ON)
            {
                cell2.on = YES;
            }
            else
            {
                cell2.on = NO;
            }
            
        }
        
    }
        else if (indexPath.section == 2){
    
            if(cell==nil){
                cell = [[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3];
                [cell setBackgroundColor:XWhite];
    
                P2PEmailSettingCell *emailsetCell = (P2PEmailSettingCell*)cell;
                emailsetCell.delegate = self;
                [emailsetCell setSection:indexPath.section];
                [emailsetCell setRow:indexPath.row];
    
            }
            P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
            [emailCell setRightIcon:@"ic_arrow.png"];
            //        [emailCell setLeftLabelText:NSLocalizedString(@"alarm_email", nil)];
            emailCell.leftLabelText = @"铃声选择";
            [emailCell setLeftLabelText:NSLocalizedString(@"bell_select",nil)];

            if(self.isLoadingBindEmail){
                [emailCell setLeftIconHidden:YES];
                [emailCell setLeftLabelHidden:NO];
                [emailCell setRightIconHidden:YES];
                [emailCell setRightLabelHidden:YES];
                [emailCell setProgressViewHidden:NO];
    
            }else{
                [emailCell setLeftIconHidden:YES];
                [emailCell setLeftLabelHidden:NO];
                [emailCell setRightIconHidden:NO];
                [emailCell setRightLabelHidden:NO];
                [emailCell setProgressViewHidden:YES];
            }
            NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
            _musicName = [userdefaults objectForKey:@"musicStr"];
            if (_musicName==nil) {
                emailCell.rightLabelText = @"";
            }else{
                
                    emailCell.rightLabelText = _musicName;
                 }
        }
    return cell;
}

-(void)onSwitchValueChange:(UISwitch *)sender indexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
            
        case 0:
        {
            if (self.VibrationsStart == SETTING_VALUE_VIBRATION_STATE_OFF && sender.on) {
                self.isVibrationsStart = YES;
                self.lastVibrationsStart = self.VibrationsStart;
                self.VibrationsStart = SETTING_VALUE_VIBRATION_STATE_ON;
                dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:self.isVibrationsStart forKey:@"isVibrationsStart"];
                [userDefaults setInteger:self.VibrationsStart forKey:@"VibrationsStart"];
                [userDefaults synchronize];
            }
            else if (self.VibrationsStart == SETTING_VALUE_VIBRATION_STATE_ON && !sender.on) {
                self.isVibrationsStart = YES;
                self.lastVibrationsStart = self.VibrationsStart;
                self.VibrationsStart = SETTING_VALUE_VIBRATION_STATE_OFF;
                dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:self.isVibrationsStart forKey:@"isVibrationsStart"];
                [userDefaults setInteger:self.VibrationsStart forKey:@"VibrationsStart"];
                [userDefaults synchronize];
            }
        }
            break;
            
        case 1:
        {
            if (self.OpenvoiceState == SETTING_VALUE_MUSIZ_STATE_OFF && sender.on) {
                self.isOpenvoice = YES;
                self.lastOpenvoice = self.OpenvoiceState;
                self.OpenvoiceState = SETTING_VALUE_MUSIZ_STATE_ON;
                dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:self.isOpenvoice forKey:@"isOpenvoice"];
                [userDefaults setInteger:self.OpenvoiceState forKey:@"OpenvoiceState"];
                [userDefaults synchronize];
            }
            else if (self.OpenvoiceState == SETTING_VALUE_MUSIZ_STATE_ON && !sender.on) {
                self.isOpenvoice = YES;
                self.lastOpenvoice = self.OpenvoiceState;
                self.OpenvoiceState = SETTING_VALUE_MUSIZ_STATE_OFF;
                dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:self.isOpenvoice forKey:@"isOpenvoice"];
                [userDefaults setInteger:self.OpenvoiceState forKey:@"OpenvoiceState"];
                [userDefaults synchronize];
            }
        }
            break;
        default:
            break;
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (indexPath.section==2) {
            MusicViewController *music = [[MusicViewController alloc] init];
    

            [self presentViewController:music animated:YES completion:nil];
        }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return BAR_BUTTON_HEIGHT;
}


- (void)onBackPress{
    MainContainer * maincontainer = [AppDelegate sharedDefault].mainController;
    [maincontainer showLeftMenu:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
