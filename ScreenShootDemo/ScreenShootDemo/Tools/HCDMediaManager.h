//
//  HCDMediaManager.h
//  ScreenShootDemo
//
//  Created by henry on 2018/8/10.
//  Copyright © 2018年 henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScreenRecorder.h"
#import "ASScreenRecorder.h"
#import "THCaptureUtilities.h"
#import "HCDAudioManager.h"

typedef enum : NSUInteger {
    RecordAudio,
    RecordScreen,
    RecordAudioAndScreen,
} RecordType;

typedef void(^MediaTimeCallBlock)(NSString *recordTimeStr);
typedef void(^MediaCompletionBlock)(void);

@interface HCDMediaManager : NSObject

@property (nonatomic, strong) MediaTimeCallBlock recordTimeBlock;
@property (nonatomic, strong) MediaCompletionBlock completion;
@property (nonatomic, assign) RecordType recordType;

+ (id)sharedManager;
- (void)startRecordWithFilePath:(NSString *)filePath completion:(MediaCompletionBlock)completion;
- (void)stopRecord;

@end
