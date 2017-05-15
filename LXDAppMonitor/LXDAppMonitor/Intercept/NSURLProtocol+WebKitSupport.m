//
//  NSURLProtocol+WebKitSupport.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/30.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "NSURLProtocol+WebKitSupport.h"
#import <WebKit/WebKit.h>

static inline NSString * lxd_scheme_selector_suffix() {
    return @"SchemeForCustomProtocol:";
}

static inline id lxd_context_controller() {
    static Class cls;
    if (!cls) {
        cls = [[[NSClassFromString(@"WKWebView") new] valueForKey:@"browsingContextController"] class];
    }
    return cls;
}

static inline SEL lxd_register_scheme_selector() {
    const NSString * const registerPrefix = @"register";
    return NSSelectorFromString([registerPrefix stringByAppendingString: lxd_scheme_selector_suffix()]);
}

static inline SEL lxd_unregister_scheme_selector() {
    const NSString * const unregisterPrefix = @"unregister";
    return NSSelectorFromString([unregisterPrefix stringByAppendingString: lxd_scheme_selector_suffix()]);
}


@implementation NSURLProtocol (WebKitSupport)


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+ (void)lxd_registerScheme: (NSString *)scheme {
    if ([lxd_context_controller() respondsToSelector: lxd_register_scheme_selector()]) {
        [lxd_context_controller() performSelector: lxd_register_scheme_selector() withObject: scheme];
    }
}

+ (void)lxd_unregisterScheme: (NSString *)scheme {
    if ([lxd_context_controller() respondsToSelector: lxd_unregister_scheme_selector()]) {
        [lxd_context_controller() performSelector: lxd_unregister_scheme_selector() withObject: scheme];
    }
}
#pragma clang diagnostic pop


@end
