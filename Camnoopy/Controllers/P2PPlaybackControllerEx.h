//
//  P2PPlaybackControllerEx.h
//  Camnoopy
//
//  Created by wutong on 15-1-19.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "KTVideoTimerView.h"
#import "OpenGLView.h"
#import "P2PClient.h"

@interface P2PPlaybackControllerEx : UIViewController<ContinueLoadRecordListDelegate, P2PPlaybackDelegate>
@property(strong, nonatomic) Contact *contact;

@property (nonatomic, copy) NSDate     *beginSearchDate;
@property (nonatomic, copy) NSDate     *endSearchDate;
@property (nonatomic, copy) NSDate     *beginShowDate;
@property (nonatomic, copy) NSDate     *endShowDate;

@property (nonatomic, strong) OpenGLView *remoteView;

@end
