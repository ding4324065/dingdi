//
//  KTVideoTimerView.m
//  KTIphoneClientPro
//
//  Created by apple on 6/3/13.
//  Copyright (c) 2013 KongTop. All rights reserved.
//

#import "KTVideoTimerView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+Additional.h"
#import "RecordInfo.h"

#define LR_MARGIN 0.0

#define HOUR_WIDTH 100.0
#define CONTENT_H_MARGIN 3.0

#define KTNumberKey(i) [NSString stringWithFormat:@"%d", (i)]
#define RGBColor255(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@class ZYDegreeSectionView;
@class KTTimeScrollView;

/*******************************************
 *滚动视图类
 *******************************************/
@protocol KTTimeScrollViewDelegate <NSObject>

- (NSInteger)numberOfUnitsInTimeScrollView:(KTTimeScrollView *)view;
- (CGFloat)timeScrollView:(KTTimeScrollView *)view widthOfUnitIndex:(NSInteger)index;
- (ZYDegreeSectionView *)timeScrollView:(KTTimeScrollView *)view unitForIndex:(NSInteger)index;

@end

#pragma mark - 刻度 -
/*******************************************
 *单元格类
 *******************************************/
@interface ZYDegreeSectionView : UIView
{
}
@property (nonatomic, strong) NSArray     *records;
@property (nonatomic, strong) NSDate      *startTm;
@property (nonatomic, strong) NSDate      *endTm;
@property (nonatomic, assign) BOOL        isLast;

- (CGFloat)realWidth;
@end
#define DEGREE_HEIGTH 6.0

@implementation ZYDegreeSectionView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
    }
    return self;
}

- (CGFloat)realWidth
{
    return [self hoursFromDate:_startTm toDate:_endTm]*HOUR_WIDTH;
}

- (NSInteger)hoursFromDate:(NSDate *)st toDate:(NSDate *)et
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitHour fromDate:st toDate:et options:0];
    
    NSInteger hours = comps.hour;
    
    if (st.minute || st.second)
    {
        hours++;
    }
    if (et.minute || et.second)
    {
        hours++;
    }
    return hours;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    NSInteger hours = [self hoursFromDate:_startTm toDate:_endTm];
    NSInteger startHour = _startTm.hour;
    if (_startTm.minute || _startTm.second)
    {
        startHour--;
        if (startHour <= 0)
        {
            startHour += 24;
        }
    }
    
    //[[UIColor whiteColor] setStroke];
    [[UIColor whiteColor] setStroke];
    NSInteger hour = 0;
    for (NSInteger i = 0; i < hours; i++)
    {
        hour = (startHour+i)%24;
        [self drawDegree:CGPointMake(i*HOUR_WIDTH, 40)
                    hour:hour
               needLabel:(i==0)
                 context:ctx];
    }
    if (_isLast)
    {
        [self drawDegree:CGPointMake(hours*HOUR_WIDTH, 40)
                    hour:hour+1
               needLabel:YES
                 context:ctx];
    }
    
    for (RecordInfo *record in _records)
    {
        [self drawRecord:record context:ctx];
    }
}

- (void)drawDegree:(CGPoint)startPnt hour:(NSInteger)hour needLabel:(BOOL)needLabel context:(CGContextRef)ctx
{
    CGContextMoveToPoint(ctx, startPnt.x, startPnt.y);
    CGContextAddLineToPoint(ctx, startPnt.x, startPnt.y-DEGREE_HEIGTH);
    CGContextStrokePath(ctx);
    
    NSString *str = [NSString stringWithFormat:@"%02ld:00", (long)hour];
    UIFont *font = [UIFont systemFontOfSize:11.0];
    CGSize size = [str sizeWithFont:font];
    if (!needLabel)
    {
        [[UIColor blackColor] setFill];
        [str drawAtPoint:CGPointMake(startPnt.x-size.width/2.0, startPnt.y-DEGREE_HEIGTH-3.0-size.height)
                withFont:font];
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(startPnt.x-size.width/2.0, startPnt.y-DEGREE_HEIGTH-3.0-size.height, size.width, size.height)];
        label.backgroundColor = [UIColor clearColor];
        [label setTextColor:[UIColor blackColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:font];
        [label setText:str];
        [self addSubview:label];
    }
}

