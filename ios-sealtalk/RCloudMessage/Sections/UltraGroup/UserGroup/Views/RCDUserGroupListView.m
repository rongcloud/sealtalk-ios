//
//  RCDUserGroupListView.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupListView.h"

@interface RCDUserGroupListView()
@property(nonatomic, strong) UILabel *emptyLab;
@property(nonatomic, strong, readwrite) UITableView *tableView;
@end


@implementation RCDUserGroupListView

- (void)setupView {
    [super setupView];
    [self addSubview:self.emptyLab];
    [self.emptyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)userGrouListEnable:(BOOL)enable {
    self.tableView.hidden = !enable;
}

#pragma mark -- Property

- (UILabel *)emptyLab {
    if (!_emptyLab) {
        _emptyLab = [self rcd_labelWithText:@"暂无数据"];
    }
    return _emptyLab;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    }
    return _tableView;
}
@end
