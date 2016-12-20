//
//  P2PSecurityCell.m
//  2cu
//
//  Created by Jie on 15/1/5.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "P2PSecurityCell.h"
#import "Constants.h"

@implementation P2PSecurityCell

-(void)dealloc{
    [self.middleLabelText release];
    [self.middleLabelView release];
    [self.leftTextFieldText release];
    [self.leftTextFieldView release];
    [self.middleButtonView release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#define LEFT_LABEL_WIDTH 150
#define PROGRESS_WIDTH_HEIGHT 32
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.contentView.frame.size.width;
    CGFloat cellHeight = self.contentView.frame.size.height;
    
    if(!self.middleLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((cellWidth-LEFT_LABEL_WIDTH)/2, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_18];
        [self.contentView addSubview:textLabel];
        self.middleLabelView = textLabel;
        [textLabel release];
    }
    self.middleLabelView.text = self.middleLabelText;
    [self.middleLabelView setHidden:self.isMiddleLabelHidden];
    
    if (!self.leftTextFieldView) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, cellWidth-40, cellHeight)];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = XBlack;
        textField.font = XFontBold_16;
        textField.borderStyle = UITextBorderStyleNone;
        textField.returnKeyType = UIReturnKeyDone;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [textField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:textField];
        self.leftTextFieldView = textField;
        [textField release];
    }
    self.leftTextFieldView.placeholder = self.leftTextFieldText;
    if (self.isnotsecureEntry) {
        self.leftTextFieldView.secureTextEntry = NO;
    }else{
        self.leftTextFieldView.secureTextEntry = YES;
    }
    
    if (!self.middleButtonView) {
        UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake((cellWidth-200)/2, (cellHeight-40)/2, 200, 40)];
        [saveButton setTitle:NSLocalizedString(@"apply", nil) forState:UIControlStateNormal];
        UIImage *saveButtonBackImg = [UIImage imageNamed:@"new_button.png"];
        saveButtonBackImg = [saveButtonBackImg stretchableImageWithLeftCapWidth:saveButtonBackImg.size.width*0.5 topCapHeight:saveButtonBackImg.size.height*0.5];
        
        UIImage *saveButtonBackImg_p = [UIImage imageNamed:@"new_button3.png"];
        saveButtonBackImg_p = [saveButtonBackImg_p stretchableImageWithLeftCapWidth:saveButtonBackImg_p.size.width*0.5 topCapHeight:saveButtonBackImg_p.size.height*0.5];
        
        [saveButton setBackgroundImage:saveButtonBackImg forState:UIControlStateNormal];
        [saveButton setBackgroundImage:saveButtonBackImg_p forState:UIControlStateHighlighted];
        [self.contentView addSubview:saveButton];
        self.middleButtonView = saveButton;
        [saveButton release];
    }
    [self.middleButtonView setHidden:self.isMiddleButtonHidden];
    [self.middleButtonView addTarget:self action:@selector(modifyPress:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)modifyPress:(id)sender{
    DLog(@"modify successfully");
    if (self.delegate) {
        [self.delegate savePress:self.section row:self.row];
    }
}


-(void)setMiddleLabelHidden:(BOOL)hidden{
    self.isMiddleLabelHidden = hidden;
    if(self.middleLabelView){
        [self.middleLabelView setHidden:hidden];
    }
}
-(void)settextinputSecurty:(BOOL)secureEntry{
    if (self.leftTextFieldView) {
        self.leftTextFieldView.secureTextEntry = secureEntry;
    }
}
-(void)setLeftLabelHidden:(BOOL)hidden{
    self.isLeftTextFieldHidden = hidden;
    if(self.leftTextFieldView){
        [self.leftTextFieldView setHidden:hidden];
    }
}

-(void)setMiddleButtonHidden:(BOOL)hidden{
    self.isMiddleButtonHidden = hidden;
    if(self.middleButtonView){
        [self.middleButtonView setHidden:hidden];
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.leftTextFieldView) {
        if (textField.text.length > 64) {
            textField.text = [textField.text substringToIndex:64];
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (!self.isBindemail) {
        return [self validateNumber:string];
    }
    return YES;
}


- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}
-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}




@end
