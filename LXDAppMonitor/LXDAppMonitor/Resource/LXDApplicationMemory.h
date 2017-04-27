//
//  LXDApplicationMemory.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/26.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct LXDApplicationMemoryUsage
{
    double usage;   ///< 已用内存(MB)
    double total;   ///< 总内存(MB)
    double ratio;   ///< 占用比率
} LXDApplicationMemoryUsage;

/*!
 *  @brief  应用内存占用
 */
@interface LXDApplicationMemory : NSObject

- (LXDApplicationMemoryUsage)currentUsage;

@end
