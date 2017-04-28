//
//  LXDCrashMonitor.m
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/26.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDCrashMonitor.h"
#import "LXDCrashLogger.h"
#import "LXDBacktraceLogger.h"


void (*other_exception_caught_handler)(NSException * exception) = NULL;


@implementation LXDCrashMonitor


void __lxd_exception_caught(NSException * exception) {
    LXDCrashLogger * crashLogger = [LXDCrashLogger crashLoggerWithName: exception.name reason: exception.reason stackInfo: [LXDBacktraceLogger lxd_backtraceOfCurrentThread] crashTime: [NSDate date] topViewController: nil applicationVersion: [[[NSBundle mainBundle] infoDictionary] valueForKey: @"CFBundleShortVersionString"]];
    [[LXDCrashLoggerServer sharedServer] insertLogger: crashLogger];
    if (other_exception_caught_handler != NULL) {
        (*other_exception_caught_handler)(exception);
    }
}


#pragma mark - Public
+ (void)startMonitoring {
    other_exception_caught_handler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(__lxd_exception_caught);
}


@end
