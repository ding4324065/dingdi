

#import "ContactController.h"
#import "NetManager.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "BottomBar.h"
#import "SVPullToRefresh.h"
#import "ContactCell.h"
#import "AddContactNextController.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "FListManager.h"
#import "GlobalThread.h"
#import "MainSettingController.h"
#import "P2PPlaybackController.h"
#import "ChatController.h"
#import "TempContactCell.h"
#import "CreateInitPasswordController.h"
#import "LocalDevice.h"
#import "Toast+UIView.h"
#import "UDPManager.h"
#import "MainAddContactControllerEx.h"
#import "MainContainer.h"
#import "P2PClient.h"
#import "LocalDeviceListController.h"
#import "ModifyDevicePasswordController.h"
@interface ContactController ()
{
    BOOL _isCancelUpdateDeviceOk;
//    UISearchDisplayController *_search1;
}
@end

@implementation ContactController

-(void)dealloc{
    [self.contacts release];
    [_searchArray release];
    [self.selectedContact release];
    [self.localDevicesLabel release];
    [self.localDevicesView release];
    [self.tableView release];
    [self.curDelIndexPath release];
    [self.netStatusBar release];
    [self.emptyView release];
    [self.checkingAlert release];
    [_search release];
//    [_search1 release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {//isGettingOnLineState
        contact.isGettingOnLineState = YES;
    }
    [self initComponent];
    // Do any additional setup after loading the view.
    
    //隐藏滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetWorkChange:) name:NET_WORK_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateContactState) name:@"updateContactState" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContact) name:@"refreshMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLocalDevices) name:@"refreshLocalDevices" object:nil];
    if([[AppDelegate sharedDefault] networkStatus]==NotReachable){
        [self.netStatusBar setHidden:NO];
    }else{
        [self.netStatusBar setHidden:YES];
    }
   
    if(!self.isInitPull){
        [[GlobalThread sharedThread:NO] start];
        
        self.isInitPull = !self.isInitPull;
    }
    [[GlobalThread sharedThread:NO] setIsPause:NO];
    [self refreshLocalDevices];
    [self refreshContact];
}



- (void)onNetWorkChange:(NSNotification *)notification{
    
    
    NSDictionary *parameter = [notification userInfo];
    int status = [[parameter valueForKey:@"status"] intValue];
    if(status==NotReachable){
        [self.netStatusBar setHidden:NO];
    }else{
        NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<[self.contacts count];i++){
            
            Contact *contact = [self.contacts objectAtIndex:i];
            [contactIds addObject:contact.contactId];
        }
        [[P2PClient sharedClient] getContactsStates:contactIds];
        
        [self.netStatusBar setHidden:YES];
    }
    [self refreshLocalDevices];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    MainController *mainController = [AppDelegate sharedDefault].mainController;
    //    [mainController setBottomBarHidden:YES];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NET_WORK_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateContactState" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshLocalDevices" object:nil];
    [[GlobalThread sharedThread:NO] setIsPause:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define CONTACT_ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 300:220)
#define HEADER_ICON_VIEW_HEIGHT_WIDTH 70
#define NET_WARNING_ICON_WIDTH_HEIGHT 24
#define LOCAL_DEVICES_VIEW_HEIGHT 52
#define LOCAL_DEVICES_ARROW_WIDTH 24
#define LOCAL_DEVICES_ARROW_HEIGHT 16
#define EMPTY_BUTTON_WIDTH 148
#define EMPTY_BUTTON_HEIGHT 42
#define EMPTY_LABEL_WIDTH 260
#define EMPTY_LABEL_HEIGHT 50

#pragma mark - 初始化界面
-(void)initComponent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    //导航栏
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"contact",nil)];
    [topBar setLeftButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonHidden2:NO];
//
    [topBar setLeftButtonIcon:[UIImage imageNamed:@"open_menu.png"]];
