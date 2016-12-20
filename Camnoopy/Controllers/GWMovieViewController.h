//
//  GWMovieViewController.h
//  2cu
//
//  Created by wutong on 15-6-24.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@protocol mp4PlayDelegate <NSObject>
-(void)onSwitchFileNext:(BOOL)isNext;
@end

@interface GWMovieViewController : MPMoviePlayerViewController
@property(assign, nonatomic) id<mp4PlayDelegate> mp4Delegate;
@end
