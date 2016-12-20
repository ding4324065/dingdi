

#import <UIKit/UIKit.h>
#import "P2PClient.h"
#import <AVFoundation/AVFoundation.h>

#import "OpenGLView.h"

@interface P2PVideoController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) OpenGLView *remoteView;
@property (nonatomic, strong) UIView *remoteMaskView;
@property (nonatomic, strong) UIImageView *localView;
@property (nonatomic) BOOL isReject;
@property (nonatomic) BOOL isFullScreen;
@property (nonatomic) BOOL isShowControllerBar;
@property (nonatomic) BOOL isVideoModeHD;
@property (nonatomic) BOOL isScreenShotting;
@property (strong, nonatomic) UIView *controllerBar;
@end
