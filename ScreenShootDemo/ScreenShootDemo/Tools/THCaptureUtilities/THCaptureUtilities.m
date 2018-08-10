//
//  THCaptureUtilities.m
//  ScreenCaptureViewTest
//
//  Created by wayne li on 11-9-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "THCaptureUtilities.h"


@implementation THCaptureUtilities

+ (void)mergeVideo:(NSString *)videoPath andAudio:(NSString *)audioPath toPath:(NSString *)filePath andTarget:(id)target andAction:(SEL)action
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:videoPath]) {
        NSLog(@"要合并的视频路径不存在:%@",videoPath);
        return;
    }
    if (![manager fileExistsAtPath:audioPath]) {
        NSLog(@"要合并的音频路径不存在:%@",videoPath);
        return;
    }
    
    NSURL *audioUrl=[NSURL fileURLWithPath:audioPath];
    NSURL *videoUrl=[NSURL fileURLWithPath:videoPath];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoUrl options:nil];
    
    //混合音乐
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:kCMTimeZero error:nil];
    
    
    //混合视频
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                    atTime:kCMTimeZero error:nil];
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetPassthrough];
    
    //[audioAsset release];
    //[videoAsset release];
    
    //保存混合后的文件的过程
//    NSString* videoName = @"test2.mp4";
//    NSString *exportPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:videoName];
    NSURL *exportUrl = [NSURL fileURLWithPath:filePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    _assetExport.outputFileType = @"com.apple.quicktime-movie";//AVFileTypeMPEG4;//
    NSLog(@"file type %@,filePath--%@",_assetExport.outputFileType,filePath);
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void )
     {
         NSLog(@"完成了");
         // your completion code here
         if ([target respondsToSelector:action])
         {
             [target performSelector:action withObject:filePath withObject:nil];
         }
     }];
    
    //[_assetExport release];
}




@end
