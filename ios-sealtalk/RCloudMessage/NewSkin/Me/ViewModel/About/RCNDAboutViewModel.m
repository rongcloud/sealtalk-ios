//
//  RCNDAboutViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDAboutViewModel.h"
#import "RCNDCommonCellViewModel.h"
#import "RCNDAboutIconCellViewModel.h"
#import "RCNDSDKCellViewModel.h"
#import "RCDDebugTableViewController.h"

@interface RCNDAboutViewModel()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *urls;
@end

@implementation RCNDAboutViewModel

- (void)ready {
    [super ready];
    __weak typeof(self) weakSelf = self;

    RCNDAboutIconCellViewModel *vcICON = [[RCNDAboutIconCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        [weakSelf openUrlFor:0];
    }];
//    
//    RCNDCommonCellViewModel *vmIntroduce = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
//        [weakSelf openUrlFor:1];
//    }];
//    vmIntroduce.title = RCDLocalizedString(@"function_introduce");
    
    RCNDCommonCellViewModel *vmWebsite = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        [weakSelf openUrlFor:2];
    }];
    vmWebsite.title = RCDLocalizedString(@"offical_website");
    
    RCNDCommonCellViewModel *vmApp = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        
    }];
    vmApp.title = RCDLocalizedString(@"ST_version");
    vmApp.hideArrow = YES;
    NSString *SealTalkVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SealTalk Version"];
    vmApp.subtitle = SealTalkVersion;
    
    RCNDSDKCellViewModel *vmSDK = [[RCNDSDKCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        RCDDebugTableViewController *debugVC = [RCDDebugTableViewController new];
        [vc.navigationController pushViewController:debugVC animated:YES];
    }];
    vmSDK.title = RCDLocalizedString(@"SDK_version");
    vmSDK.hideArrow = YES;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    vmSDK.subtitle = version;
    
    self.dataSource = @[vcICON, vmWebsite, vmApp, vmSDK];
    [self removeSeparatorLineIfNeed:@[self.dataSource]];
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDCommonCell class]
      forCellReuseIdentifier:RCNDCommonCellIdentifier];
    
    [tableView registerClass:[RCNDAboutIconCell class]
      forCellReuseIdentifier:RCNDAboutIconCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}

- (void)openWebsite {
    [self openUrlFor:0];
}
- (void)openUrlFor:(NSInteger)index {
    if (index >= self.urls.count) return;
    NSString *urlString = self.urls[index];
    if (!urlString.length) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [app openURL:url options:@{} completionHandler:nil];
            } else {
                // 旧系统调用旧方法（不会出现警告）
                [app openURL:url];
            }
        }
    }
}

- (NSArray *)urls {
    if (!_urls) {
        _urls = @[
            @"http://www.wegenmi.com/",
            @"https://www.wegenmi.com/demo/introduction",
            @"http://www.wegenmi.com/"
        ];
    }
    return _urls;
}
@end
