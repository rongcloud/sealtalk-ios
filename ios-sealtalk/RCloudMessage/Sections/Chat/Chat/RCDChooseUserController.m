//
//  RCDSelectingUserController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/20.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChooseUserController.h"
#import "RCDUIBarButtonItem.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUserInfoManager.h"
#import "RCDGroupMemberCell.h"
#import "RCDGroupManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import "UIView+MBProgressHUD.h"
#import "RCDSearchController.h"
#import "RCDUltraGroupManager.h"
#import "NormalAlertView.h"
@interface RCDChooseUserController () <UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) NSArray *allMembers;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSArray *resultKeys;
@property (nonatomic, strong) NSDictionary *resultSectionDict;
@property (nonatomic, strong) NSMutableArray *searchKeys;
@property (nonatomic, strong) NSMutableDictionary *searchResultDic;
@property (nonatomic, retain) RCDSearchController *searchController;
@property (nonatomic, assign) BOOL isUltraGroup;
@end

@implementation RCDChooseUserController
#pragma mark - life cycle
- (instancetype)initWithGroupId:(NSString *)groupId {
    return [self initWithGroupId:groupId isUltraGroup:NO];
}

- (instancetype)initWithGroupId:(NSString *)groupId isUltraGroup:(BOOL)isUltraGroup{
    if (self = [super init]) {
        self.groupId = groupId;
        self.isUltraGroup = isUltraGroup;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCLocalizedString(@"SelectMentionedUser");
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"cancel")
                                                                      style:(UIBarButtonItemStylePlain)
                                                                     target:self
                                                                     action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;

    [self getData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.resultKeys.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    NSString *key = self.resultKeys[section - 1];
    NSArray *array = self.resultSectionDict[key];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupMemberCell *cell = [RCDGroupMemberCell cellWithTableView:tableView];
    if (indexPath.section == 0 ) {
        if (self.searchController.searchBar.text.length == 0) {
            cell.portraitImageView.image = [UIImage imageNamed:@"choose_all"];
            cell.nameLabel.text = RCDLocalizedString(@"mention_all");
        }
    } else {
        NSString *key = self.resultKeys[indexPath.section - 1];
        NSArray *array = self.resultSectionDict[key];
        if (array.count > indexPath.row) {
            RCUserInfo *user = array[indexPath.row];
            [cell setDataModel:user.userId groupId:self.groupId];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    }
    return 30.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.frame = CGRectMake(12, 8, 15, 15);
    title.font = [UIFont systemFontOfSize:15.f];
    title.textColor = RCDDYCOLOR(0x999999, 0xA7a7a7);
    [view addSubview:title];
    title.text = self.resultKeys[section - 1];
    return view;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.resultKeys;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.searchController.searchBar.text.length > 0) {
        return 0;
    }
    return 55.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCUserInfo *user = [[RCUserInfo alloc] init];
    if (indexPath.section == 0) {
        user.userId = RCDMetionAllUsetId;
        user.name = RCDLocalizedString(@"all_users");
    } else {
        NSString *key = self.resultKeys[indexPath.section - 1];
        NSArray *array = self.resultSectionDict[key];
        user = array[indexPath.row];
        user = [RCDUserInfoManager getUserInfo:user.userId];
        RCDGroupMember *memberDetail = [RCDGroupManager getGroupMember:user.userId groupId:self.groupId];
        if (memberDetail.groupNickname.length > 0) {
            user.name = memberDetail.groupNickname;
        }
    }
    self.selectedBlock(user);
    [self dismissVC];
}

#pragma mark - UISearchController Delegate -
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //谓词搜索过滤
    NSString *searchString = [self.searchController.searchBar text];
    self.resultKeys = nil;
    self.resultSectionDict = nil;
    if ([searchString isEqualToString:@""]) {
        [self sortAndRefreshWithList:self.allMembers];
        return;
    } else {
        NSMutableArray *array = [NSMutableArray array];
        for (RCUserInfo *userInfo in self.allMembers) {
            RCUserInfo *user = [RCDUserInfoManager getUserInfo:userInfo.userId];
            RCDGroupMember *member = [RCDGroupManager getGroupMember:userInfo.userId groupId:self.groupId];
            if ([user.name containsString:searchString] || [user.alias containsString:searchString] ||
                [member.groupNickname containsString:searchString]) {
                [array addObject:userInfo];
            }
        }
        [self sortAndRefreshWithList:array.copy];
    }
}

#pragma mark - target action
- (void)clickBackBtn {
    self.cancelBlock();
    [self dismissVC];
}

#pragma mark - helper
- (void)getData {
    if (self.isUltraGroup) {
        __weak typeof(self) weakSelf = self;
        [RCDUltraGroupManager getUltraGroupMemberList:self.groupId count:50 complete:^(NSArray<NSString *> *memberIdList) {
            if (memberIdList) {
                [weakSelf handleData:memberIdList.mutableCopy];
            }else{
                [NormalAlertView showAlertWithTitle:nil message:RCDLocalizedString(@"获取成员列表失败") describeTitle:nil confirmTitle:RCDLocalizedString(@"confirm") confirm:^{
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        }];
    }else{
        NSMutableArray *array = [RCDGroupManager getGroupMembers:self.groupId].mutableCopy;
        if (array.count == 0) {
            __weak typeof(self) weakSelf = self;
            [RCDGroupManager getGroupMembersFromServer:self.groupId
                                              complete:^(NSArray<NSString *> *memberIdList) {
                                                  if (memberIdList) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [weakSelf handleData:memberIdList.mutableCopy];
                                                      });
                                                  }
                                              }];
        } else {
            [self handleData:array];
        }
    }
    
}

- (void)dismissVC {
    if ([self.searchController.searchBar isFirstResponder]) {
        [self.searchController.searchBar resignFirstResponder];
    }
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:^{
                                                  }];
}

- (void)handleData:(NSMutableArray *)array {
    [array removeObject:[RCIM sharedRCIM].currentUserInfo.userId];
    NSMutableArray *list = [NSMutableArray array];
    for (NSString *userId in array) {
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userId];
        if (friend.displayName.length > 0) {
            user.alias = friend.displayName;
        }
        if (user) { // 查询不到用户, 会引起crash
            [list addObject:user];
        }
    }
    self.allMembers = list.copy;
    [self sortAndRefreshWithList:list.copy];
}

- (void)sortAndRefreshWithList:(NSArray *)friendList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary *resultDic = [[RCDUtilities sortedArrayWithPinYinDic:friendList] copy];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.resultKeys = resultDic[@"allKeys"];
            self.resultSectionDict = resultDic[@"infoDic"];
            [self.tableView reloadData];
        });
    });
}

#pragma mark - getter
- (RCDSearchController *)searchController {
    if (!_searchController) {
        _searchController = [[RCDSearchController alloc] initWithSearchResultsController:nil];
        _searchController.delegate = self;
        _searchController.searchResultsUpdater = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
    }
    return _searchController;
}
@end