//    ＋图片
    [topBar setRightButtonIcon:[UIImage imageNamed:@"ic_bar_btn_add_contact.png"]];
    //[topBar setRightButtonIcon2:[UIImage imageNamed:@"ic_bar_btn_message.png"]];
    [topBar.leftButton addTarget:self action:@selector(onMenuPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.rightButton addTarget:self action:@selector(onAddPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
#pragma mark - 设备列表内容Cell的设置
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, NAVIGATION_BAR_HEIGHT + 5, width - 10, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    //self.tableView.shouldGroupAccessibilityChildren = NO;
    [tableView setBackgroundColor:XBGAlpha];
    
//    搜索
//    _search = [[UISearchController alloc] initWithSearchResultsController:nil];
//    _search.searchResultsUpdater = self;
//    _search.delegate = self;
//    [_search.searchBar sizeToFit];
//    tableView.tableHeaderView = _search.searchBar;
//    self.definesPresentationContext = YES;
//    
//    _searchArray = [[NSMutableArray alloc] init];
    
    //表尾
    UIView *footView = [[UIView alloc] init];
    [footView setBackgroundColor:[UIColor clearColor]];
    [tableView setTableFooterView:footView];
    [footView release];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
//    上下拉刷新
    [tableView addPullToRefreshWithActionHandler:^{
        
        NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<[self.contacts count];i++){
            
            Contact *contact = [self.contacts objectAtIndex:i];
            [contactIds addObject:contact.contactId];
            //进入首页时，获取设备列表里的设备的可更新状态
            //设备检查更新
            [[P2PClient sharedClient] checkDeviceUpdateWithId:contact.contactId password:contact.contactPassword];
            
        }
        [[P2PClient sharedClient] getContactsStates:contactIds];
        [[FListManager sharedFList] getDefenceStates];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLocalDevices" object:nil];
    }];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
//    网络现在状况
    UIView *netStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, 49)];
    netStatusBar.backgroundColor = [UIColor yellowColor];
    UIImageView *barLeftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (netStatusBar.frame.size.height-NET_WARNING_ICON_WIDTH_HEIGHT)/2, NET_WARNING_ICON_WIDTH_HEIGHT, NET_WARNING_ICON_WIDTH_HEIGHT)];
//    红色感叹号图片
    barLeftIconView.image = [UIImage imageNamed:@"ic_net_warning.png"];
    [netStatusBar addSubview:barLeftIconView];
    
    UILabel *barLabel = [[UILabel alloc] initWithFrame:CGRectMake(barLeftIconView.frame.origin.x+barLeftIconView.frame.size.width+10, 0, netStatusBar.frame.size.width-(barLeftIconView.frame.origin.x+barLeftIconView.frame.size.width)-10, netStatusBar.frame.size.height)];
    barLabel.textAlignment = NSTextAlignmentLeft;
    barLabel.textColor = [UIColor redColor];
    barLabel.backgroundColor = XBGAlpha;
    barLabel.font = XFontBold_16;
//    以单词为单位换行,以单位为单位截断
    barLabel.lineBreakMode = NSLineBreakByWordWrapping;
    barLabel.numberOfLines = 0;
//    当前网络不可用，请检查您的网络设置
    barLabel.text = NSLocalizedString(@"net_warning_prompt", nil);
    [netStatusBar addSubview:barLabel];
    
    [barLabel release];
    [barLeftIconView release];
    
    
//    不可获取
    if([[AppDelegate sharedDefault] networkStatus]==NotReachable){
        [netStatusBar setHidden:NO];
    }else{
        [netStatusBar setHidden:YES];
    }
    
    self.netStatusBar = netStatusBar;
    
    [self.view addSubview:netStatusBar];
    [netStatusBar release];
    

    //按钮，发现多少个新设备
    UIButton *localDevicesView = [UIButton buttonWithType:UIButtonTypeCustom];
    [localDevicesView addTarget:self action:@selector(onLocalButtonPress) forControlEvents:UIControlEventTouchUpInside];
    localDevicesView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, LOCAL_DEVICES_VIEW_HEIGHT);
    localDevicesView.backgroundColor = XBGAlpha;
    [self.view addSubview:localDevicesView];
    self.localDevicesView = localDevicesView;
    //文本，发现几个新设备
    UILabel *localDevicesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, localDevicesView.frame.size.width, localDevicesView.frame.size.height)];
    localDevicesLabel.backgroundColor = [UIColor clearColor];
    localDevicesLabel.textAlignment = NSTextAlignmentCenter;
    localDevicesLabel.textColor = [UIColor blackColor];
    localDevicesLabel.font = XFontBold_16;
    [localDevicesView addSubview:localDevicesLabel];
    self.localDevicesLabel = localDevicesLabel;
    //图片，箭头
    UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(localDevicesLabel.frame.size.width-LOCAL_DEVICES_ARROW_WIDTH, (localDevicesLabel.frame.size.height-LOCAL_DEVICES_ARROW_HEIGHT)/2, LOCAL_DEVICES_ARROW_WIDTH, LOCAL_DEVICES_ARROW_HEIGHT)];
    arrowView.image = [UIImage imageNamed:@"ic_local_devices_arrow.png"];
    [localDevicesLabel addSubview:arrowView];
    [arrowView release];
    [localDevicesLabel release];
    [localDevicesView setHidden:YES];
    [localDevicesView release];
    
    
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];

    UIButton *emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emptyButton addTarget:self action:@selector(onAddPress) forControlEvents:UIControlEventTouchUpInside];
    emptyButton.frame = CGRectMake(0, 0, width, CONTACT_ITEM_HEIGHT);
