//
//  LXDTransaction.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/5/2.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  任务封装
 */
@interface LXDTransaction : NSObject

+ (void)begin;
+ (void)commit;

@end
