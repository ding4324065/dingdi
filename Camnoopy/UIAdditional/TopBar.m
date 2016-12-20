

#import "TopBar.h"
#import "Constants.h"
@implementation TopBar

-(void)dealloc{
    [self.titleLabel release];
    [self.backButton release];
    [self.rightButton release];
    [self.rightButtonIconView release];
    [self.rightButtonLabel release];
    [super dealloc];
}

#define LEFT_BAR_BTN_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 90:60)
#define LEFT_BAR_BTN_MARGIN (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10:5)

#define RIGHT_BAR_BTN_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 90:60)
#define RIGHT_BAR_BTN_MARGIN (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10:5)
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backImgView = [[UIImageView alloc] initWithFrame:frame];
        UIImage *backImg = [UIImage imageNamed:@"title_bar.png"];
        backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
        backImgView.image = backImg;
        
        [self addSubview:backImgView];
        
        if(CURRENT_VERSION>=7.0){
            frame = CGRectMake(frame.origin.x, frame.origin.y+20, frame.size.width, frame.size.height-20);
        }
        UILabel *textLabel = [[UILabel alloc] initWithFrame:frame];
        textLabel.textAlignment = NSTextAlignmentCenter;
        //textLabel.textColor = XHeadBarTextColor;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:[UIFont boldSystemFontOfSize:XHeadBarTextSize]];
        [backImgView addSubview:textLabel];
        
        //backbutton
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(frame.origin.x+LEFT_BAR_BTN_MARGIN, frame.origin.y+LEFT_BAR_BTN_MARGIN, LEFT_BAR_BTN_WIDTH-10, frame.size.height-LEFT_BAR_BTN_MARGIN*2-10);
        
        /*返回按钮背景
        UIImage *backButtonImg = [UIImage imageNamed:@"bg_bar_btn.png"];
        backButtonImg = [backButtonImg stretchableImageWithLeftCapWidth:backButtonImg.size.width*0.5 topCapHeight:backButtonImg.size.height*0.5];
        
        UIImage *backButtonImg_p = [UIImage imageNamed:@"bg_bar_btn_p.png"];
        backButtonImg_p = [backButtonImg_p stretchableImageWithLeftCapWidth:backButtonImg_p.size.width*0.5 topCapHeight:backButtonImg_p.size.height*0.5];
        
        [backButton setBackgroundImage:backButtonImg forState:UIControlStateNormal];
        [backButton setBackgroundImage:backButtonImg_p forState:UIControlStateHighlighted];
        */
        
        UIImageView *backBtnIconView = [[UIImageView alloc]initWithFrame:CGRectMake((backButton.frame.size.width-backButton.frame.size.height)/2, 3, backButton.frame.size.height, backButton.frame.size.height)];
        backBtnIconView.image = [UIImage imageNamed:@"add_back.png"];
        [backButton addSubview:backBtnIconView];
        [backBtnIconView release];
        [backButton setHidden:YES];
        [self addSubview:backButton];
        
        //leftButton
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(frame.origin.x+LEFT_BAR_BTN_MARGIN, frame.origin.y+LEFT_BAR_BTN_MARGIN, LEFT_BAR_BTN_WIDTH, frame.size.height-LEFT_BAR_BTN_MARGIN*2);
        
        UIImageView *leftButtonIconView = [[UIImageView alloc]initWithFrame:CGRectMake((leftButton.frame.size.width-leftButton.frame.size.height)/2, LEFT_BAR_BTN_MARGIN, leftButton.frame.size.height-10, leftButton.frame.size.height-10)];
        leftButtonIconView.image = [UIImage imageNamed:@""];
        [leftButton addSubview:leftButtonIconView];
        
        self.leftButtonIconView = leftButtonIconView;
        self.leftButtonIconView.contentMode = UIViewContentModeScaleAspectFit;
        [leftButtonIconView release];
        
        [leftButton setHidden:YES];
        [self addSubview:leftButton];
        
        
        //rightbutton
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(frame.origin.x+(frame.size.width-RIGHT_BAR_BTN_MARGIN - RIGHT_BAR_BTN_WIDTH), frame.origin.y+RIGHT_BAR_BTN_MARGIN, RIGHT_BAR_BTN_WIDTH, frame.size.height-RIGHT_BAR_BTN_MARGIN*2);
        
        UIImageView *rightButtonIconView = [[UIImageView alloc]initWithFrame:CGRectMake((rightButton.frame.size.width-rightButton.frame.size.height)/2, 0, rightButton.frame.size.height, rightButton.frame.size.height)];
        rightButtonIconView.image = [UIImage imageNamed:@""];
        [rightButton addSubview:rightButtonIconView];
        
        self.rightButtonIconView = rightButtonIconView;
        [rightButtonIconView release];
        
        UILabel *rightButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rightButton.frame.size.width,rightButton.frame.size.height)];
        rightButtonLabel.textAlignment = NSTextAlignmentCenter;
        rightButtonLabel.textColor = XWhite;
        rightButtonLabel.backgroundColor = XBGAlpha;
        [rightButtonLabel setFont:XFontBold_16];
        
        [rightButton addSubview:rightButtonLabel];
        
        self.rightButtonLabel = rightButtonLabel;
        [rightButtonLabel release];
        
        [rightButton setHidden:YES];
        [self addSubview:rightButton];
        
        
        
        //rightbutton2
        UIButton *rightButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton2.frame = CGRectMake(frame.origin.x+(frame.size.width-RIGHT_BAR_BTN_MARGIN-RIGHT_BAR_BTN_WIDTH-RIGHT_BAR_BTN_WIDTH+10), frame.origin.y+RIGHT_BAR_BTN_MARGIN, RIGHT_BAR_BTN_WIDTH, frame.size.height-RIGHT_BAR_BTN_MARGIN*2);
        
        UIImageView *rightButtonIconView2 = [[UIImageView alloc]initWithFrame:CGRectMake((rightButton2.frame.size.width-rightButton2.frame.size.height)/2, RIGHT_BAR_BTN_MARGIN, rightButton2.frame.size.height-10, rightButton2.frame.size.height-10)];
        rightButtonIconView2.image = [UIImage imageNamed:@""];
        [rightButton2 addSubview:rightButtonIconView2];
        
        self.rightButtonIconView2 = rightButtonIconView2;
        self.rightButtonIconView2.contentMode = UIViewContentModeScaleAspectFit;
        [rightButtonIconView2 release];
        
        UILabel *rightButtonLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,rightButton2.frame.size.width,rightButton2.frame.size.height)];
        rightButtonLabel2.textAlignment = NSTextAlignmentCenter;
        rightButtonLabel2.textColor = XWhite;
        rightButtonLabel2.backgroundColor = XBGAlpha;
        [rightButtonLabel2 setFont:XFontBold_14];
        
        [rightButton2 addSubview:rightButtonLabel2];
        
        self.rightButtonLabel2 = rightButtonLabel2;
        [rightButtonLabel2 release];
        
        [rightButton2 setHidden:YES];
        [self addSubview:rightButton2];
        
        
        self.backButton = backButton;
        self.rightButton = rightButton;
        self.titleLabel = textLabel;
        self.rightButton2 = rightButton2;
        self.leftButton = leftButton;
        
        [textLabel release];
        [backImgView release];
    }
    return self;
}


