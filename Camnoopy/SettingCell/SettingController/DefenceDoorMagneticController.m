//
//  DefenceDoorMagneticController.m
//  2cu
//
//  Created by 高琦 on 15/2/9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
#import "DefenceDoorMagneticController.h"
#import "Constants.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "DefenceCell.h"
#import "DefenceMagneticCell.h"
#import "P2PClient.h"
#import "Contact.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "RadioButton.h"
#import "DefenceDao.h"
#import "Utils.h"
#import "mesg.h"
#import "P2PEmailSettingCell.h"
#import "yizhiweiVC.h"
@interface DefenceDoorMagneticController ()
{
    BOOL _isGetDefenceStatusData;
    BOOL _isGetDefenceSwitchData;
}
@end

@implementation DefenceDoorMagneticController
-(void)dealloc{
    [self.progressAlert release];
    [self.contact release];
    [self.tableView release];
    [self.defenceStatusData release];
    [self.switchStatusData release];
    
    [self.titleLable release];
    [self.namechangeView release];
    [self.inputView release];
    [self.inputalphaView release];
    [self.namearray release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    NSLog(@"已经打开接收通知：receiveRemoteMessage:");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    NSLog(@"已经打开接收通知：ack_receiveRemoteMessage:");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    self.progressAlert.dimBackground = YES;
//    [self.progressAlert show:YES];
    
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.tableView setEditing:NO];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSLog(@"进来了方法:receiveRemoteMessage");
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    NSLog(@"receiveRemoteMessage key=0x%x", key);
    switch(key){
        case RET_GET_PRESET_MOTOR_POS:{
            NSInteger result = [[parameter valueForKey:@"result"] integerValue];
            if (result == 1) {
                self.item1 = [[parameter valueForKey:@"item"] intValue];
                self.index = [[parameter valueForKey:@"bPresetNum"] intValue];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
            break;

        case RET_DEVICE_NOT_SUPPORT://不支持禁用、启用开关
        {
            NSLog(@"进入case RET_DEVICE_NOT_SUPPORT");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressAlert hide:YES];
            });

            //作此判断是因为，2代npc支持防区加减，却不支持防区开关
            if (!_isGetDefenceStatusData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"device_not_support", nil)];
                });
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    usleep(800000);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:nil];
                    });
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
            break;
        case RET_GET_DEFENCE_SWITCH_STATE:
        {
            NSLog(@"进入case RET_GET_DEFENCE_SWITCH_STATE");
            NSMutableArray *switchStatus = [parameter valueForKey:@"switchStatus"];
            self.switchStatusData = [switchStatus objectAtIndex:self.dwCurGroup];
            _isGetDefenceSwitchData = YES;

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressAlert hide:YES];
                if(self.isSetting){
                    self.isSetting = NO;
                    [self.view makeToast:NSLocalizedString(@"modify_success", nil)];
                }
                [self.progressAlert hide:YES];
                [self.tableView reloadData];
            });
        }
            break;
        case RET_SET_DEFENCE_SWITCH_STATE:
        {
            NSLog(@"进入case RET_SET_DEFENCE_SWITCH_STATE");
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            if(result==0){
                self.isSetting = YES;
                [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
                
            }else if(result==41){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"device_not_support", nil)];
                    [self onBackPress];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"modify_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_DEFENCE_AREA_STATE:
        {
            NSLog(@"进入case RET_GET_DEFENCE_AREA_STATE");
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSLog(@"😄😭😊：%d", result);
            if(result==MESG_SET_ID_ALARMCODE_UBOOT_VERSION_ERR || result == MESG_SET_DEVICE_NOT_SUPPORT){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_not_support_defence_area", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                });
                return;
            }
            else if (result == MESG_GET_OK)//come here
            {
                NSMutableArray *status = [parameter valueForKey:@"status"];
                self.defenceStatusData = [status objectAtIndex:self.dwCurGroup];
                _isGetDefenceStatusData = YES;
                
                
                self.dataarray = [NSMutableArray arrayWithArray:status[1]];
                self.dataarray1 = [NSMutableArray array];
                int i;
                NSNumber *indexNumber = [NSNumber numberWithInteger:0];
                for ( i =0; i < self.dataarray.count; i++) {
                        if ([self.dataarray[i] isEqualToNumber:indexNumber]) {
                            [self.dataarray1 addObject:[NSString stringWithFormat:@"%d",i]];
                    }
                } 

                for (NSString *indec1 in self.dataarray1) {
                    NSInteger indec = [indec1 integerValue];
                    [[P2PClient sharedClient] getDefenceTypeMotorPresetPosWithId:self.contact.contactId password:self.contact.contactPassword defenceArea:0 channel:indec];
                }
                
                if (!self.isSetting) {
                    [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.isSetting = NO;
                        [self.view makeToast:NSLocalizedString(@"modify_success", nil)];
                        [self.progressAlert hide:YES];
                        [self.tableView reloadData];
                    });
                }
            }
        }
            break;
        case RET_SET_DEFENCE_AREA_STATE:
        {
            NSLog(@"进入case RET_SET_DEFENCE_AREA_STATE");
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==MESG_SET_OK){
                
                
                
                self.isSetting = YES;
                [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
                
            }else if(result==32){
                int group = [[parameter valueForKey:@"group"] intValue];
                int item = [[parameter valueForKey:@"item"] intValue];
                
                DLog(@"%i %i->already learned!",group,item);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    NSString *promptString = [NSString stringWithFormat:@"%@:%@ %i %@",[self getDefenceGroupNameWithIndex:group],NSLocalizedString(@"defence_item",nil),item+1,NSLocalizedString(@"already_learn",nil)];
                    [self.view makeToast:promptString];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"modify_failure", nil)];
                });
            }
        }
            break;

    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSLog(@"进来了方法:ack_receiveRemoteMessage");
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    NSLog(@"ack_receiveRemoteMessage key=0x%x, result=%d", key, result);
    switch(key){

        case ACK_RET_GET_DEFENCE_AREA_STATE:
        {
            NSLog(@"进入了：case ACK_RET_GET_DEFENCE_AREA_STATE");
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get defence area state");
                    [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
                }
            });
            
            DLog(@"ACK_RET_GET_DEFENCE_AREA_STATE:%i",result);
        }
            break;
        case ACK_RET_SET_DEFENCE_AREA_STATE:
        {
            NSLog(@"进入了：case ACK_RET_SET_DEFENCE_AREA_STATE");
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }
                else if(result==2){
                    DLog(@"resend set defence area state");
                    
                    [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.dwCurGroup item:self.dwCurItem type:self.dwlastOperation];
                }
            });
            DLog(@"ACK_RET_SET_DEFENCE_AREA_STATE:%i",result);
        }
            break;
        case ACK_RET_GET_DEFENCE_SWITCH_STATE:{
            NSLog(@"进入了：case ACK_RET_GET_DEFENCE_SWITCH_STATE");
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            usleep(2000000);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.view makeToast:NSLocalizedString(@"id_timeout",nil)];
                                [self onBackPress];
                            });
                        });
                    });
                }
                
                
            });
            
            DLog(@"ACK_RET_GET_DEVICE_INFO:%i",result);
        }
            break;
        case ACK_RET_SET_DEFENCE_SWITCH_STATE:{
            NSLog(@"进入了：case ACK_RET_SET_DEFENCE_SWITCH_STATE");
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] setDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword switchId:self.dwlastOperation alarmCodeId:(self.dwCurGroup-1) alarmCodeIndex:self.dwCurItem];
                }
            });
            
            DLog(@"ACK_RET_GET_DEVICE_INFO:%i",result);
        }
            break;
    }
    
}

