//
//  RCNDContactCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDImageCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDContactCellViewModel : RCNDImageCellViewModel
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) RCFriendInfo *info;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, copy) NSString *displayName;

- (instancetype)initWithFriendInfo:(RCFriendInfo *)info;
- (void)cellViewModelUnselected;
@end

NS_ASSUME_NONNULL_END
