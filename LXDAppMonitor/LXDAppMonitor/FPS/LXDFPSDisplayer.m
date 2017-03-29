//
//  LXDFPSDisplayer.m
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/25.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDFPSDisplayer.h"


@interface LXDFPSDisplayer ()

@property (nonatomic, strong) UILabel * fpsDisplayer;

@end


@implementation LXDFPSDisplayer


- (instancetype)init {
    if (self = [super initWithFrame: CGRectMake((CGRectGetWidth([UIScreen mainScreen].bounds) - 54) / 2, 30, 54, 20)]) {
        CAShapeLayer * bgLayer = [CAShapeLayer layer];
        bgLayer.fillColor = [UIColor colorWithWhite: 0 alpha: 0.7].CGColor;
        bgLayer.path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 56, 20) cornerRadius: 5].CGPath;
        [self.layer addSublayer: bgLayer];
        
        self.fpsDisplayer = [[UILabel alloc] initWithFrame: self.bounds];
        self.fpsDisplayer.textColor = [UIColor whiteColor];
        self.fpsDisplayer.textAlignment = NSTextAlignmentCenter;
        self.fpsDisplayer.font = [UIFont fontWithName: @"Menlo" size: 14];
        NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString: @"60FPS" attributes: @{ NSFontAttributeName: _fpsDisplayer.font, NSForegroundColorAttributeName: _fpsDisplayer.textColor }];
        [attributed addAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithHue: 0.216 saturation: 1 brightness: 0.9 alpha: 1] } range: NSMakeRange(0, 2)];
        self.fpsDisplayer.attributedText = attributed;
        [self addSubview: self.fpsDisplayer];
    }
    return self;
}

- (void)updateFPS: (int)fps {
    NSMutableAttributedString * attributed = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat: @"%d", fps] attributes: @{ NSForegroundColorAttributeName: [UIColor colorWithHue: 0.27 * (fps / 60.0 - 0.2) saturation: 1 brightness: 0.9 alpha: 1] }];
    [attributed appendAttributedString: [[NSAttributedString alloc] initWithString: @"FPS" attributes: @{ NSFontAttributeName: _fpsDisplayer.font, NSForegroundColorAttributeName: [UIColor whiteColor] }]];
    self.fpsDisplayer.attributedText = attributed;
    [self addSubview: self.fpsDisplayer];
}


@end
