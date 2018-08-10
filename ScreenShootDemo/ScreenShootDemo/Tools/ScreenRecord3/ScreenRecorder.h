//
//  ScreenRecorder.h
//  VideoTest2
//
//  Created by henry on 2017/12/13.
//  Copyright © 2017年 chengda. All rights reserved.
//
/**
 采用ReplayKit录屏
 缺点：1、UI不能自定义；2、录制多次会报错，录制不了；3、选择仅录屏时录制不了
 */
#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@protocol ScreenRecorderDelegate <NSObject>

@optional

//不断获取录屏时间
- (void)ScreenRecorderUpadteTime:(NSInteger)recordTime;
- (void)ScreenRecorderTimeToPeak;

@end

typedef void(^CompletionBlock)(NSString *errorStr);

@interface ScreenRecorder : NSObject

@property (nonatomic,weak)id<ScreenRecorderDelegate>delegate;

@property (nonatomic,assign)NSInteger maxTime;
@property (nonatomic,assign)BOOL isRecording;

+(instancetype)sharedInstance;
- (void)prepareWithViewController:(UIViewController *)viewController;

/**
 初始化
 @param viewController 系统框架用到
 */
- (instancetype)initWithViewController:(UIViewController *)viewController;

//开始录屏
- (void)StartRecoderWithFilePath:(NSString *)savePath;

//结束录屏
- (void)stopDecoder;

@end
