//
//  RCDAgentSettingViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentSettingViewController.h"
#import "RCDAgentSettingView.h"
#import "RCDAgentSettingViewModel.h"
#import "RCDAgentTagCollectionViewModel.h"
#import "RCDAgentTagCollectionViewCell.h"

@interface RCDAgentSettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) RCDAgentSettingView *settingView;
@property (nonatomic, strong) RCDAgentSettingViewModel *viewModel;
@end

@implementation RCDAgentSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"agent_setting_title");
    self.viewModel = [[RCDAgentSettingViewModel alloc] initWithIdentifier:self.identifier];
    [self.settingView.tableView reloadData];
}

- (void)loadView {
    self.view = self.settingView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray  *array = self.viewModel.dataSource[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        RCDAgentTagViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDAgentTagViewCellIdentifier];
        NSArray  *array = [self.viewModel.dataSource objectAtIndex:indexPath.section];
        RCDAgentTagCollectionViewModel *vm = array[indexPath.row];
        [cell updateCellWithViewModel:vm];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        RCDAgentSettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDAgentSettingViewCellIdentifier];
        NSArray  *array = [self.viewModel.dataSource objectAtIndex:indexPath.section];
        RCDAgentSettingSwitchCellViewModel *vm = array[indexPath.row];
        RCDAgentSettingViewCellType type = RCDAgentSettingViewCellTypeNone;
        if (indexPath.row == 0) {
            type = RCDAgentSettingViewCellTypeTop;
        } else if(indexPath.row == array.count - 1){
            type = RCDAgentSettingViewCellTypeBottom;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell updateCellWithViewModel:vm type:type];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray  *array = [self.viewModel.dataSource objectAtIndex:indexPath.section];
    RCDAgentSettingCellViewModel *vm = array[indexPath.row];
    return [vm cellHeight];
}

- (RCDAgentSettingView *)settingView {
    if (!_settingView) {
        _settingView = [RCDAgentSettingView new];
        _settingView.tableView.delegate = self;
        _settingView.tableView.dataSource = self;
    }
    return _settingView;
}
@end
