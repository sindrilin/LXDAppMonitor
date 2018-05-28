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
    _sema = dispatch_semaphore_create(0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.fpsMonitorQueue);

    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, _pingInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_semaphore_signal(_sema);
        });
        CFAbsoluteTime pingTime = CFAbsoluteTimeGetCurrent();
        NSArray *stackFrameAddresses = [XXStackFrameBacktracer backtraceMainThreadStackFrames];
        dispatch_semaphore_wait(_sema, DISPATCH_TIME_FOREVER);
        if (CFAbsoluteTimeGetCurrent() - pingTime >= _blockThreshold) {
            [XXStackFramesUploader uploadStackFrames: stackFrameAddresses completion: ^{
            }];
        }
    });
    dispatch_resume(timer);
}
