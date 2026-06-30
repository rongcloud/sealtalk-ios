//
//  RCGroupQRCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCGroupQRCellViewModel : RCProfileCellViewModel
@property (nonatomic, copy) NSString *groupId;
+ (instancetype)viewModelWithGroupId:(NSString *)groupId;
@end

NS_ASSUME_NONNULL_END
