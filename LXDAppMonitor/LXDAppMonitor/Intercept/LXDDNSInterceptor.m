//
//  LXDDNSInterceptor.m
//  LXDAppFluecyMonitor
//
//  Created by linxinda on 2017/3/28.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDDNSInterceptor.h"
#import "LXDHostMapper.h"
#import "LXDHostFilterRule.h"
#import "NSURLProtocol+WebKitSupport.h"
#import <objc/runtime.h>


#define INVALID_STATUS_CODE 404


static LXDInvalidIpHandle lxd_invalid_ip_handle;
static void(^lxd_url_session_configure)(NSURLSessionConfiguration * configuration);
static NSString * const LXDURLHasHandledKey = @"LXDURLHasHandledKey";



@interface NSURLSession (LXDIntercept)

- (instancetype)initWithConfiguration: (NSURLSessionConfiguration *)configuration delegate: (id<NSURLSessionDelegate>)delegate delegateQueue: (NSOperationQueue *)queue;

@end



@implementation NSURLSession (LXDIntercept)

+ (void)load {
    Method origin = class_getClassMethod([NSURLSession class], @selector(initWithConfiguration:delegate:delegateQueue:));
    Method custom = class_getClassMethod([NSURLSession class], @selector(lxd_initWithConfiguration:delegate:delegateQueue:));
    method_exchangeImplementations(origin, custom);
}

- (NSURLSession *)lxd_initWithConfiguration: (NSURLSessionConfiguration *)configuration delegate: (id<NSURLSessionDelegate>)delegate delegateQueue: (NSOperationQueue *)queue {
    if (lxd_url_session_configure) {
        lxd_url_session_configure(configuration);
    }
    return [self lxd_initWithConfiguration: configuration delegate: delegate delegateQueue: queue];
}

@end



@interface LXDDNSInterceptor ()<NSURLConnectionDelegate>

@property (nonatomic, copy) NSURL * originUrl;
@property (nonatomic, copy) LXDInvalidIpHandle invalidIpHandle;

@property (nonatomic, strong) NSURLConnection * connection;

@end



@implementation LXDDNSInterceptor


#pragma mark - Public
+ (void)foreachURLSchemesWithHandle: (void(^)(NSString * scheme))handle {
    NSParameterAssert(handle);
    for (NSString * scheme in @[@"http", @"https"]) {
        handle(scheme);
    }
}

+ (void)registerInterceptor {
    [NSURLProtocol registerClass: [LXDDNSInterceptor class]];
    [self foreachURLSchemesWithHandle: ^(NSString *scheme) {
        [NSURLProtocol lxd_registerScheme: scheme];
    }];
    lxd_url_session_configure = ^(NSURLSessionConfiguration * configuration){
        if (![configuration.protocolClasses containsObject: [LXDDNSInterceptor class]]) {
            NSMutableArray * protocolClasses = [NSMutableArray arrayWithArray: configuration.protocolClasses];
            [protocolClasses addObject: [LXDDNSInterceptor class]];
            configuration.protocolClasses = protocolClasses;
        }
    };
}

+ (void)unregisterInterceptor {
    lxd_invalid_ip_handle = nil;
    [NSURLProtocol unregisterClass: [LXDDNSInterceptor class]];
    [self foreachURLSchemesWithHandle: ^(NSString *scheme) {
        [NSURLProtocol lxd_unregisterScheme: scheme];
    }];
    lxd_url_session_configure = nil;
}

+ (void)registerInvalidIpHandle: (LXDInvalidIpHandle)invalidIpHandle {
    lxd_invalid_ip_handle = invalidIpHandle;
}


#pragma mark - Override
+ (BOOL)canInitWithTask: (NSURLSessionTask *)task {
    return ([NSURLProtocol propertyForKey: LXDURLHasHandledKey inRequest: task.currentRequest] == nil);
}

+ (BOOL)canInitWithRequest: (NSURLRequest *)request {
    return ([NSURLProtocol propertyForKey: LXDURLHasHandledKey inRequest: request] == nil);
}

+ (NSURLRequest *)canonicalRequestForRequest: (NSURLRequest *)request {
    NSString * host = request.URL.host;
    NSString * ip = [LXDHostMapper parseHost: host];
    if (ip == nil) { return request; }
    if ([LXDHostFilterRule isIpInvalid: ip]) { return request; }
    
    NSString * absoluteURLString = request.URL.absoluteString;
    NSRange range = [absoluteURLString rangeOfString: host];
    if (range.location == NSNotFound) { return request; }
    
    absoluteURLString = [absoluteURLString stringByReplacingCharactersInRange: range withString: ip];
    NSMutableURLRequest * canonicalRequest = request.mutableCopy;
    canonicalRequest.URL = [NSURL URLWithString: absoluteURLString];
    return canonicalRequest;
}

- (void)startLoading {
    NSMutableURLRequest * request = self.request.mutableCopy;
    [NSURLProtocol setProperty: @YES forKey: LXDURLHasHandledKey inRequest: request];
    self.connection = [NSURLConnection connectionWithRequest: request delegate: self];
}

- (void)stopLoading {
    [self.connection cancel];
    [NSURLProtocol removePropertyForKey: LXDURLHasHandledKey inRequest: self.connection.currentRequest.mutableCopy];
}


#pragma mark - NSURLConnectionDelegate
- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == INVALID_STATUS_CODE && lxd_invalid_ip_handle) {
            NSString * host = response.URL.host;
            if ([LXDHostMapper validIp: host]) {
                [connection cancel];
                [LXDHostFilterRule registerInvailIp: host];
                
                NSString * absoluteURLString = response.URL.absoluteString;
                NSRange range = [absoluteURLString rangeOfString: host];
                if (range.location != NSNotFound) {
                    absoluteURLString = [absoluteURLString stringByReplacingCharactersInRange: range withString: [LXDHostFilterRule getHostFromIpAddress: host]];
                    lxd_invalid_ip_handle([NSURL URLWithString: absoluteURLString]);
                }
            }
        }
    }
    [self.client URLProtocol: self didReceiveResponse: response cacheStoragePolicy: NSURLCacheStorageAllowedInMemoryOnly];
}

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data {
    [self.client URLProtocol: self didLoadData: data];
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading: self];
}

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error {
    [self.client URLProtocol: self didFailWithError: error];
}


@end
