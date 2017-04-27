//
//  LXDFPSDisplayer.m
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/25.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDFPSDisplayer.h"
#import "LXDMonitorUI.h"
#import "LXDDispatchAsync.h"


#define LXD_FPS_DISPLAYER_SIZE CGSizeMake(54, 20)


@interface LXDFPSDisplayer ()

@property (nonatomic, strong) LXDAsyncLabel * fpsDisplayer;

@end


@implementation LXDFPSDisplayer


- (instancetype)init {
    if (self = [super initWithFrame: CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - LXD_FPS_DISPLAYER_SIZE.width) / 2, 30, LXD_FPS_DISPLAYER_SIZE.width, LXD_FPS_DISPLAYER_SIZE.height)]) {
        CAShapeLayer * bgLayer = [CAShapeLayer layer];
        bgLayer.fillColor = [UIColor colorWithWhite: 0 alpha: 0.7].CGColor;
        bgLayer.path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, LXD_FPS_DISPLAYER_SIZE.width, LXD_FPS_DISPLAYER_SIZE.height) cornerRadius: 5].CGPath;
        [self.layer addSublayer: bgLayer];
        
        self.fpsDisplayer = [[LXDAsyncLabel alloc] initWithFrame: self.bounds];
        self.fpsDisplayer.textColor = [UIColor whiteColor];
        self.fpsDisplayer.textAlignment = NSTextAlignmentCenter;
        self.fpsDisplayer.font = [UIFont fontWithName: @"Menlo" size: 14];
        [self updateFPS: 60];
        [self addSubview: self.fpsDisplayer];
    }
    return self;
}

- (void)updateFPS: (int)fps {
    LXDDispatchQueueAsyncBlockInDefault(^{
        NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat: @"%d", fps] attributes: @{ NSForegroundColorAttributeName: [UIColor colorWithHue: 0.27 * (fps / 60.0 - 0.2) saturation: 1 brightness: 0.9 alpha: 1], NSFontAttributeName: _fpsDisplayer.font }];
        [attributed appendAttributedString: [[NSAttributedString alloc] initWithString: @"FPS" attributes: @{ NSFontAttributeName: _fpsDisplayer.font, NSForegroundColorAttributeName: [UIColor whiteColor] }]];
        self.fpsDisplayer.attributedText = attributed;
    });
}


@end
