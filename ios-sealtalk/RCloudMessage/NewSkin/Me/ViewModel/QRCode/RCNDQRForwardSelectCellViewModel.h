//
//  RCNDQRForwardSelectCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCellViewModel.h"
#import <RongIMKit/RongIMKit.h>
#import "RCNDCommonCellViewModel.h"
NS_ASSUME_NONNULL_BEGIN
@class RCNDQRForwardSelectCellViewModel;
@protocol RCNDQRForwardSelectCellViewModelDelegate <NSObject>
- (void)refreshCellWith:(RCNDQRForwardSelectCellViewModel *)viewModel;

@end
@interface RCNDQRForwardSelectCellViewModel : RCNDBaseCellViewModel
@property (nonatomic, weak) id<RCNDQRForwardSelectCellViewModelDelegate> cellDelegate;
@property (nonatomic, copy) NSString *portraitURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *targetID;

@property (nonatomic, assign) RCConversationType conversationType;
@property (nonatomic, copy) RCNDCommonCellViewModelBlock tapBlock;
- (instancetype)initWithTapBlock:(RCNDCommonCellViewModelBlock)tapBlock;
- (void)refreshCell;
- (void)fetchData:(void(^)(void))completion;
@end

NS_ASSUME_NONNULL_END
