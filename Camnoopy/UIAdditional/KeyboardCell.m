

#import "KeyboardCell.h"
#import "Constants.h"
@implementation KeyboardCell

-(void)dealloc{
    [self.leftLabel release];
    [self.leftText release];
    [self.rightLabel release];
    [self.rightText release];
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

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.backgroundView.frame.size.width;
    CGFloat height = self.backgroundView.frame.size.height;
    
    if(!self.leftLabel){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,(width-20)/2,height)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XWhite;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftText;
        [self.contentView addSubview:textLabel];
        self.leftLabel = textLabel;
        [textLabel release];
    }else{
        self.leftLabel.text = self.leftText;
        [self.contentView addSubview:self.leftLabel];
    }
    
    if(!self.rightLabel){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(width-20)/2,0,(width-20)/2,height)];
        
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.textColor = XWhite;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.rightText;
        [self.contentView addSubview:textLabel];
        self.rightLabel = textLabel;
        [textLabel release];
    }else{
        self.rightLabel.text = self.rightText;
        [self.contentView addSubview:self.rightLabel];
    }
}
@end
