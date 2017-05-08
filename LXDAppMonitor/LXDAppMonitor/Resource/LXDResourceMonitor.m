//
//  LXDResourceMonitor.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDResourceMonitor.h"

#import "LXDSystemCPU.h"
#import "LXDApplicationCPU.h"
#import "LXDSystemMemory.h"
#import "LXDApplicationMemory.h"

#import "LXDMonitorUI.h"
#import "LXDGlobalTimer.h"
#import "LXDCPUDisplayer.h"
#import "LXDMemoryDisplayer.h"


@interface LXDResourceMonitor ()

@property (nonatomic, strong) LXDSystemCPU * sysCpu;
@property (nonatomic, strong) LXDApplicationCPU * appCpu;
@property (nonatomic, strong) LXDSystemMemory * sysMemory;
@property (nonatomic, strong) LXDApplicationMemory * appMemory;

@property (nonatomic, strong) LXDCPUDisplayer * cpuDisplayer;
@property (nonatomic, strong) LXDMemoryDisplayer * memoryDisplayer;

@end


@implementation LXDResourceMonitor


+ (instancetype)monitorWithMonitorType: (LXDResourceMonitorType)monitorType {
    return [[self alloc] initWithMonitorType: monitorType];
}

- (instancetype)init {
    return [self initWithMonitorType: LXDResourceMonitorTypeDefault];
}

- (instancetype)initWithMonitorType: (LXDResourceMonitorType)monitorType {
    if (self = [super init]) {
        BOOL cpuMonitorEnabled = YES, memoryMonitorEnabled = YES;
        if (monitorType & LXDResourceMonitorTypeApplicationCpu) {
            self.appCpu = [LXDApplicationCPU new];
        } else if (monitorType & LXDResourceMonitorTypeSystemCpu) {
            self.sysCpu = [LXDSystemCPU new];
        } else {
            cpuMonitorEnabled = NO;
        }
        if (monitorType & LXDResourceMonitorTypeApplicationMemoty) {
            self.appMemory = [LXDApplicationMemory new];
        } else if (monitorType & LXDResourceMonitorTypeSystemMemory) {
            self.sysMemory = [LXDSystemMemory new];
        } else {
            memoryMonitorEnabled = NO;
        }
        if (!(cpuMonitorEnabled | memoryMonitorEnabled)) {
            @throw [NSException exceptionWithName: NSInvalidArgumentException reason: [NSString stringWithFormat: @"[%@ initWithMonitorType]: cannot create %@ instance without monitor type", [self class], [self class]] userInfo: nil];
        }
        
        if (cpuMonitorEnabled) {
            self.cpuDisplayer = [[LXDCPUDisplayer alloc] initWithFrame: CGRectMake(0, 30, 60, 20)];
            CGFloat centerX = round(CGRectGetWidth([UIScreen mainScreen].bounds) / 4);
            self.cpuDisplayer.center = CGPointMake(centerX, self.cpuDisplayer.center.y);
        }
        if (memoryMonitorEnabled) {
            self.memoryDisplayer = [[LXDMemoryDisplayer alloc] initWithFrame: CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 140, 30, 60, 20)];
            CGFloat centerX = round(CGRectGetWidth([UIScreen mainScreen].bounds) / 4 * 3);
            self.memoryDisplayer.center = CGPointMake(centerX, self.memoryDisplayer.center.y);
        }
    }
    return self;
}

static NSString * lxd_resource_monitor_callback_key;

- (void)startMonitoring {
    if (lxd_resource_monitor_callback_key != nil) { return; }
    lxd_resource_monitor_callback_key = [[LXDGlobalTimer registerTimerCallback: ^{
        double cpuUsage, memoryUsage;
        if (_appCpu) {
            cpuUsage = [_appCpu currentUsage];
        } else {
            LXDSystemCPUUsage usage = [_sysCpu currentUsage];
            cpuUsage = usage.user + usage.system + usage.nice;
        }
        if (_appMemory) {
            LXDApplicationMemoryUsage usage = [_appMemory currentUsage];
            memoryUsage = usage.usage;
        } else {
            LXDSystemMemoryUsage usage = [_sysMemory currentUsage];
            memoryUsage = (usage.wired + usage.active);
        }
        [self.cpuDisplayer displayCPUUsage: cpuUsage];
        [self.memoryDisplayer displayUsage: memoryUsage];
    }] copy];
    [[LXDTopWindow topWindow] addSubview: self.cpuDisplayer];
    [[LXDTopWindow topWindow] addSubview: self.memoryDisplayer];
}

- (void)stopMonitoring {
    if (lxd_resource_monitor_callback_key == nil) { return; }
    [LXDGlobalTimer resignTimerCallbackWithKey: lxd_resource_monitor_callback_key];
    [self.cpuDisplayer removeFromSuperview];
    [self.memoryDisplayer removeFromSuperview];
}


@end