-(void)setTitle:(NSString *)title{
    
    if(self.titleLabel){
        self.titleLabel.text = title;
    }
}

-(void)setBackButtonHidden:(BOOL)hidden{
    if(self.backButton){
        [self.backButton setHidden:hidden];
    }
}

-(void)setLeftButtonHidden:(BOOL)hidden{
    if (self.leftButton) {
        [self.leftButton setHidden:hidden];
    }
}

-(void)setRightButtonHidden:(BOOL)hidden{
    if(self.rightButton){
        [self.rightButton setHidden:hidden];
    }
}

-(void)setRightButtonHidden2:(BOOL)hidden{
    if (self.rightButton2) {
        [self.rightButton2 setHidden:hidden];
    }
}

-(void)setLeftButtonIcon:(UIImage *)img{
    if (self.leftButtonIconView) {
        self.leftButtonIconView.image = img;
    }
}

-(void)setRightButtonIcon:(UIImage *)img{
    if(self.rightButtonIconView){
        self.rightButtonIconView.image = img;
    }
}

-(void)setRightButtonIcon2:(UIImage *)img{
    if (self.rightButtonIconView2) {
        self.rightButtonIconView2.image = img;
    }
}

-(void)setRightButtonText:(NSString *)text{
    if(self.rightButtonLabel){
        self.rightButtonLabel.text = text;
    }
}
@end
