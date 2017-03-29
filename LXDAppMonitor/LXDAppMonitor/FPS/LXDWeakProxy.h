//
//  LXDWeakProxy.h
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/24.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  弱引用代理对象
 */
@interface LXDWeakProxy : NSObject

+ (instancetype)proxyWithConsignor: (id)consignor;
- (instancetype)initWithConsignor: (id)consignor;

@end
