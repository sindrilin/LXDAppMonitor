//
//  WebViewController.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/29.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>


@interface WebViewController ()

@property (nonatomic, copy) NSString * url;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (instancetype)initWithUrl: (NSString *)url {
    self = [super initWithNibName: NSStringFromClass([self class]) bundle: nil];
    self.url = url;
    return self;
}

#define WEBKITSUPPORT

- (void)viewDidLoad {
    [super viewDidLoad];
}


@end
