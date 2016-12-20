//
//  P2PSecurityCell.h
//  2cu
//
//  Created by Jie on 15/1/5.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SavePressDelegate
-(void)savePress:(NSInteger)section row:(NSInteger)row;

@end

@interface P2PSecurityCell : UITableViewCell<UITextFieldDelegate>

@property (strong, nonatomic) id<SavePressDelegate> delegate;
@property (nonatomic) NSInteger section;
@property (nonatomic) NSInteger row;


@property (strong, nonatomic) NSString *middleLabelText;
@property (strong, nonatomic) NSString *leftTextFieldText;

@property (strong, nonatomic) UILabel *middleLabelView;
@property (strong, nonatomic) UITextField *leftTextFieldView;
@property (strong, nonatomic) UIButton *middleButtonView;

@property (assign) BOOL isnotsecureEntry;
@property (assign) BOOL isMiddleLabelHidden;
@property (assign) BOOL isLeftTextFieldHidden;
@property (assign) BOOL isMiddleButtonHidden;
@property (assign) BOOL isBindemail;
-(void)setMiddleLabelHidden:(BOOL)hidden;
-(void)setLeftLabelHidden:(BOOL)hidden;
-(void)setMiddleButtonHidden:(BOOL)hidden;
-(void)settextinputSecurty:(BOOL)secureEntry;
@end
