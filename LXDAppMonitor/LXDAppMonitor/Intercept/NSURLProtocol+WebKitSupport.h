//
//  NSURLProtocol+WebKitSupport.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/30.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  WK支持
 */
@interface NSURLProtocol (WebKitSupport)

+ (void)lxd_registerScheme: (NSString *)scheme;
+ (void)lxd_unregisterScheme: (NSString *)scheme;

@end
