//
//  RCNDSearchMessageCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchResultCellViewModel.h"
#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN
@class RCNDSearchMessageCellViewModel;
@protocol RCNDSearchMessageCellViewModelDelegate <NSObject>
- (void)refreshCellWith:(RCNDSearchMessageCellViewModel *)viewModel;

@end

@interface RCNDSearchMessageCellViewModel : RCNDSearchResultCellViewModel
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *portraitURI;
@property (nonatomic, copy) NSMutableAttributedString *subtitle;
@property (nonatomic, weak) id<RCNDSearchMessageCellViewModelDelegate> cellDelegate;
@property (nonatomic, strong) RCMessage *info;
@property (nonatomic, copy) NSString *timeString;

- (instancetype)initWithMessageInfo:(RCMessage *)info
                            keyword:(NSString *)keyword;
@end

NS_ASSUME_NONNULL_END
