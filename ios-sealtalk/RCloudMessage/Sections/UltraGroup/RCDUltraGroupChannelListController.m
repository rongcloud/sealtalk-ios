//
//  RCDUltraGroupChannelListController.m
//  SealTalk
//
//  Created by 张改红 on 2022/1/18.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUltraGroupChannelListController.h"
#import "RCDDebugUltraGroupChatViewController.h"
#import <Masonry/Masonry.h>
#import "RCDCreateGroupViewController.h"
#import "RCDContactSelectedTableViewController.h"
#import "RCDUltraGroupSettingController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+MBProgressHUD.h"

@interface RCConversationListViewController()
- (void)conversationStatusChanged:(NSNotification *)notification;
@end

@interface RCDUltraGroupChannelListController ()<RCUltraGroupChannelDelegate, RCUltraGroupMessageChangeDelegate>
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *inviteButton;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *addChannelButton;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) id footer;
@property (nonatomic, strong) NSMutableSet *privateChannels;
@property (nonatomic, strong) NSMutableSet *publicChannels;
@property (nonatomic, strong) dispatch_queue_t channelRWQueue;
@property (nonatomic, copy) NSString *currentChannelID;
@end

@implementation RCDUltraGroupChannelListController


- (id)init {
    self = [super init];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[
            @(ConversationType_ULTRAGROUP)
        ]];
        self.channelRWQueue = dispatch_queue_create("com.rongcloud.im.test.ChannelRWQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RCChannelClient sharedChannelManager] setUltraGroupChannelDelegate:self];
    self.conversationListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[RCChannelClient sharedChannelManager] setRCUltraGroupMessageChangeDelegate:self];
    self.currentChannelID = nil;
}


- (void)didReceiveMessageNotification:(NSNotification *)notification{
    [super didReceiveMessageNotification:notification];
    int left = [notification.userInfo[@"left"] intValue];
    if (left == 0) {
        [self refreshConversationTableViewIfNeeded];
    }
}

#pragma mark -- Private Channel

- (NSMutableSet *)currentPrivateChannels {
    __block NSMutableSet *channels = nil;
    dispatch_barrier_sync(self.channelRWQueue, ^{
        channels = [self.privateChannels copy];
    });
    return channels;
}

- (void)fetchPrivateChannels:(void(^)(void))completion {
    [[RCChannelClient sharedChannelManager] getUltraGroupChannelList:self.ultraGroup.groupId channelType:RCUltraGroupChannelTypePrivate success:^(NSArray<RCConversation *> *list) {
        if (list.count) {
            NSArray *channelIDs = [list valueForKeyPath:@"channelId"];
            dispatch_barrier_async(self.channelRWQueue, ^{
                [self.privateChannels removeAllObjects];
                [self.privateChannels addObjectsFromArray:channelIDs];
            });
        }
        [self fetchPublicChannels:completion];
    } error:^(RCErrorCode status) {
        if (completion) {
            completion();
        }
    }];
}

- (void)fetchPublicChannels:(void(^)(void))completion {
    [[RCChannelClient sharedChannelManager] getUltraGroupChannelList:self.ultraGroup.groupId channelType:RCUltraGroupChannelTypePublic success:^(NSArray<RCConversation *> *list) {
        if (list.count) {
            NSArray *channelIDs = [list valueForKeyPath:@"channelId"];
            dispatch_barrier_async(self.channelRWQueue, ^{
                [self.publicChannels removeAllObjects];
                [self.publicChannels addObjectsFromArray:channelIDs];
            });

        }
        [self fetchChannelsInfoFromServer:completion];
    } error:^(RCErrorCode status) {
        if (completion) {
            completion();
        }
    }];
}

- (void)fetchChannelsInfoFromServer:(void(^)(void))completion {
    [RCDUltraGroupManager getUltraGroupChannelList:self.ultraGroup.groupId complete:^(NSArray<RCDChannel *> *channels) {
        if (channels.count) {
            dispatch_barrier_async(self.channelRWQueue, ^{
                for (RCDChannel *channel in channels) {
                    if (channel && channel.type == RCUltraGroupChannelTypePrivate) {
                        [self.privateChannels addObject:channel.channelId];
                    }
                }
            });
        }
        if (completion) {
            completion();
        }
    }];
}

