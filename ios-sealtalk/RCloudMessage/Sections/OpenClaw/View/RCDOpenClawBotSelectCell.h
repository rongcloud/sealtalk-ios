//
//  RCDOpenClawBotSelectCell.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/14.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const RCDOpenClawBotSelectCellIdentifier;
extern CGFloat const RCDOpenClawBotSelectCellHeight;

typedef NS_ENUM(NSUInteger, RCDOpenClawBotSelectCellState) {
    RCDOpenClawBotSelectCellStateDisable,
    RCDOpenClawBotSelectCellStateUnselected,
    RCDOpenClawBotSelectCellStateSelected,
};

@interface RCDOpenClawBotSelectCell : RCDTableViewCell

@property (nonatomic, assign) BOOL hideSeparatorLine;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)configureWithName:(NSString *)name portraitUri:(NSString *)portraitUri;
- (void)setCellSelectState:(RCDOpenClawBotSelectCellState)state;

@end

NS_ASSUME_NONNULL_END
