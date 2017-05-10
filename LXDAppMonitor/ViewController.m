//
//  ViewController.m
//  LXDAppFluencyMonitor
//
//  Created by linxinda on 2017/3/22.
//  Copyright © 2017年 Jolimark. All rights reserved.
//

#import "ViewController.h"
#import "LXDFPSMonitor.h"
#import "LXDResourceMonitor.h"


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"cell"];
    
    [FPS_MONITOR startMonitoring];
    [RESOURCE_MONITOR startMonitoring];
}

- (void)viewDidAppear: (BOOL)animated {
    [super viewDidAppear: animated];
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
        usleep(10000);
    }
}


@end