- (UIView *)channelTypeView:(BOOL)isPrivate level:(NSInteger)level{
    UILabel *lab = [UILabel new];
    lab.textColor = [UIColor whiteColor];
    NSString *text = !isPrivate ? @" 公有" : @" 私有";
    text = [NSString stringWithFormat:@"%@:%ld ", text, level];
    lab.text = text;
    lab.backgroundColor = HEXCOLOR(0x0099fff);
    lab.font = [UIFont systemFontOfSize:12];
    lab.layer.cornerRadius = 2;
    lab.layer.masksToBounds = YES;
    [lab sizeToFit];
    return lab;
}

- (void)refreshConversationTableViewIfNeeded {
    [self fetchPrivateChannels:^{
        [super refreshConversationTableViewIfNeeded];
    }];
}

- (void)configureTagViewFor:(RCConversationBaseCell *)cell
                  channelID:(NSString *)channelID
                      level:(NSInteger)level {
    if (channelID && [cell isKindOfClass:[RCConversationCell class]]) {
        RCConversationCell *cCell = (RCConversationCell *)cell;
        NSSet *channlesPrivate = [self currentPrivateChannels];
        BOOL isPrivate = [channlesPrivate containsObject:channelID];
        UIView *tagView = [self channelTypeView:isPrivate level:level];
        for (UIView *view in cCell.conversationTagView.subviews) {
            [view removeFromSuperview];
        }
        [cCell.conversationTagView addSubview:tagView];
    }
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    if (model.conversationType == ConversationType_ULTRAGROUP) {
        if (![self.ultraGroup.groupId isEqual:model.targetId] || !model.channelId) {
            return;
        }
        [self configureTagViewFor:cell
                        channelID:model.channelId
                            level:model.notificationLevel];
        [RCDUltraGroupManager getChannelName:self.ultraGroup.groupId channelId:model.channelId complete:^(NSString *channelName) {
            if ([self.ultraGroup.groupId isEqual:model.targetId]) {
                RCConversationCell *converCell = (RCConversationCell *)cell;
                converCell.conversationTitle.text = [NSString stringWithFormat:@"%@",channelName];
                RCDChannel *channel = [[RCDChannel alloc] init];
                channel.channelId = model.channelId;
                channel.channelName = channelName;
                [(UIImageView *)(converCell.headerImageView) sd_setImageWithURL:[NSURL URLWithString:[RCDUtilities defaultUltraChannelPortrait:channel groupId:model.targetId]] placeholderImage:[RCDUtilities imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];
            }
        }];
    }
}

- (void)refreshChannelView:(RCDUltraGroup *)group{
    self.ultraGroup = group;
    [self refreshConversationTableViewIfNeeded];
    self.nameLabel.text = self.ultraGroup.groupName;
    if (self.ultraGroup) {
        self.conversationListTableView.tableHeaderView = self.headerView;
    }else{
        self.conversationListTableView.tableHeaderView = nil;
    }
    if([self.ultraGroup.creatorId isEqual:[RCIM sharedRCIM].currentUserInfo.userId]){
        self.addChannelButton.hidden = NO;
        self.addChannelButton.enabled = YES;
    }else{
        self.addChannelButton.hidden = YES;
        self.addChannelButton.enabled = NO;
    }
}

- (NSMutableArray<RCConversationModel *> *)willReloadTableData:(NSMutableArray<RCConversationModel *> *)dataSource{
    NSArray *conversationList = [[RCChannelClient sharedChannelManager] getConversationListForAllChannel:ConversationType_ULTRAGROUP targetId:self.ultraGroup.groupId];
    NSMutableArray *dataSources = [NSMutableArray new];
    for (RCConversation *conversation in conversationList) {
        RCConversationModel *model = [[RCConversationModel alloc] initWithConversation:conversation extend:nil];
        model.channelId = conversation.channelId;
        model.unreadMessageCount = conversation.unreadMessageCount;
        [dataSources addObject:model];
    }
    return dataSources;
}

- (void)loadMore{
    if([self.footer respondsToSelector:@selector(endRefreshing)]){
        [self.footer performSelector:@selector(endRefreshing)];
    }
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath{
    RCDDebugUltraGroupChatViewController *chatVC = [[RCDDebugUltraGroupChatViewController alloc] init];
    chatVC.ultraGroup = self.ultraGroup;
    chatVC.conversationType = model.conversationType;
    chatVC.targetId = model.targetId;
    chatVC.channelId = model.channelId;
    chatVC.title = model.conversationTitle;
    chatVC.firstUnreadMsgSendTime = model.firstUnreadMsgSendTime;
    if (model.targetId) {
        chatVC.isPrivate = [self.privateChannels containsObject:model.channelId];
    }
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        chatVC.unReadMessage = model.unreadMessageCount;
        chatVC.enableNewComingMessageIcon = YES; //开启消息提醒
        chatVC.enableUnreadMessageIcon = NO;
        if (model.conversationType == ConversationType_SYSTEM) {
            chatVC.title = RCDLocalizedString(@"de_actionbar_sub_system");
        } else if (model.conversationType == ConversationType_PRIVATE) {
            chatVC.displayUserNameInCell = NO;
        }
    }
    self.currentChannelID = model.channelId;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark -- RCUltraGroupMessageChangeDelegate

/*!
 消息扩展更新，删除
 
 @param messages 消息集合
 */
- (void)onUltraGroupMessageExpansionUpdated:(NSArray<RCMessage*>*)messages {
    
}

/*!
 消息内容发生变更
 
 @param messages 消息集合
 */
- (void)onUltraGroupMessageModified:(NSArray<RCMessage*>*)messages {
    
}

/*!
 消息撤回
 
 @param messages 消息集合
 */
- (void)onUltraGroupMessageRecalled:(NSArray<RCMessage*>*)messages {
    for (RCMessage *message in messages) {
        if ([message.targetId isEqualToString:self.ultraGroup.groupId]) {
            [self refreshConversationTableViewIfNeeded];
            return;
        }
    }
}


#pragma mark - NotificationLevel

- (void)updateConversationModelBy:(RCConversationStatusInfo *)statusInfo {
    for (int i = 0; i < self.conversationListDataSource.count; i++) {
        RCConversationModel *conversationModel = self.conversationListDataSource[i];
        BOOL isSameConversation = [conversationModel.targetId isEqualToString:statusInfo.targetId] &&
        (conversationModel.conversationType == statusInfo.conversationType);
        BOOL isSameChannel = [conversationModel.channelId isEqualToString:statusInfo.channelId];
        if (isSameConversation && isSameChannel) {
            conversationModel.notificationLevel = statusInfo.notificationLevel;
        }
    }
}

- (void)conversationStatusChanged:(NSNotification *)notification {
    NSArray<RCConversationStatusInfo *> *conversationStatusInfos = notification.object;
    for (RCConversationStatusInfo *statusInfo in conversationStatusInfos) {
        [self updateConversationModelBy:statusInfo];
    }
    [super conversationStatusChanged:notification];
}

#pragma mark - Private

- (void)notifyUserKicked:(NSString *)userID
                targetID:(NSString *)targetID
               channelID:(NSString *)channelID {
    NSString *currentUserID = [RCIM sharedRCIM].currentUserInfo.userId;
    NSString *msg = @"您已离开频道";
    if (userID != currentUserID) { // 自己被踢时 不能插入消息,否则会导致产生新会话
        __block NSString *name = @"";
        [RCDUtilities getGroupUserDisplayInfo:userID
                                      groupId:targetID
                                       result:^(RCUserInfo *user) {
            name = user.name;
        }];
       msg = [NSString stringWithFormat:@"%@ 被踢出频道",name];

    }
    
    [self.view showHUDMessage:msg];
}


/// 用户自己被踢出频道
- (void)userKickedoffBy:(NSString *)channelID {

    if (!self.currentChannelID || ![self.currentChannelID isEqualToString:channelID]) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    });
   
}
/// 发送用户kick消息
/// @param array 用户列表
- (void)notifyUsersKicked:(NSArray <RCUltraGroupChannelUserKickedInfo *> *)array {
    for (int i = 0; i< array.count ; i++) {
        RCUltraGroupChannelUserKickedInfo *info = array[i];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self notifyUserKicked:info.userId
                          targetID:info.changeInfo.targetId
                         channelID:info.changeInfo.channelId];
                [self refreshConversationTableViewIfNeeded];
        });
    }
}

