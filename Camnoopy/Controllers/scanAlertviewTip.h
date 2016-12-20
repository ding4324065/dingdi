//
//  scanAlertviewTip.h
//  Camnoopy
//
//  Created by wutong on 15-1-29.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol scanAlertTipDelegate <NSObject>
-(void)alertTipClickTryAgain;
-(void)alertTipClickCancel;
@end

@interface scanAlertviewTip : UIButton
@property (nonatomic, assign) id<scanAlertTipDelegate> delegate;
@end
