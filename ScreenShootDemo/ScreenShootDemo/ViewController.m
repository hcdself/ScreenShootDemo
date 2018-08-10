//
//  ViewController.m
//  ScreenShootDemo
//
//  Created by henry on 2018/8/9.
//  Copyright © 2018年 henry. All rights reserved.
//

#import "ViewController.h"
#import "ScreenRecorder.h"
#import "ASScreenRecorder.h"
#import "THCaptureUtilities.h"
#import "HCDAudioManager.h"
#import "HCDMediaManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeLb;

@end

@implementation ViewController
{
    NSTimer *timer;
    NSInteger countTime;
    NSString *videoPath;
    NSString *audioPath;
    NSString *toFilePath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)startRecord:(UIButton *)sender {

    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"test.mp4"];
    NSLog(@"%@",filePath);
    HCDMediaManager *manager = [HCDMediaManager sharedManager];
    manager.recordType = RecordScreen;
    manager.recordTimeBlock = ^(NSString *recordTimeStr) {
        self.timeLb.text = recordTimeStr;
    };
    [manager startRecordWithFilePath:filePath completion:^{
        NSLog(@"录制完成");
    }];
}

//停止录屏
- (IBAction)stopRecord:(UIButton *)sender {

    [[HCDMediaManager sharedManager] stopRecord];
}




@end
