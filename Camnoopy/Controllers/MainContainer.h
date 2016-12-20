//
//  MainContainer.h
//  Camnoopy
//
//  Created by wutong on 15-1-6.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2PClient.h"

#import "MainMenu.h"
#import "Contact.h"
#define SHOW_LEFTMENU_CMD @"SHOW_LEFTMENU_CMD"

@interface MainContainer : UIViewController<MainmenuDelegate, P2PClientDelegate>

@property (nonatomic,strong) NSString * contactName;
@property (nonatomic,strong)Contact *contact;
@property (nonatomic) BOOL isShowP2PView;
@property (strong, nonatomic) UIView *aboutView;
-(void)setUpCallWithId:(NSString*)contactId password:(NSString*)password callType:(P2PCallType)type;
-(void)popAlarmWithType:(int)type contactId:(NSString*)contactId  password:(NSString *)password group:(int)group item:(int)item;

-(void)dismissP2PView;
-(void)dismissP2PView:(void (^)())callBack;

- (void)showLeftMenu:(BOOL)bShow;
-(void)showAlertPwdForContactId:(NSString*)contactId;
@end
