//
//  RCDUnreadCountParamController.m
//  SealTalk
//
//  Created by RobinCui on 2022/8/2.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUnreadCountParamController.h"
#import "RCDUGListView.h"
#import <RongIMKit/RongIMKit.h>

NSString *const RCDUnreadCountParamControllerCellIdentifier = @"RCDUnreadCountParamControllerCellIdentifier";

NSString *const RCDUGParamTitle = @"RCDUGListTitle";
NSString *const RCDUGParamRows = @"RCDUGListRows";
NSString *const RCDUGParamIndex = @"RCDUGParamIndex";

@interface RCDUnreadCountParamController()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) RCDUGListView *listView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableSet *conversationTypes;
@property (nonatomic, strong) NSMutableSet *levels;

@property (nonatomic, strong) NSDictionary *dicTypes;
@property (nonatomic, strong) NSDictionary *dicLevels;
@end

@implementation RCDUnreadCountParamController

- (instancetype)initWithConversationTypes:(NSArray *)types
                                   levels:(NSArray *)levels
{
    self = [super init];
    if (self) {
        self.conversationTypes = [NSMutableSet set];
        self.levels = [NSMutableSet set];
        if (types) {
            [self.conversationTypes addObjectsFromArray:types];
        }
        if (levels) {
            [self.levels addObjectsFromArray:levels];
        }
    }
    return self;
}

- (void)loadView {
    self.view = self.listView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
}

#pragma mark - Private

- (void)ready {
   
    if (!self.conversationTypes) {
        self.conversationTypes = [NSMutableSet set];
    }
    
    if (!self.levels) {
        self.levels = [NSMutableSet set];
    }
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(back)];
    self.navigationItem.leftBarButtonItem = btn;
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(done)];
    self.navigationItem.rightBarButtonItem = btnDone;
    [self.listView.tableView reloadData];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)done {
    if ([self.delegate respondsToSelector:@selector(userDidSelected:typeString:levels:levelString:)]) {
        
        NSArray *types = [self.conversationTypes allObjects];
        NSMutableArray *typeStrings = [NSMutableArray array];
        for (NSNumber *num in types) {
            NSString *string = self.dicTypes[num];
            if (string) {
                [typeStrings addObject:string];
            }
        }
        
        NSArray *levels = [self.levels allObjects];
        NSMutableArray *levelStrings = [NSMutableArray array];
        for (NSNumber *num in levels) {
            NSString *string = self.dicLevels[num];
            if (string) {
                [levelStrings addObject:string];
            }
        }
        
        [self.delegate userDidSelected:types
                            typeString:[typeStrings componentsJoinedByString:@"\n -> "]
                                levels:levels levelString:[levelStrings componentsJoinedByString:@"\n -> "]];
    }
    [self back];
}


#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSource[indexPath.section];
    NSArray *rows = dic[RCDUGParamIndex];
    NSNumber *value = rows[indexPath.row];
    NSDictionary *info = dic[RCDUGParamRows];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDUnreadCountParamControllerCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = info[value];

    NSMutableSet *set = indexPath.section != 0 ? self.conversationTypes : self.levels;
    if ([set containsObject:value]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dic = self.dataSource[indexPath.section];
    NSArray *rows = dic[RCDUGParamIndex];
    NSNumber *value = rows[indexPath.row];
    NSMutableSet *set = indexPath.section != 0 ? self.conversationTypes : self.levels;
    if ([set containsObject:value]) {
        [set removeObject:value];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [set addObject:value];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = self.dataSource[section];
    return dic[RCDUGParamTitle];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = self.dataSource[section];
    NSArray *rows = dic[RCDUGParamRows];
    return [rows count];
}

#pragma mark - Property

- (RCDUGListView *)listView {
    if (!_listView) {
        _listView = [RCDUGListView new];
        _listView.tableView.delegate = self;
        _listView.tableView.dataSource = self;
        [_listView.tableView registerClass:[UITableViewCell class]
                        forCellReuseIdentifier:RCDUnreadCountParamControllerCellIdentifier];
    }
    return _listView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        NSArray *levels = @[@(RCPushNotificationLevelAllMessage),
                            @(RCPushNotificationLevelDefault),
                            @(RCPushNotificationLevelMention),
                            @(RCPushNotificationLevelMentionUsers),
                            @(RCPushNotificationLevelMentionAll),
                            @(RCPushNotificationLevelBlocked),
                            @(10)
        ];
        NSDictionary *dicLev = @{
            RCDUGParamTitle: @"NotificationLevel",
            RCDUGParamIndex: levels,
            RCDUGParamRows: self.dicLevels
        };
        if (self.isUltraGroup) {
            _dataSource = @[dicLev];
        } else {
            
            NSArray *types = @[@(ConversationType_PRIVATE),
                               @(ConversationType_GROUP),
                               @(ConversationType_ULTRAGROUP),
                               @(ConversationType_CHATROOM),
                               @(100)];
            NSDictionary *dicType = @{
                RCDUGParamTitle: @"会话类型",
                RCDUGParamIndex: types,
                RCDUGParamRows: self.dicTypes
            };
            _dataSource = @[dicLev, dicType];
        }
    }
    return _dataSource;
}


- (NSDictionary *)dicLevels {
    if (!_dicLevels) {
        NSDictionary *dicLevels = @{
            @(RCPushNotificationLevelAllMessage) : @"全部消息通知",
            @(RCPushNotificationLevelDefault) : @"未设置（向上查询群或者APP级别设置",
            @(RCPushNotificationLevelMention) : @"群聊，超级群 @所有人 或者 @成员列表有自己",
            @(RCPushNotificationLevelMentionUsers) : @"群聊，超级群 @成员列表有自己时通知，@所有人不通知",
            @(RCPushNotificationLevelMentionAll) : @"群聊，超级群 @所有人通知",
            @(RCPushNotificationLevelBlocked) : @"消息通知被屏蔽",
            @(10) : @"无效Level类型"
        };
        _dicLevels = dicLevels;
    }
    return _dicLevels;
}

- (NSDictionary *)dicTypes {
    if (!_dicTypes) {
        NSDictionary *dicTypes = @{
            @(ConversationType_PRIVATE) : @"私聊",
            @(ConversationType_GROUP) : @"群聊",
            @(ConversationType_ULTRAGROUP) : @"超级群",
            @(ConversationType_CHATROOM) : @"聊天室(不支持)",
            @(100) : @"无效类别"
        };
        _dicTypes = dicTypes;
    }
    return _dicTypes;
}
@end
