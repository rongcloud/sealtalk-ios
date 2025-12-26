//
//  RCDThemesViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/10/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDThemesViewController.h"
#import "RCDThemesContext.h"
#import "RCDLanguageSettingTableViewCell.h"
#import <RongIMKit/RongIMKit.h>

static NSString *const kThemeCellIdentifier = @"RCDLanguageSettingTableViewCell";

@interface RCDThemesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) RCDThemesCategory selectedCategory;
@end

@implementation RCDThemesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self loadData];
}

- (void)setupUI {
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"save")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = RCDLocalizedString(@"Themes");
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 44.0;
    [self.tableView registerClass:[RCDLanguageSettingTableViewCell class] forCellReuseIdentifier:kThemeCellIdentifier];
    [self.view addSubview:self.tableView];
}

- (void)save {
    // 通过 RCDThemesContext 保存选中的主题
    [RCDThemesContext changeThemTo:self.selectedCategory];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadData {
//    self.dataSource = @[RCDLocalizedString(@"TraditionThemes"),
//                        RCDLocalizedString(@"LivelyThemes"),
//                        RCDLocalizedString(@"ThemeBaseOnTradition"),
//                        RCDLocalizedString(@"ThemeBaseOnLively")];
    self.dataSource = @[RCDLocalizedString(@"TraditionThemes"),
                        RCDLocalizedString(@"LivelyThemes")];
    // 从 RCDThemesContext 读取当前选中的主题类别
    self.selectedCategory = [RCDThemesContext currentCategory];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDLanguageSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kThemeCellIdentifier];
    if (cell == nil) {
        cell = [[RCDLanguageSettingTableViewCell alloc] init];
    }
    // 设置主题名称
    cell.leftLabel.text = self.dataSource[indexPath.row];
    
    // 根据当前选中的类别显示对钩
    cell.rightImageView.image = (indexPath.row == self.selectedCategory) ? [UIImage imageNamed:@"select"] : nil;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 更新选中状态
    RCDThemesCategory newCategory = (RCDThemesCategory)indexPath.row;
    
    if (newCategory != self.selectedCategory) {
        // 保存旧的索引用于刷新
        NSInteger oldIndex = self.selectedCategory;
        
        // 更新选中的类别
        self.selectedCategory = newCategory;
        
        // 刷新对钩显示
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:oldIndex inSection:0],
                               [NSIndexPath indexPathForRow:newCategory inSection:0]];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
