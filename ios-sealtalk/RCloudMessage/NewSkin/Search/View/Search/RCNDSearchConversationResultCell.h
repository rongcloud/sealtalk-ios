//
//  RCNDSearchConversationResultCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchResultCell.h"
NSString  * const RCNDSearchConversationResultCellIdentifier;
NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchConversationResultCell : RCNDSearchResultCell
@property (nonatomic, strong) UILabel *labelSubtitle;
@end

NS_ASSUME_NONNULL_END
