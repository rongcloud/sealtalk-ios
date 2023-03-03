//
//  RCDUserGroupCreateView.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupCreateView.h"

@interface RCDUserGroupCreateView()
@property(nonatomic, strong, readwrite) UITextField *txtName;
@property(nonatomic, strong, readwrite) UIButton *btnSubmit;
@end

@implementation RCDUserGroupCreateView

- (void)setupView {
    UILabel *labName = [self rcd_labelWithText:@"名称"];
    [self addSubview:labName];
    [labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).mas_offset(16);
        make.top.mas_equalTo(self).mas_offset(40);
    }];
    
    [self addSubview:self.txtName];
    [self.txtName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self).mas_offset(-16);
        make.centerY.mas_equalTo(labName);
        make.leading.mas_equalTo(labName.mas_trailing).mas_offset(20);
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

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.txtName resignFirstResponder];
}

- (UITextField *)txtName {
    if (!_txtName) {
        _txtName = [self rcd_textFiledWith:@"请输入用户组名称"];
    }
    return _txtName;
}

- (UIButton *)btnSelect {
    if (!_btnSelect) {
        _btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSelect setTitle:@"编辑用户组成员" forState:UIControlStateNormal];
        _btnSelect.layer.cornerRadius = 4.f;
        _btnSelect.backgroundColor = HEXCOLOR(0x0099fff);
        _btnSelect.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _btnSelect;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
        [_tableView registerClass:[RCDUserGroupMemberCell class]
           forCellReuseIdentifier:RCDUserGroupMemberCellIdentifier];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.userInteractionEnabled = NO;
    }
    return _tableView;
}

@end
