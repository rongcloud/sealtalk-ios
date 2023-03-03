//
//  RCDUserGroupSelectorViewController.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/12.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDUserGroupInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RCDUserGroupUserSelectorDelegate <NSObject>

- (void)userDidSelectUserGroups:(NSArray<RCDUserGroupInfo *> *)userGroups;

@end

@interface RCDUserGroupSelectorViewController : UIViewController
@property(nonatomic, weak) id<RCDUserGroupUserSelectorDelegate> delegate;
@property(nonatomic, copy) NSString *groupID;
@property(nonatomic, strong) NSArray<NSString *> *userGroupIDs;

@end

NS_ASSUME_NONNULL_END
