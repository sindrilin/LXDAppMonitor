//
//  LXDFPSMonitor.m
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/24.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDFPSMonitor.h"
#import "LXDMonitorUI.h"
#import "LXDWeakProxy.h"
#import "LXDFPSDisplayer.h"
#import "LXDBacktraceLogger.h"


@interface LXDFPSMonitor ()

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) LXDFPSDisplayer * displayer;
@property (nonatomic, strong) CADisplayLink * displayLink;

@end



@implementation LXDFPSMonitor


#pragma mark - Singleton override
+ (instancetype)sharedMonitor {
    static LXDFPSMonitor * sharedMonitor;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedMonitor = [[super allocWithZone: NSDefaultMallocZone()] init];
    });
    return sharedMonitor;
}

+ (instancetype)allocWithZone: (struct _NSZone *)zone {
    return [self sharedMonitor];
}

- (void)dealloc {
    [self stopMonitoring];
}


#pragma mark - Public
- (void)startMonitoring {
    if (_isMonitoring) { return; }
    _isMonitoring = YES;
    [self.displayer removeFromSuperview];
    LXDFPSDisplayer * displayer = [[LXDFPSDisplayer alloc] init];
    self.displayer = displayer;
    [[LXDTopWindow topWindow] addSubview: self.displayer];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget: [LXDWeakProxy proxyWithConsignor: self] selector: @selector(monitor:)];
    [self.displayLink addToRunLoop: [NSRunLoop mainRunLoop] forMode: NSRunLoopCommonModes];
    self.lastTime = self.displayLink.timestamp;
    if ([self.displayLink respondsToSelector: @selector(setPreferredFramesPerSecond:)]) {
        self.displayLink.preferredFramesPerSecond = 60;
    } else {
        self.displayLink.frameInterval = 1;
    }
}

- (void)stopMonitoring {
    if (!_isMonitoring) { return; }
    _isMonitoring = NO;
    [self.displayer removeFromSuperview];
    [self.displayLink invalidate];
    self.displayLink = nil;
    self.displayer = nil;
}


#pragma mark - DisplayLink
- (void)monitor: (CADisplayLink *)link {
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) { return; }
    _lastTime = link.timestamp;
    
    double fps = _count / delta;
    _count = 0;
    [self.displayer updateFPS: (int)round(fps)];
}


@end
