

#import "P2PPlanTimeSettingCell.h"
#import "Constants.h"
#import "PlanTimePickView.h"
@implementation P2PPlanTimeSettingCell
-(void)dealloc{
    [self.picker1 release];
    [self.picker2 release];
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
    CGFloat cellWidth = self.contentView.frame.size.width;
    CGFloat cellHeight = self.contentView.frame.size.height;
    
    
    if(!self.picker1){
       
        PlanTimePickView *picker1 = [[PlanTimePickView alloc] initWithFrame:CGRectMake(30,5, (cellWidth-30*3)/2, cellHeight-5*2)];
        self.picker1 = picker1;
        [picker1 release];
        [self.contentView addSubview:self.picker1];
        
        
    }else{
        
        [self.picker1 setFrame:CGRectMake(30,5, (cellWidth-30*3)/2, cellHeight-5*2)];
        [self.contentView addSubview:self.picker1];
    }
    
    if(!self.picker2){
        
        PlanTimePickView *picker2 = [[PlanTimePickView alloc] initWithFrame:CGRectMake(30+(cellWidth-30*3)/2+30,5, (cellWidth-30*3)/2, cellHeight-5*2)];
        self.picker2 = picker2;
        [picker2 release];
        [self.contentView addSubview:self.picker2];
        
        
    }else{
        
       
        [self.picker2 setFrame:CGRectMake(30+(cellWidth-30*3)/2+30,5, (cellWidth-30*3)/2, cellHeight-5*2)];
        [self.contentView addSubview:self.picker2];
    }
    
}
@end
