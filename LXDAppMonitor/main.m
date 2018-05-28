//
//  main.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/29.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

void kRunloopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    XXRunLoopObserver *client = (__bridge XXRunLoopObserver *)info;
    [client runloopDidUpdateState: activity];
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    CFRunLoopObserverContext context = { 0, (__bridge void*)self, NULL, NULL };
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities ^ kCFRunLoopBeforeWaiting, YES, 0, &kRunloopObserver, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
}
