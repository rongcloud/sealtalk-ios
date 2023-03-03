//
//  RCDUserGroupUserSelectorViewController.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDUserGroupMemberInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RCDUserGroupUserSelectorDelegate <NSObject>

- (void)userDidSelectMembers:(NSArray<RCDUserGroupMemberInfo *> *)members
                    original:(NSArray<NSString *> *)userIDs;

@end

@interface RCDUserGroupUserSelectorViewController : UIViewController
@property(nonatomic, weak) id<RCDUserGroupUserSelectorDelegate> delegate;
@property(nonatomic, copy) NSString *groupID;
@property(nonatomic, strong) NSArray<NSString *> *userIDs;
@end

NS_ASSUME_NONNULL_END
