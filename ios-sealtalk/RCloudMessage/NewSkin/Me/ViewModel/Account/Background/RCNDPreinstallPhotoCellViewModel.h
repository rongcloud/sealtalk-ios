//
//  RCNDPreinstallPhotoCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RCNDPreinstallPhotoCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCNDPreinstallPhotoCellViewModel : RCBaseCellViewModel
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *detailImageName;
@end

NS_ASSUME_NONNULL_END
