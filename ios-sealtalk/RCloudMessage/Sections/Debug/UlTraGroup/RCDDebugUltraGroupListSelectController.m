//
//  RCDDebugUltraGroupListSelectController.m
//  SealTalk
//
//  Created by Lang on 2023/7/17.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDDebugUltraGroupListSelectController.h"
#import "RCDUIBarButtonItem.h"

@interface RCDDebugUltraGroupListSelectController ()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *selectedConversations;
@property (nonatomic, strong) id footer;

@end

@implementation RCDDebugUltraGroupListSelectController

- (id)init {
    self = [super init];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[
            @(ConversationType_ULTRAGROUP)
        ]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"选择频道";
    [self setNavi];
}

- (void)setNavi {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemClicked)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (NSMutableArray<RCConversationModel *> *)willReloadTableData:(NSMutableArray<RCConversationModel *> *)dataSource {
    
    NSMutableArray *dataSources = [NSMutableArray new];
    NSArray *conversationList = @[];
    if (self.targetId) {
        conversationList = [[RCChannelClient sharedChannelManager] getConversationListForAllChannel:ConversationType_ULTRAGROUP targetId:self.targetId];
    } else {
        SEL sel = NSSelectorFromString(@"getUltraGroupConversationListForAllChannel");
        if ([[RCChannelClient sharedChannelManager] respondsToSelector:sel]) {
            conversationList = [[RCChannelClient sharedChannelManager] performSelector:sel];
        }
    }
    for (RCConversation *conversation in conversationList) {
        RCConversationModel *model = [[RCConversationModel alloc] initWithConversation:conversation extend:nil];
        model.channelId = conversation.channelId;
        [dataSources addObject:model];
    }
    
    return dataSources;
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([self.selectedConversations containsObject:@(indexPath.row)]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0];
    } else {
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    ((RCConversationCell *)cell).conversationTitle.text = [NSString stringWithFormat:@"%@【%@】",model.targetId,model.channelId];
}

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath {
    if ([self.selectedConversations containsObject:@(indexPath.row)]) {
        [self.selectedConversations removeObject:@(indexPath.row)];
    } else {
        [self.selectedConversations addObject:@(indexPath.row)];
    }
    
    [self.conversationListTableView reloadData];
}

// 重写父类的方法
- (void)loadMore{
    if([self.footer respondsToSelector:@selector(endRefreshing)]){
        [self.footer performSelector:@selector(endRefreshing)];
    }
}

- (void)rightBarButtonItemClicked {
    [self.navigationController popViewControllerAnimated:NO];
    if (self.selectedChannelIdsResult) {
        NSMutableArray *channeldIds = [NSMutableArray arrayWithCapacity:self.selectedConversations.count];
        
        for (NSNumber *index in self.selectedConversations) {
            RCConversationModel *model = self.conversationListDataSource[index.intValue];
            [channeldIds addObject:model.channelId];
        }
        self.selectedChannelIdsResult(channeldIds);
    }
}

- (NSMutableArray *)selectedConversations {
    if (!_selectedConversations) {
        _selectedConversations = [NSMutableArray array];
    }
    return _selectedConversations;
}

@end
