//
//  AboutViewController.m
//  Camnoopy
//
//  Created by wutong on 15-1-7.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "AboutViewController.h"
#import "MBProgressHUD.h"
#import "TopBar.h"
#import "MainContainer.h"

#define ALERT_TAG_EXIT 0
#define ALERT_TAG_LOGOUT 1
#define ALERT_TAG_UPDATE 2

@interface AboutViewController ()

@end

@implementation AboutViewController

-(void)loadView
{
    CGRect frame = [[UIScreen mainScreen]bounds];
    CGFloat width = frame.size.width;
    //CGFloat height = frame.size.height;
    UIView* view = [[UIView alloc]initWithFrame:frame];
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, NAVIGATION_BAR_HEIGHT)];
    //    [topBar setBackButtonHidden:NO];
    [topBar.leftButton setHidden:NO];
    [topBar setLeftButtonIcon:[UIImage imageNamed:@"open_menu.png"]];
    [topBar.leftButton addTarget:self action:@selector(onMenuPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"about",nil)];
    [view addSubview:topBar];
    [topBar release];
    
    UIImage *image1 = [UIImage imageNamed:@"about_bk"];//背景图
    UIImageView* imageView1 = [[UIImageView alloc]initWithImage:image1];
    [imageView1 setFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, frame.size.width, frame.size.height-NAVIGATION_BAR_HEIGHT )];
    [view addSubview:imageView1];
    [imageView1 release];
    
    UIImage *image2 = [UIImage imageNamed:@"appIcon"];//appIcon  COTProIcon
    UIImageView* imageView2 = [[UIImageView alloc]initWithImage:image2];
    [imageView2 setFrame:CGRectMake(width/2 - 50, NAVIGATION_BAR_HEIGHT + 20, 100, 100)];
    [view addSubview:imageView2];
    [imageView2 release];
    
    //版本
    UILabel* label1 = [[UILabel alloc]initWithFrame:CGRectMake(width/2 - 40, NAVIGATION_BAR_HEIGHT*3, 80, 20)];
//    UILabel *label1 = [[UILabel alloc]init];
//    label1.frame = CGRectMake(width/2 - 40, NAVIGATION_BAR_HEIGHT*3, 80, 20);
    //    [label1 setText:[NSString stringWithFormat:@"V%@",APP_VERSION]];
    [label1 setText:@"V9.0"];
    label1.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label1];
    [label1 release];
    
    //简介
    UITextView *aboutText = [[UITextView alloc]initWithFrame:CGRectMake(15, NAVIGATION_BAR_HEIGHT*3 + 30, frame.size.width - 30, 260)];
    aboutText.backgroundColor = XBGAlpha;
    aboutText.editable = NO;
    aboutText.selectable = NO;
    aboutText.font = [UIFont systemFontOfSize:14.0];
    aboutText.textAlignment = 0;
    aboutText.text = NSLocalizedString(@"about_text", nil);
    [view addSubview:aboutText];
    [aboutText release];
    
    self.view = view;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //        self.view.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)checkUpdate:(id)sender
{
    MBProgressHUD * hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = NSLocalizedString(@"loading", nil);
    [self.view addSubview:hud];
    hud.delegate  = self;
    [hud show:YES];
    
    
    //Camnoopy680995913,889807261,GviewsX 905849946
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=680995913"];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    DLog(@"%@", urlString);
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue ] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ((!error)) {
            NSError *parseError;
            id appMetaDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            if (appMetaDataDictionary) {
                NSArray *results = [appMetaDataDictionary objectForKey:@"results"];
                NSArray *remoteVersionArr = [results valueForKey:@"version"];
                [hud hide:YES];
                
                if([remoteVersionArr count]==0){
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"latest_version", nil)
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    [alert release];
                    return;
                }
                NSString *remoteVersion = [remoteVersionArr objectAtIndex:0];
                NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"];
                [hud hide:YES];
                
                
                UIAlertView *updataAlertDiag;
                
                if ( remoteVersion && ([localVersion floatValue]<[remoteVersion floatValue]) ) {
                    updataAlertDiag = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"release_new_version", nil)
                                                                 message:NSLocalizedString(@"ask_update_immediately", nil)
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"remain_me", nil)
                                                       otherButtonTitles:NSLocalizedString(@"update_me", nil),NSLocalizedString(@"rate_me", nil), nil];
                } else {
                    updataAlertDiag = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"latest_version", nil)
                                                                 message:nil
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                       otherButtonTitles: nil];
                }
                [updataAlertDiag setTag:ALERT_TAG_UPDATE];
                [updataAlertDiag show];
                [updataAlertDiag release];
                [hud release];
            }
        }
        
    }];
}

-(void)onMenuPress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_LEFTMENU_CMD object:self];
    });
}
@end
