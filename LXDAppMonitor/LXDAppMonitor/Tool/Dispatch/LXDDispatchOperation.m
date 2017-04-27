//
//  LXDDispatchOperation.m
//  LXDDispatchOperation
//
//  Created by linxinda on 2017/4/6.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDDispatchOperation.h"
#import "LXDDispatchAsync.h"


#ifndef LXDDispatchAsync_m
#define LXD_INLINE static inline
#endif

#define LXD_FUNCTION_OVERLOAD __attribute__((overloadable))


LXD_INLINE LXD_FUNCTION_OVERLOAD void __LXDLockExecute(dispatch_block_t block, dispatch_time_t threshold);

LXD_INLINE LXD_FUNCTION_OVERLOAD void __LXDLockExecute(dispatch_block_t block) {
    __LXDLockExecute(block, dispatch_time(DISPATCH_TIME_NOW, DISPATCH_TIME_FOREVER));
}

LXD_INLINE LXD_FUNCTION_OVERLOAD void __LXDLockExecute(dispatch_block_t block, dispatch_time_t threshold) {
    if (block == nil) { return ; }
    static dispatch_semaphore_t lxd_queue_semaphore;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        lxd_queue_semaphore = dispatch_semaphore_create(0);
    });
    dispatch_semaphore_wait(lxd_queue_semaphore, threshold);
    block();
    dispatch_semaphore_signal(lxd_queue_semaphore);
}


@interface LXDDispatchOperation ()

@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, assign) BOOL isExcuting;
@property (nonatomic, assign) dispatch_queue_t queue;
@property (nonatomic, assign) dispatch_queue_t (*asyn)(dispatch_block_t);
@property (nonatomic, copy) LXDCancelableBlock cancelableBlock;

@end


@implementation LXDDispatchOperation


+ (instancetype)dispatchOperationWithBlock: (dispatch_block_t)block {
    return [self dispatchOperationWithCancelableBlock: ^(LXDDispatchOperation *operation) {
        if (!operation.isCanceled) {
            block();
        }
    } inQos: NSQualityOfServiceDefault];
}

+ (instancetype)dispatchOperationWithBlock: (dispatch_block_t)block inQoS: (NSQualityOfService)qos {
    return [self dispatchOperationWithCancelableBlock: ^(LXDDispatchOperation *operation) {
        if (!operation.isCanceled) {
            block();
        }
    } inQos: qos];
}

+ (instancetype)dispatchOperationWithCancelableBlock:(LXDCancelableBlock)block {
    return [self dispatchOperationWithCancelableBlock: block inQos: NSQualityOfServiceDefault];
}

+ (instancetype)dispatchOperationWithCancelableBlock:(LXDCancelableBlock)block inQos: (NSQualityOfService)qos {
    return [[self alloc] initWithBlock: block inQos: qos];
}

- (instancetype)initWithBlock: (LXDCancelableBlock)block inQos: (NSQualityOfService)qos {
    if (block == nil) { return nil; }
    if (self = [super init]) {
        switch (qos) {
            case NSQualityOfServiceUserInteractive:
                self.asyn = LXDDispatchQueueAsyncBlockInUserInteractive;
                break;
            case NSQualityOfServiceUserInitiated:
                self.asyn = LXDDispatchQueueAsyncBlockInUserInitiated;
                break;
            case NSQualityOfServiceDefault:
                self.asyn = LXDDispatchQueueAsyncBlockInDefault;
                break;
            case NSQualityOfServiceUtility:
                self.asyn = LXDDispatchQueueAsyncBlockInUtility;
                break;
            case NSQualityOfServiceBackground:
                self.asyn = LXDDispatchQueueAsyncBlockInBackground;
                break;
            default:
                self.asyn = LXDDispatchQueueAsyncBlockInDefault;
                break;
        }
        self.cancelableBlock = block;
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}

- (void)start {
    __LXDLockExecute(^{
        self.queue = self.asyn(^{
            self.cancelableBlock(self);
            self.cancelableBlock = nil;
        });
        self.isExcuting = YES;
    });
}

- (void)cancel {
    __LXDLockExecute(^{
        self.isCanceled = YES;
        if (!self.isExcuting) {
            self.asyn = NULL;
            self.cancelableBlock = nil;
        }
    });
}


@end
