//
//  RCDChannelUserInfoCell.m
//  SealTalk
//
//  Created by RobinCui on 2022/6/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDChannelUserInfoCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

NSString * const RCDChannelUserInfoCellIdentifier = @"RCDChannelUserInfoCellIdentifier";

@interface RCDChannelUserInfoCell()<RCDChannelUserInfoCellViewModelDelegate>

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *headImgView;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation RCDChannelUserInfoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
        if (@available(iOS 13.0, *)) {
            self.backgroundColor = [UIColor systemBackgroundColor];
        } else {
#endif
            self.backgroundColor = [UIColor whiteColor];
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
        }
#endif
        [self setupView];
    }
    return self;
}

#pragma mark - Public

- (void)updateCellWith:(RCDChannelUserInfoCellViewModel *)viewModel {
    viewModel.delegate = self;
    [self refreshUIWith:viewModel.userInfo];
}

- (void)refreshUIWith:(RCDChannelUserInfo *)userInfo {
    self.titleLab.text = userInfo.name;
    if (userInfo.portrait) {
        NSURL *url = [NSURL URLWithString:userInfo.portrait];
        [self.headImgView sd_setImageWithURL:url];
    }
    UIColor *color = userInfo.isInWhiteList ? [UIColor greenColor] : [UIColor redColor];
    self.containerView.layer.borderColor = [color CGColor];
}
#pragma mark - RCDChannelUserInfoCellViewModelDelegate

- (void)channelUserInfoDidChanged:(RCDChannelUserInfo *)userInfo isSuccess:(BOOL)success {
    if (success) {
        [self refreshUIWith:userInfo];
    } else {
        [self shakeAnimationForView:self.containerView];
    }
}

#pragma mark - Private
- (void)shakeAnimationForView:(UIView *) view
{
    // 获取到当前的View
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:.06];
    [animation setRepeatCount:3];
    [viewLayer addAnimation:animation forKey:nil];
}

- (void)setupView {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.containerView addSubview:self.headImgView];
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self).mas_offset(5);
        make.height.width.mas_equalTo(64);
    }];
    
    [self.containerView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-4);
        make.left.mas_equalTo(self).mas_offset(4);
        make.bottom.mas_equalTo(self).mas_offset(-5);
        //            make.height.mas_equalTo(12);
    }];
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.layer.cornerRadius = 8;
        _containerView.layer.borderWidth = 2;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor darkGrayColor];
    }
    return _titleLab;
}

- (UIImageView *)headImgView {
    if (!_headImgView) {
        _headImgView = [UIImageView new];
        _headImgView.layer.cornerRadius = 32;
        _headImgView.layer.masksToBounds = YES;
    }
    return _headImgView;
}
@end
