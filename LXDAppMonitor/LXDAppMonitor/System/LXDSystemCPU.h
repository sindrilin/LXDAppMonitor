//
//  LXDSystemCPU.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/1.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  系统CPU模型
 */
@interface LXDSystemCPU : NSObject

@property (nonatomic, readonly) double systemRatio;
@property (nonatomic, readonly) double userRatio;
@property (nonatomic, readonly) double niceRatio;
@property (nonatomic, readonly) double idleRatio;

- (void)updateCPUInfo;

@end
