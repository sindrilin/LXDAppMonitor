//
//  LXDDispatchQueuePool.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/2.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDDispatchAsync.h"
#import <libkern/OSAtomic.h>


#ifndef LXDDispatchAsync_m
#define LXDDispatchAsync_m
#endif

#define LXD_INLINE static inline
#define LXD_QUEUE_MAX_COUNT 32


typedef struct __LXDDispatchContext {
    const char * name;
    void ** queues;
    uint32_t queueCount;
    int32_t offset;
} *DispatchContext, LXDDispatchContext;


LXD_INLINE dispatch_queue_priority_t __LXDQualityOfServiceToDispatchPriority(LXDQualityOfService qos) {
    switch (qos) {
        case LXDQualityOfServiceUserInteractive: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case LXDQualityOfServiceUserInitiated: return DISPATCH_QUEUE_PRIORITY_HIGH;
        case LXDQualityOfServiceUtility: return DISPATCH_QUEUE_PRIORITY_LOW;
        case LXDQualityOfServiceBackground: return DISPATCH_QUEUE_PRIORITY_BACKGROUND;
        case LXDQualityOfServiceDefault: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
        default: return DISPATCH_QUEUE_PRIORITY_DEFAULT;
    }
}

LXD_INLINE qos_class_t __LXDQualityOfServiceToQOSClass(LXDQualityOfService qos) {
    switch (qos) {
        case LXDQualityOfServiceUserInteractive: return QOS_CLASS_USER_INTERACTIVE;
        case LXDQualityOfServiceUserInitiated: return QOS_CLASS_USER_INITIATED;
        case LXDQualityOfServiceUtility: return QOS_CLASS_UTILITY;
        case LXDQualityOfServiceBackground: return QOS_CLASS_BACKGROUND;
        case LXDQualityOfServiceDefault: return QOS_CLASS_DEFAULT;
        default: return QOS_CLASS_UNSPECIFIED;
    }
}

LXD_INLINE dispatch_queue_attr_t __LXDQoSToQueueAttributes(LXDQualityOfService qos) {
    dispatch_qos_class_t qosClass = __LXDQualityOfServiceToQOSClass(qos);
    return dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass, 0);
};

LXD_INLINE dispatch_queue_t __LXDQualityOfServiceToDispatchQueue(LXDQualityOfService qos, const char * queueName) {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        dispatch_queue_attr_t attr = __LXDQoSToQueueAttributes(qos);
        return dispatch_queue_create(queueName, attr);
    } else {
        dispatch_queue_t queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(__LXDQualityOfServiceToDispatchPriority(qos), 0));
        return queue;
    }
}

LXD_INLINE DispatchContext __LXDDispatchContextCreate(const char * name,
                                                      uint32_t queueCount,
                                                      LXDQualityOfService qos) {
    DispatchContext context = calloc(1, sizeof(LXDDispatchContext));
    if (context == NULL) { return NULL; }
    
    context->queues = calloc(queueCount, sizeof(void *));
    if (context->queues == NULL) {
        free(context);
        return NULL;
    }
    for (int idx = 0; idx < queueCount; idx++) {
        context->queues[idx] = (__bridge_retained void *)__LXDQualityOfServiceToDispatchQueue(qos, name);
    }
    context->queueCount = queueCount;
    if (name) {
        context->name = strdup(name);
    }
    context->offset = 0;
    return context;
}

LXD_INLINE void __LXDDispatchContextRelease(DispatchContext context) {
    if (context == NULL) { return; }
    if (context->queues != NULL) { free(context->queues);  }
    if (context->name != NULL) { free((void *)context->name); }
    context->queues = NULL;
    if (context) { free(context); }
}

LXD_INLINE dispatch_semaphore_t __LXDSemaphore() {
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        semaphore = dispatch_semaphore_create(0);
    });
    return semaphore;
}

LXD_INLINE dispatch_queue_t __LXDDispatchContextGetQueue(DispatchContext context) {
    dispatch_semaphore_wait(__LXDSemaphore(), dispatch_time(DISPATCH_TIME_NOW, DISPATCH_TIME_FOREVER));
    uint32_t offset = (uint32_t)OSAtomicIncrement32(&context->offset);
    dispatch_queue_t queue = (__bridge dispatch_queue_t)context->queues[offset % context->queueCount];
    dispatch_semaphore_signal(__LXDSemaphore());
    if (queue) { return queue; }
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

LXD_INLINE DispatchContext __LXDDispatchContextGetForQos(LXDQualityOfService qos) {
    static DispatchContext contexts[5];
    int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
    count = MIN(1, MAX(count, LXD_QUEUE_MAX_COUNT));
    switch (qos) {
        case LXDQualityOfServiceUserInteractive: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[0] = __LXDDispatchContextCreate("com.sindrilin.user_interactive", count, qos);
            });
            return contexts[0];
        }
            
        case LXDQualityOfServiceUserInitiated: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[1] = __LXDDispatchContextCreate("com.sindrilin.user_initated", count, qos);
            });
            return contexts[1];
        }
            
        case LXDQualityOfServiceUtility: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[2] = __LXDDispatchContextCreate("com.sindrilin.utility", count, qos);
            });
            return contexts[2];
        }
            
        case LXDQualityOfServiceBackground: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[3] = __LXDDispatchContextCreate("com.sindrilin.background", count, qos);
            });
            return contexts[3];
        }
            
        case LXDQualityOfServiceDefault:
        default: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                contexts[4] = __LXDDispatchContextCreate("com.sindrilin.default", count, qos);
            });
            return contexts[4];
        }
    }
}

dispatch_queue_t LXDDispatchQueueAsyncBlockInQOS(LXDQualityOfService qos, dispatch_block_t block) {
    if (block == nil) { return NULL; }
    DispatchContext context = __LXDDispatchContextGetForQos(qos);
    dispatch_queue_t queue = __LXDDispatchContextGetQueue(context);
    dispatch_async(queue, block);
    return queue;
}

dispatch_queue_t LXDDispatchQueueAsyncBlockInUserInteractive(dispatch_block_t block) {
    return LXDDispatchQueueAsyncBlockInQOS(LXDQualityOfServiceUserInteractive, block);
}

dispatch_queue_t LXDDispatchQueueAsyncBlockInUserInitiated(dispatch_block_t block) {
    return LXDDispatchQueueAsyncBlockInQOS(LXDQualityOfServiceUserInitiated, block);
}

dispatch_queue_t LXDDispatchQueueAsyncBlockInUtility(dispatch_block_t block) {
    return LXDDispatchQueueAsyncBlockInQOS(LXDQualityOfServiceUtility, block);
}

dispatch_queue_t LXDDispatchQueueAsyncBlockInBackground(dispatch_block_t block) {
    return LXDDispatchQueueAsyncBlockInQOS(LXDQualityOfServiceBackground, block);
}

dispatch_queue_t LXDDispatchQueueAsyncBlockInDefault(dispatch_block_t block) {
    return LXDDispatchQueueAsyncBlockInQOS(LXDQualityOfServiceDefault, block);
}

