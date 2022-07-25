//
//  RCDUltraGroupController.m
//  SealTalk
//
//  Created by 张改红 on 2022/1/18.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUltraGroupController.h"
#import "RCDTableView.h"
#import "RCDUltraGroupCell.h"
#import <Masonry/Masonry.h>
#import "RCDUltraGroupChannelListController.h"
#import "RCDCreateGroupViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUltraGroupNotificationMessage.h"
#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhoneX RCDScreenWidth >=375.0f && RCDScreenHeight >=812.0f&& kIs_iphone
#define kTabBarHeight (CGFloat)(kIs_iPhoneX?(49.0 + 34.0):(49.0))

@interface RCDUltraGroupController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) NSArray *ultrGroups;
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, strong) RCDUltraGroupChannelListController *chatlistVC;
@property (nonatomic, assign) BOOL isFirst;
@end

@implementation RCDUltraGroupController
- (instancetype)init{
    if (self) {
        [self refreshData];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMessageNotification:)
                                                     name:RCKitDispatchMessageNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"";
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    [self refreshFrame];
    if (!self.isFirst) {
        [self refreshData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ultrGroups.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUltraGroupCell *cell = [RCDUltraGroupCell cellWithTableView:tableView];
    if (indexPath.row < self.ultrGroups.count) {
        RCDUltraGroup *group = self.ultrGroups[indexPath.row];
        if (group.portraitUri.length > 0) {
            [cell.portraitImageView sd_setImageWithURL:[NSURL URLWithString:group.portraitUri] placeholderImage:[RCDUtilities imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];
        }
        [cell.bubbleTipView setBubbleTipNumber:[[RCChannelClient sharedChannelManager] getUltraGroupUnreadMentionedCount:group.groupId]];
    }else{
        cell.portraitImageView.image = [UIImage imageNamed:@"create_ultra_group.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.ultrGroups.count) {
        [self.chatlistVC refreshChannelView:self.ultrGroups[indexPath.row]];
    }else{
        [self.navigationController setNavigationBarHidden:NO];
        RCDCreateGroupViewController *createGroupVC = [[RCDCreateGroupViewController alloc] init];
        createGroupVC.groupType = RCDCreateTypeUltraGroup;
        [self.navigationController pushViewController:createGroupVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

#pragma mark - Private Method
- (void)didReceiveMessageNotification:(NSNotification *)notification {
    RCMessage *message = notification.object;
    if ([message.content isKindOfClass:[RCDUltraGroupNotificationMessage class]]) {
        RCDUltraGroupNotificationMessage *noti = (RCDUltraGroupNotificationMessage *)message.content;
        if ([noti.operation isEqualToString:RCDUltraGroupDismiss]) {
            [self refreshData];
        }
    }else if ([message.content isKindOfClass:[RCInformationNotificationMessage class]]){
        [self refreshData];
    }else {
        int left = [notification.userInfo[@"left"] intValue];
        if (left == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
}

- (void)setupView {
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [self.view addSubview:self.tableView];
    [self addChildViewController:self.chatlistVC];
    [self.view addSubview:self.chatlistVC.view];
    [self.chatlistVC didMoveToParentViewController:self];
    [self refreshFrame];
}

- (void)refreshFrame{
    CGRect rect = self.view.bounds;
    rect.size.height = RCDScreenHeight - kTabBarHeight;
    self.view.frame = rect;
    rect.origin.x = RCDLeftSpace;
    rect.size.width -= RCDLeftSpace;
    self.chatlistVC.view.frame = rect;
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.top.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.offset(RCDLeftSpace);
    }];
}

- (void)refreshData{
    __weak typeof(self) weakSelf = self;

    [RCDUltraGroupManager getUltraGroupList:^(NSArray<RCDUltraGroup *> * _Nonnull groupList) {
        weakSelf.ultrGroups = groupList;
        [weakSelf.tableView reloadData];
        if (weakSelf.chatlistVC.ultraGroup && [self isExit:weakSelf.chatlistVC.ultraGroup]) {
            [weakSelf.chatlistVC refreshChannelView:weakSelf.chatlistVC.ultraGroup];
        }else if (weakSelf.ultrGroups.count > 0) {
            [weakSelf.chatlistVC refreshChannelView:weakSelf.ultrGroups.firstObject];
        }else{
            [weakSelf.chatlistVC refreshChannelView:nil];
        }
    }];
}

- (BOOL)isExit:(RCDUltraGroup *)group{
    BOOL isExit = NO;
    for (RCDUltraGroup *sender in self.ultrGroups) {
        if ([sender.groupId isEqualToString:group.groupId]) {
            isExit = YES;
            break;
        }
    }
    return isExit;
}

#pragma mark - getter
- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDLeftSpace, 15)];
        _tableView.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xecebf0) darkColor:HEXCOLOR(0x1c1c1c)];
    }
    return _tableView;
}

- (RCDUltraGroupChannelListController *)chatlistVC{
    if (!_chatlistVC) {
        _chatlistVC = [[RCDUltraGroupChannelListController alloc] init];
    }
    return _chatlistVC;
}
@end
