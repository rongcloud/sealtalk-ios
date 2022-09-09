//
//  RCDUGSelectListViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/8/2.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUGSelectListViewController.h"
#import "RCDUGListView.h"
#import "RCDChannel.h"

NSString *const RCDUGSelectListViewControllerCellIdentifier = @"RCDUGSelectListViewControllerCellIdentifier";

NSString *const RCDUGListTitle = @"RCDUGListTitle";
NSString *const RCDUGGroupID = @"RCDUGGroupID";
NSString *const RCDUGListRows = @"RCDUGListRows";

@interface RCDUGSelectListViewController()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) RCDUGListView *listView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *conversations;
@end

@implementation RCDUGSelectListViewController

- (void)loadView {
    self.view = self.listView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
    [self fetchUtralGrous];
}

#pragma mark - Private

- (void)ready {
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(back)];
    self.navigationItem.leftBarButtonItem = btn;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshWith:(NSArray *)array {
    self.dataSource = array;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.listView.tableView reloadData];
    });
}

- (void)fetchUtralGrous {
    [RCDUltraGroupManager getUltraGroupList:^(NSArray<RCDUltraGroup *> * _Nonnull groupList) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (RCDUltraGroup * group in groupList) {
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            NSArray *channels = [self fetchUtralGroupChannelsBy:group.groupId];
            info[RCDUGListRows] = channels;
            info[RCDUGListTitle] = group.groupName;
            info[RCDUGGroupID] = group.groupId;
            
            [array addObject:info];
        }
        [self refreshWith:array];
    }];
}

- (NSArray *)fetchUtralGroupChannelsBy:(NSString *)targetID {
    NSArray *conversationList = [[RCChannelClient sharedChannelManager] getConversationListForAllChannel:ConversationType_ULTRAGROUP targetId:targetID];
    NSMutableArray *array = [NSMutableArray array];
    for (RCConversation *item in conversationList) {
        RCDChannel *channel = [RCDChannel new];
        channel.channelId = item.channelId;
        [self fillChannelInfo:channel targetID:targetID];
        [array addObject:channel];
    }
    return array;
}

- (void)fillChannelInfo:(RCDChannel *)channel targetID:(NSString *)targetID {
    
    [RCDUltraGroupManager getChannelName:targetID channelId:channel.channelId complete:^(NSString *channelName) {
            channel.channelName = channelName;
    }];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSource[indexPath.section];
    NSArray *rows = dic[RCDUGListRows];
    RCDChannel *channel = rows[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDUGSelectListViewControllerCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = channel.channelName;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    NSDictionary *dic = self.dataSource[indexPath.section];
    NSArray *rows = dic[RCDUGListRows];
    RCDChannel *channel = rows[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(userDidSelected:targetID:channelName:channelID:)]) {
        [self.delegate userDidSelected:dic[RCDUGListTitle]
                              targetID:dic[RCDUGGroupID]
                           channelName:channel.channelName
                             channelID:channel.channelId];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self back];
    });
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = self.dataSource[section];
    return dic[RCDUGListTitle];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = self.dataSource[section];
    NSArray *rows = dic[RCDUGListRows];
    return [rows count];
}


#pragma mark - Property

- (RCDUGListView *)listView {
    if (!_listView) {
        _listView = [RCDUGListView new];
        _listView.tableView.delegate = self;
        _listView.tableView.dataSource = self;
        [_listView.tableView registerClass:[UITableViewCell class]
                        forCellReuseIdentifier:RCDUGSelectListViewControllerCellIdentifier];
    }
    return _listView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSArray array];
    }
    return _dataSource;
}

@end
