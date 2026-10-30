//
//  RCNDSearchConversationCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchResultCellViewModel.h"
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN
@class RCNDSearchConversationCellViewModel;
@protocol RCNDSearchConversationCellViewModelDelegate <NSObject>
- (void)refreshCellWith:(RCNDSearchConversationCellViewModel *)viewModel;

@end

@interface RCNDSearchConversationCellViewModel : RCNDSearchResultCellViewModel
@property (nonatomic, strong) RCSearchConversationResult *info;
@property (nonatomic, weak) id<RCNDSearchConversationCellViewModelDelegate> cellDelegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *portraitURI;
@property (nonatomic, copy) NSMutableAttributedString *subtitle;
- (instancetype)initWithConversationInfo:(RCSearchConversationResult *)info
                                 keyword:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
