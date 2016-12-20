//
//  AddContactNextController.h
//  Camnoopy
//
//  Created by guojunyi on 14-4-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//
/*设备编辑页面*/
//手动添加设备
#import <UIKit/UIKit.h>
@class  Contact;
@class QRCodeNextController;
@interface AddContactNextController : UIViewController
@property (strong, nonatomic) UITextField *contactNameField;//device name
@property (strong, nonatomic) UITextField *contactPasswordField;//device password
@property(strong,nonatomic)UIButton *deleteBtn;

//多出的
@property (strong, nonatomic) UITextField *contactIdField;//device ID

@property (retain, nonatomic) NSString *contactId;
@property (retain, nonatomic) NSString *storeID;//缺少的

@property(strong, nonatomic) Contact *modifyContact;
@property (nonatomic) BOOL isModifyContact;
@property (nonatomic) BOOL isInFromLocalDeviceList;
@property (nonatomic) BOOL isInFromManuallAdd;
@property (nonatomic) BOOL isInFromQRCodeNextController;
@property (nonatomic) BOOL isPopRoot;

@property (nonatomic,assign) int inType;//多出的

@property(nonatomic,strong)NSString *hideDeleteBtn;//用于接收传来的值

@end
