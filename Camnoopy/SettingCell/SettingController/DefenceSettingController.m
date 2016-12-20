//
//  DefenceSettingController.m
//  2cu
//
//  Created by 高琦 on 15/2/9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "DefenceSettingController.h"
#import "DefenceDoorMagneticController.h"
#import "Constants.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "DefenceCell.h"
#import "P2PClient.h"
#import "Contact.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "DefenceDao.h"
#import "Utils.h"

@interface DefenceSettingController ()

@end

@implementation DefenceSettingController
-(void)dealloc{
    [self.tableView release];
    [self.contact release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initComponent];
}

-(void)initComponent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"defenceArea_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    [pan release];

}

-(void)onBackPress{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}


-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 9;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuseID = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = XFontBold_16;
    
    DefenceDao* dao = [[DefenceDao alloc]init];
    NSString* text = [dao getItemName:self.contact.contactId group:indexPath.row item:8];
    if (text == nil) {
        text = [Utils defaultDefenceName:indexPath.row];
    }
    [dao release];
    cell.textLabel.text = text;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 <= indexPath.row && 8>= indexPath.row)
    {
        DefenceDoorMagneticController * denfenceareasettingcontroller = [[DefenceDoorMagneticController alloc] init];
        denfenceareasettingcontroller.dwCurGroup = indexPath.row;
        denfenceareasettingcontroller.contact = self.contact;
        [self.navigationController pushViewController:denfenceareasettingcontroller animated:YES];
        [self presentViewController:denfenceareasettingcontroller animated:YES completion:nil];
        [denfenceareasettingcontroller release];
    }
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

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void) handlePan: (UIPanGestureRecognizer *)recognizer
{
    //do nothing. write this for shield recognizer in the control's view
}
@end
