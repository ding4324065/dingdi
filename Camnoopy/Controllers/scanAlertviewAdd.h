//
//  scanAlertViewAdd.h
//  Camnoopy
//
//  Created by wutong on 15-1-27.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalDevice.h"
#import "MBProgressHUD.h"

@protocol scanAlertAddDelegate <NSObject>
-(void)alertAddClickOK:(LocalDevice *)localDevice deviceName:(NSString*)deviceName;
-(void)alertAddClickCancel;
-(void)setInitPasswrod:(NSString*)contactID pwd:(NSString*)pwd;
@end

@interface scanAlertViewAdd : UIButton<UITextFieldDelegate>
{
    UITextField* _textFieldPasswordConfirm;
    
    UIActivityIndicatorView* _indicator;
}

@property (nonatomic, retain) LocalDevice* localDevice;
@property (nonatomic, assign) id<scanAlertAddDelegate> delegate;

@property (nonatomic, retain) UITextField* textFieldName;
@property (nonatomic, retain) UITextField* textFieldPassword;

@property (strong, nonatomic) MBProgressHUD *progressAlert;

- (void)setDelegate:(id)delegate localDevice:(LocalDevice*)localDevice;

@end
