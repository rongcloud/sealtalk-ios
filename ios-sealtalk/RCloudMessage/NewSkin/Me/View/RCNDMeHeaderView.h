//
//  RCNDMeHeaderView.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCNDMeHeaderView : RCNDBaseView

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *remarkLabel;

@property (nonatomic, strong) UIImageView *portraitImageView;

@property (nonatomic, strong) UIStackView *rightStackView;

@property (nonatomic, strong) UIStackView *contentStackView;

- (void)showPortrait:(NSString *)imageURL;
- (void)showPortrait:(NSString *)imageURL isGroup:(BOOL)isGroup;
@end

NS_ASSUME_NONNULL_END
