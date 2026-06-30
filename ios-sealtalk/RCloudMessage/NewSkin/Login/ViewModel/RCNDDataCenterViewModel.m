//
//  RCNDDataCenterViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/25.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDDataCenterViewModel.h"
#import "RCNDDataCenterRadioCellViewModel.h"
#import "RCDEnvironmentContext.h"
#import "AppDelegate.h"
#import "RCDCommonString.h"

@interface RCNDDataCenterViewModel()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, copy) NSString *currentEnvironment;
@property (nonatomic, strong) RCNDRadioCellViewModel *currentVM;
@property (nonatomic, strong) NSArray *allEnvironment;

@property (nonatomic, copy) void(^completionBlock)(NSString *);
@end

@implementation RCNDDataCenterViewModel
- (instancetype)initWithBlock:(void(^)(NSString *name))completion
{
    self = [super init];
    if (self) {
        self.completionBlock = completion;
        [self dataReady];
    }
    return self;
}

+ (void)refreshEnvironmentStatus {
    BOOL showTest = [DEFAULTS boolForKey:RCDSwitchTestEnvKey];
    [DEFAULTS setBool:!showTest forKey:RCDSwitchTestEnvKey];
    [DEFAULTS synchronize];
}

+ (NSString *)currentDataCenter {
    NSString *nameKey = [RCDEnvironmentContext currentEnvironmentNameKey];
    return RCDLocalizedString(nameKey);

}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDRadioCell class]
      forCellReuseIdentifier:RCNDRadioCellIdentifier];
}

- (void)dataReady {
    self.currentEnvironment = [RCDEnvironmentContext currentEnvironmentNameKey];
    NSArray *appEnvironments = [RCDEnvironmentContext appEnvironments];
    self.allEnvironment = appEnvironments;
    NSMutableArray *array = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;

    for (NSDictionary *dic in appEnvironments) {
        NSArray *env = [dic allKeys];
        NSString *key = @"";
        if (env.count) {
            key = env[0];
        }
        NSString *name = RCDLocalizedString(key);
        RCNDDataCenterRadioCellViewModel *vm = [[RCNDDataCenterRadioCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
            [weakSelf reloadDataWith:dic];
            if (weakSelf.completionBlock) {
                weakSelf.completionBlock(name);
            }
        }];
        vm.dataKey = key;
        vm.title = name;
        vm.selected = [self.currentEnvironment isEqualToString:key];
        [array addObject:vm];
    }
    self.dataSource = array;
    [self removeSeparatorLineIfNeed:@[self.dataSource]];
}

- (void)reloadDataWith:(NSDictionary *)dic {
    NSArray *env = [dic allKeys];
    NSString *key = nil;
    if (env.count) {
        key = env[0];
    }
    [RCDEnvironmentContext saveEnvironmentByCategory:dic[key]];
    for (RCNDDataCenterRadioCellViewModel *vm in self.dataSource) {
        vm.selected = [vm.dataKey isEqualToString:key];
    }
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:NO];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate respondsToSelector:@selector(configRongIM)]) {
        [appDelegate performSelector:@selector(configRongIM)];
    }
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
@end
