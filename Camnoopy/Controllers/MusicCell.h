//
//  MusicCell.h
//  Camnoopy
//
//  Created by 卡努比 on 16/5/3.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MusicCellDelegate <NSObject>

@optional
-(void)musictapLeftIconView:(NSInteger)section androw:(NSInteger)row;
@end
@interface MusicCell : UITableViewCell
@property (assign,nonatomic) NSInteger section;
@property (assign,nonatomic) NSInteger row;
@property (nonatomic, strong)NSString *leftLableText;

@property (nonatomic, strong)NSString *centerLableText;

@property (nonatomic, strong)UIImageView *imgIcon;

@property (nonatomic,strong) UILabel *nameLab;
@property (nonatomic,strong) UILabel *nameLab1;
@property (strong,nonatomic)id<MusicCellDelegate>delegate;
@end