#pragma mark - RCUltraGroupChannelDelegate
- (void)ultraGroupChannelTypeDidChanged:(NSArray<RCUltraGroupChannelChangeTypeInfo *> *)infoList {
    for (RCUltraGroupChannelChangeTypeInfo *info in infoList) {
        switch (info.changeType) {
            case RCUltraGroupChannelChangeTypePublicToPrivate:
            case RCUltraGroupChannelChangeTypePublicToPrivateUserNotIn: {
                if (info.changeInfo.channelId) {
                    dispatch_barrier_async(self.channelRWQueue, ^{
                        [self.privateChannels addObject:info.changeInfo.channelId];
                    });
                }
             
            }
                break;
            case RCUltraGroupChannelChangeTypePrivateToPublic:
                if (info.changeInfo.channelId) {
                    dispatch_barrier_async(self.channelRWQueue, ^{
                        [self.privateChannels removeObject:info.changeInfo.channelId];
                    });
                }
                break;
            default:
                break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshConversationTableViewIfNeeded];
    });

}

- (void)ultraGroupChannelUserDidKicked:(NSArray<RCUltraGroupChannelUserKickedInfo *> *)infoList {
    NSString *currentUserID = [RCIM sharedRCIM].currentUserInfo.userId;
    for (RCUltraGroupChannelUserKickedInfo *info in infoList) {
        if ([info.userId isEqualToString:currentUserID]) {
            [self userKickedoffBy:info.changeInfo.channelId];
        }
    }

    [self notifyUsersKicked:infoList];
}

