//
//  LXDCPUDisplayer.h
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  @brief  CPU占用展示器
 */
@interface LXDCPUDisplayer : UIView

- (void)displayCPUUsage: (double)usage;

@end
