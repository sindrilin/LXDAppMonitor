//
//  LXDDNSInterceptor.h
//  LXDAppFluecyMonitor
//
//  Created by linxinda on 2017/3/28.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DNSINTERCEPTOR [LXDDNSInterceptor dnsInterceptor]
/*!
 *  @brief  DNS拦截器
 */
@interface LXDDNSInterceptor : NSURLProtocol

@property (nonatomic, readonly) NSURL * currentUrl;
@property (nonatomic, readonly) NSArray * invaildIps;
@property (nonatomic, copy) NSDictionary * hostMapper;

+ (instancetype)dnsInterceptor;

@end
