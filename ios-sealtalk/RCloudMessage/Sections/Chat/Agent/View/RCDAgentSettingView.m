//
//  RCDAgentSettingView.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentSettingView.h"

@implementation RCDAgentSettingView

- (void)setupView {
    [super setupView];
    self.backgroundColor = RCDYCOLOR(0xf5f6f9, 0x1c1c1c);
    [self addSubview:self.tableView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
    
}


- (UITableView *)tableView {
    if(!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                              style:UITableViewStylePlain];
        tableView.tableFooterView = [UIView new];
        tableView.separatorColor = [UIColor clearColor];
        tableView.backgroundColor =  [UIColor clearColor];
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
        tableView.sectionHeaderHeight = 0;
        if (@available(iOS 15.0, *)) {
            tableView.sectionHeaderTopPadding = 0;
        }
        //设置右侧索引
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = HEXCOLOR(0x6f6f6f);
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            tableView.separatorInset = UIEdgeInsetsMake(0, 64, 0, 0);
        }
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            tableView.layoutMargins = UIEdgeInsetsMake(0, 64, 0, 0);
        }
        [tableView registerClass:[RCDAgentSettingViewCell class] forCellReuseIdentifier:RCDAgentSettingViewCellIdentifier];
        [tableView registerClass:[RCDAgentTagViewCell class] forCellReuseIdentifier:RCDAgentTagViewCellIdentifier];
        _tableView = tableView;
    }
    return _tableView;
}

@end
