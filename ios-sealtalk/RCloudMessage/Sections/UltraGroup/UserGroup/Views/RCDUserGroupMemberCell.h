//
//  RCDUserGroupMemberCell.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDUserGroupMemberInfo.h"
NS_ASSUME_NONNULL_BEGIN
extern NSString  * const RCDUserGroupMemberCellIdentifier;
@interface RCDUserGroupMemberCell : UITableViewCell
+ (instancetype)memberCell:(UITableView *)tableView
              forIndexPath:(NSIndexPath *)indexPath;

- (void)updateCell:(RCDUserGroupMemberInfo *)info;
@end

NS_ASSUME_NONNULL_END