//    系统默认的图片
    UIImageView *buttonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, emptyButton.frame.size.width, emptyButton.frame.size.height)];
    buttonImageView.image = [UIImage imageNamed:@"ic_header.png"];
//    ＋
    UIImageView *addButtonView = [[UIImageView alloc] initWithFrame:CGRectMake((emptyButton.frame.size.width-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, (emptyButton.frame.size.height-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, HEADER_ICON_VIEW_HEIGHT_WIDTH, HEADER_ICON_VIEW_HEIGHT_WIDTH)];
    addButtonView.image = [UIImage imageNamed:@"ic_empty_add.png"];
    
    [emptyButton addSubview:buttonImageView];
    [emptyButton addSubview:addButtonView];
    [emptyView addSubview:emptyButton];
    
    [self.tableView addSubview:emptyView];
    self.emptyView = emptyView;
    [addButtonView release];
    [buttonImageView release];
    [emptyView release];
    [self.emptyView setHidden:YES];
    
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.emptyView.frame.size.width-EMPTY_LABEL_WIDTH)/2, emptyButton.frame.origin.y+CONTACT_ITEM_HEIGHT+10, EMPTY_LABEL_WIDTH, EMPTY_LABEL_HEIGHT)];
    emptyLabel.backgroundColor = [UIColor clearColor];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = XBlack;
    emptyLabel.numberOfLines = 0;
    emptyLabel.lineBreakMode = NSLineBreakByCharWrapping;
    emptyLabel.font = XFontBold_16;
//    这里还是空的哦！您需要添加设备才能查看视频，赶快行动吧～
    emptyLabel.text = NSLocalizedString(@"empty_contact_prompt", nil);
    [self.emptyView addSubview:emptyLabel];
    [emptyLabel release];
    
    self.checkingAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.checkingAlert];
}

//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
//    [_searchArray removeAllObjects];
//    
//    NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
//    for(int i=0;i<[self.contacts count];i++){
//        
//        Contact *contact = [self.contacts objectAtIndex:i];
//        [contactIds addObject:contact.contactId];
//    }
//    [[P2PClient sharedClient] getContactsStates:contactIds];
//    for (NSString *str in contactIds) {
//        NSRange range = [str rangeOfString:searchController.searchBar.text options:NSCaseInsensitiveSearch];
//        
//        if (range.location != NSNotFound)
//        {
//            [_searchArray addObject:str];
//        }
//    }
//    [self.tableView reloadData];
//}
-(void)refreshContact{
    self.contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];
    
    if(self.tableView){
        [self.tableView reloadData];
    }
}

