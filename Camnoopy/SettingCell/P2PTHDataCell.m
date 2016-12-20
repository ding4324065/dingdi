//
//  P2PTHDataCell.m
//  Camnoopy
//
//  Created by Lio on 15/7/7.
//  Copyright © 2015年 guojunyi. All rights reserved.
//

#import "P2PTHDataCell.h"
#import "Constants.h"
#import "P2PClient.h"

@implementation P2PTHDataCell

//- (void)dealloc
//{
//    [self.leftTextFieldView release];
//    
//    
//    [super dealloc];
//}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}




-(void)layoutSubviews
{
    CGFloat cellWidth = self.contentView.frame.size.width;
    CGFloat cellHeight = self.contentView.frame.size.height;
    
    if(!self.leftLableView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, cellHeight/4, cellWidth-30*2, cellHeight/2)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftLableText;
        [self.contentView addSubview:textLabel];
        self.leftLableView = textLabel;
        [textLabel release];
        
    }
    else
    {
        self.leftLableView.frame = CGRectMake(30, cellHeight/4, cellWidth-30*2, cellHeight/2);
        self.leftLableView.textAlignment = NSTextAlignmentLeft;
        self.leftLableView.textColor = XBlack;
        self.leftLableView.backgroundColor = XBGAlpha;
        [self.leftLableView setFont:XFontBold_16];
        self.leftLableView.text = self.leftLableText;
        [self.contentView addSubview:self.leftLableView];
    }
    
    
    if(!self.rightLableView)
    {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 30*2, cellHeight/4, cellWidth-30*2, cellHeight/2)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        textLabel.text = self.rightLableText;
        [self.contentView addSubview:textLabel];
        self.rightLableView = textLabel;
        [textLabel release];
        
    }
    else
    {
        self.rightLableView.frame = CGRectMake(cellWidth - 30*2, cellHeight/4, cellWidth-30*2, cellHeight/2);
        self.rightLableView.textAlignment = NSTextAlignmentLeft;
        self.rightLableView.textColor = XBlack;
        self.rightLableView.backgroundColor = XBGAlpha;
        [self.rightLableView setFont:XFontBold_14];
        self.rightLableView.text = self.rightLableText;
        [self.contentView addSubview:self.rightLableView];
    }
    
//    if (!self.leftTextFieldView)
//    {
//        CGFloat textFieldWidth = 50;
//        CGFloat textFieldHeight = cellHeight;
//        UITextField *textField = [[UITextField alloc]init];
//        textField.frame = CGRectMake(cellWidth - textFieldWidth - 30, 0, textFieldWidth, textFieldHeight);
//        textField.backgroundColor = XGray;
//        textField.borderStyle = UITextBorderStyleNone;
//        textField.returnKeyType = UIReturnKeyDone;
//        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        [textField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
//        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        [self.contentView addSubview:textField];
//        self.leftTextFieldView = textField;
//        [textField release];
//    }
    
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}


//- (void)textFieldDidChange:(UITextField *)textField
//{
//    if (textField == self.leftTextFieldView) {
//        if (textField.text.length > 64) {
//            textField.text = [textField.text substringToIndex:64];
//        }
//    }
//}
//
//-(void)setLeftLabelHidden:(BOOL)hidden{
//    self.isLeftTextFieldHidden = hidden;
//    if(self.leftTextFieldView){
//        [self.leftTextFieldView setHidden:hidden];
//    }
//}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
