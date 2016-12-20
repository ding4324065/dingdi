

#import "AlarmHistoryCell.h"
#import "Constants.h"
#import "Utils.h"

@implementation AlarmHistoryCell

-(void)dealloc{
    [self.typeLabel release];
    [self.typeLabelText release];
    [self.deviceLabel release];
    [self.deviceLabelText release];
    [self.timeLabel release];
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

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#define LABEL_WIDTH 185
#define TYPE_LABEL_WIDTH 220
#define LABEL_HEIGHT 25
#define TIME_LABEL_WIDTH 150
#define TEXT_LABERL_WIDTH 150

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.backgroundView.frame.size.width;
//    CGFloat height = self.backgroundView.frame.size.height;
    
    
    if (!self.deviceLabel) {
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 3, LABEL_WIDTH, LABEL_HEIGHT)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_device", nil),self.deviceId];
        
        
        [self.contentView addSubview:textLabel];
        self.deviceLabel = textLabel;
        [textLabel release];
    }
    else
    {
        self.deviceLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_device", nil),self.deviceId];
    }
    
    if (!self.typeLabel) {
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 3+LABEL_HEIGHT+10, TYPE_LABEL_WIDTH, LABEL_HEIGHT)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),[Utils getAlarmtextByType:self.alarmType]];
        
        [self.contentView addSubview:textLabel];
        self.typeLabel = textLabel;
        [textLabel release];
    }
    else
    {
        self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),[Utils getAlarmtextByType:self.alarmType]];
    }
  

    if (!self.timeLabel) {
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(width - LABEL_WIDTH, 3, TIME_LABEL_WIDTH + 30, LABEL_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.alarmTime;
        
        [self.contentView addSubview:textLabel];
        self.timeLabel = textLabel;
        [textLabel release];
    }else{
        self.timeLabel.text = self.alarmTime;
    }
}

@end
