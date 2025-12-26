//
//  RCNDCleanHistoryViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDCleanHistoryViewModel : RCNDBaseListViewModel
@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)fetchAllData;
- (NSInteger)changeAllConversationsStatus;
- (NSInteger)numberOfConversationSelected;
- (void)cleanHistoryOfConversationSelected;
- (void)cleanHistoryOfConversationSelected:(void(^)(BOOL))completion;
@end

NS_ASSUME_NONNULL_END
