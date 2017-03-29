//
//  LXDDNSInterceptor.m
//  LXDAppFluecyMonitor
//
//  Created by linxinda on 2017/3/28.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDDNSInterceptor.h"
#import "LXDHostMapper.h"


static NSString * const LXDURLHasHandledKey = @"LXDURLHasHandledKey";


@interface LXDDNSInterceptor ()

@property (nonatomic, copy) NSURL * currentUrl;
@property (nonatomic, copy) NSArray * invaildIps;

@end


@implementation LXDDNSInterceptor


+ (instancetype)dnsInterceptor {
    static LXDDNSInterceptor * interceptor;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        interceptor = [[LXDDNSInterceptor alloc] init];
    });
    return interceptor;
}

+ (BOOL)canInitWithTask: (NSURLSessionTask *)task {
    return [self canInitWithRequest: task.currentRequest];
}

+ (BOOL)canInitWithRequest: (NSURLRequest *)request {
    return ![[NSURLProtocol propertyForKey: LXDURLHasHandledKey inRequest: request] boolValue];
}

+ (NSURLRequest *)canonicalRequestForRequest: (NSURLRequest *)request {
    NSString * host = request.URL.host;
    NSString * ip = DNSINTERCEPTOR.hostMapper[host];
    if (ip == nil) { return request; }
    
    NSString * ipRegExp = @"^(([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3})|(0\\.0\\.0\\.0)$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF matches %@", ipRegExp];
    if (![predicate evaluateWithObject: ip]) { return request; }
    
    NSString * absoluteURLString = request.URL.absoluteString;
    NSRange range = [absoluteURLString rangeOfString: host];
    if (range.location == NSNotFound) { return request; }
    
    absoluteURLString = [absoluteURLString stringByReplacingCharactersInRange: range withString: ip];
    NSMutableURLRequest * canonicalRequest = request.mutableCopy;
    canonicalRequest.URL = [NSURL URLWithString: absoluteURLString];
    return canonicalRequest;
}

- (void)startLoading {
    
}

- (void)stopLoading {
    
}


@end
