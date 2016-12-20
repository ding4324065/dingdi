//
//  FileListCell.h
//  2cu
//
//  Created by wutong on 15-6-29.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OnFileListCellDelegate
-(void)onLongPress:(int)row;
@end

@interface FileListCell : UITableViewCell
@property (assign) int row;
@property (assign)BOOL initGesture;
@property(nonatomic, assign) id<OnFileListCellDelegate> delegate;
@end
