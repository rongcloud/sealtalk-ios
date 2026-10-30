//
//  RCNDMemberRemoveCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDImageCellViewModel.h"
#import "RCNDMemberRemoveCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCNDMemberRemoveCellViewModel : RCNDImageCellViewModel
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, copy) NSString *userID;
- (void)actonButtonClick;
@end

NS_ASSUME_NONNULL_END
