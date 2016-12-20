//
//  MainSettingCell.h
//  Camnoopy
//
//  Created by 卡努比 on 16/7/1.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainSettingCell : UITableViewCell

@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) UILabel *leftLabelView;

@property (strong, nonatomic) UIImageView *newDeviceIconView;
@property (strong, nonatomic) NSString *newDeviceIcon;//设备检查更新

@property (strong, nonatomic) UIImageView *rightIconView;
@property (strong, nonatomic) NSString *rightIcon;
@property (assign) BOOL isleftLabelTextHidden;
@property (assign) BOOL isupdateImgHidden;
@property (assign) BOOL isrightImgHidden;

- (void)setLeftLabelTextHidden:(BOOL)hidden;
- (void)setUpdateImg:(BOOL)hidden;
- (void)setRightImg:(BOOL)hidden;
@end
