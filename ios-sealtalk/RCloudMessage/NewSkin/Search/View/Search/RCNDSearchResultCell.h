//
//  RCNDSearchResultCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/28.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCell.h"
#import <SDWebImage/SDWebImage.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchResultCell : RCNDBaseCell
@property (nonatomic, strong) UIImageView *imageViewPortrait;
@property (nonatomic, strong) UIStackView *rightStackView;
@property (nonatomic, strong) UILabel *labelTitle;

@end

NS_ASSUME_NONNULL_END
