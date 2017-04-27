//
//  LXDMemoryUsage.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/26.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct LXDSystemMemoryUsage
{
    double free;    ///< 自由内存(MB)
    double wired;   ///< 固定内存(MB)
    double active;  ///< 正在使用的内存(MB)
    double inactive;    ///< 缓存、后台内存(MB)
    double compressed;  ///< 压缩内存(MB)
    double total;   ///< 总内存(MB)
} LXDSystemMemoryUsage;

/*!
 *  @brief  系统内存使用
 */
@interface LXDSystemMemory : NSObject

- (LXDSystemMemoryUsage)currentUsage;

@end
