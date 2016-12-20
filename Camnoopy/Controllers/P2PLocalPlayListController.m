//
//  P2PLocalPlayListController.m
//  Camnoopy
//
//  Created by Lio on 16/3/3.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "P2PLocalPlayListController.h"
#import "AppDelegate.h"
#import "FListManager.h"
#import "ContactCell.h"
#import "TopBar.h"
#import "P2PPlaybackControllerEx.h"
#import "AboutViewController.h"
#import "Toast+UIView.h"
#import "P2PPlaybackController.h"
#import "LocalFilesListController.h"

@interface P2PLocalPlayListController ()

@end

@implementation P2PLocalPlayListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initComponents];
}


- (void)initComponents
{
    
    self.view.layer.contents = XBgImage;
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
//    本地录像
    [topBar setTitle:NSLocalizedString(@"playback_cellphone",nil)];
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
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.contacts) {
        [self.contacts removeAllObjects];
    }
    self.contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];
    [self.tableView reloadData];
}

-(void)onBackPress
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Contact* contact = [self.contacts objectAtIndex:indexPath.row];
    
    LocalFilesListController* filesController = [[LocalFilesListController alloc]init];
    filesController.contact = contact;
//    [self.navigationController pushViewController:filesController animated:YES];
    [self presentViewController:filesController animated:YES completion:nil];
    [filesController release];
    
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
