//
//  LXDFPSMonitor.h
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/24.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>


#define FPS_MONITOR [LXDFPSMonitor sharedMonitor]
/*!
 *  @brief  监听FPS
 */
@interface LXDFPSMonitor : NSObject

+ (instancetype)sharedMonitor;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