-(void)refreshLocalDevices{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    NSArray *lanDeviceArray = [[UDPManager sharedDefault] getLanDevices];
    NSMutableArray *array = [Utils getNewDevicesFromLan:lanDeviceArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([array count]>0){
            UILabel *localDevicesLabel = [[self.localDevicesView subviews] objectAtIndex:0];
            localDevicesLabel.text = [NSString stringWithFormat:@"%@ %i %@",NSLocalizedString(@"discovered", nil),[array count],NSLocalizedString(@"new_device", nil)];
            if([self.netStatusBar isHidden]){
                self.localDevicesView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, LOCAL_DEVICES_VIEW_HEIGHT);
                self.tableView.frame = CGRectMake(0.0, NAVIGATION_BAR_HEIGHT+LOCAL_DEVICES_VIEW_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT-LOCAL_DEVICES_VIEW_HEIGHT);//设备列表界面调整
                self.tableViewOffset = self.localDevicesLabel.frame.size.height;
            }else{
                self.localDevicesView.frame = CGRectMake(0, self.netStatusBar.frame.origin.y+self.netStatusBar.frame.size.height, width, LOCAL_DEVICES_VIEW_HEIGHT);
                self.tableView.frame = CGRectMake(0.0, NAVIGATION_BAR_HEIGHT+self.netStatusBar.frame.size.height+self.localDevicesView.frame.size.height, width, height-NAVIGATION_BAR_HEIGHT-self.netStatusBar.frame.size.height-self.localDevicesView.frame.size.height);//设备列表界面调整
                self.tableViewOffset = self.netStatusBar.frame.size.height+self.netStatusBar.frame.size.height;
            }
            
            [self.localDevicesView setHidden:NO];
            
        }else{
            if([self.netStatusBar isHidden]){
                self.tableView.frame = CGRectMake(0.0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT);//设备列表界面调整
                self.tableViewOffset = 0;
            }else{
                self.tableView.frame = CGRectMake(0.0, NAVIGATION_BAR_HEIGHT+self.netStatusBar.frame.size.height, width, height-NAVIGATION_BAR_HEIGHT-self.netStatusBar.frame.size.height);//设备列表界面调整
                self.tableViewOffset = self.netStatusBar.frame.size.height;
            }
            
            [self.localDevicesView setHidden:YES];
        }
    });
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([self.contacts count]<=0)
{
    [self.emptyView setHidden:NO];
    [self.tableView setScrollEnabled:NO];
    
}else{
    [self.emptyView setHidden:YES];
    [self.tableView setScrollEnabled:YES];
}
//    if (_search.isActive) {
//        return _searchArray.count;
//    }
    return [self.contacts count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CONTACT_ITEM_HEIGHT + 5;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"ContactCell1";
    UITableViewCell *cell = nil;
    if(indexPath.section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
        }
//        if (_search.isActive) {
//            Contact *contact = [_searchArray objectAtIndex:indexPath.row];
//            
//            ContactCell *contactCell = (ContactCell*)cell;
//            contactCell.delegate = self;
//            [contactCell setPosition:indexPath.row];
//            [contactCell setContact:contact];
//        }else{
        Contact *contact = [self.contacts objectAtIndex:indexPath.row];
        ContactCell *contactCell = (ContactCell*)cell;
        contactCell.delegate = self;
        [contactCell setPosition:indexPath.row];
        [contactCell setContact:contact];
//        }
    }
    
    UIImage *backImg = [UIImage imageNamed:@""];//bg_normal_cell.png
    UIImage *backImg_p = [UIImage imageNamed:@""];//bg_normal_cell_p.png
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

#define OPERATOR_ITEM_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80:55)
#define OPERATOR_ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:48)
#define OPERATOR_ARROW_WIDTH_AND_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 20:10)
#define OPERATOR_BAR_OFFSET (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 40:30)

