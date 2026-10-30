//
//  RCNDAccountSettingViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDAccountSettingViewModel.h"
#import "RCNDCommonCellViewModel.h"
#import "RCNDSwitchCellViewModel.h"
#import "RCNDBlackListViewController.h"
#import "RCNDConversationBackgroundViewController.h"
#import "RCNDMessageBlockViewController.h"
#import "RCNDCleanHistoryViewController.h"
#import "RCDUserInfoManager.h"
#import "RCDCommonString.h"
#import "RCDLoginManager.h"

@interface RCNDAccountSettingViewModel()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) RCDUserSetting *userSettings;

@property (nonatomic, strong) RCNDSwitchCellViewModel *addMe;
@property (nonatomic, strong) RCNDSwitchCellViewModel *searchByIM;
@property (nonatomic, strong) RCNDSwitchCellViewModel *searchByMobile;
@property (nonatomic, strong) RCNDSwitchCellViewModel *addGroup;

@property (nonatomic, strong) RCNDSwitchCellViewModel *poke;
@property (nonatomic, strong) RCNDSwitchCellViewModel *msgNotification;
@end

@implementation RCNDAccountSettingViewModel
- (void)ready {
    [super ready];
    __weak typeof(self) weakSelf = self;
    
    self.dataSource = [NSMutableArray array];
    [self.dataSource addObject:[self privacySection]];
    [self.dataSource addObject:[self messageNoticeSection]];
    NSArray *blackList = [self sectionItemsWithTitle:RCDLocalizedString(@"blacklist") tapBlock:^(UIViewController * _Nonnull vc) {
        RCNDBlackListViewModel *vm = [RCNDBlackListViewModel new];
        RCNDBlackListViewController *controller = [[RCNDBlackListViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    [self.dataSource addObject:blackList];
    
    NSArray *chatBackground = [self sectionItemsWithTitle:RCDLocalizedString(@"ChatBackground") tapBlock:^(UIViewController * _Nonnull vc) {
        RCNDConversationBackgroundViewModel *vm = [RCNDConversationBackgroundViewModel new];
        RCNDConversationBackgroundViewController *controller = [[RCNDConversationBackgroundViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    [self.dataSource addObject:chatBackground];
    
    NSArray *cleanCache = [self sectionItemsWithTitle:RCDLocalizedString(@"clear_cache") tapBlock:^(UIViewController * _Nonnull vc) {
        if ([weakSelf.accountDelegate respondsToSelector:@selector(userDidSelectedCleanCache)]) {
            [weakSelf.accountDelegate userDidSelectedCleanCache];
        }
    }];
    [self.dataSource addObject:cleanCache];
    
    NSArray *cleanHistory = [self sectionItemsWithTitle:RCDLocalizedString(@"clear_chat_history") tapBlock:^(UIViewController * _Nonnull vc) {
        RCNDCleanHistoryViewModel *vm = [RCNDCleanHistoryViewModel new];
        RCNDCleanHistoryViewController *controller = [[RCNDCleanHistoryViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    [self.dataSource addObject:cleanHistory];
    [self removeSeparatorLineIfNeed:self.dataSource];
    [self getCurrentUserSettings];
    [self getPokeSetting];
    [self getNotificationQuietHours];
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDCommonCell class]
      forCellReuseIdentifier:RCNDCommonCellIdentifier];
    [tableView registerClass:[RCNDSwitchCell class]
      forCellReuseIdentifier:RCNDSwitchCellIdentifier];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataSource[section];
    return array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (RCBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataSource[indexPath.section];
    return array[indexPath.row];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    switch (section) {
        case 0:
            title = RCDLocalizedString(@"SecurityAndprivacy");
            break;
        case 1:
            title = RCDLocalizedString(@"new_message_notification");
            break;
        default:
            break;
    }
    return title;
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 16;
    switch (section) {
        case 0:
        case 1:
            height = 21;
            break;
        default:
            break;
    }
    return height;
}
#pragma mark - Privacy Setting

- (void)changeSearchMeByMobile:(BOOL)switchOn completion:(void(^)(BOOL ret))completion {
    [RCDUserInfoManager setSearchMeByMobile:switchOn
                                   complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
            if (success) {
                [self showTips:RCDLocalizedString(@"setting_success")];
            } else {
                [self showTips:RCDLocalizedString(@"SetFailure")];
            }
        });
    }];
}

- (void)changeSearchMeBySTAccount:(BOOL)switchOn completion:(void(^)(BOOL ret))completion {
    [RCDUserInfoManager setSearchMeBySTAccount:switchOn
                                      complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
            if (success) {
                [self showTips:RCDLocalizedString(@"setting_success")];
            } else {
                [self showTips:RCDLocalizedString(@"SetFailure")];
            }
        });
    }];
}

- (void)changeAddFriendVerify:(BOOL)switchOn completion:(void(^)(BOOL ret))completion {
    [RCDUserInfoManager setAddFriendVerify:switchOn
                                  complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
            if (success) {
                [self showTips:RCDLocalizedString(@"setting_success")];
            } else {
                [self showTips:RCDLocalizedString(@"SetFailure")];
            }
        });
    }];
}


- (void)changeJoinGroupVerify:(BOOL)switchOn completion:(void(^)(BOOL ret))completion {
    [RCDUserInfoManager setJoinGroupVerify:switchOn
                                  complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
            if (success) {
                [self showTips:RCDLocalizedString(@"setting_success")];
            } else {
                [self showTips:RCDLocalizedString(@"SetFailure")];
            }
        });
    }];
}

