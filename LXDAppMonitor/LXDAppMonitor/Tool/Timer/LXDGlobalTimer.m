//
//  LXDGlobalTimer.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDGlobalTimer.h"
#import "LXDDispatchAsync.h"


static NSUInteger lxd_timer_time_interval = 2;
static dispatch_source_t lxd_global_timer = NULL;
static CFMutableDictionaryRef lxd_global_callbacks = NULL;


@implementation LXDGlobalTimer


CF_INLINE void __LXDSyncExecute(dispatch_block_t block) {
    LXDDispatchQueueAsyncBlockInBackground(^{
        assert(block != nil);
        block();
    });
}

CF_INLINE void __LXDInitGlobalCallbacks() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lxd_global_callbacks = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
}

CF_INLINE void __LXDResetTimer() {
    if (lxd_global_timer != NULL) {
        dispatch_source_cancel(lxd_global_timer);
    }
    lxd_global_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, LXDDispatchQueueAsyncBlockInDefault(^{}));
    dispatch_source_set_timer(lxd_global_timer, DISPATCH_TIME_NOW, lxd_timer_time_interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(lxd_global_timer, ^{
        NSUInteger count = CFDictionaryGetCount(lxd_global_callbacks);
        void * callbacks[count];
        CFDictionaryGetKeysAndValues(lxd_global_callbacks, NULL, (const void **)callbacks);
        for (uint idx = 0; idx < count; idx++) {
            dispatch_block_t callback = (__bridge dispatch_block_t)callbacks[idx];
            callback();
        }
    });
}

CF_INLINE void __LXDAutoSwitchTimer() {
    if (CFDictionaryGetCount(lxd_global_callbacks) > 0) {
        if (lxd_global_timer == NULL) {
            __LXDResetTimer();
            dispatch_resume(lxd_global_timer);
        }
    } else {
        if (lxd_global_timer != NULL) {
            dispatch_source_cancel(lxd_global_timer);
            lxd_global_timer = NULL;
        }
    }
}

+ (NSString *)registerTimerCallback: (dispatch_block_t)callback {
    NSString * key = [NSString stringWithFormat: @"%.2f", [[NSDate date] timeIntervalSince1970]];
    [self registerTimerCallback: callback key: key];
    return key;
}

+ (void)registerTimerCallback: (dispatch_block_t)callback key: (NSString *)key {
    if (!callback) { return; }
    __LXDInitGlobalCallbacks();
    __LXDSyncExecute(^{
        CFDictionarySetValue(lxd_global_callbacks, (__bridge void *)key, (__bridge void *)[callback copy]);
        __LXDAutoSwitchTimer();
    });
}

+ (void)resignTimerCallbackWithKey: (NSString *)key {
    if (key == nil) { return; }
    __LXDInitGlobalCallbacks();
    __LXDSyncExecute(^{
        CFDictionaryRemoveValue(lxd_global_callbacks, (__bridge void *)key);
        __LXDAutoSwitchTimer();
    });
}

+ (void)setCallbackInterval: (NSUInteger)interval {
    if (interval <= 0) { interval = 1; }
    lxd_timer_time_interval = interval;
}


@end
