//
//  maskView.m
//  Camnoopy
//
//  Created by wutong on 15-3-5.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "maskView.h"
#import "MainContainer.h"
#import "AppDelegate.h"

@implementation maskView
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    MainContainer *mainController = [AppDelegate sharedDefault].mainController;
    [mainController showLeftMenu:NO];
    NSLog(@"touchesEnded");
}
@end