- (void)showTips:(NSString *)tips {
    if ([self.delegate respondsToSelector:@selector(showTips:)]) {
        [self.delegate showTips:tips];
    }
}


- (void)getCurrentUserSettings {
    __weak typeof(self) weakSelf = self;
    [RCDUserInfoManager getUserPrivacyFromServer:^(RCDUserSetting *setting) {
        if (!setting) {
            setting = [RCDUserInfoManager getUserPrivacy];
        }
        [weakSelf refreshPrivacyWithSetting:setting];
    }];
}

- (void)refreshPrivacyWithSetting:(RCDUserSetting *)setting {
    self.userSettings = setting;
    self.addMe.switchOn = setting.needAddFriendVerify;
    self.searchByIM.switchOn = setting.allowSTAccountSearch;
    self.searchByMobile.switchOn = setting.allowMobileSearch;
    self.addGroup.switchOn = setting.needJoinGroupVerify;
    [self reloadData];
}

#pragma mark - Notification
- (void)changeReceiveNotification:(BOOL)switchOn
                       completion:(RCNDSwitchCellViewModelInnerBoolBlock)completion {
    if (!switchOn) {
        [[RCCoreClient sharedCoreClient] setNotificationQuietHours:@"00:00:00"
                                                          spanMins:1439
                                                           success:^{
            if (completion) {
                completion(YES);
            }
            [self showTips:RCDLocalizedString(@"setting_success")];
        }
                                                             error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(NO);
                }
                [self showTips:RCDLocalizedString(@"SetFailure")];
            });
        }];
    } else {
        [[RCCoreClient sharedCoreClient] removeNotificationQuietHours:^{
            if (completion) {
                completion(YES);
            }
            [self showTips:RCDLocalizedString(@"setting_success")];
        }
                                                                error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(NO);
                }
                [self showTips:RCDLocalizedString(@"SetFailure")];
            });
        }];
    }
}

- (void)changeReceivePokeMessage:(BOOL)switchOn
                      completion:(RCNDSwitchCellViewModelInnerBoolBlock)completion {
    [RCDUserInfoManager setReceivePokeMessage:switchOn
                                     complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
            if (success) {
                [self showTips:RCDLocalizedString(@"setting_success")];
            } else {
                [self showTips:RCDLocalizedString(@"SetFailure")];
            }
        });
    }];
}
- (void)changeShowPushContentStatus:(BOOL)switchOn
                         completion:(RCNDSwitchCellViewModelInnerBoolBlock)completion {
    [[RCCoreClient sharedCoreClient]
        .pushProfile updateShowPushContentStatus:switchOn
     success:^{
        if (completion) {
            completion(YES);
        }
        [self showTips:RCDLocalizedString(@"setting_success")];
    }
     error:^(RCErrorCode status) {
        if (completion) {
            completion(NO);
        }
        [self showTips:RCDLocalizedString(@"set_fail")];
        
    }];
}
- (void)getPokeSetting {
    [RCDUserInfoManager getReceivePokeMessageStatusFromServer:^(BOOL allowReceive) {
        self.poke.switchOn = allowReceive;
        [self reloadData];
    }
                                                        error:^{
        self.poke.switchOn = NO;
        [self reloadData];
    }];
}

- (void)getNotificationQuietHours {
    [[RCCoreClient sharedCoreClient] getNotificationQuietHours:^(NSString *startTime, int spanMins) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (spanMins >= 1439) {
                self.msgNotification.switchOn = NO;
            } else {
                self.msgNotification.switchOn = YES;
            }
            [self reloadData];
        });
    }
                                                         error:^(RCErrorCode status) {
        
    }];
}

#pragma mark - 清理缓存
//清理缓存
- (void)clearCache:(void(^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        //这里清除 Library/Caches 里的所有文件，融云的缓存文件及图片存放在 Library/Caches/RongCloud 下
        NSString *cachPath =
            [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];

        for (NSString *p in files) {
            NSError *error;
            NSString *path = [cachPath stringByAppendingPathComponent:p];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        }

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *naviCachePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences"]
            stringByAppendingPathComponent:@"cn.rongcloud.rcim.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:naviCachePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:naviCachePath error:nil];
        }

        if (completion) {
            completion();
        }
    });
}
#pragma mark - DataSource

