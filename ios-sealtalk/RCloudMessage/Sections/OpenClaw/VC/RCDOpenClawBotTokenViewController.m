//
//  RCDOpenClawBotTokenViewController.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawBotTokenViewController.h"
#import "RCDOpenClawBot.h"
#import "RCDOpenClawBotTokenViewModel.h"
#import "RCUChatViewController.h"
#import "RCDUIBarButtonItem.h"
#import "UIView+MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RCDOpenClawBotTokenViewController ()

@property (nonatomic, strong) RCDOpenClawBotTokenViewModel *viewModel;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *tokenContainer;
@property (nonatomic, strong) UILabel *tokenTitleLabel;
@property (nonatomic, strong) UILabel *tokenLabel;
@property (nonatomic, strong) UIButton *copyButton;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIButton *chatButton;

@end

@implementation RCDOpenClawBotTokenViewController

- (instancetype)initWithBot:(RCDOpenClawBot *)bot created:(BOOL)created {
    self = [super init];
    if (self) {
        _viewModel = [[RCDOpenClawBotTokenViewModel alloc] initWithBot:bot created:created];
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self.viewModel pageTitle];
    self.navigationItem.leftBarButtonItems =
        [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
    self.view.backgroundColor = RCDDYCOLOR(0xf3f6f9, 0x111111);
    [self buildContent];
    [self loadBotDetailIfNeeded];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buildContent {
    NSLayoutYAxisAnchor *topAnchor = self.topLayoutGuide.bottomAnchor;
    if (@available(iOS 11.0, *)) {
        topAnchor = self.view.safeAreaLayoutGuide.topAnchor;
    }

    [self.view addSubview:self.avatarView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.tokenContainer];
    [self.tokenContainer addSubview:self.tokenTitleLabel];
    [self.tokenContainer addSubview:self.tokenLabel];
    [self.tokenContainer addSubview:self.copyButton];
    [self.view addSubview:self.hintLabel];
    [self.view addSubview:self.refreshButton];
    [self.view addSubview:self.chatButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.avatarView.topAnchor constraintEqualToAnchor:topAnchor constant:16],
        [self.avatarView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.avatarView.widthAnchor constraintEqualToConstant:60],
        [self.avatarView.heightAnchor constraintEqualToConstant:60],

        [self.nameLabel.centerYAnchor constraintEqualToAnchor:self.avatarView.centerYAnchor],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:20],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.nameLabel.heightAnchor constraintEqualToConstant:31],

        [self.tokenContainer.topAnchor constraintEqualToAnchor:self.avatarView.bottomAnchor constant:40],
        [self.tokenContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.tokenContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.tokenContainer.heightAnchor constraintEqualToConstant:54],

        [self.tokenTitleLabel.leadingAnchor constraintEqualToAnchor:self.tokenContainer.leadingAnchor constant:17],
        [self.tokenTitleLabel.centerYAnchor constraintEqualToAnchor:self.tokenContainer.centerYAnchor],
        [self.tokenTitleLabel.widthAnchor constraintEqualToConstant:54],

        [self.copyButton.trailingAnchor constraintEqualToAnchor:self.tokenContainer.trailingAnchor constant:-8],
        [self.copyButton.centerYAnchor constraintEqualToAnchor:self.tokenContainer.centerYAnchor],
        [self.copyButton.widthAnchor constraintEqualToConstant:28],
        [self.copyButton.heightAnchor constraintEqualToConstant:28],

        [self.tokenLabel.leadingAnchor constraintEqualToAnchor:self.tokenTitleLabel.trailingAnchor],
        [self.tokenLabel.trailingAnchor constraintEqualToAnchor:self.copyButton.leadingAnchor constant:-6],
        [self.tokenLabel.centerYAnchor constraintEqualToAnchor:self.tokenContainer.centerYAnchor],

        [self.hintLabel.topAnchor constraintEqualToAnchor:self.tokenContainer.bottomAnchor constant:14],
        [self.hintLabel.leadingAnchor constraintEqualToAnchor:self.tokenContainer.leadingAnchor],
        [self.hintLabel.trailingAnchor constraintEqualToAnchor:self.tokenContainer.trailingAnchor],

        [self.refreshButton.topAnchor constraintEqualToAnchor:self.hintLabel.bottomAnchor constant:45],
        [self.refreshButton.leadingAnchor constraintEqualToAnchor:self.tokenContainer.leadingAnchor],
        [self.refreshButton.trailingAnchor constraintEqualToAnchor:self.tokenContainer.trailingAnchor],
        [self.refreshButton.heightAnchor constraintEqualToConstant:40],

        [self.chatButton.topAnchor constraintEqualToAnchor:self.refreshButton.bottomAnchor constant:10],
        [self.chatButton.leadingAnchor constraintEqualToAnchor:self.refreshButton.leadingAnchor],
        [self.chatButton.trailingAnchor constraintEqualToAnchor:self.refreshButton.trailingAnchor],
        [self.chatButton.heightAnchor constraintEqualToConstant:40]
    ]];
}

- (void)loadBotDetailIfNeeded {
    if (![self.viewModel needsLoadDetail]) {
        return;
    }
    [self.view showLoading];
    [self.viewModel loadBotDetailWithSuccess:^{
        [self.view hideLoading];
        [self refreshContent];
    } error:^(NSError *error) {
        [self.view hideLoading];
        [self.view showHUDMessage:error.localizedDescription ?: RCDLocalizedString(@"OpenClawLoadFailed")];
    }];
}

