//
//  WelcomViewController.m
//  Camnoopy
//
//  Created by Lio on 15/5/30.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "WelcomViewController.h"
#import "AppDelegate.h"
#import "LoginController.h"
#import "AutoNavigation.h"

@interface WelcomViewController ()
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIButton *enterBtn;

@end


@implementation WelcomViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showIntroWithCrossDissolve];
}


- (void)showIntroWithCrossDissolve {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    EAIntroPage *page1 = [EAIntroPage page];
    EAIntroPage *page2 = [EAIntroPage page];
    EAIntroPage *page3 = [EAIntroPage page];
    
    if ([preferredLang isEqualToString:@"zh-Hans-CN"]||[preferredLang isEqualToString:@"zh-Hant-CN"]||[preferredLang isEqualToString:@"zh-HK"])
    {
       page1.bgImage = [UIImage imageNamed:@"welcome1.png"];//背景
       page2.bgImage = [UIImage imageNamed:@"welcome2.png"];
       page3.bgImage = [UIImage imageNamed:@"welcome3.png"];
    }
    else
    {
        page1.bgImage = [UIImage imageNamed:@"welcome1en.png"];//背景
        page2.bgImage = [UIImage imageNamed:@"welcome2en.png"];
        page3.bgImage = [UIImage imageNamed:@"welcome3en.png"];
    }


    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];

    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];


}


//完成后进入
- (void)introDidFinish
{
    LoginController *loginController = [[LoginController alloc] init];
    AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"maintabvc"];
    app.window.rootViewController = mainController;
    [loginController release];
    [mainController release];

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
