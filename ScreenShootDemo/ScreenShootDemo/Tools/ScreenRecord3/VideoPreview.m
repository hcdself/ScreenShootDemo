//
//  VideoPreview.m
//  VideoTest2
//
//  Created by henry on 2017/12/13.
//  Copyright © 2017年 chengda. All rights reserved.
//

#import "VideoPreview.h"
#import <AVFoundation/AVFoundation.h>
#import <ReplayKit/ReplayKit.h>

@interface VideoPreview ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewlayer;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@end

@implementation VideoPreview

#pragma mark - lazy load
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {//设置分辨率
            _session.sessionPreset=AVCaptureSessionPresetMedium;
        }
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewlayer {
    if (!_previewlayer) {
        _previewlayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewlayer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self =[super initWithCoder:aDecoder]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        [self setUpVideo];
        [self startSession];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        [self setUpVideo];
        [self startSession];
    }
    return self;
}

- (void)turnOrientation:(NSNotification *)noti {
    
    UIInterfaceOrientation current = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (current == UIInterfaceOrientationLandscapeLeft || current == UIInterfaceOrientationLandscapeRight) {
        self.previewlayer.connection.videoOrientation = current;
    }
}

- (void)startSession {
    [self.session startRunning];
}

- (void)stopSession {
    [self.session stopRunning];
}

- (void)setUpVideo
{
    // 2.1 获取视频输入设备(摄像头)
    AVCaptureDevice *videoCaptureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];//取得后置摄像头
    
    // 2.2 创建视频输入源
    NSError *error=nil;
    self.videoInput= [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:&error];
    // 2.3 将视频输入源添加到会话
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
    
    self.previewlayer.frame = self.bounds;//rect;
    self.previewlayer.connection.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self.layer insertSublayer:self.previewlayer atIndex:0];
    
}

#pragma mark - 获取摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

//切换摄像头
- (void)turnCameraAction
{
    [self.session stopRunning];
    // 1. 获取当前摄像头
    AVCaptureDevicePosition position = self.videoInput.device.position;
    
    //2. 获取当前需要展示的摄像头
    if (position == AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
        
    } else {
        position = AVCaptureDevicePositionBack;
    }
    
    // 3. 根据当前摄像头创建新的device
    AVCaptureDevice *device = [self getCameraDeviceWithPosition:position];
    
    // 4. 根据新的device创建input
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //5. 在session中切换input
    [self.session beginConfiguration];
    [self.session removeInput:self.videoInput];
    [self.session addInput:newInput];
    [self.session commitConfiguration];
    self.videoInput = newInput;
    
    [self.session startRunning];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
