//
//  LXDHostMapper.h
//  LXDAppFluecyMonitor
//
//  Created by linxinda on 2017/3/28.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NSString *(^LXDHostMap)(NSString * host);


/*!
 *  @brief  域名解析
 */
@interface LXDHostMapper : NSObject

+ (BOOL)validIp: (NSString *)ip;
+ (void)setHostMap: (LXDHostMap)hostMap;
+ (void)parseHost: (NSString *)host complete: (void(^)(NSString * ip))complete;

+ (NSString *)parseHost: (NSString *)host;
+ (NSString *)getIpv4AddressFromHost: (NSString *)host;
+ (NSString *)getIpv6AddressFromHost: (NSString *)host;

@end
