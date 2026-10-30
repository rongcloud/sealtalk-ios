//
//  RCNDSearchMoreViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
#import <RongIMKit/RongIMKit.h>
NSInteger const RCNDSearchMoreViewModelMaxCount;
NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchMoreViewModel : RCNDBaseListViewModel
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *keyword;

- (instancetype)initWithTitle:(NSString *)title
                      keyword:(NSString *)keyword;
- (void)fetchData:(void (^)(BOOL noMoreData))completion;
- (void)fetchDataWithBlock:(void (^)(NSArray * _Nonnull))completion;
- (UIView *)searchBar;
- (void)loadMore:(void (^)(BOOL noMoreData))completion;
- (void)loadMoreWithBlock:(void(^)(NSArray *array))completion;
- (void)endEditingState;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (CGFloat)heightForHeaderInSection:(NSInteger)section;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