#define BORDER_COLOR 10
#define VIDEO_HEIGHT 10.0

- (void)drawRecord:(RecordInfo *)record context:(CGContextRef)ctx
{
    NSString *baseDateStr = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",
                             _startTm.year, _startTm.month, _startTm.day,
                             _startTm.hour, 0, 0];
    
    NSDate *baseDate = [NSDate dateFromString:baseDateStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSInteger startSecs = [record.startTime timeIntervalSinceDate:baseDate];
    NSInteger endSecs = [record.endTime timeIntervalSinceDate:baseDate];
    
    
    
    UIColor *color = RGBColor255(166, 201, 255);
    [color setFill];
    
    UIColor *borderColor = RGBColor255(166+BORDER_COLOR, 201+BORDER_COLOR, 255);
    [borderColor setStroke];
    
    CGFloat startX = (startSecs/3600 * HOUR_WIDTH + (startSecs%3600)/3600.0 * HOUR_WIDTH);
    CGFloat endX   = (endSecs/3600 * HOUR_WIDTH + (endSecs%3600)/3600.0 * HOUR_WIDTH);
    
    CGContextAddRect(ctx, CGRectMake(startX, 40.0, endX-startX, VIDEO_HEIGHT));
    
    CGContextDrawPath(ctx, kCGPathFill);
}



@end


#pragma mark - scrollview -
@interface KTTimeScrollView : UIScrollView <UIScrollViewDelegate>
{
    NSMutableArray      *_cells;
    NSMutableDictionary *_visibleCellsDic;
    NSMutableDictionary *_widthsDic;
    NSInteger           _cellCount;
    CGFloat             _lastOffsetX;
}

@property (nonatomic, assign) id<KTTimeScrollViewDelegate> videoDelegate;
@property (nonatomic, assign, getter = isMoving) BOOL moving;
@end



#define DEGREE_LINE_OFFSET_X 0.7

@implementation KTTimeScrollView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.delegate = self;
    }
    return self;
}

