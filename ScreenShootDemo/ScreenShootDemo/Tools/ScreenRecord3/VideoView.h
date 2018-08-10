//
//  VideoView.h
//  VideoTest2
//
//  Created by henry on 2017/12/13.
//  Copyright © 2017年 chengda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPreview.h"

@interface VideoView : UIView

@property (weak, nonatomic) IBOutlet VideoPreview *preview;

- (void)startSession;
- (void)stopSession;
- (void)turnCameraAction;

@end
