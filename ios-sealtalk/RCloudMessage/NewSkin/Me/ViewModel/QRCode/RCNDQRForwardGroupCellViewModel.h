//
//  RCNDQRForwardGroupCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardSelectCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDQRForwardGroupCellViewModel : RCNDQRForwardSelectCellViewModel
@property (nonatomic, strong) RCGroupInfo *info;
@end

NS_ASSUME_NONNULL_END
