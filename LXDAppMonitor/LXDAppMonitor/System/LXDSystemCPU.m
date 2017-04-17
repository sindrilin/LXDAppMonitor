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
static inline LXDSystemCPUInfo __LXDSystemCPUInfoMake(NSUInteger system, NSUInteger user, NSUInteger nice, NSUInteger idle) {
    return (LXDSystemCPUInfo){ system, user, nice, idle };
}

static inline NSString * LXDStringFromSystemCPUInfo(LXDSystemCPUInfo systemCPUInfo) {
    return [NSString stringWithFormat: @"%lu-%lu-%lu-%lu", systemCPUInfo.system, systemCPUInfo.user, systemCPUInfo.nice, systemCPUInfo.idle];
}

static inline LXDSystemCPUInfo LXDSystemCPUInfoFromString(NSString * string) {
    NSArray * infos = [string componentsSeparatedByString: @"-"];
    if (infos.count == LXDSystemCPUInfoCount) {
        return __LXDSystemCPUInfoMake(
                                    [infos[LXDCPUInfoOffsetStateSystem] unsignedIntegerValue],
                                    [infos[LXDCPUInfoOffsetStateUser] unsignedIntegerValue],
                                    [infos[LXDCPUInfoOffsetStateNice] unsignedIntegerValue],
                                    [infos[LXDCPUInfoOffsetStateIdle] unsignedIntegerValue]);
    }
    return (LXDSystemCPUInfo){ 0 };
}


@interface LXDSystemCPU ()

@property (nonatomic, assign) double systemRatio;
@property (nonatomic, assign) double userRatio;
@property (nonatomic, assign) double niceRatio;
@property (nonatomic, assign) double idleRatio;

@property (nonatomic, copy) NSArray<NSString *> * cpuInfos;

@end


@implementation LXDSystemCPU


- (void)updateCPUInfo {
    natural_t cpu_processor_count = 0;
    natural_t cpu_processor_info_count = 0;
    processor_info_array_t cpu_processor_infos = NULL;
    
    kern_return_t result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpu_processor_count, &cpu_processor_infos, &cpu_processor_info_count);
    if ( result == KERN_SUCCESS && cpu_processor_infos != NULL ) {
        NSMutableArray * infos = [NSMutableArray arrayWithCapacity: cpu_processor_count];
        for (int idx = 0; idx < cpu_processor_count; idx++) {
            NSInteger offset = LXDCPUInfoOffsetStateMask * idx;
            
            double system, user, nice, idle;
            if (previousCPUInfo.count > idx) {
                LXDSystemCPUInfo previousInfo = LXDSystemCPUInfoFromString(previousCPUInfo[idx]);
                system = cpu_processor_infos[offset + LXDCPUInfoOffsetStateSystem] - previousInfo.system;
                user = cpu_processor_infos[offset + LXDCPUInfoOffsetStateUser] - previousInfo.user;
                nice = cpu_processor_infos[offset + LXDCPUInfoOffsetStateNice] - previousInfo.nice;
                idle = cpu_processor_infos[offset + LXDCPUInfoOffsetStateIdle] - previousInfo.idle;
            } else {
                system = cpu_processor_infos[offset + LXDCPUInfoOffsetStateSystem];
                user = cpu_processor_infos[offset + LXDCPUInfoOffsetStateUser];
                nice = cpu_processor_infos[offset + LXDCPUInfoOffsetStateNice];
                idle = cpu_processor_infos[offset + LXDCPUInfoOffsetStateIdle];
            }
            LXDSystemCPUInfo info = __LXDSystemCPUInfoMake( system, user, nice, idle );
            [infos addObject: LXDStringFromSystemCPUInfo(info)];
        }
        
        vm_size_t cpuInfoSize = sizeof(int32_t) * cpu_processor_count;
        _kernelrpc_mach_vm_deallocate_trap(mach_task_self_, (vm_address_t)cpu_processor_infos, cpuInfoSize);
        self.cpuInfos = infos;
        [self updateCPUUsageInfo];
    }
}

- (void)updateCPUUsageInfo {
    double system = 0, user = 0, nice = 0, idle = 0;
    for (NSString * cpuInfoString in self.cpuInfos) {
        LXDSystemCPUInfo cpuInfo = LXDSystemCPUInfoFromString(cpuInfoString);
        system += cpuInfo.system;
        user += cpuInfo.user;
        nice += cpuInfo.nice;
        idle += cpuInfo.idle;
    }
    system /= self.cpuInfos.count;
    user /= self.cpuInfos.count;
    nice /= self.cpuInfos.count;
    idle /= self.cpuInfos.count;
    
    double total = system + user + nice + idle;
    self.systemRatio = system / total;
    self.userRatio = user / total;
    self.niceRatio = nice / total;
    self.idleRatio = idle / total;
    previousCPUInfo = [self.cpuInfos copy];
}


@end
