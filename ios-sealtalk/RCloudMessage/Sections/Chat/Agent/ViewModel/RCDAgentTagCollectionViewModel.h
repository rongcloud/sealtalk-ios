//
//  RCDAgentTagCollectionViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>
#import "RCDAgentSettingCellViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCDAgentTagCollectionViewModel : RCDAgentSettingCellViewModel<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) RCConversationIdentifier *identifier;

- (instancetype)initWithIdentifier:(RCConversationIdentifier*)identifier;
@end

NS_ASSUME_NONNULL_END
