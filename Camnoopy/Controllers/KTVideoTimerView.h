//
//  KTVideoTimerView.h
//  KTIphoneClientPro
//
//  Created by apple on 6/3/13.
//  Copyright (c) 2013 KongTop. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContinueLoadRecordListDelegate <NSObject>
- (void)loadRecordList:(BOOL)bTowardLeft;
@end

@interface KTVideoTimerView : UIView<UIAlertViewDelegate>
{
    NSInteger           _dayCount;
    NSMutableDictionary *_dayRecordDic;
    BOOL                _moving;
    BOOL                _isEndDrag;
    //NSTimer             *_timer;
}

@property (nonatomic, assign) BOOL     canDrag;
@property (nonatomic, copy) NSDate     *startTm;
@property (nonatomic, copy) NSDate     *endTm;
@property (atomic, copy) NSDate        *timestamp;

@property (nonatomic, copy)   NSDate *seekDate;

@property (nonatomic, assign) id<ContinueLoadRecordListDelegate> loadRdListdelegate;

//@property (nonatomic, assign) NSArray    *recordList;

- (void)clear;

- (void)setRecordList:(NSArray *)recordList offsetDate:(NSDate*)offsetDate;

- (void)setVideoTimestamp:(NSDate *)timestamp;
@end
