//
//  LXDApplicationMemory.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/26.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDApplicationMemory.h"
#import <mach/mach.h>
#import <mach/task_info.h>


#ifndef NBYTE_PER_MB
#define NBYTE_PER_MB (1024 * 1024)
#endif


@implementation LXDApplicationMemory


- (LXDApplicationMemoryUsage)currentUsage {
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = sizeof(info) / sizeof(integer_t);
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS) {
        return (LXDApplicationMemoryUsage){
            .usage = info.resident_size / NBYTE_PER_MB,
            .total = [NSProcessInfo processInfo].physicalMemory / NBYTE_PER_MB,
            .ratio = info.virtual_size / [NSProcessInfo processInfo].physicalMemory,
        };
    }
    return (LXDApplicationMemoryUsage){ 0 };
}


@end
