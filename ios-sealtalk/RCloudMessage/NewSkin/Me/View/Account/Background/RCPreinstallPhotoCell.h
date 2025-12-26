//
//  RCPreinstallPhotoCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCollectionViewCell.h"

extern NSString  * const RCPreinstallPhotoCellIdentifier;
NS_ASSUME_NONNULL_BEGIN

@interface RCNDPreinstallPhotoCell : RCNDBaseCollectionViewCell
@property (nonatomic, strong) UIImageView *imageContent;
@end

NS_ASSUME_NONNULL_END
