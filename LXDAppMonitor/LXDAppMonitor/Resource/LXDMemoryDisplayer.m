//
//  LXDMemoryDisplayer.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDMemoryDisplayer.h"
#import "LXDMonitorUI.h"
#import "LXDDispatchAsync.h"


#define LXD_HIGH_MEMORY_USAGE (([NSProcessInfo processInfo].physicalMemory / 1024 / 1024) / 2)


@interface LXDMemoryDisplayer ()

@property (nonatomic, strong) LXDAsyncLabel * displayerLabel;

@end


@implementation LXDMemoryDisplayer


- (instancetype)initWithFrame: (CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        CAShapeLayer * bgLayer = [CAShapeLayer layer];
        bgLayer.fillColor = [UIColor colorWithWhite: 0 alpha: 0.7].CGColor;
        bgLayer.path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)) cornerRadius: 5].CGPath;
        [self.layer addSublayer: bgLayer];
        
        self.displayerLabel = [[LXDAsyncLabel alloc] initWithFrame: self.bounds];
        self.displayerLabel.textColor = [UIColor whiteColor];
        self.displayerLabel.textAlignment = NSTextAlignmentCenter;
        self.displayerLabel.font = [UIFont fontWithName: @"Menlo" size: 14];
        [self addSubview: self.displayerLabel];
    }
    return self;
}

- (void)displayUsage: (double)usage {
    LXDDispatchQueueAsyncBlockInBackground(^{
        NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat: @"%.1f", usage] attributes: @{ NSFontAttributeName: _displayerLabel.font, NSForegroundColorAttributeName: [UIColor colorWithHue: 0.27 * (0.8 - usage / LXD_HIGH_MEMORY_USAGE) saturation: 1 brightness: 0.9 alpha: 1] }];
        [attributed appendAttributedString: [[NSAttributedString alloc] initWithString: @"MB" attributes: @{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: _displayerLabel.font }]];
        self.displayerLabel.attributedText = attributed;
    });
}


@end
