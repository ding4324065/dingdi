

#import "P2PVideoFormatSettingCell.h"
#import "Constants.h"
#import "RadioButton.h"
@implementation P2PVideoFormatSettingCell
-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
    [self.rightLabelText release];
    [self.rightLabelView release];
    [self.progressView release];
    [self.radio1 release];
    [self.radio2 release];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#define LEFT_LABEL_WIDTH 150
#define PROGRESS_WIDTH_HEIGHT 32
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth2 = self.contentView.frame.size.width;
    CGFloat cellHeight2 = self.contentView.frame.size.height;
    
    if(!self.leftLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftLabelText;
        [self.contentView addSubview:textLabel];
        self.leftLabelView = textLabel;
        [textLabel release];
        [self.leftLabelView setHidden:self.isLeftLabelHidden];
    }else{
        self.leftLabelView.text = self.leftLabelText;
        [self.leftLabelView setHidden:self.isLeftLabelHidden];
    }
    
    if(!self.rightLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30+LEFT_LABEL_WIDTH, 0, cellWidth2-30*2-LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.textColor = [UIColor grayColor];
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        textLabel.text = self.rightLabelText;
        [self.contentView addSubview:textLabel];
        self.rightLabelView = textLabel;
        [textLabel release];
        [self.rightLabelView setHidden:self.isRightLabelHidden];
    }else{
        self.rightLabelView.text = self.rightLabelText;
        [self.rightLabelView setHidden:self.isRightLabelHidden];
    }
    
    if(!self.progressView){
        UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        progressView.frame = CGRectMake(cellWidth2-30-PROGRESS_WIDTH_HEIGHT, (cellHeight2-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
        [self.contentView addSubview:progressView];
        [progressView startAnimating];
        self.progressView = progressView;
        [progressView release];
        [self.progressView setHidden:self.isProgressViewHidden];
    }else{
        [self.progressView startAnimating];
        [self.progressView setHidden:self.isProgressViewHidden];
    }
    
    if(self.selectedIndex==0){
        [self.radio1 setSelected:YES];
        [self.radio2 setSelected:NO];
    }else if(self.selectedIndex==1){
        [self.radio1 setSelected:NO];
        [self.radio2 setSelected:YES];
    }
}

-(void)setProgressViewHidden:(BOOL)hidden{
    self.isProgressViewHidden = hidden;
    if(self.progressView){
        [self.progressView setHidden:hidden];
    }
}

-(void)setLeftLabelHidden:(BOOL)hidden{
    self.isLeftLabelHidden = hidden;
    if(self.leftLabelView){
        [self.leftLabelView setHidden:hidden];
    }
}

-(void)setRightLabelHidden:(BOOL)hidden{
    self.isRightLabelHidden = hidden;
    if(self.rightLabelView){
        [self.rightLabelView setHidden:hidden];
    }
}

@end
