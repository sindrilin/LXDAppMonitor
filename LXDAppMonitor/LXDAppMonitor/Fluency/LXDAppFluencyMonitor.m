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
#define LXD_RESPONSE_THRESHOLD 60
static NSTimeInterval lxd_time_out_interval = 0.5;


#define LXD_MONITOR_NEED_OBSERVER 0
#define LXD_MONITOR_ASYNC_OBSERVER 0


@interface LXDAppFluencyMonitor ()

@property (nonatomic, assign) int timeOut;
@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, weak) CADisplayLink * displayLink;
@property (nonatomic, strong) dispatch_semaphore_t semphore;

#if LXD_MONITOR_NEED_OBSERVER
@property (nonatomic, assign) CFRunLoopObserverRef observer;
@property (nonatomic, assign) CFRunLoopActivity currentActivity;
#endif

@end


/*!
 *  @brief  监听runloop状态在after waiting和before sources之间
 */
static inline dispatch_queue_t lxd_fluecy_monitor_queue() {
    static dispatch_queue_t lxd_fluecy_monitor_queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        lxd_fluecy_monitor_queue = dispatch_queue_create("com.sindrilin.lxd_monitor_queue", NULL);
    });
    return lxd_fluecy_monitor_queue;
}

#if LXD_MONITOR_NEED_OBSERVER
#define LOG_RUNLOOP_ACTIVITY 0
static void lxdRunLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void * info) {
    FLUENCYMONITOR.currentActivity = activity;
#if LOG_RUNLOOP_ACTIVITY
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"runloop entry");
            break;
            
        case kCFRunLoopExit:
            NSLog(@"runloop exit");
            break;
            
        case kCFRunLoopAfterWaiting:
            NSLog(@"runloop after waiting");
            break;
            
        case kCFRunLoopBeforeTimers:
            NSLog(@"runloop before timers");
            break;
            
        case kCFRunLoopBeforeSources:
            NSLog(@"runloop before sources");
            break;
            
        case kCFRunLoopBeforeWaiting:
            NSLog(@"runloop before waiting");
            break;
            
        default:
            break;
    }
#endif
};
#endif




@implementation LXDAppFluencyMonitor


#pragma mark - Singleton override
+ (instancetype)shareMonitor {
    static LXDAppFluencyMonitor * shareMonitor;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareMonitor = [[super allocWithZone: NSDefaultMallocZone()] init];
        [shareMonitor commonInit];
    });
    return shareMonitor;
}

+ (instancetype)allocWithZone: (struct _NSZone *)zone {
    return [self shareMonitor];
}

- (void)dealloc {
    [self stopMonitoring];
}

- (void)commonInit {
    self.semphore = dispatch_semaphore_create(0);
}


#pragma mark - Public
- (void)startMonitoring {
    if (_isMonitoring) { return; }
    
    _isMonitoring = YES;
    dispatch_async(lxd_fluecy_monitor_queue(), ^{
        CADisplayLink * displayLink = [CADisplayLink displayLinkWithTarget: self selector: @selector(screenRenderCall)];
        [self.displayLink invalidate];
        self.displayLink = displayLink;
        
        [self.displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, CGFLOAT_MAX, NO);
    });
    
#if LXD_MONITOR_NEED_OBSERVER
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)self,
        NULL,
        NULL
    };
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &lxdRunLoopObserverCallback, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
#endif
    
    
#if LXD_MONITOR_ASYNC_OBSERVER
    dispatch_async(lxd_fluecy_monitor_queue(), ^{
        while (FLUENCYMONITOR.isMonitoring) {
#if LXD_MONITOR_NEED_OBSERVER
            switch (FLUENCYMONITOR.currentActivity) {
                case kCFRunLoopAfterWaiting:
                case kCFRunLoopBeforeWaiting:
                case kCFRunLoopBeforeSources: {
                    __block BOOL timeOut = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        timeOut = NO;
                        dispatch_semaphore_signal(FLUENCYMONITOR.semphore);
                    });
                    [NSThread sleepForTimeInterval: lxd_time_out_interval];
                    if (timeOut) {
                        [LXDBacktraceLogger lxd_logMain];
                    }
                    dispatch_wait(FLUENCYMONITOR.semphore, DISPATCH_TIME_FOREVER);
                } break;
                    
                default:
                    break;
            }
#else
            __block BOOL timeOut = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                timeOut = NO;
                dispatch_semaphore_signal(FLUENCYMONITOR.semphore);
            });
            [NSThread sleepForTimeInterval: lxd_time_out_interval];
            if (timeOut) {
                [LXDBacktraceLogger lxd_logMain];
            }
            dispatch_wait(FLUENCYMONITOR.semphore, DISPATCH_TIME_FOREVER);
#endif
        }
    });
#endif
}

- (void)screenRenderCall {
    __block BOOL flag = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        flag = NO;
        dispatch_semaphore_signal(self.semphore);
    });
    dispatch_wait(self.semphore, 16.7 * NSEC_PER_MSEC);
    if (flag) {
        if (++self.timeOut < LXD_RESPONSE_THRESHOLD) { return; }
        [LXDBacktraceLogger lxd_logMain];
        dispatch_wait(self.semphore, DISPATCH_TIME_FOREVER);
    }
    self.timeOut = 0;
}

- (void)stopMonitoring {
    if (!_isMonitoring) { return; }
    _isMonitoring = NO;
    
    [self.displayLink invalidate];
    dispatch_async(lxd_fluecy_monitor_queue(), ^{
        [self.displayLink removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
        CFRunLoopStop([NSRunLoop currentRunLoop].getCFRunLoop);
    });
    
#if LXD_MONITOR_NEED_OBSERVER
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = nil;
#endif
}


@end
