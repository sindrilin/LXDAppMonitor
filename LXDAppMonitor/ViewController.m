//
//  ViewController.m
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/22.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "ViewController.h"
#import "LXDFPSMonitor.h"
#import "LXDHostMapper.h"
#import "LXDFPSDisplayer.h"
#import "LXDDNSInterceptor.h"
#import "LXDAppFluencyMonitor.h"

#import "WebViewController.h"
#import <objc/runtime.h>


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    REGISTER_INTERCEPTOR
    [FLUENCYMONITOR startMonitoring];
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"cell"];
}

- (void)viewDidAppear: (BOOL)animated {
    [super viewDidAppear: animated];
    [FLUENCYMONITOR startMonitoring];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    return 1000;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
    cell.textLabel.text = [NSString stringWithFormat: @"%lu", indexPath.row];
    if (indexPath.row > 0 && indexPath.row % 30 == 0) {
        usleep(2000000);
    }
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    for (int idx = 0; idx < 100; idx++) {
//        usleep(10000);
    }
//    [self.navigationController pushViewController: [[WebViewController alloc] initWithUrl: @"http://www.sindrilin.com"] animated: YES];
}


@end
