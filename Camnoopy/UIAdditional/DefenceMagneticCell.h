//
//  DefenceMagneticCell.h
//  Camnoopy
//
//  Created by 高琦 on 15/2/10.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DefenceMagneticCell;

@protocol DefenceCMagneticellDelegate <NSObject>
@optional
-(void)defenceCell:(DefenceMagneticCell *)defenceCell section:(NSInteger)section row:(NSInteger)row status:(NSInteger)status;
@end
@interface DefenceMagneticCell : UITableViewCell<UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIButton * addbutton;
@property(nonatomic, strong) UIButton * addbutton1;
@property(nonatomic, strong) UILabel * addLable;

@property(nonatomic, strong) UIImageView * controllerView;
@property(nonatomic, strong) UISwitch * defenceswitch;
@property(nonatomic, strong) UIImageView  *defenimage;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;

@property(nonatomic) NSInteger group;
@property(nonatomic) NSInteger item;
@property(nonatomic, assign) id<DefenceCMagneticellDelegate> delegate;

-(void)setAddbuttonHidden:(BOOL)hidden;
-(void)setAddbutton1Hidden:(BOOL)hidden;

-(void)setDefenceswitchHidden:(BOOL)hidden;
-(void)setDefenimageWithHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;
-(void)setContollerViewHidden:(BOOL)hidden;
-(void)setAddLableHidden:(BOOL)hidden;
@end
