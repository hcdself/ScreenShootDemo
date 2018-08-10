//
//  ScreenRecorder.m
//  VideoTest2
//
//  Created by henry on 2017/12/13.
//  Copyright © 2017年 chengda. All rights reserved.
//

#import "ScreenRecorder.h"
#import <Photos/Photos.h>
#import <ReplayKit/ReplayKit.h>
#import "MBProgressHUD.h"

@interface ScreenRecorder()<RPScreenRecorderDelegate,RPPreviewViewControllerDelegate>

@property (nonatomic,strong)RPPreviewViewController *RPPreview;
@property (nonatomic,weak) UIViewController *viewController;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CompletionBlock completionBlock;
@property (nonatomic, assign) NSInteger countTime;
@property (nonatomic, assign) BOOL isSave;

@end

@implementation ScreenRecorder
{
    NSString *filePath;
}

+(instancetype)sharedInstance {
    static ScreenRecorder *recorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorder = [[ScreenRecorder alloc] init];
    });
    return recorder;
}

- (void)prepareWithViewController:(UIViewController *)viewController {
    _viewController = viewController;
    _isRecording = NO;
    __weak typeof(self) weakSelf = self;
    
    self.completionBlock = ^(NSString * errorStr) {
        
        NSLog(@"errorStr--%@",errorStr);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.hud removeFromSuperview];
        });
        
        if (errorStr) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showAlert:@"提示" andMessage:@"保存失敗"];
                });
            });
        }
        [weakSelf hideVideoPreviewController:weakSelf.RPPreview withAnimation:YES];
    };
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        
        _viewController = viewController;
        _isRecording = NO;
        __weak typeof(self) weakSelf = self;
        
        self.completionBlock = ^(NSString * errorStr) {
            NSLog(@"errorStr--%@",errorStr);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.hud removeFromSuperview];
            });
            
            if (errorStr) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showAlert:@"提示" andMessage:@"保存失敗"];
                    });
                });
            }
            [weakSelf hideVideoPreviewController:weakSelf.RPPreview withAnimation:YES];
        };
    }
    return self;
}

#pragma mark - replayKit
//开始录屏
- (void)StartRecoderWithFilePath:(NSString *)savePath {
    
    filePath = savePath;
    //将开启录屏功能的代码放在主线程执行
    dispatch_queue_t queue = dispatch_get_main_queue();
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        if ([[RPScreenRecorder sharedRecorder] isAvailable] && [self isSystemVersionOk]) { //判断硬件和ios版本是否支持录屏
           // NSLog(@"支持ReplayKit录制");
            //这是录屏的类
            RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
            recorder.delegate = self;
            recorder.cameraEnabled = YES;
            recorder.microphoneEnabled = YES;
            
            [recorder startRecordingWithHandler:^(NSError * _Nullable error) {
                if (error) {
                   // NSLog(@"开始录屏错误error--%@",error);
                    [self showAlert:@"提示" andMessage:@"錄屏功能啟動失敗"];
                }else {
                    NSLog(@"开始录屏成功");
                    weakSelf.countTime = 0;
                    if (weakSelf.timer == nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
                        });
                    }
                    weakSelf.isRecording = YES;
                }
            }];
        } else {
            [self showAlert:@"设备不支持录制" andMessage:@"升级ios系统"];
            NSLog(@"设备不支持录屏");
            return;
        }
    });
}

- (void)updateTime:(NSTimer *)timer {
    self.countTime++;
    if (self.countTime >self.maxTime && self.maxTime >0) {//时间达到规定值，停止录屏
        [timer invalidate];
        timer = nil;
        
        [self stopDecoder];
        
        if ([_delegate respondsToSelector:@selector(ScreenRecorderTimeToPeak)]) {
            [_delegate ScreenRecorderTimeToPeak];
        }
        
    } else {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(ScreenRecorderUpadteTime:)]) {
            [_delegate ScreenRecorderUpadteTime:self.countTime];
        }
    }
}

//结束录屏
- (void)stopDecoder {
    __weak typeof (self)weakSelf = self;
    
    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController *previewViewController, NSError *  error){
        

        [weakSelf.timer invalidate];
        weakSelf.timer = nil;
        weakSelf.isRecording = NO;
        
       weakSelf.RPPreview = previewViewController;
        if (error) {
            NSLog(@"这里关闭有误%@",error.description);
        } else {
            NSLog(@"展示录屏");
            [self.RPPreview setPreviewControllerDelegate:self];
            //在结束录屏时显示预览画面
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showVideoPreviewController:weakSelf.RPPreview withAnimation:YES];
            });
        }
    }];
}

//显示视频预览页面,animation=是否要动画显示
- (void)showVideoPreviewController:(RPPreviewViewController *)previewController withAnimation:(BOOL)animation {
    __weak typeof (self) weakSelf = self;
    //UI需要放到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = previewController.view.frame;
        if (animation) {
            rect.origin.x += rect.size.width;
            previewController.view.frame = rect;
            rect.origin.x -= rect.size.width;
            [UIView animateWithDuration:0.3 animations:^(){
                previewController.view.frame = rect;
            } completion:^(BOOL finished){
            }];
        } else {
            previewController.view.frame = rect;
        }
        [weakSelf.viewController.view addSubview:previewController.view];
        [weakSelf.viewController addChildViewController:previewController];
    });
}

