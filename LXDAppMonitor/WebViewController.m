//
//  WebViewController.m
//  LXDAppMonitor
//
//  Created by linxinda on 2017/3/29.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "WebViewController.h"
#import "LXDDNSInterceptor.h"
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
    
#ifdef WEBKITSUPPORT
    WKWebView * webView = [[WKWebView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self.view addSubview: webView];
    [webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: self.url]]];
#else
    __weak typeof(self) weakself = self;
    [self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: self.url]]];
#endif
    
    [LXDDNSInterceptor registerInvalidIpHandle: ^(NSURL *originUrl) {
#ifdef WEBKITSUPPORT
        [webView loadRequest: [NSURLRequest requestWithURL: originUrl]];
#else
        [weakself.webView loadRequest: [NSURLRequest requestWithURL: originUrl]];
#endif
    }];
}


@end
