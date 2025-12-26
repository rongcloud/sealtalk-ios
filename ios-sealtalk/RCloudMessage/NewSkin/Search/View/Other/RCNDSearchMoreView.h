//
//  RCNDSearchMoreView.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import <MJRefresh/MJRefresh.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchMoreView : RCSearchBarListView
@property (nonatomic, strong) MJRefreshAutoNormalFooter *footer;

@end

NS_ASSUME_NONNULL_END
