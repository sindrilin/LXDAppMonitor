//
//  LXDHostMapper.m
//  LXDAppFluecyMonitor
//
//  Created by linxinda on 2017/3/28.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDHostMapper.h"
#import <netdb.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>


static LXDHostMap lxd_host_map;


@implementation LXDHostMapper


+ (BOOL)validIp: (NSString *)ip {
    return [self validIpv4: ip] || [self validIpv6: ip];
}

+ (BOOL)validIpv4: (NSString *)ip {
    NSString * ipRegExp = @"^(([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3})|(0\\.0\\.0\\.0)$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF matches %@", ipRegExp];
    return [predicate evaluateWithObject: ip];
}

+ (BOOL)validIpv6: (NSString *)ip {
    NSString * ipRegExp = @"^(^((\\p{XDigit}{1,4}):){7}(\\p{XDigit}{1,4})$)|(^(::((\\p{XDigit}//{1,4}):){0,5}(\\p{XDigit}{1,4}))$)|(^((\\p{XDigit}{1,4})(:|::)){0,6}(\\p//{XDigit}{1,4})$)$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF matches %@", ipRegExp];
    return [predicate evaluateWithObject: ip];
}

+ (BOOL)validHost: (NSString *)host {
    NSString * hostRegExp = @"((http[s]?|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF matches %@", hostRegExp];
    return [predicate evaluateWithObject: host];
}

+ (void)setHostMap: (LXDHostMap)hostMap {
    lxd_host_map = [hostMap copy];
}

+ (void)parseHost: (NSString *)host complete: (void(^)(NSString * ip))complete {
    NSParameterAssert(complete);
    if ([self validIp: host]) { complete(host); }
    if (![self validHost: host]) { complete(nil); }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (lxd_host_map != nil) {
            NSString * ipAddress = lxd_host_map(host);
            if (ipAddress == nil) {
                ipAddress = [self getIpAddressFromHostName: host];
            }
            complete(ipAddress);
        } else {
            complete([self getIpAddressFromHostName: host]);
        }
    });
}

+ (NSString *)getIpAddressFromHostName: (NSString *)host {
    NSString * ipAddress = [self getIpv4AddressFromHost: host];
    if (ipAddress == nil) {
        ipAddress = [self getIpv6AddressFromHost: host];
    }
    return ipAddress;
}

+ (NSString *)getIpv4AddressFromHost: (NSString *)host {
    const char * hostName = host.UTF8String;
    struct hostent * phost;
    if ( (phost = gethostbyname(hostName)) == NULL ) {
        return nil;
    }
    struct in_addr ip_addr;
    memcpy(&ip_addr, phost->h_addr_list[0], 4);
    
    char ip[20] = { 0 };
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    return [NSString stringWithUTF8String: ip];
}

+ (NSString *)getIpv6AddressFromHost: (NSString *)host {
    const char * hostName = host.UTF8String;
    struct hostent * phost;
    if ( (phost = gethostbyname(hostName)) == NULL ) {
        return nil;
    }
    
    char ip[32] = { 0 };
    char ** aliases;
    for (aliases = phost->h_addr_list; *aliases != NULL; aliases++) {
        NSString * ipAddress = [NSString stringWithUTF8String: inet_ntop(phost->h_addrtype, *aliases, ip, sizeof(ip))];
        if (ipAddress) { break; }
    }
    return nil;
}


@end
