//
//  URLProtocol.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/31.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "URLProtocol.h"
#import "LXDDNSInterceptor.h"

@implementation URLProtocol

- (void)monitor {
    if (self.protocolClasses != nil) {
        NSMutableArray * protocolClasses = [NSMutableArray arrayWithArray: self.protocolClasses];
        [protocolClasses insertObject: [LXDDNSInterceptor class] atIndex: 0];
        self.protocolClasses = protocolClasses;
    } else {
        self.protocolClasses = @[[LXDDNSInterceptor class]];
    }
}

@end
