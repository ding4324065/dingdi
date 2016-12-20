//
//  LocalFilesListController.h
//  2cu
//
//  Created by wutong on 15-6-24.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "GWMovieViewController.h"
#import "FileListCell.h"

@interface LocalFilesListController : UIViewController<UITableViewDelegate, UITableViewDataSource, mp4PlayDelegate, OnFileListCellDelegate>
@property(strong, nonatomic) Contact *contact;
@property(strong, nonatomic) UITableView* tableView;
@property(strong, nonatomic) NSMutableArray* arrayFiles;
//@property(strong, nonatomic) GWMovieViewController* movieCtrl;

@end
