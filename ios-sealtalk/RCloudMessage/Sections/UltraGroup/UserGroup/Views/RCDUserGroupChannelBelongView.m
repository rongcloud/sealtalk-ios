//
//  RCDUserGroupChannelBelongView.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/12.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupChannelBelongView.h"

@interface RCDUserGroupChannelBelongView()
@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) UIButton *btnEdit;
@end


@implementation RCDUserGroupChannelBelongView

- (void)setupView {
    [super setupView];

    [self addSubview:self.tableView];
    [self addSubview:self.btnEdit];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.btnEdit.mas_top).mas_equalTo(-10);
    }];
    
    [self.btnEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self).mas_offset(-16);
        make.bottom.mas_equalTo(self).mas_offset(-10);
        make.height.mas_equalTo(44);
        make.leading.mas_equalTo(self).mas_offset(16);
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (UIButton *)btnEdit {
    if (!_btnEdit) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"编辑用户组绑定信息" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 4.f;
        btn.backgroundColor = HEXCOLOR(0x0099fff);
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _btnEdit = btn;
    }
    return _btnEdit;
}
@end
