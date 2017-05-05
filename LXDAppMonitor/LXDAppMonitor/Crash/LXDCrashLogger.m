//
//  LXDCrashLogger.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDCrashLogger.h"
#import "LXDDispatchAsync.h"


#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif


static const NSUInteger kMaxLoggerNumber = 20;
static NSString * const kLoggerDatabaseFileName = @"crash_logger.sqlite";


@interface LXDCrashLogger ()

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * reason;
@property (nonatomic, copy) NSString * stackInfo;
@property (nonatomic, copy) NSString * crashTime;
@property (nonatomic, copy) NSString * topViewController;
@property (nonatomic, copy) NSString * applicationVersion;

@end


@implementation LXDCrashLogger


NSString * __lxd_convert_time(NSDate * date) {
    static NSDateFormatter * lxd_date_formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lxd_date_formatter = [NSDateFormatter new];
        lxd_date_formatter.dateFormat = @"yyyy-HH-dd HH:mm:ss";
    });
    return [lxd_date_formatter stringFromDate: date];
}

+ (instancetype)crashLoggerWithName: (NSString *)name
                             reason: (NSString *)reason
                          stackInfo: (NSString *)stackInfo
                          crashTime: (NSDate *)crashTime
                  topViewController: (NSString *)topViewController
                 applicationVersion: (NSString *)applicationVersion {
    LXDCrashLogger * crashLogger = [LXDCrashLogger new];
    crashLogger.name = name ?: @"";
    crashLogger.reason = reason ?: @"";
    crashLogger.stackInfo = stackInfo ?: @"";
    crashLogger.topViewController = topViewController ?: @"";
    crashLogger.applicationVersion = applicationVersion ?: @"";
    crashLogger.crashTime = __lxd_convert_time(crashTime);
    return crashLogger;
}

- (NSString *)loggerDescription {
    return [NSString stringWithFormat: @"Error: %@\nReson: %@\n%@\nTop viewcontroller: %@\nCrash time: %@\n\nCall Stack: \n%@", _name, _reason, _applicationVersion, _topViewController, _crashTime, _stackInfo];
}


@end




@interface LXDCrashLoggerServer ()

@property (nonatomic, unsafe_unretained) sqlite3 * database;
@property (nonatomic, unsafe_unretained) CFMutableDictionaryRef stmtCache;

@end


@implementation LXDCrashLoggerServer


#pragma mark - Singleton
+ (instancetype)sharedServer {
    static LXDCrashLoggerServer * sharedServer;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedServer = [[super allocWithZone: NSDefaultMallocZone()] init];
    });
    return sharedServer;
}

+ (instancetype)allocWithZone: (struct _NSZone *)zone {
    return [self sharedServer];
}

- (instancetype)init {
    if (self = [super init]) {
        if ([self _dbOpen]) {
            [self _dbInitialize];
            CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
            CFDictionaryValueCallBacks valueCallbacks = { 0 };
            self.stmtCache = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &keyCallbacks, &valueCallbacks);
        }
    }
    return self;
}

- (id)copy {
    return [[self class] sharedServer];
}

- (void)dealloc {
    if (!_database) {
        sqlite3_close(_database);
        CFRelease(_stmtCache);
        _stmtCache = NULL;
        _database = NULL;
    }
}


#pragma mark - Public
- (void)insertLogger: (LXDCrashLogger *)logger {
    [self _insertCrashLogger: logger];
}

- (void)fetchLastLogger: (void(^)(LXDCrashLogger * logger))fetchHandle {
    [self _syncExecute: ^{
        [self fetchLastLogger: fetchHandle];
    }];
}

- (void)fetchLoggers: (void(^)(NSArray<LXDCrashLogger *> *))fetchHandle {
    [self _syncExecute: ^{
        [self _fetchCrashLoggers: fetchHandle];
    }];
}


#pragma mark - Private
- (NSString *)_crashLoggerFilePath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent: kLoggerDatabaseFileName];
}

- (void)_syncExecute: (dispatch_block_t)block {
    assert(block != nil);
    if ([NSThread isMainThread]) {
        LXDDispatchQueueAsyncBlockInUtility(block);
    } else {
        block();
    }
}

- (void)_insertCrashLogger: (LXDCrashLogger *)crashLogger {
    NSString * sql = @"insert or replace into crash_logger (name, reason, stack_info, crash_time, top_view_controller, application_version) values (?1, ?2, ?3, ?4, ?5, ?6);";
    sqlite3_stmt * stmt = [self _dbPrepareStmt: sql];
    if (!stmt) { return; }
    
    sqlite3_bind_text(stmt, 1, crashLogger.name.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 2, crashLogger.reason.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 3, crashLogger.stackInfo.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 4, crashLogger.crashTime.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 5, crashLogger.topViewController.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 6, crashLogger.applicationVersion.UTF8String, -1, NULL);
    sqlite3_step(stmt);
}

