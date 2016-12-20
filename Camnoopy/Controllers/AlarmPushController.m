//
//  AlarmPushController.m
//  Camnoopy
//
//  Created by 高琦 on 15/3/12.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
#define ALARMVIEW_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 300:200)
#define REJECTVIEW_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 40:30)
#define TOUCHBTNVIEW_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100:80)
#define LEFT_DOOLBELL_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100:100)

#import "AlarmPushController.h"
#import "mesg.h"
#import "MainContainer.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "Toast+UIView.h"
#import "ContactDAO.h"
#import "DefenceDao.h"
#import "Utils.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "MusicViewController.h"
@interface AlarmPushController ()
{
    UIImageView* _viewCommon;
    UIImageView* _viewDoorbell1;
    UIImageView* _viewDoorbell2;
    
    UILabel* _labelName;
    UILabel* _labelId;
    UILabel* _labelType;
    UILabel* _labelDefence;
    SystemSoundID soundId;
    
}
@end

@implementation AlarmPushController

-(void)dealloc
{
    NSLog(@"AlarmPushController dealloc");
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initComponent];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[P2PClient sharedClient] getDefenceTypeMotorPresetPosWithId:self.contactId password:@"" defenceArea:0 channel:self.item];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
#pragma mark - 更新报警信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdadateAlarmInfomation:) name:@"UpdateAlarmInformation" object:nil];
    self.isshow = YES;
    self.isbreathe = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(back) userInfo:nil repeats:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateAlarmInformation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    self.isshow = NO;
    self.isbreathe = NO;
    [self.timer invalidate];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key = [[parameter valueForKey:@"key"] intValue];
    switch (key) {
        
        case RET_GET_PRESET_MOTOR_POS:{
            NSInteger result = [[parameter valueForKey:@"result"] integerValue];
            if (result == 1) {
                
                self.group = [[parameter valueForKey:@"group"] intValue];
                self.item = [[parameter valueForKey:@"item"] intValue];
                self.index = [[parameter valueForKey:@"bPresetNum"] intValue];

            }
        }
            break;
        default:
            break;
    }
}


-(void)back{
    self.isshow = NO;
    AppDelegate * appDdelegate = [AppDelegate sharedDefault];
    appDdelegate.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
    appDdelegate.iCurrentShowAlarmType = -1; 
    appDdelegate.currentShowAlarmId = @"";
//
    dispatch_async(dispatch_get_main_queue(), ^{
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
        AudioServicesDisposeSystemSoundID(soundId);
    });
    
    //    MainContainer * mainController = [AppDelegate sharedDefault].mainController;
    //    appDdelegate.window.rootViewController = mainController;
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)initComponent{
    self.isbreathe = YES;
    if (self.alarmtype == ALARM_TYPE_MD)
    {
        self.view.layer.contents = (id)[UIImage imageNamed:@"movealarm_bg.png"].CGImage;
    }
    else
    {
        self.view.layer.contents = (id)[UIImage imageNamed:@"alarmpush_bg.png"].CGImage;
    }
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    
    //设备名...
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:self.contactId];
    [contactDAO release];
//    根据字体来确定宽高
    CGSize labelSize = [@"CONTACTNAME" sizeWithFont:XFontBold_18];
    UILabel* lableName = [[UILabel alloc] initWithFrame:CGRectMake((width-labelSize.width)/2, 15, labelSize.width, 40)];
    lableName.textColor = XWhite;
    lableName.text = (contact != nil) ? contact.contactName : @"";
    lableName.textAlignment = NSTextAlignmentCenter;
    lableName.font = XFontBold_18;
    _labelName = lableName;
    
    [self.view addSubview:lableName];
    [lableName release];
    
    //设备id
    NSString* textId = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_device", nil),self.contactId];
    labelSize = [textId sizeWithFont:XFontBold_14];
    UILabel* labelId = [[UILabel alloc] initWithFrame:CGRectMake((width-labelSize.width)/2, 40, labelSize.width, 40)];
    labelId.textColor = XWhite;
    labelId.text = textId;
    labelId.textAlignment = NSTextAlignmentCenter;
    labelId.font = XFontBold_14;
    _labelId = labelId;
    [self.view addSubview:labelId];
    [labelId release];
    
