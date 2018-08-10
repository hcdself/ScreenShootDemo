//
//  VideoView.m
//  VideoTest2
//
//  Created by henry on 2017/12/13.
//  Copyright © 2017年 chengda. All rights reserved.
//

#import "VideoView.h"

@interface VideoView()<UIGestureRecognizerDelegate>

@property (nonatomic,strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong)UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic,strong)UIRotationGestureRecognizer *rotationGesture;

@end

@implementation VideoView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 100.0;
    
    self.preview.layer.masksToBounds = YES;
    self.preview.layer.cornerRadius = 100.0;
//    self.preview.layer.borderColor = [UIColor cyanColor].CGColor;
//    self.preview.layer.borderWidth = 5.0;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveVideoView:)];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchVideoView:)];
    self.pinchGesture.delegate = self;
    [self addGestureRecognizer:self.pinchGesture];
    self.rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateVideoView:)];
    self.rotationGesture.delegate = self;
    //取消旋转手势
    //[self addGestureRecognizer:self.rotationGesture];
}

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"VideoView" owner:nil options:nil] firstObject];
    
    return self;
}

#pragma mark - 手势

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    [self.superview bringSubviewToFront:self];
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)moveVideoView:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [pan translationInView:pan.view];
        self.transform = CGAffineTransformTranslate(self.transform, point.x, point.y);
        [pan setTranslation:CGPointZero inView:pan.view];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)pinchVideoView:(UIPinchGestureRecognizer *)pinch {
    if (pinch.state == UIGestureRecognizerStateBegan) {
        
    } else if (pinch.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"%.2f",pinch.scale);
        self.transform = CGAffineTransformScale(self.transform, pinch.scale, pinch.scale);
        [pinch setScale:1];
    } else if (pinch.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)rotateVideoView:(UIRotationGestureRecognizer *)rotation {
    if (rotation.state == UIGestureRecognizerStateBegan) {
        
    } else if (rotation.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"%.2f",rotation.rotation);
        self.transform = CGAffineTransformRotate(self.transform, rotation.rotation);
        rotation.rotation = 0;
    } else if (rotation.state == UIGestureRecognizerStateEnded) {
        
    }
}

#pragma mark - 视频相关
- (void)startSession {
    [self.preview startSession];
}

- (void)stopSession {
    [self.preview stopSession];
}

- (void)turnCameraAction {
    [self.preview turnCameraAction];
}

@end
