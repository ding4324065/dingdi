//
//  HelpViewController.m
//  Camnoopy
//
//  Created by 卡努比 on 16/4/28.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "HelpViewController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "MainController.h"
#import "Constants.h"
#import "YLLabel.h"
#define CELL_ID     @"cellID"

#define HEADER_ID   @"headerID"
@interface HelpViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) NSMutableArray *shows;

@property (nonatomic, strong) NSArray *groupTitles;
@property (nonatomic, strong) NSArray *groupTitles1;
@property (nonatomic, strong)NSMutableArray *subArr;
@property (nonatomic, strong)NSString *str;

@property (nonatomic,assign)CGSize size;

@property (nonatomic,strong)TopBar *topBar;

@end

@implementation HelpViewController

- (void)dealloc
{
    //    [self.tableView release];
    //    [_datas release];
    //    [_shows release];
    //    [_subArr release];
    //    [_groupTitles release];
    //    [_groupTitles1 release];
    //    [super dealloc];
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
    [topBar setTitle:NSLocalizedString(@"mainmenu_help",nil)];
    _topBar = topBar;
    [self.view addSubview:topBar];
    //    [topBar release];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    
    [_tableView setBackgroundColor:XBGAlpha];
    _tableView.dataSource = self;
    _tableView.delegate = self;

    [self.view addSubview:_tableView];
    // 防止拽出边界
    _tableView.bounces = NO;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID];
    
}

// 懒汉模式，在需要加载的时候才去创建
- (NSMutableArray *)datas
{
    if (!_datas)
    {
        
        _groupTitles = [[NSArray alloc] initWithObjects:
                        NSLocalizedString(@"questionone",nil),
                        NSLocalizedString(@"questiontwo",nil),
                        NSLocalizedString(@"questionthree",nil),
                        NSLocalizedString(@"questionfour",nil),
                        NSLocalizedString(@"questionfive",nil),
                        NSLocalizedString(@"questionsix",nil),
                        NSLocalizedString(@"questionseven", nil),
                        NSLocalizedString(@"questioneight", nil),
                        NSLocalizedString(@"questionnine",nil),
                        NSLocalizedString(@"questionten",nil),
                        NSLocalizedString(@"questioneleven",nil),
                        NSLocalizedString(@"questiontwelve",nil),
                        NSLocalizedString(@"questionthirteen",nil),
                        NSLocalizedString(@"questionfourteen",nil),
                        NSLocalizedString(@"questionfifteen", nil),
                        NSLocalizedString(@"questionsixteen", nil),
                        NSLocalizedString(@"questionseventeen",nil),
                        NSLocalizedString(@"questioneighteen",nil),
                        NSLocalizedString(@"questionnineteen",nil),
                        NSLocalizedString(@"questiontwenty", nil),
                        NSLocalizedString(@"questionTwentyone", nil),
                        NSLocalizedString(@"questionTwentytwo",nil),nil];
        
        
        _groupTitles1 = [[NSArray alloc] initWithObjects:
                         NSLocalizedString(@"answerone",nil),
                         NSLocalizedString(@"answertwo",nil),
                         NSLocalizedString(@"answerthree",nil),
                         NSLocalizedString(@"answerfour",nil),
                         NSLocalizedString(@"answerfive",nil),
                         NSLocalizedString(@"answersix",nil),
                         NSLocalizedString(@"answerseven", nil),
                         NSLocalizedString(@"answereight", nil),
                         NSLocalizedString(@"answernine",nil),
                         NSLocalizedString(@"answerten",nil),
                         NSLocalizedString(@"answereleven",nil),
                         NSLocalizedString(@"answertwelve",nil),
                         NSLocalizedString(@"answerthirteen",nil),
                         NSLocalizedString(@"answerfourteen",nil),
                         NSLocalizedString(@"answerfifteen", nil),
                         NSLocalizedString(@"answersixteen", nil),
                         NSLocalizedString(@"answerseventeen",nil),
                         NSLocalizedString(@"answereighteen",nil),
                         NSLocalizedString(@"answernineteen",nil),
                         NSLocalizedString(@"answertwenty", nil),
                         NSLocalizedString(@"answerTwentyone", nil),
                         NSLocalizedString(@"answerTwentytwo",nil),nil];
       
        
        _datas = [[NSMutableArray alloc] init];
        
        _shows = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < _groupTitles.count; i++)
        {
            _subArr = [[NSMutableArray alloc] init];
            
            for (int j = 0; j < _groupTitles1.count; j++)
            {
                _str = [NSString stringWithFormat:@"%@",_groupTitles1[i]];
                [_subArr addObject:_str];
                
            }
            
            [_shows addObject:@(YES)];
            
            [_datas addObject:_subArr];
        }
    }
    return _datas;
    
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_shows[section] boolValue])
    {
        return 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
    }
    cell.backgroundColor = XBGAlpha;
    cell.textLabel.text = self.datas[indexPath.section][indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.numberOfLines = 0;
    _size = [cell.textLabel.text boundingRectWithSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:NULL].size;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return _size.height+15;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    view.tag = section + 100;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTapAction:)];
    [view addGestureRecognizer:tap]; // 加手势加到view上, 等下获取这个view, 再根据view的tag值-100就可以知道点击是对应的哪个section
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, [UIScreen mainScreen].bounds.size.width-60, 40)];
    lab.text = _groupTitles[section];
    lab.numberOfLines = 0;
    lab.textAlignment = NSTextAlignmentLeft;
    lab.font = [UIFont systemFontOfSize:16];
    [view addSubview:lab];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-40, 10, 20, 20)];
    BOOL isShwo = [_shows[section] boolValue];
   imageView.clipsToBounds = YES;
   imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (isShwo) {
        imageView.image = [UIImage imageNamed:@"buddy_header_arrow_right"];
    } else {
        imageView.image = [UIImage imageNamed:@"buddy_header_arrow_down"];
    }
    [view addSubview:imageView];
    return view;
}

// 设置组头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 40.0f;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001f;
}
#pragma mark - 头部手势点击事件

- (void)headerViewTapAction:(UITapGestureRecognizer *)tap
{
    int index = tap.view.tag - 100;
    NSLog(@"%d",index);
    
    BOOL isShow = [_shows[index] boolValue];
    
    // 替换原来的值
    [_shows replaceObjectAtIndex:index withObject:@(!isShow)];
    
        [_tableView reloadData];
    
    // 代表哪个行
    //    NSIndexPath *path = [NSIndexPath indexPathForRow:<#(NSInteger)#> inSection:<#(NSInteger)#>];
    
    // 代表哪个组
//    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    // 指定刷新某一组
    //    [_tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];

}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBackPress{
    MainContainer * maincontainer = [AppDelegate sharedDefault].mainController;
    [maincontainer showLeftMenu:YES];
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
