//
//  LXDDispatchQueuePool.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/2.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, LXDQualityOfService) {
    LXDQualityOfServiceUserInteractive = NSQualityOfServiceUserInteractive,
    LXDQualityOfServiceUserInitiated = NSQualityOfServiceUserInitiated,
    LXDQualityOfServiceUtility = NSQualityOfServiceUtility,
    LXDQualityOfServiceBackground = NSQualityOfServiceBackground,
    LXDQualityOfServiceDefault = NSQualityOfServiceDefault,
};


dispatch_queue_t LXDDispatchQueueAsyncBlockInQOS(LXDQualityOfService qos, dispatch_block_t block);
dispatch_queue_t LXDDispatchQueueAsyncBlockInUserInteractive(dispatch_block_t block);
dispatch_queue_t LXDDispatchQueueAsyncBlockInUserInitiated(dispatch_block_t block);
dispatch_queue_t LXDDispatchQueueAsyncBlockInBackground(dispatch_block_t block);
dispatch_queue_t LXDDispatchQueueAsyncBlockInDefault(dispatch_block_t block);
dispatch_queue_t LXDDispatchQueueAsyncBlockInUtility(dispatch_block_t block);
