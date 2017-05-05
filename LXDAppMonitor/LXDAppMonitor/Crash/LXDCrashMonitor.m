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
#import "UIApplication+LXDTool.h"


void (*other_exception_caught_handler)(NSException * exception) = NULL;


@implementation LXDCrashMonitor


static void __lxd_exception_caught(NSException * exception) {
    NSDictionary * infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString * appInfo = [NSString stringWithFormat: @"Device: %@\nOS Version: %@\nOS System: %@", [UIDevice currentDevice].model, infoDict[@"CFBundleShortVersionString"], [[UIDevice currentDevice].systemName stringByAppendingString: [UIDevice currentDevice].systemVersion]];
    
    LXDCrashLogger * crashLogger = [LXDCrashLogger crashLoggerWithName: exception.name
                                                                reason: exception.reason
                                                             stackInfo: [LXDBacktraceLogger lxd_backtraceOfCurrentThread] crashTime: [NSDate date]
                                                     topViewController: NSStringFromClass([[[UIApplication sharedApplication] findTopViewController] class])
                                                    applicationVersion: appInfo];
    [[LXDCrashLoggerServer sharedServer] insertLogger: crashLogger];
    if (other_exception_caught_handler != NULL) {
        (*other_exception_caught_handler)(exception);
    }
}

CF_INLINE NSString * __signal_name(int signal) {
    switch (signal) {
            /// 非法指令
        case SIGILL:
            return @"SIGILL";
            /// 计算错误
        case SIGFPE:
            return @"SIGFPE";
            /// 总线错误
        case SIGBUS:
            return @"SIGBUS";
            /// 无进程接手数据
        case SIGPIPE:
            return @"SIGPIPE";
            /// 无效地址
        case SIGSEGV:
            return @"SIGSEGV";
            /// abort信号
        case SIGABRT:
            return @"SIGABRT";
        default:
            return @"Unknown";
    }
}

CF_INLINE NSString * __signal_reason(int signal) {
    switch (signal) {
            /// 非法指令
        case SIGILL:
            return @"Invalid Command";
            /// 计算错误
        case SIGFPE:
            return @"Math Type Error";
            /// 总线错误
        case SIGBUS:
            return @"Bus Error";
            /// 无进程接手数据
        case SIGPIPE:
            return @"No Data Receiver";
            /// 无效地址
        case SIGSEGV:
            return @"Invalid Address";
            /// abort信号
        case SIGABRT:
            return @"Abort Signal";
        default:
            return @"Unknown";
    }
}

static void __lxd_signal_handler(int signal) {
    __lxd_exception_caught([NSException exceptionWithName: __signal_name(signal) reason: __signal_reason(signal) userInfo: nil]);
    [LXDCrashMonitor _killApp];
}


#pragma mark - Public
+ (void)startMonitoring {
    other_exception_caught_handler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(__lxd_exception_caught);
    signal(SIGILL, __lxd_signal_handler);
    signal(SIGFPE, __lxd_signal_handler);
    signal(SIGBUS, __lxd_signal_handler);
    signal(SIGPIPE, __lxd_signal_handler);
    signal(SIGSEGV, __lxd_signal_handler);
    signal(SIGABRT, __lxd_signal_handler);
}


#pragma mark - Private
+ (void)_killApp {
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGILL, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGABRT, SIG_DFL);
    kill(getpid(), SIGKILL);
}


@end