-(UIButton*)getOperatorView:(CGFloat)offset itemCount:(NSInteger)count{
    offset += self.tableViewOffset;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIButton *operatorView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height-TAB_BAR_HEIGHT)];
    operatorView.tag = kOperatorViewTag;
    
    UIView *barView = [[UIView alloc] init];
    barView.tag = kBarViewTag;
    
    UIImageView *arrowView = [[UIImageView alloc] init];
    UIView *buttonsView = [[UIView alloc] init];
    buttonsView.tag = kButtonsViewTag;
    if((offset>self.tableView.frame.size.height)||((self.tableView.frame.size.height-offset)<CONTACT_ITEM_HEIGHT)){
        barView.frame = CGRectMake((width-OPERATOR_ITEM_WIDTH*count), offset-OPERATOR_BAR_OFFSET, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT+OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        arrowView.frame = CGRectMake((OPERATOR_ITEM_WIDTH*count-OPERATOR_ARROW_WIDTH_AND_HEIGHT)/2, OPERATOR_ITEM_HEIGHT, OPERATOR_ARROW_WIDTH_AND_HEIGHT, OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        buttonsView.frame = CGRectMake(0, 0, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT);
        [arrowView setImage:[UIImage imageNamed:@"bg_operator_bar_arrow_bottom.png"]];
        
    }else{
        barView.frame = CGRectMake((width-OPERATOR_ITEM_WIDTH*count), offset+OPERATOR_BAR_OFFSET, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT+OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        
        arrowView.frame = CGRectMake((OPERATOR_ITEM_WIDTH*count-OPERATOR_ARROW_WIDTH_AND_HEIGHT)/2, 0, OPERATOR_ARROW_WIDTH_AND_HEIGHT, OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        buttonsView.frame = CGRectMake(0, OPERATOR_ARROW_WIDTH_AND_HEIGHT, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT);
        [arrowView setImage:[UIImage imageNamed:@"bg_operator_bar_arrow_top.png"]];
    }
    
    buttonsView.layer.borderColor = [[UIColor grayColor] CGColor];
    buttonsView.layer.borderWidth = 1;
    buttonsView.layer.cornerRadius = 5;
    [buttonsView.layer setMasksToBounds:YES];
    
    [barView addSubview:arrowView];
    [barView addSubview:buttonsView];
    [operatorView addSubview:barView];
    [buttonsView release];
    [arrowView release];
    [barView release];
    return operatorView;
}

//当用户选中某个行的cell的时候，回调用这个
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    控制取消选中该表格中指定indexPath对应的表格行
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)onOperatorViewSingleTap{
    UIView *operatorView = [self.view viewWithTag:kOperatorViewTag];
    UIView *barView = [operatorView viewWithTag:kBarViewTag];
    [UIView transitionWithView:barView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        barView.alpha = 0.3;
                        
                    }
                    completion:^(BOOL finished){
                        [operatorView removeFromSuperview];
                    }
     ];
}


//该方法返回值决定指定indexPath对应的cell是否可以编辑
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return YES;
    }else{
        return NO;
    }
    
}
//＋跳转界面
-(void) onAddPress{
    MainAddContactControllerEx *mainAddContactController = [[MainAddContactControllerEx alloc] init];
    
    [self.navigationController pushViewController:mainAddContactController animated:YES];
    [mainAddContactController release];
}

-(void)onUpdateContactState{
    DLog(@"onUpdateContactState");
    
    self.contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.pullToRefreshView stopAnimating];
            [self.tableView reloadData];
        });
    });
    
    
}

