//
//  LXDAppFluencyMonitor.h
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/22.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>


#define FLUENCYMONITOR [LXDAppFluencyMonitor shareMonitor]


/*!
 *  @brief  监听UI线程卡顿
 */
@interface LXDAppFluencyMonitor : NSObject

+ (instancetype)shareMonitor;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
