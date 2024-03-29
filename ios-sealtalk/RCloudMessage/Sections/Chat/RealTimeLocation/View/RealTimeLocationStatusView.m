//
//  RealTimeLocationStatusView.m
//  LocationSharer
//
//  Created by litao on 15/7/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RealTimeLocationStatusView.h"
#import "RealTimeLocationDefine.h"
#import "RTLUtilities.h"

@interface RealTimeLocationStatusView ()
@property (nonatomic) BOOL isExpended;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *locationIcon;
@property (nonatomic, strong) UIImageView *moreIcon;

@property (nonatomic, strong) UILabel *expendLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *joinButton;
@end

#define RC_REAL_TIME_LOCATION_STATUS_FRAME CGRectMake(0, 62, self.frame.size.width, 38)
#define RC_REAL_TIME_LOCATION_EXPEND_FRAME CGRectMake(0, 62, self.frame.size.width, 85)

@implementation RealTimeLocationStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
         [self setBackgroundColor:UIColorFromRGB(0x000000, 0.6)];

        [self setup];
    }
    return self;
}
#pragma mark - public api
- (void)updateText:(NSString *)statusText {
    self.statusLabel.text = statusText;
}

- (void)updateRealTimeLocationStatus {
    switch ([self.delegate getStatus]) {
    case RC_REAL_TIME_LOCATION_STATUS_IDLE:
        self.hidden = YES;
        self.isExpended = NO;
        break;
    case RC_REAL_TIME_LOCATION_STATUS_INCOMING:
        self.hidden = NO;
        self.isExpended = NO;
        break;
    case RC_REAL_TIME_LOCATION_STATUS_OUTGOING:
    case RC_REAL_TIME_LOCATION_STATUS_CONNECTED:
        self.hidden = NO;
        self.isExpended = NO;
        break;
    default:
        break;
    }
}

#pragma mark - helper
- (void)setup {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTaped:)];
    [self addGestureRecognizer:tap];
}

- (void)onTaped:(id)sender {
    if ([self.delegate getStatus] == RC_REAL_TIME_LOCATION_STATUS_INCOMING) {
        self.isExpended = !self.isExpended;
    } else if ([self.delegate getStatus] == RC_REAL_TIME_LOCATION_STATUS_IDLE) {
        self.hidden = YES;
    } else {
        [self.delegate onShowRealTimeLocationView];
    }
}

- (void)onCanelPressed:(id)sender {
    self.isExpended = NO;
}

- (void)onJoinPressed:(id)sender {
    self.isExpended = NO;
    [self.delegate onJoin];
}

- (void)setIsExpended:(BOOL)isExpended {
    if (!self.hidden) {
        CGFloat statusBarHeight = [self statusBarHeight];
        if (!isExpended) {
            [self showStatus];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1f];
            CGRect frame = RC_REAL_TIME_LOCATION_STATUS_FRAME;
            frame.origin.y = 44 + statusBarHeight + FRAUD_PREVENTION_TIPS_HEIGHT;
            self.frame = frame;
            [UIView commitAnimations];
        } else {
            [self showExtendedView];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1f];
            CGRect frame = RC_REAL_TIME_LOCATION_EXPEND_FRAME;
            frame.origin.y = 44 + statusBarHeight + FRAUD_PREVENTION_TIPS_HEIGHT;
            self.frame = frame;
            [UIView commitAnimations];
        }
    }
    _isExpended = isExpended;
}

- (CGFloat)statusBarHeight {
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;

    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = appWindow.safeAreaInsets;
    }
    
    CGFloat statusBarHeight = (CGFloat)(safeAreaInsets.top != 0 ? safeAreaInsets.top : [UIApplication sharedApplication].statusBarFrame.size.height);
    return statusBarHeight;
}