-(NSString*)getDefenceGroupNameWithIndex:(NSInteger)index{
    switch (index) {
        case 0:
            return NSLocalizedString(@"remote", nil);
            break;
        case 1:
            return NSLocalizedString(@"hall", nil);
            break;
        case 2:
            return NSLocalizedString(@"window", nil);
            break;
        case 3:
            return NSLocalizedString(@"balcony", nil);
            break;
        case 4:
            return NSLocalizedString(@"bedroom", nil);
            break;
        case 5:
            return NSLocalizedString(@"kitchen", nil);
            break;
        case 6:
            return NSLocalizedString(@"courtyard", nil);
            break;
        case 7:
            return NSLocalizedString(@"door_lock", nil);
            break;
        case 8:
            return NSLocalizedString(@"other", nil);
            break;
            
        default:
            return @"";
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
    [self inputViewinit];
    [self initNameArray];
    
    [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#define LEFT_LABEL_WIDTH 120
#define GROUP_HEAD_WIDTH ([UIScreen mainScreen].bounds.size.width)

-(void)initComponent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    DefenceDao* defenceDao = [[DefenceDao alloc]init];
    NSString* title = [defenceDao getItemName:self.contact.contactId group:self.dwCurGroup item:8];
    if (title == nil) {
        title = [Utils defaultDefenceName:self.dwCurGroup];
    }
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:title];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonIcon:[UIImage imageNamed:@"defence_edit.png"]];
    if (self.dwCurGroup != 0)
    {
        [topBar setRightButtonHidden:NO];
    }
    [topBar.rightButton addTarget:self action:@selector(changeAreaName) forControlEvents:UIControlEventTouchUpInside];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    self.mytopbar = topBar;
    [topBar release];
    
    UIView *maskLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [maskLayerView addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:maskLayerView] autorelease];
    [maskLayerView addSubview:self.progressAlert];
    
    [self.view addSubview:maskLayerView];
    [maskLayerView release];
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
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

