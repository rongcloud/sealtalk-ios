//
//  RCDOpenClawBotActionCell.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/9.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const RCDOpenClawBotActionCellIdentifier;
extern CGFloat const RCDOpenClawBotActionCellHeight;

@interface RCDOpenClawBotActionCell : UITableViewCell

@property (nonatomic, strong, readonly) UIButton *actionButton;
@property (nonatomic, assign) BOOL hideSeparatorLine;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)configureWithName:(NSString *)name portraitUri:(NSString *)portraitUri;
- (void)setActionButtonVisible:(BOOL)visible;
- (void)configureDeleteActionButton;
- (void)configureAddActionButtonWithTitle:(NSString *)title enabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
