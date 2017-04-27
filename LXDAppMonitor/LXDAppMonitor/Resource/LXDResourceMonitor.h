//
//  LXDResourceMonitor.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>


#define RESOURCE_MONITOR [LXDResourceMonitor new]


typedef NS_ENUM(NSInteger, LXDResourceMonitorType)
{
    LXDResourceMonitorTypeDefault = (1 << 2) | (1 << 3),
    LXDResourceMonitorTypeSystemCpu = 1 << 0,   ///<    监控系统CPU使用率，优先级低
    LXDResourceMonitorTypeSystemMemory = 1 << 1,    ///<    监控系统内存使用率，优先级低
    LXDResourceMonitorTypeApplicationCpu = 1 << 2,  ///<    监控应用CPU使用率，优先级高
    LXDResourceMonitorTypeApplicationMemoty = 1 << 3,   ///<    监控应用内存使用率，优先级高
};


/*!
 *  @brief  硬件资源监控
 */
@interface LXDResourceMonitor : NSObject

+ (instancetype)monitorWithMonitorType: (LXDResourceMonitorType)monitorType;
- (void)startMonitoring;
- (void)stopMonitoring;

@end