# pragma mark - 自定义弹出输入框
-(void)inputViewinit{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIView * alphaView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    alphaView.backgroundColor = XBlack_128;
    alphaView.hidden = YES;
    [self.view addSubview:alphaView];
    self.inputalphaView = alphaView;
    [alphaView release];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.inputalphaView addGestureRecognizer:tap];
    [tap release];
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, CUSTOM_VIEW_HEIGHT_SHORT)];
    view.backgroundColor = XWhite;
    [self.inputalphaView addSubview:view];
    self.inputView = view;
    [view release];
    
    CGFloat rowheight = CUSTOM_VIEW_HEIGHT_SHORT/3;
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, rowheight)];
    label.backgroundColor = [UIColor colorWithRed:3/255.0 green:162.0/255.0 blue:234.0/255.0 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedString(@"modify_defenceArea_name", nil);
    label.textColor = XWhite;
    label.font = XFontBold_18;
    [self.inputView addSubview:label];
    self.titleLable = label;
    [label release];
    
    UIButton * backbutton = [[UIButton alloc] init];
    backbutton.frame = CGRectMake(width - 35, 5, 40, 40);
    UIImageView *downImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 8, 20, 20)];
    downImage.image = [UIImage imageNamed:@"ic_down.png"];
    [backbutton addSubview:downImage];
    [backbutton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.inputView addSubview:backbutton];
    
    UILabel * linelabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, rowheight, width, 1)];
    linelabel1.backgroundColor = XGray;
    [self.inputView addSubview:linelabel1];
    [linelabel1 release];
    
    UILabel * linelabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, rowheight*2, width, 1)];
    linelabel2.backgroundColor = XGray;
    [self.inputView addSubview:linelabel2];
    [linelabel2 release];
    
    UITextField * inputtext = [[UITextField alloc] initWithFrame:CGRectMake(10, rowheight, width-10*2, rowheight)];
    inputtext.textAlignment = NSTextAlignmentLeft;
    inputtext.returnKeyType = UIReturnKeyDone;
    [inputtext addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [inputtext addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.inputView addSubview:inputtext];
    self.namechangeView = inputtext;
    [inputtext release];
    
    UIButton * button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"new_button.png"] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    [button setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [button setTitleColor:XWhite forState:UIControlStateNormal];
    button.frame=CGRectMake(10, rowheight*2+10, width-2*10, rowheight-10*2);
    [button addTarget:self action:@selector(changename) forControlEvents:UIControlEventTouchUpInside];
    [self.inputView addSubview:button];
}

-(void)inputAnimationStart{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    self.inputView.frame = CGRectMake(0, height-CUSTOM_VIEW_HEIGHT_SHORT, width, CUSTOM_VIEW_HEIGHT_SHORT);
    
    self.inputalphaView.frame = CGRectMake(0, 0, width, height);
    self.inputalphaView.hidden = NO;
    
    [UIView setAnimationDelegate:self];
    // 动画完毕后调用animationFinished
    [UIView setAnimationDidStopSelector:@selector(animationFinished)];
    [UIView commitAnimations];
}

