//
//  LXDDNSInterceptor.h
//  LXDAppFluecyMonitor
//
//  Created by linxinda on 2017/3/28.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LXDInvalidIpHandle)(NSURL * originUrl);

#define REGISTER_INTERCEPTOR [LXDDNSInterceptor registerInterceptor];
#define UNREGISTER_INTERCEPTOR [LXDDNSInterceptor unregisterInterceptor];
/*!
 *  @brief  DNS拦截器
 */
@interface LXDDNSInterceptor : NSURLProtocol

+ (void)registerInterceptor;
+ (void)unregisterInterceptor;
+ (void)registerInvalidIpHandle: (LXDInvalidIpHandle)invalidIpHandle;

@end
