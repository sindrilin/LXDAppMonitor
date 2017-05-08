//
//  LXDTopWindow.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/4/27.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "LXDTopWindow.h"


static LXDTopWindow * lxd_top_window;



@implementation LXDTopWindow


+ (instancetype)topWindow {
#if DEBUG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lxd_top_window = [[super allocWithZone: NSDefaultMallocZone()] initWithFrame: [UIScreen mainScreen].bounds];
    });
#endif
    return lxd_top_window;
}

+ (instancetype)allocWithZone: (struct _NSZone *)zone {
    return [self topWindow];
}

- (instancetype)copy {
    return [[self class] topWindow];
}

- (instancetype)initWithFrame: (CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        [super setUserInteractionEnabled: NO];
        [super setWindowLevel: CGFLOAT_MAX];
        
        self.rootViewController = [UIViewController new];
        [self makeKeyAndVisible];
    }
    return self;
}

- (void)setWindowLevel: (UIWindowLevel)windowLevel { }
- (void)setBackgroundColor: (UIColor *)backgroundColor { }
- (void)setUserInteractionEnabled: (BOOL)userInteractionEnabled { }


@end
