//
//  LXDSystemCPU.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/1.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDSystemCPU.h"
#import <mach/vm_map.h>
#import <mach/mach_host.h>
#import <mach/processor_info.h>


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
    NSUInteger system;  ///< 系统态占用。
    NSUInteger user;    ///< 用户态占用。
    NSUInteger nice;    ///< nice加权的用户态占用。
    NSUInteger idle;    ///< 空闲占用
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
                                    [infos[LXDCPUInfoOffsetStateSystem] integerValue],
                                    [infos[LXDCPUInfoOffsetStateUser] integerValue],
                                    [infos[LXDCPUInfoOffsetStateNice] integerValue],
                                    [infos[LXDCPUInfoOffsetStateIdle] integerValue]);
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


- (LXDSystemCPUUsage)currentUsage {
    return [self generateSystemCpuUsageWithCpuInfos: [self generateCpuInfos]];
}

- (NSArray<NSString *> *)generateCpuInfos {
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
        vm_deallocate(mach_task_self_, (vm_address_t)cpu_processor_infos, cpuInfoSize);
        return infos;
    }
    return nil;
}

- (LXDSystemCPUUsage)generateSystemCpuUsageWithCpuInfos: (NSArray<NSString *> *)cpuInfos {
    if (cpuInfos.count == 0) { return (LXDSystemCPUUsage){ 0 }; }
    double system = 0, user = 0, nice = 0, idle = 0;
    for (NSString * cpuInfoString in cpuInfos) {
        LXDSystemCPUInfo cpuInfo = LXDSystemCPUInfoFromString(cpuInfoString);
        system += cpuInfo.system;
        user += cpuInfo.user;
        nice += cpuInfo.nice;
        idle += cpuInfo.idle;
    }
    system /= cpuInfos.count;
    user /= cpuInfos.count;
    nice /= cpuInfos.count;
    idle /= cpuInfos.count;
    
    double total = system + user + nice + idle;
    return (LXDSystemCPUUsage){
        .system = system / total,
        .user = user / total,
        .nice = nice / total,
        .idle = idle / total,
    };
}


@end
