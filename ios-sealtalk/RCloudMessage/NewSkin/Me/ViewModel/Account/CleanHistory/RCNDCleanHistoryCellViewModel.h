//
//  RCNDCleanHistoryCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDImageCellViewModel.h"
#import "RCNDCleanHistoryCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCNDCleanHistoryCellViewModel : RCNDImageCellViewModel
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) RCConversation *conversation;
@property (nonatomic, strong) NSString *imageURL;

- (instancetype)initWithConversation:(RCConversation *)conversation;
@end

NS_ASSUME_NONNULL_END
