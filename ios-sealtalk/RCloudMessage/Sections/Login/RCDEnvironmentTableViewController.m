//
//  RCDEnvironmentTableViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/3/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDEnvironmentTableViewController.h"
#import "RCDEnvironmentContext.h"
#import "AppDelegate.h"


NSString * const RCDEnvironmentCellIndeitifier = @"RCDEnvironmentCellIndeitifier";

@interface AppDelegate ()
- (void)configRongIM;
@end


@interface RCDEnvironmentTableViewController ()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, copy) NSString *currentEnvironment;
@property (nonatomic, strong) NSDictionary *environmentInfo;
@end

@implementation RCDEnvironmentTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentEnvironment = [RCDEnvironmentContext currentEnvironmentNameKey];
        self.dataSource = [RCDEnvironmentContext appEnvironments];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = RCDLocalizedString(@"DataCenter");
    [self checkEnviroment];
}

- (void)checkEnviroment {
    if (!self.currentEnvironment) {
        return;
    }
    for (NSDictionary *info in self.dataSource) {
        if (info[self.currentEnvironment]) {
            self.environmentInfo = info;
        }
    }
}

- (void)dismiss {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate respondsToSelector:@selector(configRongIM)]) {
        [appDelegate performSelector:@selector(configRongIM)];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDEnvironmentCellIndeitifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:RCDEnvironmentCellIndeitifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = self.dataSource[indexPath.row];
    NSArray *env = [dic allKeys];
    NSString *key = nil;
    if (env.count) {
        key = env[0];
    }
    cell.textLabel.text = RCDLocalizedString(key);
    if ([self.currentEnvironment isEqualToString:key]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.userInteractionEnabled = NO;
    if (self.environmentInfo) {
        NSInteger index = [self.dataSource indexOfObject:self.environmentInfo];
        if (index == indexPath.row) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSDictionary *dic = self.dataSource[indexPath.row];
    NSArray *env = [dic allKeys];
    NSString *key = nil;
    if (env.count) {
        key = env[0];
    }
    
    [RCDEnvironmentContext saveEnvironmentByCategory:dic[key]];
    [self dismiss];
}
@end
