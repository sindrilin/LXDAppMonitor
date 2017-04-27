//
//  LXDGlobalTimer.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  全局倒计时
 */
@interface LXDGlobalTimer : NSObject

/*!
 *  @brief  注册定时器回调处理，返回时间戳作为key
 */
+ (NSString *)registerTimerCallback: (dispatch_block_t)callback;

/*!
 *  @brief  注册定时器回调处理
 */
+ (void)registerTimerCallback: (dispatch_block_t)callback key: (NSString *)key;

/*!
 *  @brief  取消定时器注册
 */
+ (void)resignTimerCallbackWithKey: (NSString *)key;

/*!
 *  @brief  设置定时器间隔，默认为2
 */
+ (void)setCallbackInterval: (NSUInteger)interval;

@end
