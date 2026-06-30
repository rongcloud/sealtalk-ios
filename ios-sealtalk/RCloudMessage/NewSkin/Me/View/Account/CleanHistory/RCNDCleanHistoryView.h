//
//  RCNDCleanHistoryView.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCNDCleanHistoryView : RCSearchBarListView
@property (nonatomic, strong) UIButton *buttonDelete;
@property (nonatomic, strong) UIButton *buttonSelectAll;
- (void)changeButtonsStatusBy:(NSInteger)count
                isAllSelected:(BOOL)allSelected;
@end

NS_ASSUME_NONNULL_END
