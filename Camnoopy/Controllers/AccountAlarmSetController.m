//
//  AccountAlarmSetController.m
//  Camnoopy
//
//  Created by 高琦 on 15/3/19.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
#define RGBA(r,g,b,a)               [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:(float)a]
#define ALERT_TAG_DEC_SHIELD_ALARM_ID 5
#define ALERT_TAG_ADD_SHIELD_ALARM_ID 6

#import "P2PTimeSettingCell.h"
#import "P2PSecurityCell.h"
#import "P2PPlanTimeSettingCell.h"
#import "Utils.h"
#import "P2PClient.h"
#import "AccountAlarmSetController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "MBProgressHUD.h"
#import "P2PEmailSettingCell.h"
#import "MainContainer.h"
#import "Toast+UIView.h"
#import "shieldDao.h"
#import "Utils.h"
@interface AccountAlarmSetController ()
{
    TopBar* _topBar;
    
    //bindview
    UILabel* _headnameLabel;
    UILabel* _tipLabel;
    UIButton* _btnSave;
    
    //table
    UILabel* _tableheadLable;
}
@end

@implementation AccountAlarmSetController

-(void)dealloc{
    [self.tableView release];
    [super dealloc];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCompent];
    [self inittimepicker];
    [self initdataArr];
    [self BindViewinit];
    // Do any additional setup after loading the view.
}

- (void)initdataArr{
    shieldDao* dao = [[shieldDao alloc]init];
    self.shieldingIdArr = [dao findAll];
    [dao release];
}

- (void)inittimepicker{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat rowheight = BAR_BUTTON_HEIGHT*3/5;
    
    self.timezoneview = [[[MXSCycleScrollView alloc] initWithFrame:CGRectMake(0,0, width, BAR_BUTTON_HEIGHT*3)]autorelease];
    self.timezoneview.delegate = self;
    self.timezoneview.datasource = self;
//   本地报警间隔时间
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSInteger intertime =  [manager integerForKey:@"Local alarm interval"];
    [self.timezoneview setCurrentSelectPage:intertime-1];
    
    [self.timezoneview reloadData];
    [self setAfterScrollShowView:self.timezoneview andCurrentPage:1];
    
    UIView *beforeSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, rowheight, width, 1.0)];//黑线1
    [beforeSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [_timezoneview addSubview:beforeSepLine];
    
    UIView *middleSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, rowheight*2+1, width, 0.5)];//黑线2(选中上方)
    [middleSepLine setBackgroundColor:[UIColor blackColor]];
    [_timezoneview addSubview:middleSepLine];
    
    UIImage* image1= [UIImage imageNamed:@"timeset2.png"];
    image1 = [image1 stretchableImageWithLeftCapWidth:image1.size.width*0.5 topCapHeight:image1.size.height*0.5];
    UIImageView * imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, width/30, rowheight*5-7)];
    imageview1.image=image1;
    [_timezoneview addSubview:imageview1];
    
    UIImage* image2= [UIImage imageNamed:@"timeset2.png"];
    image2 = [image2 stretchableImageWithLeftCapWidth:image2.size.width*0.5 topCapHeight:image2.size.height*0.5];
    UIImageView * imageview2 = [[UIImageView alloc] initWithFrame:CGRectMake(width-width/30, 0, width/30, rowheight*5)];
    imageview2.image=image2;
    [_timezoneview addSubview:imageview2];
    
    UIView * middlesecSepLine =[[UIView alloc] initWithFrame:CGRectMake(0, rowheight*3+1, width, 0.5)];//黑线2
    [middlesecSepLine setBackgroundColor:[UIColor blackColor]];
    [_timezoneview addSubview:middlesecSepLine];
    
    UIView *bottomSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, rowheight*4+1, width, 1.5)];
    [bottomSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [_timezoneview addSubview:bottomSepLine];

    
}
- (void)setAfterScrollShowView:(MXSCycleScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    UILabel *oneLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:14]];
    [oneLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
    UILabel *twoLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+1];
    [twoLabel setFont:[UIFont systemFontOfSize:16]];
    [twoLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *currentLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+2];
    [currentLabel setFont:[UIFont systemFontOfSize:18]];
    [currentLabel setTextColor:RGBA(3.0, 162.0, 234.0, 1.0)];
    
    UILabel *threeLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+3];
    [threeLabel setFont:[UIFont systemFontOfSize:16]];
    [threeLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    UILabel *fourLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+4];
    [fourLabel setFont:[UIFont systemFontOfSize:14]];
    [fourLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
}
#pragma mark mxccyclescrollview delegate
#pragma mark mxccyclescrollview databasesource
- (NSInteger)numberOfPages:(MXSCycleScrollView*)scrollView
{
    return 60;
}

- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(MXSCycleScrollView *)scrollView
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height/5)];
    
    l.tag = index+100;
    
    l.text = [NSString stringWithFormat:@"%d",index+1];
    l.font = [UIFont systemFontOfSize:12];
    l.textAlignment = NSTextAlignmentCenter;
    l.backgroundColor = [UIColor clearColor];
    return l;
}

#pragma mark 当滚动时设置选中的cell
- (void)scrollviewDidChangeNumber
{
    
    UILabel * label = [[(UILabel*)[[self.timezoneview subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    label.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    
}
#pragma mark 滚动完成后的回调
- (void)scrollviewDidEndChangeNumber
{
    
    UILabel * label = [[(UILabel*)[[self.timezoneview subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    label.textColor = RGBA(3.0, 162.0, 234.0, 1.0);
    self.settime = [label.text integerValue];
    [self.tableView reloadData];
}

-(void)onKeyBoardWillShow:(NSNotification*)notification{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, -kbSize.height);
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
-(void)initCompent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar.leftButton setHidden:NO];
    [topBar setLeftButtonIcon:[UIImage imageNamed:@"open_menu.png"]];
    [topBar.leftButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"mainmenu_alarmset",nil)];
    _topBar = topBar;
    
    
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
}

-(void)onBackPress{
    MainContainer * maincontainer = [AppDelegate sharedDefault].mainController;
    [maincontainer showLeftMenu:YES];
}

-(void)addShieldingID{
    [self BindUp];
}

-(void)havetapLeftIconView:(NSInteger)section androw:(NSInteger)row{
    self.delsection = section;
    self.delrow = row;
    NSString* text = [NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"confirm_unblock", nil), [self.shieldingIdArr objectAtIndex:row]];
    UIAlertView *unBindAccountAlert = [[UIAlertView alloc] initWithTitle:text
                                                                 message:@""
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                                       otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    unBindAccountAlert.tag = ALERT_TAG_DEC_SHIELD_ALARM_ID;
    [unBindAccountAlert show];
    [unBindAccountAlert release];
}

-(void)savePress:(NSInteger)section row:(NSInteger)row{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    [manager setInteger:self.settime forKey:@"Local alarm interval"];
    [manager synchronize];
    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
}

-(void)BindViewinit
{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIView * alphaView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    alphaView.backgroundColor = XBlack_128;
    alphaView.hidden = YES;
    [self.view addSubview:alphaView];
    self.alphaView = alphaView;
    [alphaView release];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.alphaView addGestureRecognizer:tap];
    [tap release];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.alphaView addGestureRecognizer:pan];
    [pan release];
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, CUSTOM_VIEW_HEIGHT_SHORT+40)];
    view.backgroundColor = XWhite;
    [self.alphaView addSubview:view];
    self.BindView = view;
    self.BindView.layer.contents = (id)[UIImage imageNamed:@"about_bk.png"].CGImage;
    [view release];
    
    UIView * headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    headview.backgroundColor = [UIColor colorWithRed:3.0/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0f];
    [self.BindView addSubview:headview];
    [headview release];
    
    UILabel * headnamelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, width, 30)];
    headnamelabel.backgroundColor = [UIColor clearColor];
    headnamelabel.textAlignment = NSTextAlignmentCenter;
    headnamelabel.textColor = XWhite;
    headnamelabel.text = NSLocalizedString(@"addshield_device", nil);
    _headnameLabel = headnamelabel;
    [self.BindView addSubview:headnamelabel];
    [headnamelabel release];
    
    UIButton * DownBtn = [[UIButton alloc] init];
    DownBtn.frame = CGRectMake(width - 40, 5, 40, 34);
    UIImageView *downImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 20, 20)];
    downImage.image = [UIImage imageNamed:@"ic_down.png"];
    [DownBtn addSubview:downImage];
    [DownBtn addTarget:self action:@selector(sheetViewHidden) forControlEvents:UIControlEventTouchUpInside];
    [self.BindView addSubview:DownBtn];
    [DownBtn release];
    [downImage release];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, width, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
    label.numberOfLines = 0;
    label.text = NSLocalizedString(@"addshield_tip", nil);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12.0];
    _tipLabel = label;
    [self.BindView addSubview:label];
    [label release];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(10, 85, width-20, TEXT_FIELD_HEIGHT)];
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_contact_id", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.returnKeyType = UIReturnKeyDone;
    field1.font = XFontBold_16;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.shieldIDtextView = field1;
    [self.shieldIDtextView addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.shieldIDtextView.delegate = self;
    [self.BindView addSubview:field1];
    [field1 release];
    
    UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"new_button.png"] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    [button setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame=CGRectMake(20, 145, width-2*20, TEXT_FIELD_HEIGHT - 3*2);
    [button addTarget:self action:@selector(onShieldbtnclick) forControlEvents:UIControlEventTouchUpInside];
    _btnSave = button;
    [self.BindView addSubview:button];
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
    self.BindView.frame = CGRectMake(0, height-CUSTOM_VIEW_HEIGHT_SHORT-40, width, CUSTOM_VIEW_HEIGHT_SHORT+40);
    self.alphaView.hidden = NO;
    self.shieldIDtextView.text = @"";
    
    [UIView setAnimationDelegate:self];
    // 动画完毕后调用animationFinished
    [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    [UIView commitAnimations];
}

-(void)sheetViewHidden{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
        self.BindView.frame = CGRectMake(0, height, width,CUSTOM_VIEW_HEIGHT_SHORT+40);
        [self.shieldIDtextView resignFirstResponder];
        
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
}

-(void)animationFinished{
    //NSLog(@"动画结束!");
    
}
-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

//pragma mark 输入框限制
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.shieldIDtextView) {
        NSString* text = textField.text;
        for (int i=0; i<text.length; i++) {
            NSString* temp = [text substringWithRange:NSMakeRange(i,1)];
            if (![temp isValidateNumber]) {
                self.shieldIDtextView.text = [text substringWithRange:NSMakeRange(0,i)];
                return;
            }
        }
    }
    
    if (textField == self.shieldIDtextView) {
        if (textField.text.length > 9) {
            textField.text = [textField.text substringToIndex:9];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.shieldIDtextView) {
        return [string isValidateNumber];
    }
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//pragma mark 添加屏蔽账号
-(void)onShieldbtnclick
{
    NSString *shieldId = self.shieldIDtextView.text;
    if ([shieldId isEqualToString:@""])
    {
        [self.view makeToast:NSLocalizedString(@"input_contact_id", nil)];
        return;
    }
    
    if([shieldId characterAtIndex:0]=='0'){
        [self.view makeToast:NSLocalizedString(@"device_id_zero_format_error", nil)];
        return;
    }
    
    shieldDao* dao = [[shieldDao alloc]init];
    BOOL isShield = [dao isShield:shieldId];
    if (isShield) {
        [self.view makeToast:NSLocalizedString(@"already_shield", nil)];
        [dao release];
        return;
    }
    
    //更新数据库
    [dao insert:shieldId];
    
    //更新内存
    self.shieldingIdArr = [dao findAll];
    [dao release];
    
    //更新ui
    [self sheetViewHidden];
    [self.tableView reloadData];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        return YES;
    }
    return NO;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    UIView * head = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, BAR_BUTTON_HEIGHT)]autorelease];
    head.backgroundColor = [UIColor whiteColor];
    if (section==1) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, BAR_BUTTON_HEIGHT)];
        label.text = NSLocalizedString(@"alarm_shield_device", nil);
        label.font = XFontBold_16;
        [head addSubview:label];
        _tableheadLable = label;
        [label release];
        
        UIButton * addbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addbtn.frame = CGRectMake(head.frame.size.width-50, 5, BAR_BUTTON_HEIGHT-10, BAR_BUTTON_HEIGHT-10);
        [addbtn setBackgroundImage:[UIImage imageNamed:@"alarm_add.png"] forState:UIControlStateNormal];
        [addbtn addTarget:self action:@selector(addShieldingID) forControlEvents:UIControlEventTouchUpInside];
        addbtn.layer.cornerRadius = (BAR_BUTTON_HEIGHT-10)/2;
        addbtn.clipsToBounds = YES;
        [head addSubview:addbtn];
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, BAR_BUTTON_HEIGHT-1, head.frame.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [head addSubview:line];
        [line release];
    }
    return head;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    else {
        return BAR_BUTTON_HEIGHT;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 3;
    }
    return self.shieldingIdArr.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        if(indexPath.row==1){
            return BAR_BUTTON_HEIGHT*3;
        }else{
            return BAR_BUTTON_HEIGHT;
        }
    }
    return BAR_BUTTON_HEIGHT;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier3 = @"P2PEmailSettingCell";
    static NSString *identifier4 = @"P2PTimeSettingCell";
    static NSString *identifier7 = @"P2PSecurityCell";
    UITableViewCell *cell = nil;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
    if(cell==nil){
        cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
        [cell setBackgroundColor:XBGAlpha];
    }
    switch (section) {
        case 0:{
            if(row==0){
                cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
                if(cell==nil){
                    cell = [[[P2PTimeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }else if(row==1){
                cell = [tableView dequeueReusableCellWithIdentifier:identifier4];
                if(cell==nil){
                    cell = [[[P2PTimeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier4] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }else if(row==2){
                cell = [tableView dequeueReusableCellWithIdentifier:identifier7];
                if(cell==nil){
                    cell = [[[P2PSecurityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier7] autorelease];
                    [cell setBackgroundColor:XWhite];
                }
            }
            P2PTimeSettingCell *timeCell = (P2PTimeSettingCell*)cell;
            if(row==0){
                [timeCell setLeftLabelHidden:YES];
                [timeCell setRightLabelHidden:YES];
                [timeCell setCustomViewHidden:YES];
                [timeCell setTitleViewHidden:YES];
                [timeCell setProgressViewHidden:YES];
                [timeCell setMiddleLabelHidden:NO];
                [timeCell setMiddleLabelText:NSLocalizedString(@"alarm_interval", nil)];
            }else if(row==1){
                [timeCell setLeftLabelHidden:YES];
                [timeCell setRightLabelHidden:YES];
                [timeCell setMiddleLabelHidden:YES];
                [timeCell setCustomViewHidden:NO];
                [timeCell setTitleViewHidden:NO];
                [timeCell setProgressViewHidden:YES];
                [timeCell.contentView addSubview:self.timezoneview];
            }else {
                P2PSecurityCell *settingCell = (P2PSecurityCell*)cell;
                settingCell.delegate = self;
                [settingCell setMiddleLabelHidden:YES];
                [settingCell setLeftLabelHidden:YES];
                [settingCell setMiddleButtonHidden:NO];
            }
        }
            
            break;
        case 1:{
            P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
            emailCell.row = row;
            emailCell.section = section;
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, BAR_BUTTON_HEIGHT-1, self.tableView.frame.size.width, 0.5)];
            line.backgroundColor = [UIColor lightGrayColor];
            [emailCell.contentView addSubview:line];
            [line release];
            emailCell.backgroundColor = [UIColor whiteColor];
            [emailCell setRightLabelText:self.shieldingIdArr[row]];
            [emailCell setLeftIcon:@"alarm_dec.png"];
            [emailCell setLeftLabelHidden:YES];
            [emailCell setLeftIconHidden:NO];
            [emailCell setRightLabelHidden:NO];
            [emailCell setProgressViewHidden:YES];
            
        }
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        [self havetapLeftIconView:indexPath.section androw:indexPath.row];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_DEC_SHIELD_ALARM_ID:
        {
            if(buttonIndex==1)
            {
                NSString* deleteId = self.shieldingIdArr[self.delrow];
                //更新数据库
                shieldDao* dao = [[shieldDao alloc]init];
                [dao deleteContent:deleteId];
                [dao release];
                
                //更新内存
                [self.shieldingIdArr removeObject:deleteId];
                
                //更新界面
                NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                [indexSet release];
            }
        }
            break;
        case ALERT_TAG_ADD_SHIELD_ALARM_ID:
        {
            
        }
    }
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
- (void) handleTap: (UITapGestureRecognizer *)recognizer
{
    if (self.BindView == nil) {
        return;
    }
    CGPoint point = [recognizer locationInView:self.alphaView];
    
    if (!CGRectContainsPoint(self.BindView.frame, point)) {
        [self sheetViewHidden];
    }
}

-(void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    return;
}

@end
