//
//  RCDOpenClawIntroViewController.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/8.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawIntroViewController.h"
#import "RCDOpenClawCreateBotViewController.h"
#import "RCDUIBarButtonItem.h"

@interface RCDOpenClawIntroViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *stepTitleLabel;
@property (nonatomic, strong) UIView *stepsCardView;
@property (nonatomic, strong) UILabel *stepsLabel;
@property (nonatomic, strong) UIButton *startButton;

@end

@implementation RCDOpenClawIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"OpenClawIntroTitle");
    self.navigationItem.leftBarButtonItems =
        [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
    self.view.backgroundColor = RCDDYCOLOR(0xf3f6f9, 0x111111);
    [self buildContent];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buildContent {
    NSLayoutYAxisAnchor *topAnchor = self.topLayoutGuide.bottomAnchor;
    NSLayoutYAxisAnchor *bottomAnchor = self.bottomLayoutGuide.topAnchor;
    if (@available(iOS 11.0, *)) {
        topAnchor = self.view.safeAreaLayoutGuide.topAnchor;
        bottomAnchor = self.view.safeAreaLayoutGuide.bottomAnchor;
    }

    [self.view addSubview:self.startButton];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.stepTitleLabel];
    [self.contentView addSubview:self.stepsCardView];
    [self.stepsCardView addSubview:self.stepsLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.startButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.startButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.startButton.bottomAnchor constraintEqualToAnchor:bottomAnchor constant:-25],
        [self.startButton.heightAnchor constraintEqualToConstant:42],

        [self.scrollView.topAnchor constraintEqualToAnchor:topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.startButton.topAnchor constant:-16],
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],

        [self.avatarView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:68],
        [self.avatarView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.avatarView.widthAnchor constraintEqualToConstant:58],
        [self.avatarView.heightAnchor constraintEqualToConstant:58],

        [self.descLabel.topAnchor constraintEqualToAnchor:self.avatarView.bottomAnchor constant:51],
        [self.descLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.descLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],

        [self.stepTitleLabel.topAnchor constraintEqualToAnchor:self.descLabel.bottomAnchor constant:47],
        [self.stepTitleLabel.leadingAnchor constraintEqualToAnchor:self.descLabel.leadingAnchor],
        [self.stepTitleLabel.trailingAnchor constraintEqualToAnchor:self.descLabel.trailingAnchor],

        [self.stepsCardView.topAnchor constraintEqualToAnchor:self.stepTitleLabel.bottomAnchor constant:16],
        [self.stepsCardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.stepsCardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.stepsCardView.heightAnchor constraintGreaterThanOrEqualToConstant:158],
        [self.stepsCardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-24],

        [self.stepsLabel.topAnchor constraintEqualToAnchor:self.stepsCardView.topAnchor constant:22],
        [self.stepsLabel.leadingAnchor constraintEqualToAnchor:self.stepsCardView.leadingAnchor constant:22],
        [self.stepsLabel.trailingAnchor constraintEqualToAnchor:self.stepsCardView.trailingAnchor constant:-22],
        [self.stepsLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.stepsCardView.bottomAnchor constant:-22]
    ]];
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarView.layer.cornerRadius = 29;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.image = [UIImage imageNamed:@"openclaw_assistant_logo"];
    }
    return _avatarView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [self labelWithFont:[UIFont systemFontOfSize:15] color:RCDDYCOLOR(0x020814, 0xffffff)];
        _descLabel.numberOfLines = 0;
        _descLabel.attributedText =
            [self attributedText:RCDLocalizedString(@"OpenClawIntroDescription")
                            font:[UIFont systemFontOfSize:15]
                           color:RCDDYCOLOR(0x020814, 0xffffff)
                     lineSpacing:8];
    }
    return _descLabel;
}

- (UILabel *)stepTitleLabel {
    if (!_stepTitleLabel) {
        _stepTitleLabel = [self labelWithFont:[UIFont systemFontOfSize:15] color:RCDDYCOLOR(0x020814, 0xffffff)];
        _stepTitleLabel.text = RCDLocalizedString(@"OpenClawIntroStepsTitle");
    }
    return _stepTitleLabel;
}

- (UIView *)stepsCardView {
    if (!_stepsCardView) {
        _stepsCardView = [[UIView alloc] init];
        _stepsCardView.translatesAutoresizingMaskIntoConstraints = NO;
        _stepsCardView.backgroundColor = RCDDYCOLOR(0xffffff, 0x1c1c1e);
        _stepsCardView.layer.cornerRadius = 10;
        _stepsCardView.layer.masksToBounds = YES;
    }
    return _stepsCardView;
}

- (UILabel *)stepsLabel {
    if (!_stepsLabel) {
        _stepsLabel = [self labelWithFont:[UIFont systemFontOfSize:15] color:RCDDYCOLOR(0x020814, 0xffffff)];
        _stepsLabel.numberOfLines = 0;
        _stepsLabel.attributedText =
            [self attributedText:RCDLocalizedString(@"OpenClawIntroSteps")
                            font:[UIFont systemFontOfSize:15]
                           color:RCDDYCOLOR(0x020814, 0xffffff)
                     lineSpacing:20];
    }
    return _stepsLabel;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [self blueButtonWithTitle:RCDLocalizedString(@"OpenClawIntroStart")];
        [_startButton addTarget:self action:@selector(startCreate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (NSAttributedString *)attributedText:(NSString *)text
                                  font:(UIFont *)font
                                 color:(UIColor *)color
                           lineSpacing:(CGFloat)lineSpacing {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:@{
                                               NSFontAttributeName : font,
                                               NSForegroundColorAttributeName : color,
                                               NSParagraphStyleAttributeName : paragraphStyle
                                           }];
}

- (UILabel *)labelWithFont:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = font;
    label.textColor = color;
    return label;
}

- (UIButton *)blueButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = HEXCOLOR(0x0047ff);
    button.layer.cornerRadius = 6;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    return button;
}

- (void)startCreate {
    RCDOpenClawCreateBotViewController *vc = [[RCDOpenClawCreateBotViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
