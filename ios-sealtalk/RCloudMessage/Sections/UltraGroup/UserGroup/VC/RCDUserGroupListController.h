//
//  RCDUserGroupTableViewController.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/10.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupListController : UIViewController
@property(nonatomic, copy) NSString *groupID;
@property(nonatomic, assign) BOOL isOwner;
@end

NS_ASSUME_NONNULL_END