- (void)ultraGroupChannelDidDisbanded:(NSArray<RCUltraGroupChannelDisbandedInfo *> *)infoList {
    for (RCUltraGroupChannelDisbandedInfo *info in infoList) {
        if (!self.currentChannelID) {
            continue;
        }
        if ([info.changeInfo.targetId isEqualToString:self.ultraGroup.groupId] &&
            [info.changeInfo.channelId isEqualToString:self.currentChannelID]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view showHUDMessage:@"频道已解散"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            });
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshConversationTableViewIfNeeded];
    });
}
#pragma mark - privite
- (void)invite{
    RCDContactSelectedTableViewController *contactSelectedVC =
        [[RCDContactSelectedTableViewController alloc] initWithTitle:RCDLocalizedString(@"select_contact")
                                           isAllowsMultipleSelection:YES];
    contactSelectedVC.groupOptionType = RCDContactSelectedGroupOptionTypeAddUltraMember;
    contactSelectedVC.groupId = self.ultraGroup.groupId;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:contactSelectedVC animated:YES];
}

- (void)addChannel{
    RCDCreateGroupViewController *createGroupVC = [[RCDCreateGroupViewController alloc] init];
    createGroupVC.groupType = RCDCreateTypeUltraGroupChannel;
    createGroupVC.groupId = self.ultraGroup.groupId;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:createGroupVC animated:YES];
}

- (void)setting{
    RCDUltraGroupSettingController *setting = [[RCDUltraGroupSettingController alloc] init];
    setting.ultraGroup = self.ultraGroup;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:setting animated:YES];
}