-(void)cancel{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.6];//动画时间长度，单位秒，浮点数
        self.inputView.frame = CGRectMake(0, height, width, CUSTOM_VIEW_HEIGHT_SHORT);
        [self.namechangeView resignFirstResponder];
        
        [UIView setAnimationDelegate:self];
        // 动画完毕后调用animationFinished
        [UIView setAnimationDidStopSelector:@selector(animationFinished)];
        [UIView commitAnimations];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            usleep(600000);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.inputalphaView setHidden:YES];
            });
        });
    });
    
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.namechangeView) {
        if (textField.text.length > 32) {
            textField.text = [textField.text substringToIndex:32];
        }
    }
}
-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

#pragma mark 更改名称
-(void)changename{
    if ([self.namechangeView.text isEqualToString:@""])
    {
        NSString* title = self.titleLable.text;
        if ([title isEqualToString:NSLocalizedString(@"modify_defenceArea_name", nil)])
        {
            [self.view makeToast:NSLocalizedString(@"input_defenceArea_name", nil)];
        }
        else if([title isEqualToString:NSLocalizedString(@"modify_channel_name", nil)])
        {
            [self.view makeToast:NSLocalizedString(@"input_channel_name", nil)];
        }
        return;
    }

    [self.namechangeView resignFirstResponder];

    NSString* newName = self.namechangeView.text;
    //更新数据库
    DefenceDao* dao = [[DefenceDao alloc]init];
    NSString* text = [dao getItemName:self.contact.contactId group:self.dwCurGroup item:self.dwItemModify];
    if (text == nil) {
        [dao insert:self.contact.contactId group:self.dwCurGroup item:self.dwItemModify text:newName];
    }
    else
    {
        [dao update:self.contact.contactId group:self.dwCurGroup item:self.dwItemModify text:newName];
    }
    
    if (self.dwItemModify == 8) //修改标题
    {
        [self.mytopbar setTitle:newName];
    }
    else
    {
        [self.namearray setObject:newName atIndexedSubscript:self.dwItemModify];

        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.dwItemModify inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }

    [self.tableView reloadData];
    [self cancel];
}

- (void)changeAreaName
{
    self.dwItemModify = 8;

    self.titleLable.text = NSLocalizedString(@"modify_defenceArea_name", nil);
    self.namechangeView.text = self.mytopbar.titleLabel.text;
    [self inputAnimationStart];
}

- (void)changeChannelName:(int)item
{
    self.titleLable.text = NSLocalizedString(@"modify_channel_name", nil);
    self.dwItemModify = item;
    
    UITableViewCell *cell = [self.tableView  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:item inSection:0]];
    self.namechangeView.text = cell.textLabel.text;
    [self inputAnimationStart];
}

