//
//  LXDAppFluencyMonitor.m
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/22.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDAppFluencyMonitor.h"
#import "LXDBacktraceLogger.h"
#import <UIKit/UIKit.h>


#define LXD_SEMAPHORE_SUCCESS 0
static BOOL lxd_is_monitoring = NO;
static dispatch_semaphore_t lxd_semaphore;
static NSTimeInterval lxd_time_out_interval = 0.5;


@implementation LXDAppFluencyMonitor

static inline dispatch_queue_t __lxd_fluecy_monitor_queue() {
    static dispatch_queue_t lxd_fluecy_monitor_queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        lxd_fluecy_monitor_queue = dispatch_queue_create("com.sindrilin.lxd_monitor_queue", NULL);
    });
    return lxd_fluecy_monitor_queue;
}

static inline void __lxd_monitor_init() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lxd_semaphore = dispatch_semaphore_create(0);
    });
}

#pragma mark - Public
+ (instancetype)monitor {
    return [LXDAppFluencyMonitor new];
}

- (void)startMonitoring {
    if (lxd_is_monitoring) { return; }
    lxd_is_monitoring = YES;
    __lxd_monitor_init();
    dispatch_async(__lxd_fluecy_monitor_queue(), ^{
        while (lxd_is_monitoring) {
            __block BOOL timeOut = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                timeOut = NO;
                dispatch_semaphore_signal(lxd_semaphore);
            });
            [NSThread sleepForTimeInterval: lxd_time_out_interval];
            if (timeOut) {
                [LXDBacktraceLogger lxd_logMain];
            }
            dispatch_wait(lxd_semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}

- (void)stopMonitoring {
    if (!lxd_is_monitoring) { return; }
    lxd_is_monitoring = NO;
}


@end
