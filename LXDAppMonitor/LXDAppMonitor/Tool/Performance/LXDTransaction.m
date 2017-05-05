//
//  LXDTransaction.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/5/2.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDTransaction.h"
#import <sys/time.h>



#define TRANSACTION_LOCK(__lock) dispatch_wait(__lock, DISPATCH_TIME_FOREVER)
#define TRANSACTION_UNLOCK(__lock) dispatch_semaphore_signal(__lock);



#pragma mark - Task Queue
@interface LXDExecuteTaskQueue : NSObject
@end


@implementation LXDExecuteTaskQueue


static inline CFMutableArrayRef _lxd_execute_task_queue() {
    static CFMutableArrayRef lxd_execute_task_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lxd_execute_task_queue = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    });
    return lxd_execute_task_queue;
}

static inline dispatch_semaphore_t _lxd_excute_task_queue_lock() {
    static dispatch_semaphore_t lxd_transaction_queue_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lxd_transaction_queue_lock = dispatch_semaphore_create(1);
    });
    return lxd_transaction_queue_lock;
}

+ (dispatch_block_t)fetchExecuteTask {
    if (CFArrayGetCount(_lxd_execute_task_queue()) == 0) { return nil; }
    TRANSACTION_LOCK(_lxd_excute_task_queue_lock());
    dispatch_block_t executeTask = CFArrayGetValueAtIndex(_lxd_execute_task_queue(), 0);
    CFArrayRemoveValueAtIndex(_lxd_execute_task_queue(), 0);
    TRANSACTION_UNLOCK(_lxd_excute_task_queue_lock());
    return executeTask;
}

+ (void)insertExecuteTask: (dispatch_block_t)block {
    assert(block != nil);
    TRANSACTION_LOCK(_lxd_excute_task_queue_lock());
    CFArrayAppendValue(_lxd_execute_task_queue(), (__bridge void *)[block copy]);
    TRANSACTION_UNLOCK(_lxd_excute_task_queue_lock());
}


@end




#pragma mark - RunLoop Observer
static struct timeval lxd_free_loop_entry_time;
static inline bool _lxd_calculate_time_interval_valid(struct timeval start, struct timeval end) {
    static long lxd_max_loop_time = NSEC_PER_SEC / 60 * 0.8;
    long time_interval = (end.tv_sec - start.tv_sec) * NSEC_PER_SEC + (end.tv_usec - start.tv_usec);
    return time_interval < lxd_max_loop_time;
}

static void _lxd_run_loop_free_time_observer(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void * info) {
    gettimeofday(&lxd_free_loop_entry_time, NULL);
}

static void _lxd_transaction_run_loop_observer(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void * info) {
    struct timeval current_time;
    dispatch_block_t executeTask;
    
    do {
        executeTask = [LXDExecuteTaskQueue fetchExecuteTask];
        if (executeTask != nil) { executeTask(); }
        else { break; }
        gettimeofday(&current_time, NULL);
    } while( _lxd_calculate_time_interval_valid(lxd_free_loop_entry_time, current_time) );
}



#pragma mark - Transaction
@implementation LXDTransaction


static bool lxd_transaction_flag = false;
static inline dispatch_semaphore_t _lxd_transaction_lock() {
    static dispatch_semaphore_t lxd_transaction_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lxd_transaction_lock = dispatch_semaphore_create(1);
    });
    return lxd_transaction_lock;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true, 0x0,
                                           _lxd_run_loop_free_time_observer, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
        
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,
                                           0xFFFFFF,
                                           _lxd_transaction_run_loop_observer, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}

+ (void)begin {
    if (lxd_transaction_flag) { return; }
    TRANSACTION_LOCK(_lxd_transaction_lock());
    lxd_transaction_flag = true;
    TRANSACTION_UNLOCK(_lxd_transaction_lock());
}

+ (void)commit {
    if (!lxd_transaction_flag) { return; }
    TRANSACTION_LOCK(_lxd_transaction_lock());
    lxd_transaction_flag = false;
    TRANSACTION_UNLOCK(_lxd_transaction_lock());
}


@end
