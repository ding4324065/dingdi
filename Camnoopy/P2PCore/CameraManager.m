

#import "CameraManager.h"
#import "Constants.h"
#import "config.h"
@interface CameraManager ()

@end

@implementation CameraManager


+ (id)sharedManager
{
    
    static CameraManager *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            DLog(@"Alloc CameraManager");
            manager = [[CameraManager alloc] init];
        }
    }
    return manager;
}
#pragma mark - 寻找前置摄像头，没有则返回空
- (AVCaptureDevice *)frontFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

#pragma mark - 寻找背置摄像头，没有则返回空
- (AVCaptureDevice *)backFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}
#pragma mark - 从指定AVCaptureDevice的位置获取设置
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}


- (int)cameraChange {
    
    if ([self cameraCount] > 1) {
        
        NSError *error;
        AVCaptureDevicePosition position = self.input.device.position;
        [self.session beginConfiguration];
        [self.session removeInput:self.input];
        self.input = nil;
        
        AVCaptureDeviceInput * newDeviceInput = nil;
        if (position == AVCaptureDevicePositionBack) {
            newDeviceInput =
            [AVCaptureDeviceInput deviceInputWithDevice:[self frontFacingCamera] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newDeviceInput =
            [AVCaptureDeviceInput deviceInputWithDevice:[self backFacingCamera] error:&error];
        }
        if (newDeviceInput != nil) {
            if ([self.session canAddInput:newDeviceInput]) {
                [self.session addInput:newDeviceInput];
                self.input = newDeviceInput;
            }
        }
        
        
        
        position = self.input.device.position;
        
        
        [self setFrontCameraChangeOrientationToLandscapeRight];
        [self.session commitConfiguration];
        
    }
    //自动对焦
    //[self autoFocusAtPoint:CGPointMake(.5f, .5f)];
    
    return self.input.device.position;
}

- (void)autoFocusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = self.input.device;
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        }
    }
}

- (void)setFrontCameraChangeOrientationToLandscapeRight {
    
    for (AVCaptureConnection *connection in self.output.connections)
        if (connection.supportsVideoOrientation && connection.videoOrientation != AVCaptureVideoOrientationLandscapeRight)
            [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
}

- (void)setFrameRate:(NSInteger)fRate {
    DLog(@"setFrameRate");
	if (fRate > 0)
	{
		for (AVCaptureConnection *connection in self.output.connections)
		{
            
			if ([connection respondsToSelector:@selector(setVideoMinFrameDuration:)])
				connection.videoMinFrameDuration = CMTimeMake(1, fRate);
            
			if ([connection respondsToSelector:@selector(setVideoMaxFrameDuration:)])
                if ( connection.isVideoMaxFrameDurationSupported ) {
                    connection.videoMaxFrameDuration = CMTimeMake(1, fRate);
                }
		}
	}
	else
	{
		for (AVCaptureConnection *connection in self.output.connections)
		{
			if ([connection respondsToSelector:@selector(setVideoMinFrameDuration:)])
				connection.videoMinFrameDuration = kCMTimeInvalid; // This sets videoMinFrameDuration back to default
			
			if ([connection respondsToSelector:@selector(setVideoMaxFrameDuration:)])
				connection.videoMaxFrameDuration = kCMTimeInvalid; // This sets videoMaxFrameDuration back to default
		}
	}
}

- (NSInteger)frameRate {
	return self.frameRate;
}


- (void)addCameraView:(UIView *)view
{
    UIView *bgView = [[UIView alloc] initWithFrame:view.bounds];
    [bgView setBackgroundColor:[UIColor blackColor]];
    [self.previewLayer setBackgroundColor:[UIColor blackColor].CGColor];

    [self.previewLayer setFrame:view.bounds];
    [bgView.layer addSublayer:self.previewLayer];
    
    [view addSubview:bgView];
    [view sendSubviewToBack:bgView];
    [self.previewLayer setOrientation:AVCaptureVideoOrientationLandscapeRight];
}

-(void)startCamera:(BOOL)isFont{
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
//    开始配置
    [session beginConfiguration];
//    capture session 可以通过一个 sessionPreset 来进一步配置，用来指定输出质量的等级
    [session setSessionPreset:AVCaptureSessionPreset352x288];

    
    AVCaptureVideoDataOutput * newVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    // 指定像素格式
    newVideoDataOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                                        kCVPixelBufferPixelFormatTypeKey,nil];
    newVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    // 配置图像输出
    if ([session canAddOutput:newVideoDataOutput]) {
        [session addOutput:newVideoDataOutput];
        dispatch_queue_t queue = dispatch_queue_create("com.yige.cameraProcessingQueue", NULL);
        [newVideoDataOutput setSampleBufferDelegate:self queue:queue];
        dispatch_release(queue);
        self.output = newVideoDataOutput;
    }
    [newVideoDataOutput release];
    
    // 设置预览祯率
    self.frameRate = VIDEO_FRAME_RATE;
    
    if(isFont){
       #pragma mark - 寻找前置摄像头，没有则返回空  self frontFacingCamera
        AVCaptureDeviceInput * newDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[self frontFacingCamera] error:nil];
        if ([session canAddInput:newDeviceInput]) {
            [session addInput:newDeviceInput];
            self.input = newDeviceInput;
        }
    }else{
        #pragma mark - 寻找背置摄像头，没有则返回空 self backFacingCamera
        AVCaptureDeviceInput * newDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[self backFacingCamera] error:nil];
        if ([session canAddInput:newDeviceInput]) {
            [session addInput:newDeviceInput];
            self.input = newDeviceInput;
        }
    }
    
    
//    预览
    AVCaptureVideoPreviewLayer * newPreviewLayer =
    [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
   
    [newPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer = newPreviewLayer;
    [newPreviewLayer release];
    
    for (AVCaptureConnection *connection in self.output.connections)
        if (connection.supportsVideoOrientation && connection.videoOrientation != AVCaptureVideoOrientationLandscapeRight)
            [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    
    [session commitConfiguration];
    [session startRunning];
    self.session = session;
    self.isRun = YES;
    [session release];
}

-(void)stopCamera{
    if([self session]){
        [self.session stopRunning];
        self.isRun = NO;
//        [self.input release];
//        [self.output release];
//        [self.previewLayer release];
//        [self.session release];
        
        self.session = nil;
        self.input = nil;
        self.output = nil;
        self.previewLayer = nil;
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if(self.isRun){
        @autoreleasepool {
//            照相机获取的每一帧保存为图片 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//            锁定pixel buffer(像素缓存区)的基地址
            CVPixelBufferLockBaseAddress(imageBuffer,0);
            // 得到pixel buffer的基地址
            uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
            // 得到pixel buffer的宽高
            DWORD dwSize = CVPixelBufferGetDataSize(imageBuffer);
            DWORD dwWidth = CVPixelBufferGetWidth(imageBuffer);
            DWORD dwHeight = CVPixelBufferGetHeight(imageBuffer);
//            capture session 可以通过一个 sessionPreset 来进一步配置，用来指定输出质量的等级
            if (self.session.sessionPreset == AVCaptureSessionPreset352x288) {
                fgFillVideoRawFrame(baseAddress, dwSize, dwWidth, dwHeight, 0);
            }else {
                fgFillVideoRawFrame(baseAddress, dwSize, dwWidth, dwHeight, 1);
            }
            
            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
            
        }
    }
}

@end
