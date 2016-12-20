

#import <UIKit/UIKit.h>

@interface GroupHead : UIControl

@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong) UILabel *groupNameLabel;
@property(nonatomic, strong) UIImageView *backImageView;

@property(assign) BOOL isStatusLabelHidden;

-(void)setStatusLabelHidden:(BOOL)hidden;

- (void)refreshUIWithDictionary:(NSDictionary *)dictionary;
@end
