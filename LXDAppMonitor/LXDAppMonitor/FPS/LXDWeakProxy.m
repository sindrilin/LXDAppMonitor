//
//  LXDWeakProxy.m
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/24.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDWeakProxy.h"


@interface LXDWeakProxy ()

@property (nonatomic, weak) id consignor;

@end


@implementation LXDWeakProxy


#pragma mark - Public
+ (instancetype)proxyWithConsignor: (id)consignor {
    return [[self alloc] initWithConsignor: consignor];
}

- (instancetype)initWithConsignor: (id)consignor {
    if (self = [super init]) {
        self.consignor = consignor;
    }
    return self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.fpsMonitorQueue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        NSArray<NSNumber *> *timestamps = [XXFPSList getContinuousLowFpsTimestampsWithThreshold: 10];
        for (NSNumber *timestamp in timestamps) {
            [XXStackFramesUploader uploadStackFrames: [XXStackFramesCache getStackFramesWithTimestamp: timestamp.unsignedIntegerValue] completion: nil];
        }
        [XXStackFramesCache clearAllCaches];
    });
}


#pragma mark - method transmit
- (id)forwardingTargetForSelector: (SEL)aSelector {
    return _consignor;
}

- (void)forwardInvocation: (NSInvocation *)anInvocation {
    void * null = NULL;
    [anInvocation setReturnValue: &null];
}

- (NSMethodSignature *)methodSignatureForSelector: (SEL)aSelector {
    return [_consignor methodSignatureForSelector: aSelector];
}


#pragma mark - judge
- (BOOL)isProxy {
    return YES;
}

- (Class)class {
    return [_consignor class];
}

- (Class)superclass {
    return [_consignor superclass];
}

- (NSUInteger)hash {
    return [_consignor hash];
}

- (NSString *)description {
    return [_consignor description];
}

- (NSString *)debugDescription {
    return [_consignor debugDescription];
}

- (BOOL)isEqual: (id)object {
    return [_consignor isEqual: object];
}

- (BOOL)isKindOfClass: (Class)aClass {
    return [_consignor isKindOfClass: aClass];
}

- (BOOL)isMemberOfClass: (Class)aClass {
    return [_consignor isMemberOfClass: aClass];
}

- (BOOL)respondsToSelector: (SEL)aSelector {
    return [_consignor respondsToSelector: aSelector];
}

- (BOOL)conformsToProtocol: (Protocol *)aProtocol {
    return [_consignor conformsToProtocol: aProtocol];
}


@end
