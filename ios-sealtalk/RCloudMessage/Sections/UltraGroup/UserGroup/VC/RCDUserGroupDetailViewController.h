//
//  RCDUserGroupDetailViewController.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDUserGroupInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupDetailViewController : UIViewController
@property(nonatomic, assign) BOOL isOwner;

- (instancetype)initWithUserGroup:(RCDUserGroupInfo *)userGroup;

@end

NS_ASSUME_NONNULL_END
