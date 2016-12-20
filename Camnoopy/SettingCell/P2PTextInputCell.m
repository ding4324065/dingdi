//
//  P2PTextInputCell.m
//  Camnoopy
//
//  Created by 高琦 on 15/1/29.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "P2PTextInputCell.h"
#import "Constants.h"

@implementation P2PTextInputCell
-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
    [self.rightTextFieldText release];
    [self.rightTextFieldView release];
    
    [super dealloc];
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define LEFT_LABEL_WIDTH 120
#define PROGRESS_WIDTH_HEIGHT 32

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.contentView.frame.size.width;
    
    
    
    if(!self.leftLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftLabelText;
        [self.contentView addSubview:textLabel];
        self.leftLabelView = textLabel;
        [textLabel release];
    }else{
        self.leftLabelView.frame = CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        self.leftLabelView.backgroundColor = [UIColor clearColor];
        self.leftLabelView.textAlignment = NSTextAlignmentLeft;
        self.leftLabelView.textColor = XBlack;
        //self.leftLabelView.backgroundColor = XBGAlpha;
        [self.leftLabelView setFont:XFontBold_16];
        self.leftLabelView.text = self.leftLabelText;
        [self.contentView addSubview:self.leftLabelView];
    }
    
    if (!self.rightTextFieldView) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(30+LEFT_LABEL_WIDTH, 0, cellWidth-LEFT_LABEL_WIDTH-30-10, BAR_BUTTON_HEIGHT)];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.placeholder = self.rightTextFieldText;
        textField.textColor = XBlack;
        textField.secureTextEntry = NO;
        textField.borderStyle = UITextBorderStyleNone;
        textField.returnKeyType = UIReturnKeyDone;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //textField.delegate = self;
        [textField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:textField];
        self.rightTextFieldView = textField;
        [textField release];
    }else{
        self.rightTextFieldView.frame = CGRectMake(30+LEFT_LABEL_WIDTH, 0, cellWidth-LEFT_LABEL_WIDTH-30-10, BAR_BUTTON_HEIGHT);
        self.rightTextFieldView.textAlignment = NSTextAlignmentRight;
        self.rightTextFieldView.placeholder = self.rightTextFieldText;
        self.rightTextFieldView.textColor = XBlack;
        self.rightTextFieldView.secureTextEntry = NO;
        self.rightTextFieldView.borderStyle = UITextBorderStyleNone;
        self.rightTextFieldView.returnKeyType = UIReturnKeyDone;
        self.rightTextFieldView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.rightTextFieldView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.rightTextFieldView.delegate = self;
        [self.rightTextFieldView addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [self.rightTextFieldView addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:self.rightTextFieldView];
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.rightTextFieldView) {
        if (textField.text.length > 32) {
            textField.text = [textField.text substringToIndex:32];
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return [self validateNumber:string];
}


- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
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