- (void)reloadData {
    if ([self.delegate respondsToSelector:@selector(reloadData:)]) {
        [self.delegate reloadData:NO];
    }
}
- (NSArray *)privacySection {
    __weak typeof(self) weakSelf = self;
    RCNDSwitchCellViewModel *addMe = [[RCNDSwitchCellViewModel alloc] initWithSwitchOn:YES switchBlock:^(BOOL switchOn, RCNDSwitchCellViewModelInnerBoolBlock  _Nullable innerBlock) {
        [weakSelf changeAddFriendVerify:switchOn completion:innerBlock];
    }];
    addMe.title = RCDLocalizedString(@"AddFriendNeedAuth");
    
    RCNDSwitchCellViewModel *searchByIM = [[RCNDSwitchCellViewModel alloc] initWithSwitchOn:YES switchBlock:^(BOOL switchOn, RCNDSwitchCellViewModelInnerBoolBlock  _Nullable innerBlock) {
        [weakSelf changeSearchMeBySTAccount:switchOn completion:innerBlock];
        
    }];
    searchByIM.title = RCDLocalizedString(@"AllowSearchBySTNum");
    
    RCNDSwitchCellViewModel *searchByMobile = [[RCNDSwitchCellViewModel alloc] initWithSwitchOn:YES switchBlock:^(BOOL switchOn, RCNDSwitchCellViewModelInnerBoolBlock  _Nullable innerBlock) {
        [weakSelf changeSearchMeByMobile:switchOn completion:innerBlock];
    }];
    searchByMobile.title = RCDLocalizedString(@"AllowSearchByMobile");
    
    RCNDSwitchCellViewModel *addGroup = [[RCNDSwitchCellViewModel alloc] initWithSwitchOn:YES switchBlock:^(BOOL switchOn, RCNDSwitchCellViewModelInnerBoolBlock  _Nullable innerBlock) {
        [weakSelf changeJoinGroupVerify:switchOn completion:innerBlock];
    }];
    addGroup.title = RCDLocalizedString(@"AllowAddGroup");
    self.addMe = addMe;
    self.searchByIM = searchByIM;
    self.searchByMobile = searchByMobile;
    self.addGroup = addGroup;
    return @[addMe, searchByIM, searchByMobile, addGroup];
}

- (NSArray *)messageNoticeSection {
    __weak typeof(self) weakSelf = self;
    
    RCNDSwitchCellViewModel *msgNotification = [[RCNDSwitchCellViewModel alloc] initWithSwitchOn:YES switchBlock:^(BOOL switchOn, RCNDSwitchCellViewModelInnerBoolBlock  _Nullable innerBlock) {
        [weakSelf changeReceiveNotification:switchOn completion:innerBlock];
    }];
    msgNotification.title = RCDLocalizedString(@"Receive_new_message_notifications");
    self.msgNotification = msgNotification;
    RCNDSwitchCellViewModel *pushContent = [[RCNDSwitchCellViewModel alloc] initWithSwitchOn:YES switchBlock:^(BOOL switchOn, RCNDSwitchCellViewModelInnerBoolBlock  _Nullable innerBlock) {
        [weakSelf changeShowPushContentStatus:switchOn completion:innerBlock];
    }];
    pushContent.switchOn = [RCCoreClient sharedCoreClient].pushProfile.isShowPushContent;
    pushContent.title = RCDLocalizedString(@"Display_remotely_pushed_content");
    
    
    RCNDCommonCellViewModel *distribution = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        RCNDMessageBlockViewModel *vm = [RCNDMessageBlockViewModel new];
        
        RCNDMessageBlockViewController *controller = [[RCNDMessageBlockViewController alloc] initWithViewModel:vm];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    distribution.title = RCDLocalizedString(@"Turn_on_message_do_not_disturb");
    
    RCNDSwitchCellViewModel *poke = [[RCNDSwitchCellViewModel alloc] initWithSwitchOn:YES switchBlock:^(BOOL switchOn, RCNDSwitchCellViewModelInnerBoolBlock  _Nullable innerBlock) {
        [weakSelf changeReceivePokeMessage:switchOn completion:innerBlock];
    }];
    self.poke = poke;
    poke.title = RCDLocalizedString(@"ReceivePokeMessage");
    return @[msgNotification, pushContent, distribution,poke];
}

- (NSArray *)sectionItemsWithTitle:(NSString *)title
                          tapBlock:(RCNDCommonCellViewModelBlock)tapBlock {
    RCNDCommonCellViewModel *vm = [[RCNDCommonCellViewModel alloc] initWithTapBlock:tapBlock];
    vm.title = title;
    return @[vm];
}

- (void)removeAccount:(void (^)(BOOL success))completeBlock {
    [RCDLoginManager removeAccount:^(BOOL success) {
        if(success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self class] clearAccountInfo];
                [DEFAULTS removeObjectForKey:RCDPhoneKey];
                [DEFAULTS synchronize];
            });
        }
        if (completeBlock) {
            completeBlock(success);
        }
        
    }];
}


+ (void)clearAccountInfo {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [DEFAULTS removeObjectForKey:RCDIMTokenKey];
    [RCDNotificationServiceDefaults removeObjectForKey:RCDIMTokenKey];
    [DEFAULTS synchronize];


    [[RCIM sharedRCIM] logout];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:MCShareExtensionKey];
    [userDefaults removeObjectForKey:RCDCookieKey];
    [userDefaults synchronize];
    [RCDLoginManager logout:^(BOOL success){
    }];
}
@end