-(void)animationFinished{
    //NSLog(@"动画结束!");
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber* defenceStatus = [self.defenceStatusData objectAtIndex:indexPath.row];
    return ([defenceStatus intValue] == 0);
}
//删除
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.dwCurItem = indexPath.row;
        UIAlertView *clearAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"clear_defence_prompt", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
        clearAlert.tag = ALERT_TAG_CLEAR;
        [clearAlert show];
        [clearAlert release];
    }
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
    return 8;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * reuseID = @"DefenceCell";
    DefenceMagneticCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[[DefenceMagneticCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
    }
    [cell.textLabel setText:self.namearray[indexPath.row]];
    
    cell.group = self.dwCurGroup;
    cell.item = indexPath.row;
    cell.delegate = self;
    if ([self.defenceStatusData count] == 0) {
        return cell;
    }
    
    //数据到达
    [cell setProgressViewHidden:YES];
    NSLog(@"接收到了原来的设置数据。");
    
    NSNumber* defenceStatus = [self.defenceStatusData objectAtIndex:indexPath.row];
    
    if ([defenceStatus intValue] == 0)//学习对吗
    {
        if (self.dwCurGroup == 0) {//遥控器
            [cell setContollerViewHidden:NO];
            [cell setAddbuttonHidden:YES];
            [cell setDefenceswitchHidden:YES];
            [cell setDefenimageWithHidden:YES];
            [cell setAddbutton1Hidden:YES];
            [cell setAddLableHidden:YES];
            
        }
        else//门磁
        {
            [cell setAddbuttonHidden:YES];
            if (_isGetDefenceSwitchData) {
                [cell setContollerViewHidden:YES];
                [cell setDefenceswitchHidden:YES];
                [cell setDefenimageWithHidden:NO];
                [cell setAddbutton1Hidden:NO];

                if (indexPath.row == self.item1) {

                    if (self.index >= 5 ) {
                        [cell setAddLableHidden:YES];
                    }else{
                        [cell setAddLableHidden:NO];
                        
                        cell.addLable.text = [NSString stringWithFormat:@"%d",self.index+1];
                    }
                }

                [cell.addbutton1 setImage:[UIImage imageNamed:@"baidu"] forState:UIControlStateNormal];
                [cell.addbutton1 addTarget:self action:@selector(yuzhiwei:) forControlEvents:UIControlEventTouchUpInside];
                
                NSNumber* switchStatus = [self.switchStatusData objectAtIndex:indexPath.row];
                if ([switchStatus intValue] == 0)   //关
                {
                    cell.defenceswitch.on = NO;
                }
                else
                {
                    cell.defenceswitch.on = YES;

                }
            }
            else
            {
                [cell setContollerViewHidden:NO];
                [cell setDefenceswitchHidden:NO];
                [cell setDefenimageWithHidden:YES];
            }
        }
    }
    else
    {
        NSLog(@"未学习对码。");
        [cell setAddbuttonHidden:NO];
        [cell setDefenceswitchHidden:YES];
        [cell setContollerViewHidden:YES];
        [cell setDefenimageWithHidden:YES];
        [cell setAddbutton1Hidden:YES];
        [cell setAddLableHidden:YES];

    }
    
    return cell;
}

- (void)yuzhiwei:(UIButton *)sender{
    
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    yizhiweiVC *vc = [[yizhiweiVC alloc] init];

    vc.item = path.row;
    vc.group = _dwCurGroup;
    vc.contact = self.contact;
 
    [self presentViewController:vc animated:YES completion:nil];

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self changeChannelName:indexPath.row];
 }

#pragma mark 删除和添加
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_CLEAR:
        {
            if(buttonIndex==1){
                self.progressAlert.dimBackground = YES;
                self.progressAlert.labelText = NSLocalizedString(@"clearing", nil);
                [self.progressAlert show:YES];
                
                [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.dwCurGroup item:self.dwCurItem type:1];
            }
        }
            break;
        case ALERT_TAG_LEARN:
        {
            if(buttonIndex==1)
            {
                self.progressAlert.dimBackground = YES;
                self.progressAlert.labelText = NSLocalizedString(@"learning", nil);
                [self.progressAlert show:YES];
                
                [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.dwCurGroup item:self.dwCurItem type:0];
                
            }
        }
            break;
    }
}

-(void)defenceCell:(DefenceMagneticCell *)defenceCell section:(NSInteger)section row:(NSInteger)row status:(NSInteger)status
{
    //学码
    if (status == 3)
    {
        self.dwCurItem = row;
        UIAlertView *learnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"learn_defence_prompt", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
        learnAlert.tag = ALERT_TAG_LEARN;
        [learnAlert show];
        [learnAlert release];
    }
    
    //开关
    else if (status == 4)
    {
        self.dwCurItem = row;
        self.dwlastOperation =defenceCell.defenceswitch.on;
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
        
        [[P2PClient sharedClient] setDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword switchId:self.dwlastOperation alarmCodeId:(self.dwCurGroup-1) alarmCodeIndex:defenceCell.item];
    }
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

-(void)initNameArray
{
    DefenceDao* defenceDao = [[DefenceDao alloc]init];
    NSMutableArray* nameArray = [NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<8; i++) {
        NSString* name = [defenceDao getItemName:self.contact.contactId group:self.dwCurGroup item:i];
        if (name == nil)
        {
            name = [NSString stringWithFormat:@"%@ %d", [Utils defaultDefenceName:self.dwCurGroup], i+1];
        }
        [nameArray addObject:name];
    }
    [defenceDao release];
    self.namearray = nameArray;
    

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
    if (self.inputView == nil) {
        return;
    }
    CGPoint point = [recognizer locationInView:self.inputalphaView];
    
    if (!CGRectContainsPoint(self.inputView.frame, point)) {
        [self cancel];
    }
}
@end
