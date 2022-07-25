//
//  RCDUltraGroupCell.h
//  SealTalk
//
//  Created by 张改红 on 2022/1/19.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
#import <RongIMKit/RongIMKit.h>
static NSString *_Nullable RCDUltraGroupCellIdentifier = @"RCDUltraGroupCellIdentifier";

NS_ASSUME_NONNULL_BEGIN

@interface RCDUltraGroupCell : RCDTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) UIImageView *portraitImageView;
/*!
 头像右上角未读消息提示的View
 */
@property (nonatomic, strong) RCMessageBubbleTipView *bubbleTipView;
@end

NS_ASSUME_NONNULL_END
