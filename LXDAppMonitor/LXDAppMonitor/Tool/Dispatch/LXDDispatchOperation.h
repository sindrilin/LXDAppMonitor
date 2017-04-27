//
//  LXDDispatchOperation.h
//  LXDDispatchOperation
//
//  Created by linxinda on 2017/4/6.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LXDDispatchOperation;
typedef void(^LXDCancelableBlock)(LXDDispatchOperation * operation);


/*!
 *  @brief  派发任务封装
 */
@interface LXDDispatchOperation : NSObject

@property (nonatomic, readonly) BOOL isCanceled;
@property (nonatomic, readonly) dispatch_queue_t queue;

+ (instancetype)dispatchOperationWithBlock: (dispatch_block_t)block;
+ (instancetype)dispatchOperationWithBlock: (dispatch_block_t)block inQoS: (NSQualityOfService)qos;

+ (instancetype)dispatchOperationWithCancelableBlock:(LXDCancelableBlock)block;
+ (instancetype)dispatchOperationWithCancelableBlock:(LXDCancelableBlock)block inQos: (NSQualityOfService)qos;

- (void)start;
- (void)cancel;

@end
