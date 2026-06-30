//
//  RCNDSearchMessageCell.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseCell.h"
NSString  * const RCNDSearchMessageCellIdentifier;
NS_ASSUME_NONNULL_BEGIN

@interface RCNDSearchMessageCell : RCNDBaseCell
@property (nonatomic, strong) UIImageView *imageViewPortrait;
@property (nonatomic, strong) UIStackView *topStackView;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *labelSubtitle;
@property (nonatomic, strong) UILabel *labelTime;
@property (nonatomic, strong) UIStackView *rightStackView;

@end

NS_ASSUME_NONNULL_END