- (void)_cleanExtraLoggers {
    NSString * sql = @"delete from crash_logger order by crash_time desc limit (select count(crash_time) from crash_logger) offset 20";
    sqlite3_stmt * stmt = [self _dbPrepareStmt: sql];
    if (!stmt) { return; }
    sqlite3_step(stmt);
}

- (void)_fetchLastLogger: (void(^)(LXDCrashLogger *))fetchHandle {
    assert(fetchHandle != nil);
    sqlite3_stmt * stmt = [self _fetchLoggerWithCount: 1];
    if (!stmt) { return; }
    
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        dispatch_async(dispatch_get_main_queue(), ^{
            fetchHandle([self _dbGetLoggerFromStmt: stmt]);
        });
    }
}

- (void)_fetchCrashLoggers: (void(^)(NSArray<LXDCrashLogger *> *))fetchHandle {
    assert(fetchHandle != nil);
    sqlite3_stmt * stmt = [self _fetchLoggerWithCount: 20];
    if (!stmt) { return; }
    
    NSMutableArray * loggers = [NSMutableArray array];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        [loggers addObject: [self _dbGetLoggerFromStmt: stmt]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        fetchHandle(loggers);
    });
    if (loggers.count == 20) {
        [self _cleanExtraLoggers];
    }
}

- (sqlite3_stmt *)_fetchLoggerWithCount: (NSUInteger)count {
    NSString * sql = @"select * from crash_logger order by crash_time desc limit 0,?1;";
    sqlite3_stmt * stmt = [self _dbPrepareStmt: sql];
    if (!stmt) { return NULL; }
    sqlite3_bind_int64(stmt, 1, count);
    return stmt;
}

- (LXDCrashLogger *)_dbGetLoggerFromStmt: (sqlite3_stmt *)stmt {
    int idx = 0;
    char * name = (char *)sqlite3_column_text(stmt, idx++);
    char * reason = (char *)sqlite3_column_text(stmt, idx++);
    char * stack_info = (char *)sqlite3_column_text(stmt, idx++);
    char * crash_time = (char *)sqlite3_column_text(stmt, idx++);
    char * top_view_controller = (char *)sqlite3_column_text(stmt, idx++);
    char * application_version = (char *)sqlite3_column_text(stmt, idx++);
    
    LXDCrashLogger * logger = [LXDCrashLogger new];
    logger.name = [NSString stringWithUTF8String: name];
    logger.reason = [NSString stringWithUTF8String: reason];
    logger.stackInfo = [NSString stringWithUTF8String: stack_info];
    logger.crashTime = [NSString stringWithUTF8String: crash_time];
    logger.applicationVersion = [NSString stringWithUTF8String: application_version];
    logger.topViewController = [NSString stringWithUTF8String: top_view_controller];
    return logger;
}


#pragma mark - Sqlite
- (BOOL)_dbOpen {
    if (_database) { return YES; }
    int result = sqlite3_open([self _crashLoggerFilePath].UTF8String, &_database);
    if (result == SQLITE_OK) {
        return YES;
    } else {
        _database = NULL;
        return NO;
    }
}

- (BOOL)_dbInitialize {
    NSString * sql = @"pragma journal_mode = wal; pragma synchronous = normal; create table if not exists crash_logger (name text, reason text, stack_info text, crash_time text primary key, top_view_controller text, application_version text);";
    return [self _dbExecute: sql];
}

- (BOOL)_dbExecute: (NSString *)sql {
    if (sql.length == 0) { return NO; }
    if (![self _dbCheck]) { return NO; }
    
    char * error = NULL;
    int result = sqlite3_exec(_database, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        sqlite3_free(error);
    }
    return (result == SQLITE_OK);
}

- (BOOL)_dbCheck {
    if (!_database) {
        return ([self _dbOpen] && [self _dbInitialize]);
    }
    return YES;
}

- (sqlite3_stmt *)_dbPrepareStmt: (NSString *)sql {
    if (![self _dbCheck] || sql.length == 0 || !_stmtCache) { return NULL; }
    sqlite3_stmt * stmt = (sqlite3_stmt *)CFDictionaryGetValue(_stmtCache, (__bridge const void *)sql);
    if (!stmt) {
        int result = sqlite3_prepare_v2(_database, sql.UTF8String, -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            return NULL;
        }
        CFDictionarySetValue(_stmtCache, (__bridge const void *)sql, stmt);
    } else {
        sqlite3_reset(stmt);
    }
    return stmt;
}


@end


