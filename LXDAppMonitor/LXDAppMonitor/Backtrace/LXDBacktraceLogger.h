//
//  LXDBacktraceLogger.h
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/23.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  线程堆栈上下文输出
 */
@interface LXDBacktraceLogger : NSObject

+ (NSString *)lxd_backtraceOfAllThread;
+ (NSString *)lxd_backtraceOfMainThread;
+ (NSString *)lxd_backtraceOfCurrentThread;
+ (NSString *)lxd_backtraceOfNSThread:(NSThread *)thread;

+ (void)lxd_logMain;
+ (void)lxd_logCurrent;
+ (void)lxd_logAllThread;

+ (NSString *)backtraceLogFilePath;
+ (void)recordLoggerWithFileName: (NSString *)fileName;

@end
