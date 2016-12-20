//
//  P2PTextInputCell.h
//  Camnoopy
//
//  Created by 高琦 on 15/1/29.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface P2PTextInputCell : UITableViewCell<UITextFieldDelegate>
@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) NSString *rightTextFieldText;

@property (strong, nonatomic) UILabel *leftLabelView;
@property (strong, nonatomic) UITextField *rightTextFieldView;
@end
