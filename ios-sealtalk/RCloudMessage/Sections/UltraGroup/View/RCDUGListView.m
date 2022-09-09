//
//  RCDUGSettingsView.m
//  SealTalk
//
//  Created by RobinCui on 2022/8/1.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUGListView.h"
#import <Masonry/Masonry.h>

@implementation RCDUGListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        
    }
    return _tableView;
}
@end