#pragma mark - 报警预置位联动
    [[P2PClient sharedClient] setAndSearchPresetWithId:self.contactId password:@"" operation:0 presetNumber:self.index];

//    一般动画
    [self CreateCommonAnimation];
//    门铃动画
    [self createDoorbellAnimation];
//    ALARM_TYPE_MD 移动侦测
    if (self.alarmtype != ALARM_TYPE_MD) {
//        ALARM_TYPE_DOOLBEL = 13,   门铃报警
        if (self.alarmtype == ALARM_TYPE_DOOLBEL) {
            _viewDoorbell1.hidden = NO;
            _viewDoorbell2.hidden = NO;
            [_viewDoorbell1 startAnimating];
            [_viewDoorbell2 startAnimating];
        }
        else
        {
            _viewCommon.hidden = NO;
            [_viewCommon startAnimating];
        }
    }
    
    //报警类型。。。
    NSString* textType = [Utils getAlarmtextByType:self.alarmtype];
    labelSize = [textType sizeWithFont:XFontBold_16];
    UILabel * labelType = [[UILabel alloc] initWithFrame:CGRectMake((width-labelSize.width)/2, height-TOUCHBTNVIEW_WIDTH_HEIGHT-70, labelSize.width, labelSize.height)];
    labelType.text = textType;
    labelType.font = XFontBold_16;
    labelType.textColor = XWhite;
    labelType.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelType];
    _labelType = labelType;
    [labelType release];
    
    //防区通道信息（只针对外部报警）
    UILabel * defenceLable = [[UILabel alloc] initWithFrame:CGRectMake((width-labelSize.width)/2, CGRectGetMaxY(_labelType.frame)+10, labelSize.width, labelSize.height)];
    if (self.alarmtype == ALARM_TYPE_EXT) {
        DefenceDao* dao = [[DefenceDao alloc]init];
        NSString* groupName = [dao getItemName:self.contactId group:self.group item:8];
        NSString* itemName = [dao getItemName:self.contactId group:self.group item:self.item];
        [dao release];
        if (groupName == nil) {
            groupName = [NSString stringWithFormat:@"%@", [Utils defaultDefenceName:self.group]];
        }
        if (itemName == nil) {
            itemName = [NSString stringWithFormat:@"%@ %d", [Utils defaultDefenceName:self.group], self.item+1];
        }
        NSString* defenceText = [NSString stringWithFormat:@"%@:%@  %@:%@", NSLocalizedString(@"defence_group", nil), groupName, NSLocalizedString(@"defence_item", nil), itemName];
        labelSize = [defenceText sizeWithFont:XFontBold_12];
        defenceLable.frame = CGRectMake((width-labelSize.width)/2, CGRectGetMaxY(_labelType.frame)+10, labelSize.width, labelSize.height);
        defenceLable.text = defenceText;
    }
    defenceLable.font = XFontBold_12;
    defenceLable.textColor = XWhite;
    defenceLable.textAlignment = NSTextAlignmentCenter;
    _labelDefence = defenceLable;
    [self.view addSubview:defenceLable];
    [defenceLable release];
    
    
    //红色x
    UIImageView * rejectview = [[UIImageView alloc] initWithFrame:CGRectMake(10, height-REJECTVIEW_WIDTH_HEIGHT-40, REJECTVIEW_WIDTH_HEIGHT, REJECTVIEW_WIDTH_HEIGHT)];
    rejectview.contentMode = UIViewContentModeScaleAspectFit;
    rejectview.image = [UIImage imageNamed:@"down_reject.png"];
    [self.view addSubview:rejectview];
    rejectview.hidden = YES;
    self.rejectview = rejectview;
    [rejectview release];
    
    //白色圈圈按钮
    UIImageView* touchbtnview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-TOUCHBTNVIEW_WIDTH_HEIGHT/2, rejectview.frame.origin.y+REJECTVIEW_WIDTH_HEIGHT/2-TOUCHBTNVIEW_WIDTH_HEIGHT/2, TOUCHBTNVIEW_WIDTH_HEIGHT, TOUCHBTNVIEW_WIDTH_HEIGHT)];
    touchbtnview.contentMode = UIViewContentModeScaleAspectFit;
    touchbtnview.image = [UIImage imageNamed:@"down_btn.png"];
    [self.view addSubview:touchbtnview];
    self.touchbtnview = touchbtnview;
    [touchbtnview release];
    
    self.touchbtnframe = self.touchbtnview.frame;
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (self.isshow) {
                while(self.isbreathe){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.75 animations:^{
                            self.touchbtnview.transform = CGAffineTransformMakeScale(0.6, 0.6);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.75 animations:^{
                                self.touchbtnview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                            } completion:^(BOOL finished) {
                                
                            }];
                        }];
                    });
                    usleep(1000000);
                }
            }
        });
    });
    UIImageView * lineview = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rejectview.frame), rejectview.frame.origin.y, width-CGRectGetMaxX(rejectview.frame)*2, rejectview.frame.size.height)];
    lineview.contentMode = UIViewContentModeScaleAspectFit;
    lineview.image = [UIImage imageNamed:@"down_line.png"];
    [self.view addSubview:lineview];
    self.downlineview = lineview;
    lineview.hidden = YES;
    [lineview release];
    self.touchlineframe = lineview.frame;
    
    UIImageView * acceptview = [[UIImageView alloc] initWithFrame:CGRectMake(width-10-REJECTVIEW_WIDTH_HEIGHT, rejectview.frame.origin.y, REJECTVIEW_WIDTH_HEIGHT, REJECTVIEW_WIDTH_HEIGHT)];
    acceptview.contentMode = UIViewContentModeScaleAspectFit;
    acceptview.image = [UIImage imageNamed:@"down_accept.png"];
    [self.view addSubview:acceptview];
    self.acceptview = acceptview;
    acceptview.hidden = YES;
    [acceptview release];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchbtnview.transform = CGAffineTransformMakeScale(1.0, 1.0);
    self.isbreathe = NO;
    self.iscanmove = NO;
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:self.view];
    int originx = self.touchbtnview.frame.origin.x;
    int originy = self.touchbtnview.frame.origin.y;
    int widthmax = CGRectGetMaxX(self.touchbtnview.frame);
    int heightmax = CGRectGetMaxY(self.touchbtnview.frame);
    if (point.x>originx&&point.x<widthmax&&point.y>originy&&point.y<heightmax) {
        self.downlineview.hidden = NO;
        self.rejectview.hidden = NO;
        self.acceptview.hidden = NO;
        self.touchbtnview.image = [UIImage imageNamed:@"down_btn_d.png"];
        self.iscanmove = YES;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:self.view];
    int heightmin = self.touchlineframe.origin.y;
    int heightmax = CGRectGetMaxY(self.touchlineframe);
    if (self.iscanmove) {
        if (point.y>=heightmin&&point.y<=heightmax) {
            self.touchbtnview.center = point;
        }
    }
    if (point.x<=CGRectGetMaxX(self.rejectview.frame)) {
        AppDelegate * appDdelegate = [AppDelegate sharedDefault];
        appDdelegate.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
        appDdelegate.iCurrentShowAlarmType = -1;
        appDdelegate.currentShowAlarmId = @"";
        

        [self dismissViewControllerAnimated:NO completion:^{
//             AudioServicesDisposeSystemSoundID(soundId);//停止铃声
//             AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);//停止震动
            dispatch_async(dispatch_get_main_queue(), ^{
                AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
                AudioServicesDisposeSystemSoundID(soundId);
                AudioServicesDisposeSystemSoundID(soundId);

            });
          
//            MainContainer * mainController = [AppDelegate sharedDefault].mainController;
//            [mainController.view makeToast:@"~"];
        }];
    }
    if (point.x>=self.acceptview.frame.origin.x)
    {
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:self.contactId];
        [contactDAO release];
        
        if(nil!=contact){
            AppDelegate * appDdelegate = [AppDelegate sharedDefault];
            appDdelegate.mainController.contact = contact;
            appDdelegate.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
            appDdelegate.iCurrentShowAlarmType = -1;
            appDdelegate.currentShowAlarmId = @"";
            
            [self dismissViewControllerAnimated:NO completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
                    AudioServicesDisposeSystemSoundID(soundId);
                    AudioServicesDisposeSystemSoundID(soundId);

                });
               
                [appDdelegate.mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
            }];
        }else{
        
            [self dismissViewControllerAnimated:NO completion:^{

                dispatch_async(dispatch_get_main_queue(), ^{
                    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
                    AudioServicesDisposeSystemSoundID(soundId);
                    AudioServicesDisposeSystemSoundID(soundId);

                });
                MainContainer * mainController = [AppDelegate sharedDefault].mainController;
                [mainController showAlertPwdForContactId:self.contactId];
            }];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    AppDelegate * appDdelegate = [AppDelegate sharedDefault];
    
    if(buttonIndex==1){
        UITextField *passwordField = [alertView textFieldAtIndex:0];
        
        NSString *inputPwd = passwordField.text;
        if(!inputPwd||inputPwd.length==0){
//            请输入设备密码
            [appDdelegate.mainController.view makeToast:NSLocalizedString(@"input_device_password", nil)];
        }
        else
        {
            Contact* contact = [[Contact alloc]init];
            contact.contactId = self.contactId;
            contact.contactPassword = inputPwd;
            contact.defenceState = DEFENCE_STATE_ON;
            appDdelegate.mainController.contact = contact;
            [contact release];
            [appDdelegate.mainController setUpCallWithId:self.contactId password:inputPwd callType:P2PCALL_TYPE_MONITOR];
        }
    }
    appDdelegate.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
    appDdelegate.iCurrentShowAlarmType = -1;
    appDdelegate.currentShowAlarmId = @"";
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    self.isbreathe = YES;
    self.downlineview.hidden = YES;
    self.rejectview.hidden = YES;
    self.acceptview.hidden = YES;
    [UIView animateWithDuration:0.5f animations:^{
        self.touchbtnview.frame = self.touchbtnframe;
    }];
    self.touchbtnview.image = [UIImage imageNamed:@"down_btn.png"];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    

    self.isbreathe = YES;
    self.downlineview.hidden = YES;
    self.rejectview.hidden = YES;
    self.acceptview.hidden = YES;
    [UIView animateWithDuration:0.5f animations:^{
        self.touchbtnview.frame = self.touchbtnframe;
    }];
    self.touchbtnview.image = [UIImage imageNamed:@"down_btn.png"];
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
//声音报警动画
-(void)CreateCommonAnimation
{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    

#pragma mark - 震动报警
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSInteger  vibrationsStart= [manager integerForKey:@"VibrationsStart"];
#pragma mark - 铃声报警
    NSInteger openvoiceState = [manager integerForKey:@"OpenvoiceState"];
    
    NSLog(@"接收vibrationsStart==%d openvoiceState==%d",vibrationsStart,openvoiceState);
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    _musicName = [userdefaults objectForKey:@"musicStr"];
    
    if (vibrationsStart == SETTING_VALUE_VIBRATION_STATE_ON && openvoiceState == SETTING_VALUE_MUSIZ_STATE_OFF) {
            AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL,systemAudioCallback, NULL);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    else if (vibrationsStart == SETTING_VALUE_VIBRATION_STATE_OFF && openvoiceState == SETTING_VALUE_MUSIZ_STATE_ON)
         {
             NSString *path = [[NSBundle mainBundle]pathForResource:_musicName ofType:@"m4r"];
             AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
             AudioServicesPlaySystemSound(soundId);
    }else if (vibrationsStart == SETTING_VALUE_VIBRATION_STATE_ON && openvoiceState == SETTING_VALUE_MUSIZ_STATE_ON) {
            NSString *path = [[NSBundle mainBundle]pathForResource:_musicName ofType:@"m4r"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
            AudioServicesPlaySystemSound(soundId);
            
            AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL,systemAudioCallback, NULL);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    
    UIImageView * alarmview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-ALARMVIEW_WIDTH_HEIGHT/2, 150, ALARMVIEW_WIDTH_HEIGHT, ALARMVIEW_WIDTH_HEIGHT)];
    alarmview.image = [UIImage imageNamed:@"em_alarm.png"];
    alarmview.contentMode = UIViewContentModeScaleAspectFit;
    NSArray *imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"em_alarm.png"],[UIImage imageNamed:@"em_alarm_d.png"],nil];
    alarmview.animationImages = imagesArray;
    alarmview.animationDuration = ((CGFloat)[imagesArray count])*200.0f/1000.0f;
    alarmview.animationRepeatCount = 0;
    //    [alarmview startAnimating];
    alarmview.hidden = YES;
    [self.view addSubview:alarmview];
    _viewCommon = alarmview;
    [alarmview release];
    
}
void systemAudioCallback()
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
//创建门铃动画
-(void)createDoorbellAnimation
{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
//    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
//    NSInteger  vibrationsStart= [manager integerForKey:@"VibrationsStart"];
//    //    BOOL isStart = [manager boolForKey:@"isVibrationsStart"];
//#pragma mark - 铃声报警
//    NSInteger openvoiceState = [manager integerForKey:@"OpenvoiceState"];
//    //    BOOL isStart1 = [manager boolForKey:@"isOpenvoice"];
//    
//    if (vibrationsStart == SETTING_VALUE_VIBRATION_STATE_ON && openvoiceState == SETTING_VALUE_MUSIZ_STATE_OFF) {
//        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL,systemAudioCallback, NULL);
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//    }
//    else if (vibrationsStart == SETTING_VALUE_VIBRATION_STATE_OFF && openvoiceState == SETTING_VALUE_MUSIZ_STATE_ON)
//    {
//        NSString *path = [[NSBundle mainBundle]pathForResource:@"BIGBOSS" ofType:@"m4r"];
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
//        AudioServicesPlaySystemSound(soundId);
//    }else if (vibrationsStart == SETTING_VALUE_VIBRATION_STATE_ON && openvoiceState == SETTING_VALUE_MUSIZ_STATE_ON) {
//        NSString *path = [[NSBundle mainBundle]pathForResource:@"BIGBOSS" ofType:@"m4r"];
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
//        AudioServicesPlaySystemSound(soundId);
//        
//        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL,systemAudioCallback, NULL);
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//    }
    
    
    
    UIImageView * alarmview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-ALARMVIEW_WIDTH_HEIGHT/4, 150, ALARMVIEW_WIDTH_HEIGHT/2, ALARMVIEW_WIDTH_HEIGHT/2)];
    alarmview.image = [UIImage imageNamed:@"em_alarm.png"];
    alarmview.contentMode = UIViewContentModeScaleAspectFit;
    NSArray *imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"doorbell_l.png"],[UIImage imageNamed:@"doorbell_m.png"],[UIImage imageNamed:@"doorbell_r.png"], nil];
    alarmview.animationImages = imagesArray;
    alarmview.animationDuration = ((CGFloat)[imagesArray count])*200.0f/1000.0f;
    alarmview.animationRepeatCount = 0;
    //    [alarmview startAnimating];
    [self.view addSubview:alarmview];
    _viewDoorbell1 = alarmview;
    alarmview.hidden = YES;
    [alarmview release];
    
    UIImageView * dbbackview = [[UIImageView alloc] initWithFrame:CGRectMake(40, CGRectGetMidY(alarmview.frame)-alarmview.frame.size.height/2, width-40*2, TOUCHBTNVIEW_WIDTH_HEIGHT)];
    dbbackview.contentMode = UIViewContentModeScaleAspectFit;
    NSArray * dbbackimgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"alarm_doorbell_left1.png"],[UIImage imageNamed:@"alarm_doorbell_left2.png"],[UIImage imageNamed:@"alarm_doorbell_left3.png"], nil];
    dbbackview.animationImages = dbbackimgArray;
    dbbackview.animationDuration = ((CGFloat)[imagesArray count])*200.0f/1000.0f;
    dbbackview.animationRepeatCount = 0;
    //    [dbbackview startAnimating];
    [self.view addSubview:dbbackview];
    dbbackview.hidden = YES;
    _viewDoorbell2 = dbbackview;
    [dbbackview release];
    
}
#pragma mark - 显示报警类型
-(void)showAlarmWithType
{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:self.contactId];
    [contactDAO release];
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    if (contact) {
        CGSize labelSize = [contact.contactName sizeWithFont:XFontBold_18];
        _labelName.frame = CGRectMake((width-labelSize.width)/2, 15, labelSize.width, 40);
        _labelName.text = contact.contactName;
    }
    else
    {
        _labelName.text = @"";
    }
    
    //设备id
    NSString* textDevice = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_device", nil),self.contactId];
    CGSize labelSize = [textDevice sizeWithFont:XFontBold_14];
    _labelId.frame = CGRectMake((width-labelSize.width)/2, 40, labelSize.width, 40);
    _labelId.text = textDevice;
    
    //animation
    if (self.alarmtype == ALARM_TYPE_MD) {
        self.view.layer.contents = (id)[UIImage imageNamed:@"movealarm_bg.png"].CGImage;
        _viewCommon.hidden = YES;
        _viewDoorbell1.hidden = YES;
        _viewDoorbell2.hidden = YES;
        [_viewCommon stopAnimating];
        [_viewDoorbell1 stopAnimating];
        [_viewDoorbell2 stopAnimating];
    }
    else if(self.alarmtype == ALARM_TYPE_DOOLBEL)
    {
        self.view.layer.contents = (id)[UIImage imageNamed:@"alarmpush_bg.png"].CGImage;
        _viewCommon.hidden = YES;
        _viewDoorbell1.hidden = NO;
        _viewDoorbell2.hidden = NO;
        [_viewCommon stopAnimating];
        [_viewDoorbell1 startAnimating];
        [_viewDoorbell2 startAnimating];
    }
    else
    {
        self.view.layer.contents = (id)[UIImage imageNamed:@"alarmpush_bg.png"].CGImage;
        _viewCommon.hidden = NO;
        _viewDoorbell1.hidden = YES;
        _viewDoorbell2.hidden = YES;
        [_viewCommon startAnimating];
        [_viewDoorbell1 stopAnimating];
        [_viewDoorbell2 stopAnimating];
    }
    
    //报警类型。。。
    NSString* alarmTest = [Utils getAlarmtextByType:self.alarmtype];
    NSLog(@"%@-------",alarmTest);
    labelSize = [alarmTest sizeWithAttributes: @{NSFontAttributeName: XFontBold_16}];

    _labelType.frame = CGRectMake((width-labelSize.width)/2, height-TOUCHBTNVIEW_WIDTH_HEIGHT-70, labelSize.width, labelSize.height);
    _labelType.text = alarmTest;
    
    //防区通道信息（只针对外部报警）
    if (self.alarmtype == ALARM_TYPE_EXT) {
        DefenceDao* dao = [[DefenceDao alloc]init];
        NSString* groupName = [dao getItemName:self.contactId group:self.group item:8];
        NSString* itemName = [dao getItemName:self.contactId group:self.group item:self.item];
        [dao release];
        if (groupName == nil) {
            groupName = [NSString stringWithFormat:@"%@", [Utils defaultDefenceName:self.group]];
        }
        if (itemName == nil) {
            itemName = [NSString stringWithFormat:@"%@ %d", [Utils defaultDefenceName:self.group], self.item+1];
        }
        NSString* defenceText = [NSString stringWithFormat:@"%@:%@  %@:%@", NSLocalizedString(@"defence_group", nil), groupName, NSLocalizedString(@"defence_item", nil), itemName];
        labelSize = [defenceText sizeWithFont:XFontBold_12];
        _labelDefence.frame = CGRectMake((width-labelSize.width)/2, CGRectGetMaxY(_labelType.frame)+10, labelSize.width, labelSize.height);
        _labelDefence.text = defenceText;
        
        
        
    }
    else
    {
        _labelDefence.text = @"";
    }
}

-(void)UpdadateAlarmInfomation:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *parameter = [notification userInfo];
        NSString *contactId   = [parameter valueForKey:@"contactId"];
        int type   = [[parameter valueForKey:@"type"] intValue];
        int group = [[parameter valueForKey:@"group"] intValue];
        int item = [[parameter valueForKey:@"item"] intValue];

        self.contactId = contactId;
        self.alarmtype = type;
        self.group = group;
        self.item = item;
        [self showAlarmWithType];
    });
}

@end
