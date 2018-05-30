//
//  main.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/29.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"



int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

- (void)runloopDidUpdateState: (CFRunLoopActivity)state {
    NSArray *_stackFrames;
    dispatch_queue_t _serialQueue;
    
    CGFloat _blockThreshold = 3;
    CFAbsoluteTime _lastTime = CFAbsoluteTimeGetCurrent();
    if (CFAbsoluteTimeGetCurrent() - _lastTime >= _blockThreshold) {
        [XXStackFramesUploader uploadStackFrames: _stackFrames completion: nil];
    }
    dispatch_async(_serialQueue, ^{
        _stackFrames = [XXStackFrameBacktracer backtraceMainThreadStackFrames];
    });
    _lastTime = CFAbsoluteTimeGetCurrent();
}
