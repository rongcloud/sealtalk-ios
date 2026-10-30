//
//  RCDOpenClawGroupBotAddCell.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/14.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const RCDOpenClawGroupBotAddCellIdentifier;
extern CGFloat const RCDOpenClawGroupBotAddCellHeight;

@interface RCDOpenClawGroupBotAddCell : RCDTableViewCell

@property (nonatomic, assign) BOOL hideSeparatorLine;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)configureWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
