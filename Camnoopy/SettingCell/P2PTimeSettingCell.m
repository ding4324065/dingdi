

#import "P2PTimeSettingCell.h"
#import "Constants.h"
#import "MyPickerView.h"
#import "MyPickTitleView.h"

@implementation P2PTimeSettingCell
-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
    [self.rightLabelText release];
    [self.rightLabelView release];
    [self.middleLabelView release];
    [self.middleLabelText release];
    [self.customView release];
    [self.progressView release];
    //[self.titleView release];
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

#define LEFT_LABEL_WIDTH 100
#define MIDDLE_LABEL_WIDTH 180
#define PROGRESS_WIDTH_HEIGHT 32
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.contentView.frame.size.width;
    CGFloat cellHeight = self.backgroundView.frame.size.height;
    
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
        self.leftLabelView.frame = CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        self.leftLabelView.textAlignment = NSTextAlignmentLeft;
        self.leftLabelView.textColor = XBlack;
        self.leftLabelView.backgroundColor = XBGAlpha;
        [self.leftLabelView setFont:XFontBold_16];
        self.leftLabelView.text = self.leftLabelText;
        [self.contentView addSubview:self.leftLabelView];
        [self.leftLabelView setHidden:self.isLeftLabelHidden];
    }
    
    
    if(!self.rightLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30+LEFT_LABEL_WIDTH, 0, cellWidth-30*2-LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.textColor = XBlue;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        textLabel.text = self.rightLabelText;
        [self.contentView addSubview:textLabel];
        self.rightLabelView = textLabel;
        [textLabel release];
        [self.rightLabelView setHidden:self.isRightLabelHidden];
    }else{
        self.rightLabelView.frame = CGRectMake(30+LEFT_LABEL_WIDTH, 0, cellWidth-30*2-LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        self.rightLabelView.textAlignment = NSTextAlignmentRight;
        self.rightLabelView.textColor = XBlue;
        self.rightLabelView.backgroundColor = XBGAlpha;
        [self.rightLabelView setFont:XFontBold_14];
        self.rightLabelView.text = self.rightLabelText;
        [self.contentView addSubview:self.rightLabelView];
        [self.rightLabelView setHidden:self.isRightLabelHidden];
    }
    
    if(!self.middleLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((cellWidth-MIDDLE_LABEL_WIDTH)/2, 0, MIDDLE_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = XBlue;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.middleLabelText;
        [self.contentView addSubview:textLabel];
        self.rightLabelView = textLabel;
        [textLabel release];
        [self.middleLabelView setHidden:self.isMiddleLabelHidden];
    }else{
        self.middleLabelView.frame = CGRectMake((cellWidth-MIDDLE_LABEL_WIDTH)/2, 0, MIDDLE_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        self.middleLabelView.textAlignment = NSTextAlignmentCenter;
        self.middleLabelView.textColor = XBlue;
        self.middleLabelView.backgroundColor = XBGAlpha;
        [self.middleLabelView setFont:XFontBold_16];
        self.middleLabelView.text = self.middleLabelText;
        [self.contentView addSubview:self.middleLabelView];
        [self.middleLabelView setHidden:self.isMiddleLabelHidden];
    }
    
//    if(!self.titleView){
//        
//        MyPickTitleView *picker = [[MyPickTitleView alloc] initWithFrame:CGRectMake(0,5, cellWidth, (cellHeight1-5*2)*1/6)];
//        
//        self.titleView = picker;
//        [picker release];
//        [self.contentView addSubview:self.titleView];
//        
//        [self.titleView setHidden:self.isTitleViewHidden];
//    }else{
//        
//        [self.titleView setFrame:CGRectMake(0,5, cellWidth, (cellHeight1-5*2)*1/6)];
//        
//        [self.contentView addSubview:self.titleView];
//        
//        [self.titleView setHidden:self.isTitleViewHidden];
//        
//    }

#if 0
    if(!self.customView){
        
        //MyPickerView *picker = [[MyPickerView alloc] initWithFrame:CGRectMake(0,self.titleView.frame.size.height, cellWidth, (cellHeight1-5*2)*5/6)];
        MytestPickerView * picker = [[MytestPickerView alloc] initWithFrame:CGRectMake(0,50, cellWidth, (cellHeight1-5*2)*5/6)];
        //GQCycleViewController * testpick = [[GQCycleViewController alloc] init];
        //self.customView = testpick.view;
        self.customView = picker;
        [picker release];
        [self.contentView addSubview:self.customView];
        //[testpick.view release];
        [self.customView setHidden:self.isCustomViewHidden];
    }else{
        //GQCycleViewController * testpick = [[GQCycleViewController alloc] init];
        [self.customView setFrame:CGRectMake(0,50, cellWidth, (cellHeight1-5*2)*5/6)];
        //self.customView = testpick.view;
        [self.contentView addSubview:self.customView];
        
        [self.customView setHidden:self.isCustomViewHidden];
        
    }
#endif
    if(!self.progressView){
        UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        progressView.frame = CGRectMake(cellWidth-30-PROGRESS_WIDTH_HEIGHT, (cellHeight-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
        [self.contentView addSubview:progressView];
        [progressView startAnimating];
        self.progressView = progressView;
        [progressView release];
        [self.progressView setHidden:self.isProgressViewHidden];
    }else{
        self.progressView.frame = CGRectMake(cellWidth-30-PROGRESS_WIDTH_HEIGHT, (cellHeight-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
        [self.contentView addSubview:self.progressView];
        [self.progressView startAnimating];
        [self.progressView setHidden:self.isProgressViewHidden];
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

-(void)setMiddleLabelHidden:(BOOL)hidden{
    self.isMiddleLabelHidden = hidden;
    if(self.middleLabelView){
        [self.middleLabelView setHidden:hidden];
    }
}

-(void)setCustomViewHidden:(BOOL)hidden{
    self.isCustomViewHidden = hidden;
    if(self.customView){
        [self.customView setHidden:hidden];
    }
}

-(void)setTitleViewHidden:(BOOL)hidden{
    self.isTitleViewHidden = hidden;
//    if (self.titleView) {
//        [self.titleView setHidden:hidden];
//    }
}
@end
