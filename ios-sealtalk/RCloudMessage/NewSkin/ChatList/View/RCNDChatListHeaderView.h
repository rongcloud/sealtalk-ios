//
//  RCNDChatListHeaderView.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/17.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCNDChatListHeaderView : RCBaseView

/// 配置 searchBar，模仿 RCSearchBarListView 的容器包装方式
/// inner 容器的 masksToBounds 和 backgroundColor 会遮挡 searchBar 内部的背景色
- (void)configureSearchBar:(UIView *)bar;

@end

NS_ASSUME_NONNULL_END
