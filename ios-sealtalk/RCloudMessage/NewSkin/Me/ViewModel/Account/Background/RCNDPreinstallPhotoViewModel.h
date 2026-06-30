//
//  RCNDPreinstallPhotoViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewModel.h"
#import "RCNDPreinstallPhotoCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDPreinstallPhotoViewModel : RCNDBaseViewModel
@property (nonatomic, strong) NSArray *dataSource;
- (void)refresh;
@end

NS_ASSUME_NONNULL_END
