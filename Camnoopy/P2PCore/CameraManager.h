

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#pragma mark - 摄像机管理
@interface CameraManager : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureVideoDataOutput *output;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, assign) NSInteger frameRate;
@property (nonatomic) BOOL isRun;
+ (id)sharedManager;
- (void)addCameraView:(UIView *)view;
#pragma mark -改变视角
- (int)cameraChange;
-(void)startCamera:(BOOL)isFont;
-(void)stopCamera;
@end