//关闭视频预览页面，animation=是否要动画显示
- (void)hideVideoPreviewController:(RPPreviewViewController *)previewController withAnimation:(BOOL)animation {
    //UI需要放到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = previewController.view.frame;
        if (animation) {
            rect.origin.x += rect.size.width;
            [UIView animateWithDuration:0.3 animations:^(){
                previewController.view.frame = rect;
            } completion:^(BOOL finished){
                //移除页面
                [previewController.view removeFromSuperview];
                [previewController removeFromParentViewController];
            }];
        } else {
            //移除页面
            [previewController.view removeFromSuperview];
            [previewController removeFromParentViewController];
        }
    });
}

#pragma mark - RPPreviewViewControllerDelegate
//关闭的回调
- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    NSLog(@"%s",__func__);
    NSLog(@"currentThread--%@",[NSThread currentThread]);
    if (self.isSave == 1) {
        //获取相册中最新的视频，添加一个延时,不延时的话将获取不到相册中最新的视频，只能获取上一个
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getVideo];
        });
        
        self.isSave = 0;
    }else
    {
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertAction *queding = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf hideVideoPreviewController:weakSelf.RPPreview withAnimation:YES];
                weakSelf.isSave = 0;
            }];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"录制未保存\n确定要取消吗" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:actionCancel];
            [alert addAction:queding];
            [self.viewController presentViewController:alert animated:NO completion:nil];
        });
    }
}
//选择了某些功能的回调（如分享和保存）
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes {
    NSLog(@"%s",__func__);
    __weak typeof (self)weakSelf = self;
    if ([activityTypes containsObject:@"com.apple.UIKit.activity.SaveToCameraRoll"]) {
        self.isSave = 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hud = [MBProgressHUD showHUDAddedTo:self.viewController.view animated:NO];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            self.hud.labelText = @"正在保存...";
        });
    }
    
    if ([activityTypes containsObject:@"com.apple.UIKit.activity.CopyToPasteboard"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAlert:@"復製成功" andMessage:@"已經複製到粘貼板"];
        });
    }
}

#pragma mark ====RPScreenDelegate===
- (void)screenRecorderDidChangeAvailability:(RPScreenRecorder *)screenRecorder
{
    NSLog(@"%s",__func__);
}

//ios10以上已经被废弃
- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(nullable RPPreviewViewController *)previewViewController
{
    NSLog(@"%s\n%@",__func__,error);
//    NSLog(@"停止录屏成功");
//    [_RPPreview setPreviewControllerDelegate:self];
//    [self showVideoPreviewController:_RPPreview withAnimation:YES];
}

//ios11以上才能使用
- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithPreviewViewController:(RPPreviewViewController *)previewViewController error:(NSError *)error {
    NSLog(@"%s\n%@",__func__,error);
}

//显示弹框提示
- (void)showAlert:(NSString *)title andMessage:(NSString *)message {
    if (!title) {
        title = @"";
    }
    if (!message) {
        message = @"";
    }
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:actionCancel];
    [self.viewController presentViewController:alert animated:NO completion:nil];
}

//判断对应系统版本是否支持ReplayKit
- (BOOL)isSystemVersionOk {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 获取相册中的视频
- (void)getVideo {
    //相册的权限
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    if (photoAuthorStatus == PHAuthorizationStatusAuthorized) {

    }else if (photoAuthorStatus == PHAuthorizationStatusDenied ||photoAuthorStatus == PHAuthorizationStatusRestricted){
        UIAlertView *aview= [[UIAlertView alloc] initWithTitle:@"無法訪問相冊" message:@"請在「設定」>「私隱」>「相機」內，在本應用程式選擇「允許」" delegate:self cancelButtonTitle:nil otherButtonTitles:@"確定", nil];
        [aview show];
        return;
        
    }else if (photoAuthorStatus == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self getVideo];
        }];
        return ;
    }
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];//按时间排序
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];

    if (fetchResult.count >0) {
        // 获取相册中最新的视频
        PHAsset *asset = fetchResult[0];
        NSLog(@"获取最新视频time--%@",asset.creationDate);
        
        PHImageManager *manager = [PHImageManager defaultManager];
        PHVideoRequestOptions *requestOptions = [[PHVideoRequestOptions alloc] init];
        
        [manager requestAVAssetForVideo:asset options:requestOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            [self convertVideoToMP4WithAsset:asset];
        }];
    } else {
        self.completionBlock(@"保存失敗");
    }
}

//视频转格式
- (void)convertVideoToMP4WithAsset:(AVAsset *)asset {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        NSURL *oldUrl = [NSURL fileURLWithPath:filePath];
        [[NSFileManager defaultManager] removeItemAtURL:oldUrl error:&error];
        NSLog(@"删除文件error--%@",error);
    }
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality])
    {
        //视频导出并转码
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
        exportSession.outputURL = [NSURL fileURLWithPath:filePath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        __weak typeof(self) weakSelf = self;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    // [weakSelf completeWithUrl:exportSession.outputURL];
                    weakSelf.completionBlock(nil);
                    break;
                default:
                    weakSelf.completionBlock(@"保存失敗");
                    break;
            }
        }];
    }else {
        self.completionBlock(@"保存失敗");
    }
}

@end
