//
//  RCNDImageCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCommonCellViewModel.h"
#import "RCNDImageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDImageCellViewModel : RCNDCommonCellViewModel
@property (nonatomic, assign) BOOL hideIcon;
@property (nonatomic, strong) NSString *imageName;
@end

NS_ASSUME_NONNULL_END
