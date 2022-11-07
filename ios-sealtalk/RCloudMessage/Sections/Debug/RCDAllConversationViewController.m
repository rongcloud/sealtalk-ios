//
//  RCDAllConversationViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/9/23.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDAllConversationViewController.h"
#import "RCDUGListView.h"
#import "RCDChannel.h"
#import "RCDUltraGroupManager.h"
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
NSString *const RCDCListViewControllerCellIdentifier = @"RCDCListViewControllerCellIdentifier";

@implementation RCDConversationItem

@end

@interface RCDAllConversationViewController()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) RCDUGListView *listView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *conversations;
@end

@implementation RCDAllConversationViewController

- (void)loadView {
    self.view = self.listView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
    [self fetchUtralGroups];
}

#pragma mark - Private

- (NSString *)tagBy:(RCConversationType)type {
    switch (type) {
        case ConversationType_PRIVATE:
            return @"私聊";
            break;
        case ConversationType_GROUP:
            return @"群聊";
            break;
        case ConversationType_CHATROOM:
            return @"聊天室";
            break;
        case ConversationType_ULTRAGROUP:
            return @"超级群";
            break;
        default:
            return @"位置";
            break;
    }
}

- (NSArray *)fetchOtherConversastion {
    NSArray *types =  @[@(ConversationType_PRIVATE),
                        @(ConversationType_GROUP),
                        @(ConversationType_CHATROOM)];
    NSMutableArray *array = [NSMutableArray array];
    NSArray *conversationList =
    [[RCIMClient sharedRCIMClient] getConversationList:types];
    for (RCConversation *conversation in conversationList) {
        RCDConversationItem *item = [RCDConversationItem new];
        item.targetID = conversation.targetId;
        item.type = conversation.conversationType;
        NSString *tag = [self tagBy:item.type];
        NSString *name = @"";
        if (conversation.conversationType == ConversationType_PRIVATE ) {
            RCUserInfo *userInfo = [RCDUserInfoManager getUserInfo:conversation.senderUserId];
            name = userInfo.name;
     
        } else if (conversation.conversationType == ConversationType_GROUP) {
            RCGroup *groupInfo = [RCDGroupManager getGroupInfo:conversation.targetId];
            name = groupInfo.groupName;
        }
        item.title = [NSString stringWithFormat:@"[%@] %@",tag, name];

        [array addObject:item];
    }
    return array;
}

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

- (void)fetchUtralGroups {
    [RCDUltraGroupManager getUltraGroupList:^(NSArray<RCDUltraGroup *> * _Nonnull groupList) {
        NSMutableArray *array = [NSMutableArray array];
        
        for (RCDUltraGroup * group in groupList) {
            NSArray *channels = [self fetchUtralGroupChannelsBy:group.groupId groupName:group.groupName];
            [array addObjectsFromArray:channels];
        }
        NSArray *conversations = [self fetchOtherConversastion];
        [array addObjectsFromArray:conversations];

        [self refreshWith:array];
    }];
}

- (NSArray *)fetchUtralGroupChannelsBy:(NSString *)targetID groupName:(NSString *)groupName {
    NSArray *conversationList = [[RCChannelClient sharedChannelManager] getConversationListForAllChannel:ConversationType_ULTRAGROUP targetId:targetID];
    NSMutableArray *array = [NSMutableArray array];
    for (RCConversation *item in conversationList) {
        RCDConversationItem *channel = [RCDConversationItem new];
        channel.channelID = item.channelId;
        channel.targetID = targetID;
        channel.type = ConversationType_ULTRAGROUP;
        channel.title = groupName;
        [self fillChannelInfo:channel targetID:targetID];
        [array addObject:channel];
    }
    return array;
}

- (void)fillChannelInfo:(RCDConversationItem *)item targetID:(NSString *)targetID {
    [RCDUltraGroupManager getChannelName:targetID channelId:item.channelID complete:^(NSString *channelName) {
        NSString *tag = [self tagBy:item.type];
        item.title = [NSString stringWithFormat:@"[%@] %@:%@",tag, item.title, channelName];
    }];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDConversationItem *item = self.dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDCListViewControllerCellIdentifier
                                                            forIndexPath:indexPath];
    cell.textLabel.text = item.title;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    RCDConversationItem *item = self.dataSource[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(conversationDidSelected:)]) {
        [self.delegate conversationDidSelected:item];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self back];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

#pragma mark - Property

- (RCDUGListView *)listView {
    if (!_listView) {
        _listView = [RCDUGListView new];
        _listView.tableView.delegate = self;
        _listView.tableView.dataSource = self;
        [_listView.tableView registerClass:[UITableViewCell class]
                        forCellReuseIdentifier:RCDCListViewControllerCellIdentifier];
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
