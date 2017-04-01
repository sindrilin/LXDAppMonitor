//
//  LXDSystemCPU.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/1.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDSystemCPU.h"
#import <mach/mach_host.h>
#import <mach/processor_info.h>

//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//#import <CoreTelephony/CTCarrier.h>
//#import <mach/mach.h>
//#import <sys/types.h>
//#import <sys/param.h>
//#import <sys/mount.h>
//#include <sys/types.h>
//#include <sys/sysctl.h>
//#include <sys/socket.h>
//#include <sys/sysctl.h>
//#include <sys/stat.h>
//#include <net/if.h>
//#include <net/if_dl.h>


static NSArray * previousCPUInfo;


/// processor_info_array_t结构数据偏移位
typedef NS_ENUM(NSInteger, LXDCPUInfoOffsetState)
{
    LXDCPUInfoOffsetStateSystem = 0,
    LXDCPUInfoOffsetStateUser = 1,
    LXDCPUInfoOffsetStateNice = 2,
    LXDCPUInfoOffsetStateIdle = 3,
    LXDCPUInfoOffsetStateMask = 4,
};

/// cpu信息结构体
static NSUInteger LXDSystemCPUInfoCount = 4;
typedef struct LXDSystemCPUInfo {
    NSUInteger system;
    NSUInteger user;
    NSUInteger nice;
    NSUInteger idle;
} LXDSystemCPUInfo;

/// 结构体构造转换
static inline LXDSystemCPUInfo LXDSystemCPUInfoMake(NSUInteger system, NSUInteger user, NSUInteger nice, NSUInteger idle) {
    return (LXDSystemCPUInfo){ system, user, nice, idle };
}

static inline NSString * LXDStringFromSystemCPUInfo(LXDSystemCPUInfo systemCPUInfo) {
    return [NSString stringWithFormat: @"%lu-%lu-%lu-%lu", systemCPUInfo.system, systemCPUInfo.user, systemCPUInfo.nice, systemCPUInfo.idle];
}

static inline LXDSystemCPUInfo LXDSystemCPUInfoFromString(NSString * string) {
    NSArray * infos = [string componentsSeparatedByString: @"-"];
    if (infos.count == LXDSystemCPUInfoCount) {
        return LXDSystemCPUInfoMake(
                                    [infos[LXDCPUInfoOffsetStateSystem] unsignedIntegerValue],
                                    [infos[LXDCPUInfoOffsetStateUser] unsignedIntegerValue],
                                    [infos[LXDCPUInfoOffsetStateNice] unsignedIntegerValue],
                                    [infos[LXDCPUInfoOffsetStateIdle] unsignedIntegerValue]);
    }
    return (LXDSystemCPUInfo){ 0 };
}


@implementation LXDSystemCPU


- (void)updateCPUInfo {
    natural_t cpu_processor_count = 0;
    natural_t cpu_processor_info_count = 0;
    processor_info_array_t cpu_processor_infos = NULL;
    
    kern_return_t result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpu_processor_count, &cpu_processor_infos, &cpu_processor_info_count);
    if ( result == KERN_SUCCESS && cpu_processor_infos != NULL ) {
        NSMutableArray * infos = [NSMutableArray arrayWithCapacity: cpu_processor_count];
        
    }
}


@end
