//
//  URLProtocol.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/31.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  注册NSURLSession请求
 */
@interface URLProtocol : NSURLSessionConfiguration

- (void)monitor;

@end