- (void)refreshContent {
    self.title = [self.viewModel pageTitle];
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:[self.viewModel portraitUri]]
                       placeholderImage:[UIImage imageNamed:@"openclaw_assistant_logo"]];
    self.nameLabel.text = [self.viewModel displayName];
    self.tokenLabel.text = [self.viewModel tokenText];
    [self.refreshButton setTitle:[self.viewModel refreshButtonTitle] forState:UIControlStateNormal];
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.layer.cornerRadius = 30;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.backgroundColor = [UIColor clearColor];
        [_avatarView sd_setImageWithURL:[NSURL URLWithString:[self.viewModel portraitUri]]
                       placeholderImage:[UIImage imageNamed:@"openclaw_assistant_logo"]];
    }
    return _avatarView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.text = [self.viewModel displayName];
        _nameLabel.font = [UIFont systemFontOfSize:20];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = RCDDYCOLOR(0x020814, 0xffffff);
    }
    return _nameLabel;
}

- (UIView *)tokenContainer {
    if (!_tokenContainer) {
        _tokenContainer = [[UIView alloc] init];
        _tokenContainer.translatesAutoresizingMaskIntoConstraints = NO;
        _tokenContainer.backgroundColor = [UIColor whiteColor];
        _tokenContainer.layer.cornerRadius = 2;
    }
    return _tokenContainer;
}

- (UILabel *)tokenTitleLabel {
    if (!_tokenTitleLabel) {
        _tokenTitleLabel = [[UILabel alloc] init];
        _tokenTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tokenTitleLabel.text = RCDLocalizedString(@"OpenClawTokenTitle");
        _tokenTitleLabel.font = [UIFont systemFontOfSize:17];
        _tokenTitleLabel.textColor = RCDDYCOLOR(0x020814, 0xffffff);
    }
    return _tokenTitleLabel;
}

- (UILabel *)tokenLabel {
    if (!_tokenLabel) {
        _tokenLabel = [[UILabel alloc] init];
        _tokenLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tokenLabel.numberOfLines = 1;
        _tokenLabel.font = [UIFont systemFontOfSize:17];
        _tokenLabel.textColor = RCDDYCOLOR(0x020814, 0xffffff);
        _tokenLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _tokenLabel.text = [self.viewModel tokenText];
    }
    return _tokenLabel;
}

- (UIButton *)copyButton {
    if (!_copyButton) {
        _copyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _copyButton.translatesAutoresizingMaskIntoConstraints = NO;
        UIImage *copyIcon = [[UIImage imageNamed:@"openclaw_copy_token_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_copyButton setImage:copyIcon forState:UIControlStateNormal];
        _copyButton.tintColor = HEXCOLOR(0x0047ff);
        [_copyButton addTarget:self action:@selector(copyToken) forControlEvents:UIControlEventTouchUpInside];
    }
    return _copyButton;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _hintLabel.numberOfLines = 0;
        _hintLabel.font = [UIFont systemFontOfSize:12];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.textColor = RCDDYCOLOR(0x8f96a3, 0x999999);
        _hintLabel.text = RCDLocalizedString(@"OpenClawTokenHint");
    }
    return _hintLabel;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [self blueButtonWithTitle:[self.viewModel refreshButtonTitle]];
        [_refreshButton addTarget:self action:@selector(refreshToken) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

- (UIButton *)chatButton {
    if (!_chatButton) {
        _chatButton = [self whiteButtonWithTitle:RCDLocalizedString(@"OpenClawStartConversation")];
        [_chatButton addTarget:self action:@selector(startChat) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chatButton;
}

- (UIButton *)blueButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = HEXCOLOR(0x0047ff);
    button.layer.cornerRadius = 6;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    return button;
}

- (UIButton *)whiteButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 6;
    UIImage *chatIcon = [[UIImage imageNamed:@"new_conversation"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:chatIcon forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.tintColor = HEXCOLOR(0x0047ff);
    [button setTitleColor:HEXCOLOR(0x0047ff) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 4);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
    return button;
}

- (void)copyToken {
    if (![self.viewModel hasToken]) {
        [self.view showHUDMessage:RCDLocalizedString(@"OpenClawTokenEmptyReset")];
        return;
    }
    [UIPasteboard generalPasteboard].string = self.viewModel.bot.token;
    [self.view showHUDMessage:RCDLocalizedString(@"OpenClawCopySuccess")];
}

- (void)refreshToken {
    [self.view showLoading];
    [self.viewModel refreshTokenWithSuccess:^{
        [self.view hideLoading];
        [self refreshContent];
        [self.view showHUDMessage:RCDLocalizedString(@"OpenClawRefreshTokenSuccess")];
    } error:^(NSError *error) {
        [self.view hideLoading];
        [self.view showHUDMessage:error.localizedDescription ?: RCDLocalizedString(@"OpenClawRefreshTokenFailed")];
    }];
}

- (void)startChat {
    [self.viewModel cacheCurrentBot];
    RCDChatViewController *existingChatVC = [self existingChatViewControllerForBotId:self.viewModel.bot.botId];
    if (existingChatVC) {
        [self.navigationController popToViewController:existingChatVC animated:YES];
        return;
    }

    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = self.viewModel.bot.botId;
    chatVC.title = self.viewModel.bot.name;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (RCDChatViewController *)existingChatViewControllerForBotId:(NSString *)botId {
    if (botId.length == 0) {
        return nil;
    }
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if (![viewController isKindOfClass:[RCDChatViewController class]]) {
            continue;
        }
        RCDChatViewController *chatVC = (RCDChatViewController *)viewController;
        if (chatVC.conversationType == ConversationType_PRIVATE && [chatVC.targetId isEqualToString:botId]) {
            return chatVC;
        }
    }
    return nil;
}

@end
