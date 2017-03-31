//
//  LXDFilterRule.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/29.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief 域名过滤规则
 */
@interface LXDHostFilterRule : NSObject

+ (void)registerInvailIp: (NSString *)ip;
+ (void)mapHost: (NSString *)host toIp: (NSString *)ip;

+ (BOOL)isIpInvalid: (NSString *)ip;
+ (NSString *)getIpAddressFromHost: (NSString *)host;
+ (NSString *)getHostFromIpAddress: (NSString *)ipAddress;

@end
