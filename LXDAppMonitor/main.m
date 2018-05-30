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

- (void)startMonitoring {
    NSArray *_lastStackFrames;
    CGFloat _pingInterval = 3;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.fpsMonitorQueue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, _pingInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(timer, ^{
        NSArray *curStackFrames = [XXStackFrameBacktracer backtraceMainThreadStackFrames];
        if ([_lastStackFrames isEqual: curStackFrames]) {
            [XXStackFramesUploader uploadStackFrames: curStackFrames completion: nil];
            _lastStackFrames = nil;
        } else {
            _lastStackFrames = curStackFrames;
        }
    });
    dispatch_resume(timer);
}
