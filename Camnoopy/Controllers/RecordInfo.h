//
//  RecordInfo.h
//  Camnoopy
//
//  Created by wutong on 15-1-23.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordInfo : NSObject
@property (nonatomic, copy) NSDate      *startTime;     //开始时间
@property (nonatomic, copy) NSDate      *endTime;       //结束时间
@property (nonatomic, assign) NSInteger type;           //结束时间
@end