- (void)addSubviews{
    CGRect rect = self.view.bounds;
    rect.size.width -= RCDLeftSpace;
    self.conversationListTableView.frame =  rect;
    self.emptyConversationView.center = self.conversationListTableView.center;
    self.headerView.frame = CGRectMake(0, 0, rect.size.width, 150+[RCKitUtility getWindowSafeAreaInsets].top);
    [self.headerView addSubview:self.nameLabel];
    [self.headerView addSubview:self.settingButton];
    [self.headerView addSubview:self.inviteButton];
    [self.headerView addSubview:self.infoLabel];
    [self.headerView addSubview:self.lineView];
    [self.headerView addSubview:self.addChannelButton];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.headerView).offset(12);
        make.top.equalTo(self.headerView).offset(10+[RCKitUtility getWindowSafeAreaInsets].top);
        make.height.offset(25);
        make.trailing.equalTo(self.settingButton).offset(-10);
    }];
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.headerView).offset(-12);
        make.height.offset(25);
        make.width.offset(22);
        make.centerY.equalTo(self.nameLabel);
    }];
    [self.inviteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.headerView).offset(18);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(15);
        make.height.offset(32);
        make.centerX.equalTo(self.headerView);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.nameLabel);
        make.top.equalTo(self.inviteButton.mas_bottom).offset(33);
        make.height.offset(16);
        make.width.offset(30);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.infoLabel.mas_trailing).offset(10);
        make.trailing.equalTo(self.addChannelButton.mas_leading).offset(-10);
        make.height.offset(0.5);
        make.centerY.equalTo(self.infoLabel);
    }];
    
    [self.addChannelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.headerView).offset(-16);
        make.width.height.offset(24);
        make.centerY.equalTo(self.infoLabel);
    }];
}

#pragma mark - getter
- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
    }
    return _headerView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = RCDDYCOLOR(0x000000, 0xffffff);
        _nameLabel.font = [UIFont boldSystemFontOfSize:18];
        _nameLabel.text = @"融融的超级群";
    }
    return _nameLabel;
}

- (UIButton *)inviteButton{
    if (!_inviteButton) {
        _inviteButton = [[UIButton alloc] init];
        [_inviteButton setTitle:RCDLocalizedString(@"invite_new_member") forState:UIControlStateNormal];
        _inviteButton.layer.cornerRadius = 4.f;
        _inviteButton.backgroundColor = HEXCOLOR(0x0099fff);
        _inviteButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_inviteButton addTarget:self action:@selector(invite) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _inviteButton;
}

- (UILabel *)infoLabel{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = [RCDUtilities generateDynamicColor:[HEXCOLOR(0x000000) colorWithAlphaComponent:0.55] darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.9]];
        _infoLabel.font = [UIFont boldSystemFontOfSize:14];
        _infoLabel.text = RCDLocalizedString(@"channel");
    }
    return _infoLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = HEXCOLOR(0x979797);
    }
    return _lineView;
}

- (UIButton *)addChannelButton{
    if (!_addChannelButton) {
        _addChannelButton = [[UIButton alloc] init];
        [_addChannelButton setImage:[UIImage imageNamed:@"add_channel.png"] forState:(UIControlStateNormal)];
        _addChannelButton.layer.cornerRadius = 4.f;
        [_addChannelButton addTarget:self action:@selector(addChannel) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _addChannelButton;
}

- (UIButton *)settingButton{
    if (!_settingButton) {
        _settingButton = [[UIButton alloc] init];
        [_settingButton setImage:        [UIImage imageNamed:@"Setting"]
 forState:(UIControlStateNormal)];
        _settingButton.layer.cornerRadius = 4.f;
        [_settingButton addTarget:self action:@selector(setting) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _settingButton;
}


- (NSMutableSet *)privateChannels {
    if (!_privateChannels) {
        _privateChannels = [NSMutableSet set];
    }
    return _privateChannels;
}

- (NSMutableSet *)publicChannels {
    if (!_publicChannels) {
        _publicChannels = [NSMutableSet set];
    }
    return _publicChannels;
}

@end
