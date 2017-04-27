//
//  LXDSystemCPU.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/1.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct LXDSystemCPUUsage
{
    double system;  ///< 系统占用率
    double user;    ///< user占用率
    double nice;    ///< 加权user占用率
    double idle;    ///< 空闲率
} LXDSystemCPUUsage;

/*!
 *  @brief  系统CPU占用
 */
@interface LXDSystemCPU : NSObject

@property (nonatomic, readonly) double systemRatio;
@property (nonatomic, readonly) double userRatio;
@property (nonatomic, readonly) double niceRatio;
@property (nonatomic, readonly) double idleRatio;

- (LXDSystemCPUUsage)currentUsage;

@end
