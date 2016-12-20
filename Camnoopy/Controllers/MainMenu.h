//
//  MainMenu.h
//  Camnoopy
//
//  Created by wutong on 15-1-6.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

/*侧滑菜单相关*/
#import <UIKit/UIKit.h>

@protocol MainmenuDelegate <NSObject>
- (void)OnMenuBtnAction:(NSInteger)tag;
@end

@interface MainMenu : UIView

@property (nonatomic, assign) id<MainmenuDelegate> delegate;
@end
