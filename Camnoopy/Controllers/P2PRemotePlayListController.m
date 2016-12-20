//
//  P2PRemotePlayListController.m
//  2cu
//
//  Created by wutong on 15-1-26.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "P2PRemotePlayListController.h"
#import "AppDelegate.h"
#import "FListManager.h"
#import "ContactCell.h"
#import "TopBar.h"
#import "P2PPlaybackControllerEx.h"
#import "AboutViewController.h"
#import "Toast+UIView.h"
#import "P2PPlaybackController.h"

#define CONTACT_ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 120:220)

@interface P2PRemotePlayListController ()

@end

@implementation P2PRemotePlayListController

- (void)initComponents
{
    self.view.layer.contents = XBgImage;
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
//    导航栏
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"playback_TFCard",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [tableView setBackgroundColor:XBGAlpha];
    
    UIView *footView = [[UIView alloc] init];
    [footView setBackgroundColor:[UIColor clearColor]];
    [tableView setTableFooterView:footView];
    [footView release];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    if(CURRENT_VERSION>=7.0){
//        自动修改位置
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initComponents];
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.contacts) {
        [self.contacts removeAllObjects];
    }
    self.contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.contacts count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"ContactCell1";
    UITableViewCell *cell = nil;
    if(indexPath.section==0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1]autorelease];
        }
        Contact* contact = [self.contacts objectAtIndex:indexPath.row];
        cell.textLabel.text = contact.contactName;
        cell.imageView.image = [UIImage imageNamed:@"ic_playback.png"];
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*    P2PPlaybackControllerEx* playbackController = [[P2PPlaybackControllerEx alloc] init];
     playbackController.contact = [self.contacts objectAtIndex:indexPath.row];
     [self presentViewController:playbackController animated:YES completion:nil];
     [playbackController release];
     
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
     */
    Contact* contact = [self.contacts objectAtIndex:indexPath.row];
//    设备不允许访问
    if (contact.defenceState==DEFENCE_STATE_NO_PERMISSION) {
        [self.view makeToast:NSLocalizedString(@"no_permission", nil)];
    }else{
//        允许访问
        P2PPlaybackController *playbackController = [[P2PPlaybackController alloc] init];
        playbackController.contact = contact;
        [self presentViewController:playbackController animated:YES completion:nil];
        [playbackController release];
    }
    
}

-(void)onBackPress
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
