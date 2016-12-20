

#import "ContactCell.h"
#import "Utils.h"
#import "Constants.h"
#import "Contact.h"
#import "P2PClient.h"
#import "FListManager.h"
#import "Toast+UIView.h"
#import "StorageSettingController.h"
@implementation ContactCell

#define kOperatorBtnTag_Chat 23581
#define kOperatorBtnTag_Message 23582
#define kOperatorBtnTag_Modify 23583
#define kOperatorBtnTag_Monitor 23584
#define kOperatorBtnTag_Playback 23585
#define kOperatorBtnTag_UpdateDevice 23588
#define kOperatorBtnTag_Control 23586
#define kOperatorBtnTag_WeakPwd 23587


-(void)dealloc{
    [self.topView release];
    [self.topMaskView release];
    [self.headView release];
    [self.typeView release];
    [self.nameLabel release];
    [self.stateLabel release];
    [self.contact release];
    [self.messageCountView release];
    [self.defenceStateView release];
    [self.settingView release];
    [self.modifyView release];
    [self.stateView release];
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

#define CONTACT_HEADER_VIEW_MARGIN 6
#define CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT 16
#define CONTACT_STATE_LABEL_WIDTH 50
#define MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT 24
#define HEADER_ICON_VIEW_HEIGHT_WIDTH 70
#define DEFENCE_STATE_VIEW_WIDTH_HEIGHT 24
#define CONTACT_TOP_VIEW_HEIGHT 40
#define NAME_LABEL_WIDTH 100
#define NAME_LABEL_HEIGHT 30
-(void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor = XBGAlpha;//将cell的背景设置为透明
    
    CGFloat width = self.backgroundView.frame.size.width;
    CGFloat height = self.backgroundView.frame.size.height;
#pragma mark - 设备工具条
    
//    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.contentView] autorelease];
//    [self.contentView addSubview:self.progressAlert];
    
    if (!self.topView)
    {
        UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, height-CONTACT_TOP_VIEW_HEIGHT, width, CONTACT_TOP_VIEW_HEIGHT)];
        topView.layer.contents = (id)[UIImage imageNamed:@"whrite_bar_background.png"].CGImage;
        [self.contentView addSubview:topView];
        self.topView = topView;
        [topView release];

    }
    
#pragma mark - 设备缩略图
    if(!self.headView)
    {
        UIButton *headButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, width, height-CONTACT_TOP_VIEW_HEIGHT)];
        
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, headButton.frame.size.width, headButton.frame.size.height)];
        headImageView.tag = 101;
        NSString *filePath = [Utils getHeaderFilePathWithId:self.contact.contactId];
        
        UIImage *headImg = [UIImage imageWithContentsOfFile:filePath];
        if(headImg==nil)
        {
            headImg = [UIImage imageNamed:@"ic_header.png"];
        }
        
        headImageView.image = headImg;
        [headButton addSubview:headImageView];
        
        [self.contentView addSubview:headButton];
        headButton.tag = kOperatorBtnTag_Monitor;
        self.headView = headButton;
        [headButton release];
        [headImageView release];
    }
    else
    {
        for (UIView * view in self.headView.subviews)
        {
            if (view.tag==101)
            {
                UIImageView * headimgView = (UIImageView *)view;
                NSString *filePath = [Utils getHeaderFilePathWithId:self.contact.contactId];
                
                UIImage *headImg = [UIImage imageWithContentsOfFile:filePath];
                if(headImg==nil)
                {
                    
                    headImg = [UIImage imageNamed:@"ic_header.png"];
                }
                headimgView.image = headImg;
            }
        }
    }
    