- (void)reloadData:(CGFloat)offsetRate
{
    
    if (!_visibleCellsDic)
    {
        _visibleCellsDic = [[NSMutableDictionary alloc] init];
    }
    else
    {
        [_visibleCellsDic removeAllObjects];
    }
    
    if (!_widthsDic)
    {
        _widthsDic = [[NSMutableDictionary alloc] init];
    }
    else
    {
        [_widthsDic removeAllObjects];
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _cellCount = [_videoDelegate numberOfUnitsInTimeScrollView:self];
    if (_cellCount == 0)
    {
        return;
    }
    CGFloat width = 0;
    CGFloat tmpWidth;
    for (NSInteger i = 0; i < _cellCount; i++)
    {
        tmpWidth = [_videoDelegate timeScrollView:self widthOfUnitIndex:i];
        width += tmpWidth;
        [_widthsDic setValue:@(tmpWidth) forKey:KTNumberKey(i)];
    }
    self.contentSize = CGSizeMake(width+self.bounds.size.width, self.bounds.size.height);
/*
    CGFloat startX = self.bounds.size.width/2.0;
    NSInteger index = 0;
    while (startX <= self.bounds.size.width)
    {
        ZYDegreeSectionView *section = [_videoDelegate timeScrollView:self unitForIndex:index];
        section.frame = CGRectMake(startX, 0, [_widthsDic[KTNumberKey(index)] floatValue], self.bounds.size.height);
        [self addSubview:section];
        
        startX += section.frame.size.width;
        [_visibleCellsDic setObject:section forKey:KTNumberKey(index)];
        
        index++;
    }
 */
/*
    CGFloat startX = self.bounds.size.width/2.0+width;
    NSInteger index = _cellCount-1;
    while (startX >= width)
    {
        ZYDegreeSectionView *section = [_videoDelegate timeScrollView:self unitForIndex:index];
        section.frame = CGRectMake(startX-[_widthsDic[KTNumberKey(index)] floatValue], 0, [_widthsDic[KTNumberKey(index)] floatValue], self.bounds.size.height);
        NSLog(@"frame = %@, _widthsDic = %f", NSStringFromCGRect(section.frame), [_widthsDic[KTNumberKey(index)] floatValue]);
        [self addSubview:section];
        
        startX -= section.frame.size.width;
        [_visibleCellsDic setObject:section forKey:KTNumberKey(index)];
        
        index--;
    }
 */
    
    CGFloat startX = self.bounds.size.width/2.0+width;
    NSInteger index = _cellCount-1;
    while (index >= 0)
    {
        ZYDegreeSectionView *section = [_videoDelegate timeScrollView:self unitForIndex:index];
        section.frame = CGRectMake(startX-[_widthsDic[KTNumberKey(index)] floatValue], 0, [_widthsDic[KTNumberKey(index)] floatValue], self.bounds.size.height);
        NSLog(@"frame = %@, _widthsDic = %f", NSStringFromCGRect(section.frame), [_widthsDic[KTNumberKey(index)] floatValue]);
        [self addSubview:section];
        
        startX -= section.frame.size.width;
        [_visibleCellsDic setObject:section forKey:KTNumberKey(index)];
        
        index--;
    }
    
    self.contentOffset = CGPointMake(width*offsetRate, 0);
    _lastOffsetX = self.contentOffset.x;
}

- (void)drawRect:(CGRect)rect
{
    //刻度基准线
    [self drawLineFromPoint:CGPointMake(LR_MARGIN, self.bounds.size.height*DEGREE_LINE_OFFSET_X)
                    toPoint:CGPointMake(self.bounds.size.width-LR_MARGIN, self.bounds.size.height*DEGREE_LINE_OFFSET_X)
                      color:[UIColor blackColor]
                  lineWidth:1.0];
    [self drawLineFromPoint:CGPointMake(LR_MARGIN, self.bounds.size.height*DEGREE_LINE_OFFSET_X+1.0)
                    toPoint:CGPointMake(self.bounds.size.width-LR_MARGIN, self.bounds.size.height*DEGREE_LINE_OFFSET_X+1.0)
                      color:[UIColor colorWithWhite:80.0/255.0 alpha:0.9]
                  lineWidth:1.0];
}

- (void)drawLineFromPoint:(CGPoint)pnt1 toPoint:(CGPoint)pnt2 color:(UIColor *)color lineWidth:(CGFloat)width
{
    [color setStroke];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = width;
    [path moveToPoint:pnt1];
    [path addLineToPoint:pnt2];
    
    [path stroke];
}

- (ZYDegreeSectionView *)rightmostVisibleCell
{
    ZYDegreeSectionView *result = nil;
    for (ZYDegreeSectionView *section in _visibleCellsDic.allValues)
    {
        if (section.tag >= result.tag)
        {
            result = section;
        }
    }
    return result;
}

- (ZYDegreeSectionView *)leftmostVisibleCell
{
    ZYDegreeSectionView *result = nil;
    for (ZYDegreeSectionView *section in _visibleCellsDic.allValues)
    {
        if (!result)
        {
            result = section;
        }
        else if (section.tag <= result.tag)
        {
            result = section;
        }
    }
    return result;
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    CGPoint offset = scrollView.contentOffset;
    if (offset.x > _lastOffsetX)
    {
        //向左滚动
        ZYDegreeSectionView *rightSection = [self rightmostVisibleCell];
        if (rightSection && CGRectGetMaxX(rightSection.frame) <= (offset.x+scrollView.frame.size.width) && rightSection.tag < (_cellCount-1))
        {
            
            ZYDegreeSectionView *section = [_videoDelegate timeScrollView:self unitForIndex:rightSection.tag+1];
            NSString *key = KTNumberKey(section.tag);
            section.frame = CGRectMake(CGRectGetMaxX(rightSection.frame), 0, [_widthsDic[key] floatValue], scrollView.bounds.size.height);
            [scrollView addSubview:section];
            
            [_visibleCellsDic setObject:section forKey:key];
        }
        
        ZYDegreeSectionView *leftSection = [self leftmostVisibleCell];
        if (leftSection && CGRectGetMaxX(leftSection.frame) < offset.x)
        {
            [leftSection removeFromSuperview];
            [_visibleCellsDic removeObjectForKey:KTNumberKey(leftSection.tag)];
        }
        
    }
    else
    {
        //向右滚动
        ZYDegreeSectionView *leftSection = [self leftmostVisibleCell];
        if (leftSection && leftSection.tag > 0 && (CGRectGetMinX(leftSection.frame) + offset.x) > 0)
        {
            ZYDegreeSectionView *section = [_videoDelegate timeScrollView:self unitForIndex:leftSection.tag-1];
            NSString *key = KTNumberKey(section.tag);
            section.frame = CGRectMake(CGRectGetMinX(leftSection.frame)-[_widthsDic[key] floatValue], 0, [_widthsDic[key] floatValue], scrollView.bounds.size.height);
            [scrollView addSubview:section];
            
            [_visibleCellsDic setObject:section forKey:KTNumberKey(section.tag)];
        }
        
        ZYDegreeSectionView *rightSection = [self rightmostVisibleCell];
        if (rightSection && CGRectGetMinX(rightSection.frame) > (offset.x+scrollView.bounds.size.width))
        {
            [rightSection removeFromSuperview];
            [_visibleCellsDic removeObjectForKey:KTNumberKey(rightSection.tag)];
        }
        
    }
     */
    
    _lastOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.moving = YES;
}


//松开手指的时候调用，有惯性时decelerate=true,否则decelerate=false
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        self.moving = NO;
    }
}

