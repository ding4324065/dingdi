

#import "BottomBar.h"
#import "Constants.h"
@implementation BottomBar

-(void)dealloc{
    [self.items release];
    [self.backViews release];
    [self.iconViews release];
    [super dealloc];
}

#define ITEM_COUNT 4
#define ICON_MARGIN 6
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.items = [NSMutableArray arrayWithCapacity:0];
        self.iconViews = [NSMutableArray arrayWithCapacity:0];
        self.backViews = [NSMutableArray arrayWithCapacity:0];
        self.selectedIndex = 0;
        CGFloat itemWidth = frame.size.width/ITEM_COUNT;

        for(int i=0;i<ITEM_COUNT;i++){
            
            UIButton *item = [[UIButton alloc] init];
            item.frame = CGRectMake(itemWidth*i, 0, itemWidth, frame.size.height);
            
            UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, item.frame.size.width, item.frame.size.height)];
            UIImage *backImg = [UIImage imageNamed:@"bg_tab_item.png"];
            backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
            backView.image = backImg;
            [item addSubview:backView];
            
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((backView.frame.size.width-backView.frame.size.height+ICON_MARGIN*2)/2, ICON_MARGIN, backView.frame.size.height-ICON_MARGIN*2, backView.frame.size.height-ICON_MARGIN*2)];
            UIImage *iconImg = nil;
            switch(i){
                case 0:
                {
                    iconImg = [UIImage imageNamed:@"ic_tab_item_contact_p.png"];
                }
                    break;
                case 1:
                {
                    iconImg = [UIImage imageNamed:@"ic_tab_item_keyboard.png"];
                }
                    break;
                case 2:
                {
                    iconImg = [UIImage imageNamed:@"ic_tab_toolbox.png"];
                }
                    break;
                case 3:
                {
                    iconImg = [UIImage imageNamed:@"ic_tab_item_setting.png"];
                }
                    break;
//                case 4:
//                {
//                    iconImg = [UIImage imageNamed:@"ic_tab_item_setting.png"];
//                }
//                    break;
            }
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            iconView.image = iconImg;
            [backView addSubview:iconView];
            [self.iconViews addObject:iconView];
            [self.backViews addObject:backView];
            [iconView release];
            [backView release];
            
            [self addSubview:item];
            [self.items addObject:item];
            [item release];
        }
        
        
    }
    return self;
}


-(void)updateItemIcon:(NSInteger)willSelectedIndex{
    
    UIImageView *backView = [self.backViews objectAtIndex:self.selectedIndex];
    UIImageView *iconView = [self.iconViews objectAtIndex:self.selectedIndex];
    
    UIImageView *willBackView = [self.backViews objectAtIndex:willSelectedIndex];
    UIImageView *willIconView = [self.iconViews objectAtIndex:willSelectedIndex];
    
    UIImage *backImg = [UIImage imageNamed:@"bg_tab_item.png"];
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backView.image = backImg;
    [backView setImage:backImg];
    
    UIImage *willBackImg = [UIImage imageNamed:@"bg_tab_item_p.png"];
    willBackImg = [willBackImg stretchableImageWithLeftCapWidth:willBackImg.size.width*0.5 topCapHeight:willBackImg.size.height*0.5];
    willBackView.image = willBackImg;
    [willBackView setImage:willBackImg];
    
    switch(self.selectedIndex){
        case 0:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_contact.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [iconView setImage:iconImg];
        }
            break;
        case 1:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_keyboard.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [iconView setImage:iconImg];
        }
            break;
        case 2:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_toolbox.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [iconView setImage:iconImg];
        }
            break;
        case 3:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_setting.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [iconView setImage:iconImg];
        }
            break;
//        case 4:
//        {
//            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_setting.png"];
//            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
//            [iconView setImage:iconImg];
//        }
//            break;
    }
    
    switch(willSelectedIndex){
        case 0:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_contact_p.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [willIconView setImage:iconImg];
        }
            break;
        case 1:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_keyboard_p.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [willIconView setImage:iconImg];
        }
            break;
        case 2:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_toolbox_p.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [willIconView setImage:iconImg];
        }
            break;
        case 3:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_setting_p.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [willIconView setImage:iconImg];
        }
            break;
//        case 4:
//        {
//            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_setting_p.png"];
//            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
//            [willIconView setImage:iconImg];
//        }
//            break;
    }
    
    self.selectedIndex = willSelectedIndex;
}
@end