-(void)onClick:(NSInteger)position contact:(Contact *)contact tag:(NSInteger)tag{
    
    [AppDelegate sharedDefault].isDoorBellAlarm = NO;
    //
    if (tag==kOperatorBtnTag_Monitor) {
        MainContainer *mainController = [AppDelegate sharedDefault].mainController;
        mainController.contactName = contact.contactName;
        mainController.contact = contact;
        [mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
    }
    //等待验证
    else if (tag==kOperatorBtnTag_Control)
    {
        self.selectedContact = contact;
        self.checkingAlert.dimBackground = YES;
        [self.checkingAlert setLabelText:NSLocalizedString(@"check_for_setting", nil)];
        [self.checkingAlert show:YES];
        [[P2PClient sharedClient]getNpcSettingsWithId:contact.contactId password:contact.contactPassword];
    }
    //添加设备
    else if (tag==kOperatorBtnTag_Modify)
    {
        AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
        addContactNextController.isModifyContact = YES;
        addContactNextController.modifyContact = contact;
        [self.navigationController pushViewController:addContactNextController animated:YES];
        [addContactNextController release];
    }
    //若密码
    else if (tag == kOperatorBtnTag_WeakPwd){
        ModifyDevicePasswordController *modifyDevicePasswordController = [[ModifyDevicePasswordController alloc] init];
        modifyDevicePasswordController.contact = contact;
        modifyDevicePasswordController.isIntoHereOfClickWeakPwd = YES;
        [self.navigationController pushViewController:modifyDevicePasswordController animated:YES];
        [modifyDevicePasswordController release];
    }
}

-(void)onLocalButtonPress{
    NSArray* lanDevicesArray = [[UDPManager sharedDefault]getLanDevices];
    NSArray* newDevicesArray = [Utils getNewDevicesFromLan:lanDevicesArray];
    
    LocalDeviceListController *localDeviceListController = [[LocalDeviceListController alloc] init];
    localDeviceListController.newDevicesArray = newDevicesArray;
    [self.navigationController pushViewController:localDeviceListController animated:YES];
    [localDeviceListController release];
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


-(void)onMenuPress
{
//    接收注册的返回界面的消息
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_LEFTMENU_CMD object:self];
    });
}
#pragma mark -receiveRemoteMessage
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_DO_DEVICE_UPDATE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSInteger value = [[parameter valueForKey:@"value"] intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self.isShowProgressAlert) {
                    [self.progressAlert hide:YES];
                    self.isShowProgressAlert = NO;
                }
                if(result==1){
                    self.progressLabel.text = [NSString stringWithFormat:@"%i%%",value];//device update
                    [self.progressMaskView setHidden:NO];
                    DLog(@"%i",value);
                }else if(result==65){
                    [self.progressMaskView setHidden:YES];
                    [self.view makeToast:NSLocalizedString(@"start_update", nil)];
                    //设备检查更新
                    //设备升级成功，将设备的isNewVersionDevice设置为NO，刷新表格，去除红色角标
                    for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {
                        if ([self.selectedContact.contactId isEqualToString:contact.contactId]) {
                            contact.isNewVersionDevice = NO;
                        }
                    }
                    [self.tableView reloadData];
                    
                }else{
                    _isCancelUpdateDeviceOk = YES;
                    [self.progressMaskView setHidden:YES];
                    [self.view makeToast:NSLocalizedString(@"update_failed", nil)];
                }
            });
        }
            break;
        case RET_CHECK_DEVICE_UPDATE://设备检查更新
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSString *contactId = [parameter valueForKey:@"contactId"];
            if(result==1 || result==72){
                //读取到了服务器升级文件（1）
                //读取到了sd卡升级文件（72）
                NSString *curVersion = [parameter valueForKey:@"curVersion"];
                NSString *upgVersion = [parameter valueForKey:@"upgVersion"];
                for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {
                    if ([contactId isEqualToString:contact.contactId]) {
                        contact.isNewVersionDevice = YES;
                        contact.result_sd_server = result;
                        contact.deviceCurVersion = curVersion;
                        contact.deviceUpgVersion = upgVersion;
                    }
                }
            }else{
                //设备没有可升级包
                for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {
                    if ([contactId isEqualToString:contact.contactId]) {
                        contact.isNewVersionDevice = NO;
                    }
                }
            }
        }
        
    }
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    
    if (key != ACK_RET_GET_NPC_SETTINGS) {
        return;
    }
    switch(key){
        case ACK_RET_CHECK_DEVICE_UPDATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend check device update");
                    [[P2PClient sharedClient] checkDeviceUpdateWithId:self.contact.contactId password:self.contact.contactPassword];
                }
            });
            DLog(@"ACK_RET_CHECK_DEVICE_UPDATE:%i",result);
        }
            break;
        case ACK_RET_DO_DEVICE_UPDATE:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] doDeviceUpdateWithId:self.contact.contactId password:self.contact.contactPassword];
                }
            });
            
            DLog(@"ACK_RET_DO_DEVICE_UPDATE:%i",result);
        }
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.checkingAlert hide:YES];
        if (result == 0)
        {
            MainSettingController *mainSettingController = [[MainSettingController alloc] init];
            mainSettingController.contact = self.selectedContact;
            [self.navigationController pushViewController:mainSettingController animated:YES];
            [mainSettingController release];
        }
        else if(result==1)
        {
//            设备密码错误
            [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
        }
        else if(result==2)
        {
//            请检查设备联网状况
            [self.view makeToast:NSLocalizedString(@"net_exception", nil)];
        }
        else if(result==4)
        {
//            权限不足
            [self.view makeToast:NSLocalizedString(@"no_permission", nil)];
        }
    });
}



@end
