//
//  RCNDContactViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
#import "RCNDContactCellViewModel.h"
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCNDContactViewModel : RCNDBaseListViewModel

/// 分区名称
- (NSArray *)sectionIndexTitles;

/// 获取数据
- (void)fetchData;

/// 停止编辑
- (void)endEditingState;

- (UIView *)searchBarView;

- (RCNDContactCellViewModel *)currentContactCellViewModel;
@end

NS_ASSUME_NONNULL_END
