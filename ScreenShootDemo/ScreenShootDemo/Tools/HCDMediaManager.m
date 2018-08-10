//
//  HCDMediaManager.m
//  ScreenShootDemo
//
//  Created by henry on 2018/8/10.
//  Copyright © 2018年 henry. All rights reserved.
//

#import "HCDMediaManager.h"

@implementation HCDMediaManager
{
    NSTimer *timer;
    NSInteger countTime;
    NSString *videoPath;
    NSString *audioPath;
    NSString *toFilePath;
}

static HCDMediaManager *manager = nil;
+ (id)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HCDMediaManager alloc] init];
    });
    return manager;
}

- (void)startRecordWithFilePath:(NSString *)filePath completion:(MediaCompletionBlock)completion {
    
    self.completion = completion;
    
    if (self.recordType == RecordAudio) {
        audioPath = filePath;
        toFilePath = filePath;
        videoPath = nil;
        [[HCDAudioManager sharedManager] startRecordWithFilePath: audioPath];
    } else if (self.recordType == RecordScreen){
        
        videoPath = filePath;
        toFilePath = filePath;
        audioPath = nil;
        NSURL *fileUrl = [NSURL fileURLWithPath:videoPath];
        [ASScreenRecorder sharedInstance].videoURL = fileUrl;
        [[ASScreenRecorder sharedInstance] startRecording];
        
    } else if (self.recordType == RecordAudioAndScreen){
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
        NSString * fileName = [formatter stringFromDate:date];
        
        NSString *audioFileName = [fileName stringByAppendingString:@".caf"];
        NSString* videofileName = [fileName stringByAppendingString:@".mp4"];
        audioPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:audioFileName];
        videoPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:videofileName];
        toFilePath = filePath;
        
        //录制音频
        [[HCDAudioManager sharedManager] startRecordWithFilePath: audioPath];
        
        //录制屏幕
        NSURL *fileUrl = [NSURL fileURLWithPath:videoPath];
        [ASScreenRecorder sharedInstance].videoURL = fileUrl;
        [[ASScreenRecorder sharedInstance] startRecording];
        
    }
    
    //显示录制时间
    countTime = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecordTime:) userInfo:nil repeats:YES];
}

//停止录制
- (void)stopRecord {
    
    [timer invalidate];
    timer = nil;
    
    if (self.recordType == RecordAudio) {
        [[HCDAudioManager sharedManager] stopRecord];
        [self finishRecord];
    } else if (self.recordType == RecordScreen){
        [[ASScreenRecorder sharedInstance] stopRecordingWithCompletion:^{
            [self finishRecord];
        }];
    } else if (self.recordType == RecordAudioAndScreen){
        [[HCDAudioManager sharedManager] stopRecord];
        
        [[ASScreenRecorder sharedInstance] stopRecordingWithCompletion:^{
            //音频、视频合并
            [THCaptureUtilities mergeVideo:self->videoPath andAudio:self->audioPath toPath:self->toFilePath andTarget:self andAction:@selector(finishRecord)];
        }];
        [self finishRecord];
    }
}

- (void)finishRecord {
    //NSLog(@"录制完成");
    if (self.completion) {
        self.completion();
    }
}

- (void)updateRecordTime:(NSTimer *)timer {
    countTime++;
    if (self.recordTimeBlock) {
        self.recordTimeBlock([self createTimeForm:countTime]);
    }
}

- (NSString *)createTimeForm:(double)time {
    //时
    int hour = time/3600;
    //分
    int minute = time/60 - hour *60;
    //秒
    int second = ((int)time)%60;
    NSString *timeStr = nil;
    if (hour >0) {
        timeStr = [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
    } else {
        timeStr = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    }
    
    return timeStr;
}



@end
