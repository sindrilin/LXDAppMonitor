//
//  LXDCPUDisplayer.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDCPUDisplayer.h"
#import "LXDMonitorUI.h"
#import "LXDDispatchAsync.h"


@interface LXDCPUDisplayer ()

@property (nonatomic, strong) LXDAsyncLabel * displayerLabel;

@end


@implementation LXDCPUDisplayer


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

- (void)displayCPUUsage: (double)usage {
    int use = usage;
    LXDDispatchQueueAsyncBlockInDefault(^{
        NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString: @"CPU" attributes: @{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: _displayerLabel.font }];
        [attributed appendAttributedString: [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"%d%%", use] attributes: @{ NSFontAttributeName: _displayerLabel.font, NSForegroundColorAttributeName: [UIColor colorWithHue: 0.27 * (0.8 - (use / 100.)) saturation: 1 brightness: 0.9 alpha: 1] }]];
        self.displayerLabel.attributedText = attributed;
    });
}


@end
