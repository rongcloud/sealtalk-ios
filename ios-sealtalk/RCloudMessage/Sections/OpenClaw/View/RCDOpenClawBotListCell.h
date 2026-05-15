//
//  RCDOpenClawBotListCell.h
//  SealTalk
//
//  Created by RongCloud on 2026/5/9.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const RCDOpenClawBotListCellIdentifier;
extern CGFloat const RCDOpenClawBotListCellHeight;

@interface RCDOpenClawBotListCell : UITableViewCell

- (void)configureWithName:(NSString *)name portraitUri:(NSString *)portraitUri;

@end

NS_ASSUME_NONNULL_END
