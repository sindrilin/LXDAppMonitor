//
//  LXDCrashLogger.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  崩溃日志
 */
@interface LXDCrashLogger : NSObject

@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) NSString * reason;
@property (nonatomic, readonly) NSString * stackInfo;
@property (nonatomic, readonly) NSString * crashTime;
@property (nonatomic, readonly) NSString * topViewController;
@property (nonatomic, readonly) NSString * applicationVersion;

+ (instancetype)crashLoggerWithName: (NSString *)name
                             reason: (NSString *)reason
                          stackInfo: (NSString *)stackInfo
                          crashTime: (NSDate *)crashTime
                  topViewController: (NSString *)topViewController
                 applicationVersion: (NSString *)applicationVersion;

- (NSString *)loggerDescription;

@end


/*!
 *  @brief  日志服务管理
 */
@interface LXDCrashLoggerServer : NSObject

+ (instancetype)sharedServer;
- (void)insertLogger: (LXDCrashLogger *)logger;
- (void)fetchLastLogger: (void(^)(LXDCrashLogger * logger))fetchHandle;
- (void)fetchLoggers: (void(^)(NSArray<LXDCrashLogger *> * loggers))fetchHandle;

@end

