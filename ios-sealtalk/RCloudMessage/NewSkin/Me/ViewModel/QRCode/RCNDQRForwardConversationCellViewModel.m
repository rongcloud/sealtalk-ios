//
//  RCNDConversationSelectCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardConversationCellViewModel.h"

@implementation RCNDQRForwardConversationCellViewModel
- (void)fetchData:(void (^)(void))completion {
    self.targetID = self.info.targetId;
    self.conversationType = self.info.conversationType;
    if (self.info.conversationType == ConversationType_PRIVATE) {
        [[RCCoreClient sharedCoreClient] getFriendsInfo:@[self.info.targetId] success:^(NSArray<RCFriendInfo *> * _Nonnull friendInfos) {
            if (friendInfos.count) {
                RCFriendInfo *info = [friendInfos firstObject];
                self.title = info.remark.length >0 ? info.remark : info.name;
                self.portraitURL = info.portraitUri;
                if (completion) {
                    completion();
                }
            } else {
                [self fetchTitleFailed:completion];
            }
            
        } error:^(RCErrorCode errorCode) {
            [self fetchTitleFailed:completion];
        }];
    } else if (self.info.conversationType == ConversationType_GROUP) {
        RCPagingQueryOption *opt = [RCPagingQueryOption new];
        opt.count = 1;
        [[RCCoreClient sharedCoreClient] getGroupsInfo:@[self.info.targetId] success:^(NSArray<RCGroupInfo *> * _Nonnull groupInfos) {
            if (groupInfos.count) {
                RCGroupInfo *info = groupInfos[0];
                self.title = info.groupName;
                self.portraitURL = info.portraitUri;
                if (completion) {
                    completion();
                }
            } else {
                [self fetchTitleFailed:completion];
            }
        } error:^(RCErrorCode errorCode) {
            [self fetchTitleFailed:completion];
        }];
        
    } else {
        [self fetchTitleFailed:completion];
    }
}

- (void)fetchTitleFailed:(void (^)(void))completion {
    self.title = self.info.targetId;
    if (completion) {
        completion();
    }
}

@end
