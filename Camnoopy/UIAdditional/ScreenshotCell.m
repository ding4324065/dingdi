

#import "ScreenshotCell.h"
#import "Constants.h"

@implementation ScreenshotCell
-(void)dealloc{
    [self.filePath1 release];
    [self.filePath2 release];
    [self.backButton1 release];
    [self.backButton2 release];
    [self.text1 release];
    [self.text2 release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
#define BORDER_WIDTH 5
#define VERTICAL_MARGIN 2
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGFloat horizontalMargin = 10;
    CGFloat itemHeight = height-VERTICAL_MARGIN*2;
    CGFloat itemWidth = itemHeight*16/9;
    if (itemWidth < (width-horizontalMargin*3)/2)
    {
        horizontalMargin = (width - itemWidth*2)/3;
    }
    else
    {
        itemWidth = (width-horizontalMargin*3)/2;
    }
    
    DLog(@"%@",self.filePath1);
    if(!self.backButton1){
        //button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 0;
        button.backgroundColor = XWhite;
        button.frame = CGRectMake(horizontalMargin, VERTICAL_MARGIN, itemWidth, itemHeight);
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        self.backButton1 = button;
        
        //id、日期信息
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, itemHeight-15, itemWidth, 15)];
        label.backgroundColor = XBlack;
        label.textColor = XWhite;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:9.0];
        label.alpha = 0.4;
        label.tag = 101;
        [self.backButton1 addSubview:label];
        [label release];
        
        //选中灰色视图
        UIView* viewMask = [[UIView alloc]initWithFrame:CGRectMake(0, VERTICAL_MARGIN, itemWidth, itemHeight)];
        viewMask.userInteractionEnabled = NO;
        viewMask.exclusiveTouch = NO;
        viewMask.backgroundColor = [UIColor grayColor];
        viewMask.alpha = 0.5;
        viewMask.tag = 102;
        [self.backButton1 addSubview:viewMask];
        [viewMask release];
        
        //红色勾
        UIImageView* viewSelect = [[UIImageView alloc]initWithFrame:CGRectMake(itemWidth-20, 0, 20, 20)];
        viewSelect.userInteractionEnabled = NO;
        viewSelect.exclusiveTouch = NO;
        viewSelect.tag = 103;
        viewSelect.image = [UIImage imageNamed:@"screenshot_selecte"];
        [self.backButton1 addSubview:viewSelect];
        [viewSelect release];
        
        //手势
        UILongPressGestureRecognizer* longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressClick:)];
        [longPressGes setMinimumPressDuration:1.0f];
        [self.backButton1 addGestureRecognizer:longPressGes];
        [longPressGes release];
        
        [self.contentView addSubview:self.backButton1];
    }
    [self.backButton1 setImage:[UIImage imageWithContentsOfFile:self.filePath1] forState:UIControlStateNormal];
    
    UILabel* label1 = (UILabel* )[self.backButton1 viewWithTag:101];
    label1.text = self.text1;
    
    UIView* view2 = (UIView* )[self.backButton1 viewWithTag:102];
    UIImageView* view3 = (UIImageView* )[self.backButton1 viewWithTag:103];
    [view2 setHidden:self.isHiddenMask1];
    [view3 setHidden:self.isHiddenMask1];
    
    
    if(!self.backButton2){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 1;
        button.backgroundColor = XWhite;
        button.frame = CGRectMake(horizontalMargin*2+itemWidth, VERTICAL_MARGIN, itemWidth, itemHeight);
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        self.backButton2 = button;
        
        //id、日期信息
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, itemHeight-15, itemWidth, 15)];
        label.backgroundColor = XBlack;
        label.textColor = XWhite;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:9.0];
        label.alpha = 0.4;
        label.tag = 104;
        [self.backButton2 addSubview:label];
        [label release];
        
        //选中灰色视图
        UIView* viewMask = [[UIView alloc]initWithFrame:CGRectMake(0, VERTICAL_MARGIN, itemWidth, itemHeight)];
        viewMask.userInteractionEnabled = NO;
        viewMask.exclusiveTouch = NO;
        viewMask.backgroundColor = [UIColor grayColor];
        viewMask.alpha = 0.5;
        viewMask.tag = 105;
        [self.backButton2 addSubview:viewMask];
        [viewMask release];
        
        //删除标记视图
        UIImageView* viewSelect = [[UIImageView alloc]initWithFrame:CGRectMake(itemWidth-20, 0, 20, 20)];
        viewSelect.userInteractionEnabled = NO;
        viewSelect.exclusiveTouch = NO;
        viewSelect.image = [UIImage imageNamed:@"screenshot_selecte"];
        viewSelect.tag = 106;
        [self.backButton2 addSubview:viewSelect];
        [viewSelect release];
        
        //手势
        UILongPressGestureRecognizer* longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressClick:)];
        [longPressGes setMinimumPressDuration:1.0f];
        [self.backButton2 addGestureRecognizer:longPressGes];
        [longPressGes release];
        
        [self.contentView addSubview:self.backButton2];
    }
    [self.backButton2 setImage:[UIImage imageWithContentsOfFile:self.filePath2] forState:UIControlStateNormal];
    
    UILabel* label2 = (UILabel* )[self.backButton2 viewWithTag:104];
    label2.text = self.text2;
    
    UIView* view5 = (UIView* )[self.backButton2 viewWithTag:105];
    [view5 setHidden:self.isHiddenMask2];
    
    UIImageView* view6 = (UIImageView* )[self.backButton2 viewWithTag:106];
    [view6 setHidden:self.isHiddenMask2];
    
    if(!self.filePath1||[self.filePath1 isEqualToString:@""]){
        [self.backButton1 setHidden:YES];
    }else{
        [self.backButton1 setHidden:NO];
    }
    
    if(!self.filePath2||[self.filePath2 isEqualToString:@""]){
        [self.backButton2 setHidden:YES];
    }else{
        [self.backButton2 setHidden:NO];
    }
}

-(void)onButtonPress:(UIButton*)button{
    if(self.delegate){
        [self.delegate onItemClick:self row:self.row index:button.tag];
    }
}

-(void)longPressClick:(UILongPressGestureRecognizer* )ges{
    
    switch (ges.state) {
        case UIGestureRecognizerStateEnded:
        {
        }
            break;
        case UIGestureRecognizerStateBegan:
        {
            if(self.delegate){
                [self.delegate onItemLongPress:self row:self.row index:ges.view.tag];
            }
        }
            break;
        default:
            break;
    }
}
@end