- (void)showStatus {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self addSubview:self.statusLabel];
    [self addSubview:self.locationIcon];
    [self addSubview:self.moreIcon];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // iPad 位置共享提示横竖屏适配
    if (RTLIsIPad && [self.delegate getStatus] != RC_REAL_TIME_LOCATION_STATUS_IDLE) {
        CGRect statusFrame = self.statusLabel.frame;
        statusFrame = CGRectMake(30, 0, self.frame.size.width - 60, 40);
        self.statusLabel.frame = statusFrame;

        CGRect locationFrame = self.locationIcon.frame;
        locationFrame = CGRectMake(10, 13, 10, 14);
        self.locationIcon.frame = locationFrame;

        CGRect moreIconFrame = self.moreIcon.frame;
        moreIconFrame = CGRectMake(self.frame.size.width - 20, 13, 10, 14);
        self.moreIcon.frame = moreIconFrame;

        CGRect expendLabelFrame = self.expendLabel.frame;
        expendLabelFrame = CGRectMake(30, 0, self.frame.size.width - 48, 60);
        self.expendLabel.frame = expendLabelFrame;

        CGRect cancelFrame = self.cancelButton.frame;
        cancelFrame = CGRectMake(79, 52, 60, 25);
        self.cancelButton.frame = cancelFrame;

        CGRect joinFrame = self.joinButton.frame;
        joinFrame = CGRectMake(self.frame.size.width - 60 - 79, 52, 60, 25);
        self.joinButton.frame = joinFrame;
        [self setIsExpended:_isExpended];
    }
}

- (void)showExtendedView {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self addSubview:self.expendLabel];
    [self addSubview:self.cancelButton];
    [self addSubview:self.joinButton];
}

#pragma mark - getter

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, self.frame.size.width - 60, 40)];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.textColor = [RCKitUtility generateDynamicColor:UIColorFromRGB(0xffffff, 1) darkColor:UIColorFromRGB(0xffffff, 0.6)];
    }
    return _statusLabel;
}
- (UIImageView *)locationIcon {
    if (!_locationIcon) {
        if ([RTLUtilities isRTL]) {
            _locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 20, 13, 10, 14)];
        } else {
            _locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 13, 10, 14)];
        }
        [_locationIcon setImage:[UIImage imageNamed:@"white_location_icon"]];
    }
    return _locationIcon;
}
- (UIImageView *)moreIcon {
    if (!_moreIcon) {
        UIImage *image = [UIImage imageNamed:@"location_arrow"];
        if ([RTLUtilities isRTL]) {
            _moreIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 13, 10, 14)];
            image = [image imageFlippedForRightToLeftLayoutDirection];
        } else {
            _moreIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 20, 13, 10, 14)];
        }
        [_moreIcon setImage:image];
    }
    return _moreIcon;
}
- (UILabel *)expendLabel {
    if (!_expendLabel) {
        _expendLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.frame.size.width - 40, 60)];
        _expendLabel.textAlignment = NSTextAlignmentLeft;
        _expendLabel.textColor = [RCKitUtility generateDynamicColor:UIColorFromRGB(0xffffff, 1) darkColor:UIColorFromRGB(0xffffff, 0.6)];
        [_expendLabel setText:RTLLocalizedString(@"join_share_location_alert")];
        _expendLabel.font = [UIFont systemFontOfSize:14];
        _expendLabel.numberOfLines = 0;
    }
    return _expendLabel;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(79, 52, 60, 25)];
        [_cancelButton setTitle:RTLLocalizedString(@"cancel") forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [RCKitUtility generateDynamicColor:UIColorFromRGB(0x444444, 1) darkColor:UIColorFromRGB(0x52676F,1)];
        [_cancelButton addTarget:self action:@selector(onCanelPressed:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cancelButton;
}
- (UIButton *)joinButton {
    if (!_joinButton) {
        _joinButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 60 - 79, 52, 60, 25)];
        [_joinButton setTitle:RTLLocalizedString(@"join") forState:UIControlStateNormal];
        _joinButton.backgroundColor = [RCKitUtility generateDynamicColor:UIColorFromRGB(0x444444, 1) darkColor:UIColorFromRGB(0x9fb7bf,1)];
        [_joinButton addTarget:self action:@selector(onJoinPressed:) forControlEvents:UIControlEventTouchUpInside];
        _joinButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _joinButton;
}
@end
