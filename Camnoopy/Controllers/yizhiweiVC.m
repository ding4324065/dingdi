//
//  yizhiweiVC.m
//  Camnoopy
//
//  Created by 卡努比 on 16/11/2.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "yizhiweiVC.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "DefenceDoorMagneticController.h"
#import "P2PEmailSettingCell.h"
#import "yizhiweiCell.h"
#import "Toast+UIView.h"

@interface yizhiweiVC () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation yizhiweiVC

- (void)dealloc{
    [super dealloc];
    [self.array release];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[P2PClient sharedClient] getPressetInfo:self.contact.contactId password:self.contact.contactPassword];
    [[P2PClient sharedClient] getDefenceTypeMotorPresetPosWithId:self.contact.contactId password:self.contact.contactPassword defenceArea:0 channel:self.item];
    
    //接收远程消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    NSLog(@"%d== %d %d",_item,_group,_index1);
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key = [[parameter valueForKey:@"key"] intValue];
    switch (key) {
        case RET_SET_SEARCH_PRESET:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            
            if (result == 0) {
                //设置成功
                int bOperation = [[parameter valueForKey:@"bOperation"] intValue];
                if (bOperation == 1) {
                    int bPresetNum = [[parameter valueForKey:@"bPresetNum"] intValue];
                    NSLog(@"%d bPresetNum bPresetNum ", bPresetNum);
                }
                
            }else if (result == 1){
                //操作获取成功
                int bOperation = [[parameter valueForKey:@"bOperation"] intValue];
                if (bOperation == 2) {
                    int bPresetNum = [[parameter valueForKey:@"bPresetNum"] intValue];
                    NSLog(@"%d bPresetNum bPresetNum ", bPresetNum);
                    _Num = bPresetNum;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        int c = _Num & 0b0001;
                        int d = _Num & 0b0010;
                        int f = _Num & 0b0100;
                        int g = _Num & 0b1000;
                        int h = _Num & 0b10000;
                        NSLog(@"%d,%d,%d,%d,%d",c,d,f,g,h);
                        if (c == 1) {
                            [_array addObject:@"1"];
                        }
                        if (d == 2){
                            [_array addObject:@"2"];
                        }
                        if (f == 4){
                            [_array addObject:@"3"];
                        }
                        if (g == 8){
                            [_array addObject:@"4"];
                        }
                        if (h == 16){
                            [_array addObject:@"5"];
                        }
//                        NSLog(@"===array====%d",_array.count);
//                        for (NSString *c in _array) {
//                            NSLog(@"%@",c);
//                        }
                        
                       
                        
                        [self.tableView reloadData];
                    });
                }
                
            }else if (result == 84 ){
                //为无此设置选项
            }else if (result == 254){
                //表示填入参数有误
            }else if (result == 255){
                //设备不支持预置位
            }
        }
            break;
        case RET_SET_PRESET_MOTOR_POS:{
            NSInteger result = [[parameter valueForKey:@"result"] integerValue];
            
            if (result == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
            }
        }
            break;
        case RET_GET_PRESET_MOTOR_POS:{
            NSInteger result = [[parameter valueForKey:@"result"] integerValue];
            if (result == 1) {

                self.group = [[parameter valueForKey:@"group"] intValue];
                self.item = [[parameter valueForKey:@"item"] intValue];
                self.index = [[parameter valueForKey:@"bPresetNum"] intValue];
                
                for (int i =0; i<_array.count; i++) {
                    if ([_array[i] isEqualToString:[NSString stringWithFormat:@"%d",_index+1]]) {
                        _index1 = i;
                    }
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
            break;
        default:
            break;
    }
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    
    NSDictionary *parameter = [notification userInfo];
    int key = [[parameter valueForKey:@"key"] intValue];
    int result = [[parameter valueForKey:@"result"] intValue];
    switch (key) {
        case ACK_RET_SET_PRESET_MOTOR_POS:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == 1) {
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        [self  onBackPress];
                    });
                    
                }else if (result == 2){
                    [[P2PClient sharedClient] setDefenceTypeMotorPresetPosWithId:self.contact.contactId password:self.contact.contactPassword defenceArea:0 channel:_item presetNumber:_index];
                }
            });
        }
            break;
            
        default:
            break;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _array = [[NSMutableArray alloc] init];
//    [_array addObject:@"没预置位"];
    [self initComponent];
}

- (void)initComponent{
    self.view.layer.contents = XBgImage;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"Pick_the_preset", nil)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:YES];
    
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
}

-(void)onBackPress{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseID = @"cell";
    yizhiweiCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[[yizhiweiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
        
    }
    cell.leftLab.text = _array[indexPath.row];
    
    
    
    
    if (indexPath.row == _index1) {
        cell.img.image = [UIImage imageNamed:@"radio_btn_on"];
    }else{
        cell.img.image = [UIImage imageNamed:@"radio_btn_off"];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _index1 = indexPath.row;
    _preNum = [_array[_index1] intValue];
    [self.tableView reloadData];

    [[P2PClient sharedClient] setDefenceTypeMotorPresetPosWithId:self.contact.contactId password:self.contact.contactPassword defenceArea:0 channel:self.item presetNumber:_preNum-1];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
