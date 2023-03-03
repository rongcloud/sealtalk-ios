//
//  RCDUserGroupDetailView.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupDetailView.h"
#import "RCDUserGroupMemberCell.h"

@interface RCDUserGroupDetailView()

@end

@implementation RCDUserGroupDetailView


- (void)setupView {
    [super setupView];
    
    [self addSubview:self.txtName];
    [self.txtName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).mas_offset(16);
        make.top.mas_equalTo(self).mas_offset(10);
        make.trailing.mas_equalTo(self).mas_offset(-16);
    }];
    
    [self addSubview:self.tableView];
    [self addSubview:self.btnSelect];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.txtName.mas_bottom).mas_offset(10);
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.btnSelect.mas_top).mas_equalTo(-10);
    }];
    
    [self.btnSelect mas_makeConstraints:^(MASConstraintMaker *make) {
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
        [_tableView registerClass:[RCDUserGroupMemberCell class]
           forCellReuseIdentifier:RCDUserGroupMemberCellIdentifier];
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (UIButton *)btnSelect {
    if (!_btnSelect) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"编辑成员" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 4.f;
        btn.backgroundColor = HEXCOLOR(0x0099fff);
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _btnSelect = btn;
    }
    return _btnSelect;
}

- (UITextField *)txtName {
    if (!_txtName) {
        _txtName = [self rcd_textFiledWith:@"请输入用户组名称"];
        _txtName.userInteractionEnabled = NO;
    }
    return _txtName;
}

@end
