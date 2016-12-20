

#import "P2PWifiCell.h"
#import "Constants.h"
@implementation P2PWifiCell
-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
    [self.leftStatelabelText release];
    [self.leftStatelabelView release];
    [self.rightIconView release];
    [self.rightIcon release];
    [self.rightIconView2 release];
    [self.rightIcon2 release];
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

#define LEFT_LABEL_WIDTH 200

-(void)layoutSubviews{
    [super layoutSubviews];
    //CGFloat cellWidth = self.backgroundView.frame.size.width;
    CGFloat cellWidth = self.contentView.frame.size.width;
//    CGFloat cellHeight = self.backgroundView.frame.size.height;
    
    CGFloat leftlabelheight = ((BAR_BUTTON_HEIGHT/3)*2);
    CGFloat leftstatelabelheight = BAR_BUTTON_HEIGHT/3;
    
    if(!self.leftLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LEFT_LABEL_WIDTH, leftlabelheight)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlue;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        textLabel.text = self.leftLabelText;
        [self.contentView addSubview:textLabel];
        self.leftLabelView = textLabel;
        [textLabel release];
        
        
    }else{
        self.leftLabelView.frame = CGRectMake(30, 0, LEFT_LABEL_WIDTH, leftlabelheight);
        self.leftLabelView.textAlignment = NSTextAlignmentLeft;
        self.leftLabelView.textColor = XBlue;
        self.leftLabelView.backgroundColor = XBGAlpha;
        [self.leftLabelView setFont:XFontBold_14];
        self.leftLabelView.text = self.leftLabelText;
        [self.contentView addSubview:self.leftLabelView];

    }
    
    if(!self.leftStatelabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, leftlabelheight, LEFT_LABEL_WIDTH, leftstatelabelheight)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = [UIColor grayColor];
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftStatelabelText;
        [self.contentView addSubview:textLabel];
        self.leftStatelabelView = textLabel;
        [textLabel release];
        
        
    }else{
        self.leftStatelabelView.frame = CGRectMake(30, leftlabelheight, LEFT_LABEL_WIDTH, leftstatelabelheight);
        self.leftStatelabelView.textAlignment = NSTextAlignmentLeft;
        self.leftStatelabelView.textColor = [UIColor grayColor];
        self.leftStatelabelView.backgroundColor = XBGAlpha;
        [self.leftStatelabelView setFont:XFontBold_16];
        self.leftStatelabelView.text = self.leftStatelabelText;
        [self.contentView addSubview:self.leftStatelabelView];
        
    }
    
    if(!self.rightIconView){
        UIImageView *rightIconView = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)];
        rightIconView.contentMode = UIViewContentModeScaleAspectFit;
        rightIconView.image = [UIImage imageNamed:self.rightIcon];
        [self.contentView addSubview:rightIconView];
        self.rightIconView = rightIconView;
        [rightIconView release];
            }else{
        self.rightIconView.frame = CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT);
        
        self.rightIconView.image = [UIImage imageNamed:self.rightIcon];
        
        [self.contentView addSubview:self.rightIconView];
    }
    
    if(!self.rightIconView2){
        UIImageView *rightIconView = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-60-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)];
        rightIconView.contentMode = UIViewContentModeScaleAspectFit;
        rightIconView.image = [UIImage imageNamed:self.rightIcon2];
        [self.contentView addSubview:rightIconView];
        self.rightIconView2 = rightIconView;
        [rightIconView release];
    }else{
        self.rightIconView2.frame = CGRectMake(cellWidth-60-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT);
        
        self.rightIconView2.image = [UIImage imageNamed:self.rightIcon2];
        
        [self.contentView addSubview:self.rightIconView2];
    }

}
@end
