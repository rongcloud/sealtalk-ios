//
//  RCNDSearchGroupCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchResultCellViewModel.h"
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchGroupCellViewModel : RCNDSearchResultCellViewModel
@property (nonatomic, strong) RCGroupInfo *info;
@property (nonatomic, copy) NSMutableAttributedString *title;
- (instancetype)initWithGroupInfo:(RCGroupInfo *)info
                          keyword:(NSString *)keyword;
@end

NS_ASSUME_NONNULL_END