//    if (!self.topMaskView)
//    {
//        
//        UIView * topMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, CONTACT_TOP_VIEW_HEIGHT + 169, width, 10)];
//        topMaskView.layer.contents = (id)[UIImage imageNamed:@"ic_top_view_mask_1.png"].CGImage;
//        [self.contentView addSubview:topMaskView];
//        self.topMaskView = topMaskView;
//        [topMaskView release];
//        
//        //UILabel *grayLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CONTACT_TOP_VIEW_HEIGHT + 172, width, 3)];
//        self.contentView.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0];
//    }
    
    //stateView
    if(!self.stateView){
        UIImageView *stateView = [[UIImageView alloc] initWithFrame:CGRectMake((self.headView.frame.size.width-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, (self.headView.frame.size.height-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, HEADER_ICON_VIEW_HEIGHT_WIDTH, HEADER_ICON_VIEW_HEIGHT_WIDTH)];
        [self.headView addSubview:stateView];
        self.stateView = stateView;
    }
    //    if(self.contact.onLineState==STATE_ONLINE)
    //    {
    //        UIImage *typeImg = [UIImage imageNamed:@"ic_header_play.png"];
    //        self.stateView.image = typeImg;
    //    }
    //    else if(self.contact.onLineState==STATE_OFFLINE)
    //    {
    //        UIImage *typeImg = [UIImage imageNamed:@"ic_offline.png"];
    //        self.stateView.image = typeImg;
    //    }
#pragma mark - 设备在线离线图标
    if(self.contact.onLineState==STATE_ONLINE)
    {
//        在线图片
        UIImage *typeImg = [UIImage imageNamed:@"device_online.png"];
        self.stateView.image = typeImg;
    }
    else if(self.contact.onLineState==STATE_OFFLINE)
    {
//        离线图片
        UIImage *typeImg = [UIImage imageNamed:@"device_offline1.png"];
        self.stateView.image = typeImg;
    }
    
    
    //nameLable
    if(!self.nameLabel){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, NAME_LABEL_WIDTH,CONTACT_TOP_VIEW_HEIGHT-2*3)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        
        [self.topView addSubview:textLabel];
        self.nameLabel = textLabel;
        [textLabel release];
    }
    self.nameLabel.text = self.contact.contactName;
    
    
    
    //布防撤防按钮
    if(!self.defenceStateView){
        UIButton *defenceStateView = [UIButton buttonWithType:UIButtonTypeCustom];
        defenceStateView.frame = CGRectMake(width-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20, 4, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+10);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 3, defenceStateView.frame.size.width-15, defenceStateView.frame.size.height-5)];
        
        [defenceStateView addSubview:imageView];
        [imageView release];
        self.defenceStateView = defenceStateView;
        [self.topView addSubview:self.defenceStateView];
    }
    UIImageView *imageView = [[self.defenceStateView subviews] objectAtIndex:0];
    switch(self.contact.defenceState){
        case DEFENCE_STATE_ON:
        {
//            布防成功
            imageView.image = [UIImage imageNamed:@"defence_on.png"];
        }
            break;
            
        case DEFENCE_STATE_OFF:
        {
//            布防失败
            imageView.image = [UIImage imageNamed:@"defence_off.png"];
        }
            break;
            
        case DEFENCE_STATE_LOADING:
        {
            
        }
            break;
            
        case DEFENCE_STATE_WARNING_NET:
        {
//            布防警告
            imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
        }
            break;
            
        case DEFENCE_STATE_WARNING_PWD:
        {
            imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
        }
            break;
        case DEFENCE_STATE_NO_PERMISSION:
        {
//            布防锁
            imageView.image = [UIImage imageNamed:@"ic_defence_limit.png"];
        }
            break;
    }

    //设置按钮
    if (!self.settingView) {
        UIButton *settingView = [UIButton buttonWithType:UIButtonTypeCustom];
        settingView.frame = CGRectMake(self.defenceStateView.frame.origin.x - 43, 4, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+10);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 3, settingView.frame.size.width-15, settingView.frame.size.height-5)];
        
        if (!self.contact.isNewVersionDevice) {
            imageView.image = [UIImage imageNamed:@"new_set.png"];
        }else{
            imageView.image = [UIImage imageNamed:@"new_set1.png"];
        }
    
        [settingView addSubview:imageView];
        [imageView release];
        settingView.tag = kOperatorBtnTag_Control;
        self.settingView = settingView;
        [self.topView addSubview:self.settingView];
    }else{
        UIImageView *imageView = (UIImageView *)self.settingView.subviews[0];
        if (!self.contact.isNewVersionDevice) {
            imageView.image = [UIImage imageNamed:@"new_set.png"];
        }else{
            imageView.image = [UIImage imageNamed:@"new_set1.png"];
        }
    }
    
    //编辑按钮
    if (!self.modifyView) {
        UIButton *modifyView = [UIButton buttonWithType:UIButtonTypeCustom];
        modifyView.frame = CGRectMake(self.settingView.frame.origin.x-45, 4, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+10);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 3, modifyView.frame.size.width-15, modifyView.frame.size.height-5)];
        imageView.image = [UIImage imageNamed:@"new_editor.png"];
        [modifyView addSubview:imageView];
        [imageView release];
        modifyView.tag = kOperatorBtnTag_Modify;
        self.modifyView = modifyView;
        [self.topView addSubview:self.modifyView];
    }
    
    //弱密码提示
    if(!self.weakPwdButton){
        UIButton *weakPwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        weakPwdButton.frame = CGRectMake(self.modifyView.frame.origin.x-47, 4, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+10);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 3, weakPwdButton.frame.size.width-15, weakPwdButton.frame.size.height-5)];
        imageView.image = [UIImage imageNamed:@"weak_password.png"];
        [weakPwdButton addSubview:imageView];
        [imageView release];
        weakPwdButton.tag = kOperatorBtnTag_WeakPwd;
        self.weakPwdButton = weakPwdButton;
        [self.topView addSubview:self.weakPwdButton];
        
    }
    //NVR没有布防撤防
    [self showOrHiddenWeakPwdButton];
    [self.contentView bringSubviewToFront:self.weakPwdButton];
    
    //转动条
    if(!self.defenceProgressView){
        YProgressView *progressView = [[YProgressView alloc] initWithFrame:CGRectMake(width-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-10, 10, DEFENCE_STATE_VIEW_WIDTH_HEIGHT, DEFENCE_STATE_VIEW_WIDTH_HEIGHT)];
        progressView.backgroundView.image = [UIImage imageNamed:@"new_ic_progress_arrow.png"];
        
        self.defenceProgressView = progressView;
        [progressView release];
        [self.topView addSubview:self.defenceProgressView];
    }
    
    [self updateDefenceStateView];
    [self.headView addTarget:self action:@selector(onHeadClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.defenceStateView addTarget:self action:@selector(onDefencePress:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingView addTarget:self action:@selector(onHeadClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.modifyView addTarget:self action:@selector(onHeadClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.weakPwdButton addTarget:self action:@selector(onHeadClick:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)showOrHiddenWeakPwdButton{
    //密码的第一位为0，则表示是加密过的，为非弱密码
    //因为设备密码的第一位不为0
    NSString *weakPwd = [self.contact.contactPassword substringToIndex:1];
    if ((self.contact.onLineState==STATE_ONLINE) && (self.contact.defenceState == DEFENCE_STATE_ON || self.contact.defenceState == DEFENCE_STATE_OFF) && (![weakPwd isEqualToString:@"0"])) {
        [self.weakPwdButton setHidden:NO];//弱（红）
        
    }else{
        [self.weakPwdButton setHidden:YES];
    }
}
-(void)onHeadClick:(UIButton*)button{
    DLog(@"HEAD CLICK");
    if (self.delegate) {
        [self.delegate onClick:self.position contact:self.contact tag:button.tag];
    }
}

-(void)onButtonPress:(UIButton*)button{
    
}

-(void)onDefencePress:(UIButton*)button{
    //    UIImageView *imageView = [[button subviews] objectAtIndex:0];
    [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:self.contact.contactId isClick:YES];
    if(self.contact.defenceState==DEFENCE_STATE_WARNING_NET||self.contact.defenceState==DEFENCE_STATE_WARNING_PWD){
        self.contact.defenceState = DEFENCE_STATE_LOADING;
        [self updateDefenceStateView];
        [[P2PClient sharedClient] getDefenceState:self.contact.contactId password:self.contact.contactPassword];
        
    }else if(self.contact.defenceState==DEFENCE_STATE_ON){
        self.contact.defenceState = DEFENCE_STATE_LOADING;
        [self updateDefenceStateView];
        [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF];
    }else if(self.contact.defenceState==DEFENCE_STATE_OFF){
        self.contact.defenceState = DEFENCE_STATE_LOADING;
        [self updateDefenceStateView];
        [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_ON];
    }
}

-(void)updateDefenceStateView{
    if(self.contact.defenceState==DEFENCE_STATE_LOADING){
//        先不隐藏
        [self.defenceProgressView setHidden:NO];
//        运行完毕
        [self.defenceProgressView start];
//        隐藏
        [self.defenceStateView setHidden:YES];
    }
    else
    {
//        隐藏
        [self.defenceProgressView setHidden:YES];
//        不运行
        [self.defenceProgressView stop];
//        不隐藏
        [self.defenceStateView setHidden:NO];
    }
    
}
@end
