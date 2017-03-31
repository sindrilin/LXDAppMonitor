//
//  LXDFilterRule.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/29.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDHostFilterRule.h"

static inline NSMutableSet * lxd_invalid_ips() {
    static NSMutableSet * lxd_invalid_ips;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        lxd_invalid_ips = [NSMutableSet set];
    });
    return lxd_invalid_ips;
}

static inline NSMutableDictionary * lxd_ip_mapper() {
    static NSMutableDictionary * lxd_ip_mapper;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        lxd_ip_mapper = @{}.mutableCopy;
    });
    return lxd_ip_mapper;
}

static inline NSMutableDictionary * lxd_host_mapper() {
    static NSMutableDictionary * lxd_host_mapper;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        lxd_host_mapper = @{}.mutableCopy;
    });
    return lxd_host_mapper;
}


@implementation LXDHostFilterRule


+ (void)registerInvailIp: (NSString *)ip {
    [lxd_invalid_ips() addObject: ip];
}

+ (void)mapHost: (NSString *)host toIp: (NSString *)ip {
    lxd_ip_mapper()[ip] = host;
    lxd_host_mapper()[host] = ip;
}

+ (BOOL)isIpInvalid: (NSString *)ip {
    return [lxd_invalid_ips() containsObject: ip];
}

+ (NSString *)getIpAddressFromHost: (NSString *)host {
    return lxd_host_mapper()[host];
}

+ (NSString *)getHostFromIpAddress: (NSString *)ipAddress {
    return lxd_ip_mapper()[ipAddress];
}


@end
