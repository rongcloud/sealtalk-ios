//
//  RCNDSearchFriendCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchResultCellViewModel.h"
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchFriendCellViewModel : RCNDSearchResultCellViewModel
@property (nonatomic, strong) RCFriendInfo *info;
@property (nonatomic, copy) NSMutableAttributedString *title;
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *uniqueID;
- (instancetype)initWithFriendInfo:(RCFriendInfo *)info
                           keyword:(NSString *)keyword;
- (BOOL)shouldShowRemark;
@end

NS_ASSUME_NONNULL_END
