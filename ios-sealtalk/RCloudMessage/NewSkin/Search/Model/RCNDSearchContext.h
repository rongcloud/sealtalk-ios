//
//  RCNDSearchContext.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCNDSearchFriendCellViewModel.h"
#import "RCNDSearchGroupCellViewModel.h"
#import "RCNDSearchConversationCellViewModel.h"
#import "RCNDSearchMoreCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchResult : NSObject
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger index;
@end

@interface RCNDSearchContext : NSObject
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, strong) NSArray <RCNDSearchResult *>*dataSource;
- (instancetype)initWithKeyword:(NSString *)keyword
                     completion:(void(^)(void))completion;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSections;
- (void)tasksInvalid;
- (void)tasksResume;
@end

NS_ASSUME_NONNULL_END