//只有在有惯性的情况下才会调用此函数，self.isDragging总是0
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!self.isDragging)
    {
        self.moving = NO;
    }
    //再次搜索
}

@end


#pragma mark - 组件 -
/*******************************************
 *组件类
 *******************************************/
@interface  KTVideoTimerView()<KTTimeScrollViewDelegate>
{
    KTTimeScrollView    *_timeScrollView;
    UILabel             *_timeLabel;
}
@end

@implementation KTVideoTimerView
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _timeScrollView = [[KTTimeScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width-2.0, frame.size.height-2.0)];
        _timeScrollView.backgroundColor = [UIColor clearColor];
        
        _timeScrollView.videoDelegate = self;
        [self addSubview:_timeScrollView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2.0, 0, 1.0, frame.size.height)];
        lineView.backgroundColor = [UIColor blueColor];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:lineView];
        
        //时间戳
        NSString *demoString = @"8888-88-88 00:00:00";
        UIFont *font = [UIFont systemFontOfSize:12.0];
        CGSize size = [demoString sizeWithFont:font];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [_timeLabel setFont:font];
        
        _timeLabel.center = CGPointMake(frame.size.width/2.0-([@"8888-88-88" sizeWithFont:font].width+[@" " sizeWithFont:font].width/2.0-_timeLabel.bounds.size.width/2.0), 3.0+_timeLabel.bounds.size.height/2.0);
        lineView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        [self addSubview:_timeLabel];
        [_timeScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
        [_timeScrollView addObserver:self forKeyPath:@"moving" options:0 context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [_timeScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_timeScrollView removeObserver:self forKeyPath:@"moving"];
    [super dealloc];
}


#pragma mark - 委托 -
- (NSInteger)numberOfUnitsInTimeScrollView:(KTTimeScrollView *)view
{
    return _dayCount;
}

- (CGFloat)timeScrollView:(KTTimeScrollView *)view widthOfUnitIndex:(NSInteger)index
{
    NSDate *start;
    NSDate *end;
    NSDate *baseDate = [NSDate dateFromString:[_startTm stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];
    if (index == 0)
    {
        start = [NSDate dateFromString:[_startTm stringWithFormat:@"yyyy-MM-dd HH"] withFormat:@"yyyy-MM-dd HH"];
    }
    else
    {
        start = [NSDate dateWithTimeInterval:index*24*3600 sinceDate:baseDate];
    }
    
    if (index == (_dayCount-1))
    {
/*
        end = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-%02d-%02d %02d", _endTm.year, _endTm.month, _endTm.day, (_endTm.minute || _endTm.second)?(_endTm.hour+1):_endTm.hour]
                          withFormat:@"yyyy-MM-dd HH"];
*/
        end = _endTm;
    }
    else
    {
        end = [NSDate dateWithTimeInterval:index*24*3600+(24*3600-1) sinceDate:baseDate];
    }
    
    NSTimeInterval secs = [end timeIntervalSinceDate:start];
    
    return (secs/3600)*HOUR_WIDTH;
}

- (ZYDegreeSectionView *)timeScrollView:(KTTimeScrollView *)view unitForIndex:(NSInteger)index
{
    ZYDegreeSectionView *section = [[ZYDegreeSectionView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    section.tag = index;
    section.backgroundColor = [UIColor orangeColor];
    
    NSDate *start;
    NSDate *end;
    NSDate *baseDate = [NSDate dateFromString:[_startTm stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];
    if (index == 0)
    {
        start = [NSDate dateFromString:[_startTm stringWithFormat:@"yyyy-MM-dd HH"] withFormat:@"yyyy-MM-dd HH"];
    }
    else
    {
        start = [NSDate dateWithTimeInterval:index*24*3600 sinceDate:baseDate];
    }
    
    if (index == (_dayCount-1))
    {
        /*
        end = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-%02d-%02d %02d", _endTm.year, _endTm.month, _endTm.day, (_endTm.minute || _endTm.second)?(_endTm.hour+1):_endTm.hour]
                          withFormat:@"yyyy-MM-dd HH"];
        section.isLast = YES;
         */
        end = _endTm;

    }
    else
    {
        end = [NSDate dateWithTimeInterval:index*24*3600+(24*3600-1) sinceDate:baseDate];
    }
    
    section.startTm = start;
    section.endTm = end;
    
    [section setRecords:_dayRecordDic[[section.startTm stringWithFormat:@"yyyy-MM-dd"]]];
    
    return section;
}
- (void)clear
{
    [_dayRecordDic removeAllObjects];
    _dayCount = 0;
    [_timeScrollView reloadData:0];
}

- (void)setRecordList:(NSArray *)recordList offsetDate:(NSDate*)offsetDate
{
    if (_dayRecordDic)
    {
        [_dayRecordDic removeAllObjects];
    }
    else
    {
        _dayRecordDic = [[NSMutableDictionary alloc] init];
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitDay fromDate:_startTm toDate:_endTm options:0];
    
    _dayCount = comps.day+1;
    
    
    NSString *dayString = @"";
    if (recordList.count > 0)
    {
        NSMutableArray *arr = nil;
        for (RecordInfo *rd in recordList)
        {
            NSString *tmpDayString= [rd.startTime stringWithFormat:@"yyyy-MM-dd"];
            if (![tmpDayString isEqualToString:dayString])
            {
                arr = [NSMutableArray arrayWithObject:rd];
                [_dayRecordDic setValue:arr forKey:tmpDayString];
                dayString = tmpDayString;
            }
            else
            {
                [arr addObject:rd];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat offsetRate = [offsetDate timeIntervalSinceDate:_startTm]/[_endTm timeIntervalSinceDate:_startTm];
        [_timeScrollView reloadData:offsetRate];
        _timeLabel.text = [offsetDate stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
//        [_timeScrollView setNeedsDisplay];
    });
    
}

- (void)setVideoTimestamp:(NSDate *)timestamp
{
    assert(timestamp != nil);
    if (_timestamp)
    {
        NSTimeInterval timeInterval = [timestamp timeIntervalSinceDate:self.timestamp];
        if ((NSInteger)timeInterval != 0)
        {
            self.timestamp = timestamp;
            
            if (!_moving)
            {
                NSInteger secs = [_timestamp timeIntervalSinceDate:[NSDate dateFromString:[_startTm stringWithFormat:@"yyyy-MM-dd HH"] withFormat:@"yyyy-MM-dd HH"]];
                CGFloat offsetX = secs/3600.0 * HOUR_WIDTH;
                if (_isEndDrag)
                {
                    _moving = YES;
                    double delayInSeconds = 2.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        _moving = NO;
                        _isEndDrag = NO;
                    });
                }
                else
                {
                    [_timeScrollView setContentOffset:CGPointMake(offsetX, 0)];
                    _timeLabel.text = [_timestamp stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
                }
            }
        }
    }
    else
    {
        self.timestamp = timestamp;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"timestamp"])
    {
        //uint64_t = change[@"new"]];
        NSNumber *tm = change[@"new"];
        uint64_t timestamp = [tm longLongValue];
        time_t      secNum = timestamp/1000000;
        struct tm   *ptime = localtime(&secNum);
        NSDate *time = [NSDate dateFromString:[NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", ptime->tm_year+1900, ptime->tm_mon+1, ptime->tm_mday, ptime->tm_hour, ptime->tm_min, ptime->tm_sec]
                                   withFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setVideoTimestamp:time];
        });
        
    }
    else if ([keyPath isEqualToString:@"contentOffset"])
    {
        if (_timeScrollView.isDragging || _timeScrollView.isDecelerating)
        {
            CGPoint pnt = CGPointMake(_timeScrollView.bounds.size.width/2.0+_timeScrollView.contentOffset.x, _timeScrollView.bounds.size.height/2.0);
            ZYDegreeSectionView *section = (ZYDegreeSectionView *)[_timeScrollView hitTest:pnt withEvent:NULL];
            if ([section isMemberOfClass:[ZYDegreeSectionView class]])
            {
                pnt = [section convertPoint:pnt fromView:_timeScrollView];
                NSDate *date = [section.startTm dateByAddingTimeInterval:(pnt.x/HOUR_WIDTH)*3600];
                _timeLabel.text = [date stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
            }
        }
        
    }
    else if ([keyPath isEqualToString:@"moving"])
    {
        BOOL isMoving = _timeScrollView.isMoving;
        if (!isMoving && _moving)
        {
            //是否搜索
            if (_timeScrollView.contentOffset.x == 0 ||
               (_timeScrollView.contentSize.width- _timeScrollView.contentOffset.x - _timeScrollView.bounds.size.width) < 1 )
            {
                //wxlanguage
                UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:@"message" message:@"do you want to stop play and search again?" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                [inputAlert show];
                [inputAlert release];
            }

            //==
            CGPoint pnt = CGPointMake(_timeScrollView.bounds.size.width/2.0+_timeScrollView.contentOffset.x, _timeScrollView.bounds.size.height/2.0);
            ZYDegreeSectionView *section = (ZYDegreeSectionView *)[_timeScrollView hitTest:pnt withEvent:NULL];
            if ([section isMemberOfClass:[ZYDegreeSectionView class]])
            {
                _isEndDrag = YES;
                pnt = [section convertPoint:pnt fromView:_timeScrollView];
                NSDate *date = [section.startTm dateByAddingTimeInterval:(pnt.x/HOUR_WIDTH)*3600];
                self.seekDate = date;
            }
        }

        _moving = isMoving;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //继续播放
    }
    else
    {
        //继续加载录像文件
        if (_timeScrollView.contentOffset.x == 0) {
            [self.loadRdListdelegate loadRecordList:YES];
        }
        else
        {
            [self.loadRdListdelegate loadRecordList:NO];
        }
    }
}

@end
