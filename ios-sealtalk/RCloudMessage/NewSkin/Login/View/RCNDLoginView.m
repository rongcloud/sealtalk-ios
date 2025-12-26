//
//  RCNDLoginView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDLoginView.h"

@implementation RCNDLoginView

- (void)setupView {
    [super setupView];
    self.backgroundColor = RCDynamicColor(@"auxiliary_background_1_color", @"0xf5f6f9", @"0x111111");
    [self addSubview:self.contentStackView];
    [self.contentStackView addArrangedSubview:[self languageView]];
    [self.contentStackView addArrangedSubview:[self dataCenterView]];
    [self.contentStackView addArrangedSubview:[self countryAreaView]];
    [self.contentStackView addArrangedSubview:[self phoneNumberView]];
    [self.contentStackView addArrangedSubview:[self photoVerifyCodeView]];
    [self.contentStackView addArrangedSubview:[self verifyCodeView]];
    [self.contentStackView addArrangedSubview:[self loginButtonView]];
    [self.contentStackView addArrangedSubview:[self privacyView]];
    UIView *placeholder = [self createContainerView];
    placeholder.backgroundColor = [UIColor clearColor];
    [self.contentStackView addArrangedSubview:placeholder];
    [NSLayoutConstraint activateConstraints:@[
          [placeholder.heightAnchor constraintGreaterThanOrEqualToConstant:40]
      ]];
}

- (void)setupConstraints {
    [super setupConstraints];
    [NSLayoutConstraint activateConstraints:@[
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.contentStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:52],
        [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
}

- (UIView *)languageView {
    UIButton *btn = [self createButton];
    [btn setTitle:@"EN" forState:UIControlStateNormal];
    [btn setTitleColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x007acc")
              forState:UIControlStateNormal];
    
    UIView *placeHolder = [UIView new];
    placeHolder.translatesAutoresizingMaskIntoConstraints = NO;
    UIStackView *stackView = [self createHorizontalStackView];
    [stackView addArrangedSubview:placeHolder];
    [stackView addArrangedSubview:btn];
    [NSLayoutConstraint activateConstraints:@[
        [placeHolder.heightAnchor constraintEqualToConstant:40],
    ]];
    self.buttonLanguage = btn;
    return stackView;
}

- (UIView *)dataCenterView {
    UIStackView *stackView = [self sectionViewWithTitle:RCDLocalizedString(@"DataCenter")];
    self.labelDataCenter = [self createLabelWith:@"北京"];
    self.labelDataCenter.userInteractionEnabled = YES;
    self.labelDataCenter.font = [UIFont systemFontOfSize:14];
    UIView *bottom = [self arrowContainerView:self.labelDataCenter];
    [stackView addArrangedSubview:bottom];
    return stackView;
}

- (UIView *)countryAreaView {
    UIStackView *stackView = [self sectionViewWithTitle:RCDLocalizedString(@"country")];
    self.labelArea =  [self createLabelWith:@"中国"];
    self.labelArea.font = [UIFont systemFontOfSize:14];
    self.labelArea.userInteractionEnabled = YES;
   
    UIView *bottom = [self arrowContainerView:self.labelArea];
    [stackView addArrangedSubview:bottom];
    return stackView;
}

- (UIView *)phoneNumberView {
    UIStackView *stackView = [self sectionViewWithTitle:RCDLocalizedString(@"LoginPhoneNum")];
    self.txtPhoneNum = [self createTextFiled];
    self.txtPhoneNum.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.txtPhoneNum.keyboardType = UIKeyboardTypeNumberPad;
    self.labelCountryCode = [self createLabelWith:@"+86"];
    self.labelCountryCode.textColor = RCDynamicColor(@"text_primary_color", @"0x020814", @"0xFFFFFF");
    UIStackView *bottom = [self createHorizontalStackView];
    [bottom addArrangedSubview:[self containerViewWith:self.labelCountryCode]];
    [bottom addArrangedSubview:[self containerViewWith:self.txtPhoneNum]];
    
    [stackView addArrangedSubview:bottom];
    [NSLayoutConstraint activateConstraints:@[
        [self.labelCountryCode.heightAnchor constraintEqualToConstant:42],
        [self.labelCountryCode.widthAnchor constraintEqualToConstant:74]
    ]];
    return stackView;
}

- (UIView *)photoVerifyCodeView {
    UIStackView *stackView = [self sectionViewWithTitle:RCDLocalizedString(@"picture_verification_code")];
    self.txtPhotoVerifyCode = [self createTextFiled];
    UIStackView *bottom = [self createHorizontalStackView];
    [bottom addArrangedSubview:[self containerViewWith:self.txtPhotoVerifyCode]];
    self.buttonPhotoVerify = [self createButton];
    [ self.buttonPhotoVerify setTitle:RCDLocalizedString(@"refresh") forState:UIControlStateNormal];
    UIView *view = [self createContainerView];
    [view addSubview:self.buttonPhotoVerify];
    [NSLayoutConstraint activateConstraints:@[
        [self.buttonPhotoVerify.topAnchor constraintEqualToAnchor:view.topAnchor constant:5],
        [self.buttonPhotoVerify.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-4],
        [self.buttonPhotoVerify.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:6],
        [self.buttonPhotoVerify.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-6],
        [self.buttonPhotoVerify.heightAnchor constraintEqualToConstant:33],
        [self.buttonPhotoVerify.widthAnchor constraintEqualToConstant:88]
    ]];
    [bottom addArrangedSubview:view];
    
    [stackView addArrangedSubview:bottom];
    return stackView;
}


- (UIView *)verifyCodeView {
    UIStackView *stackView = [self sectionViewWithTitle:RCDLocalizedString(@"verification_code")];
    self.txtVerifyCode = [self createTextFiled];
    self.txtVerifyCode.keyboardType = UIKeyboardTypeNumberPad;
    UIButton *buttonVerify = [self createButton];
    [buttonVerify setTitle:RCDLocalizedString(@"send_verification_code") forState:UIControlStateNormal];
    [buttonVerify setTitleColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x1AA3FF")
                       forState:UIControlStateNormal];
    [buttonVerify setTitleColor:RCDynamicColor(@"text_secondary_color", @"0x7C838E", @"0x7C838E")
                       forState:UIControlStateDisabled];
    buttonVerify.titleLabel.font = [UIFont systemFontOfSize:14];
    buttonVerify.contentEdgeInsets = UIEdgeInsetsMake(2, 10, 2, 10);
    self.buttonVerify = buttonVerify;
    UIStackView *bottom = [self createHorizontalStackView];
    [bottom addArrangedSubview:[self containerViewWith:self.txtVerifyCode]];
    [bottom addArrangedSubview:buttonVerify];
    
    UIView *containerView = [self createContainerView];
    [containerView addSubview:bottom];
    
    [NSLayoutConstraint activateConstraints:@[
          [bottom.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor],
          [bottom.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor],
          [bottom.topAnchor constraintEqualToAnchor:containerView.topAnchor],
          [bottom.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],
      ]];

    [stackView addArrangedSubview:containerView];
    return stackView;
}


- (UIView *)loginButtonView {
    UIView *view = [self createContainerView];
    view.backgroundColor = [UIColor clearColor];
    self.buttonLogin = [self createButton];
    self.buttonLogin.layer.cornerRadius = 6;
    self.buttonLogin.layer.masksToBounds = YES;
    [self.buttonLogin setTitle:RCDLocalizedString(@"Login") forState:UIControlStateNormal];
    [self.buttonLogin setBackgroundColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x1AA3FF")];
    [self.buttonLogin setTitleColor:RCDynamicColor(@"control_title_white_color", @"0xffffff", @"0xffffff")
                           forState:UIControlStateNormal];
    [view addSubview:self.buttonLogin];
    [NSLayoutConstraint activateConstraints:@[
          [self.buttonLogin.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
          [self.buttonLogin.trailingAnchor constraintEqualToAnchor:view.trailingAnchor ],
          [self.buttonLogin.topAnchor constraintGreaterThanOrEqualToAnchor:view.topAnchor constant:20],
          [self.buttonLogin.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
          [self.buttonLogin.heightAnchor constraintEqualToConstant:42],
          [view.heightAnchor constraintLessThanOrEqualToConstant:66],
      ]];
    return view;
}

- (UIView *)privacyView {
    UIView *view = [self createContainerView];
    view.backgroundColor = [UIColor clearColor];
    self.textViewPrivacy = [self footerView];
    [view addSubview:self.textViewPrivacy];
    [NSLayoutConstraint activateConstraints:@[
          [self.textViewPrivacy.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
          [self.textViewPrivacy.trailingAnchor constraintEqualToAnchor:view.trailingAnchor ],
          [self.textViewPrivacy.topAnchor constraintGreaterThanOrEqualToAnchor:view.topAnchor constant:10],
          [self.textViewPrivacy.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:30],
          [self.textViewPrivacy.heightAnchor constraintEqualToConstant:64]
      ]];
    return view;
}
- (UITextView *)footerView {
    NSString *registrationTerms = [NSString stringWithFormat:RCDLocalizedString(@"Registration_Terms_Format"), RCDLocalizedString(@"Registration_Terms")];
    NSString *privacyPolicy = [NSString stringWithFormat:RCDLocalizedString(@"Privacy_Policy_Format"), RCDLocalizedString(@"Privacy_Policy")];
    NSString *content = [NSString stringWithFormat:RCDLocalizedString(@"Registration_Bottom_Text"), registrationTerms,  privacyPolicy, [RCCoreClient getVersion]];
    UITextView *contentTextView = [[UITextView alloc] init];
    contentTextView.backgroundColor = [UIColor clearColor];
    contentTextView.attributedText = [self getContentLabelAttributedText:content];
    contentTextView.textAlignment = NSTextAlignmentCenter;
    contentTextView.delegate = self;
    contentTextView.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    contentTextView.translatesAutoresizingMaskIntoConstraints = NO;
    contentTextView.scrollEnabled = NO;
    return contentTextView;
}

- (NSAttributedString *)getContentLabelAttributedText:(NSString *)text {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11],NSForegroundColorAttributeName:HEXCOLOR(0x585858)}];
    NSRange range = NSMakeRange(0, text.length);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5; // 调整行间距
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    
    NSString *registrationTerms = [NSString stringWithFormat:RCDLocalizedString(@"Registration_Terms_Format"), RCDLocalizedString(@"Registration_Terms")];
    NSString *privacyPolicy = [NSString stringWithFormat:RCDLocalizedString(@"Privacy_Policy_Format"), RCDLocalizedString(@"Privacy_Policy")];
    NSRange rangeLink = [attrStr.string rangeOfString:registrationTerms];
    [attrStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x0099ff) range:rangeLink];
    [attrStr addAttribute:NSLinkAttributeName value:@"registrationterms://" range:rangeLink];
    
    rangeLink = [attrStr.string rangeOfString:privacyPolicy];
    [attrStr addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x0099ff) range:rangeLink];
    [attrStr addAttribute:NSLinkAttributeName value:@"privacypolicy://" range:rangeLink];
    
    return attrStr;
}
- (UIView *)containerViewWith:(UIView *)subview {
    UIView *view = [self createContainerView];
    [view addSubview:subview];
    [NSLayoutConstraint activateConstraints:@[
        [subview.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:16],
        [subview.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-16],
        [subview.topAnchor constraintEqualToAnchor:view.topAnchor],
        [subview.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
        [view.heightAnchor constraintEqualToConstant:42]
    ]];
    return view;
}

/// 创建分区stack
/// - Parameter title: 标题
- (UIStackView *)sectionViewWithTitle:(NSString *)title {
    UIStackView *verticalStack = [self createVerticalStackView];
    UILabel *lab = [self createLabelWith:title];
    [verticalStack addArrangedSubview:lab];
    return verticalStack;
}

- (UIView *)arrowContainerView:(UILabel *)lab {
    UIView *view = [self createContainerView];
    UIStackView *stackView = [self createHorizontalStackView];
    [view addSubview:stackView];
    [stackView addArrangedSubview:lab];
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow"]];
    [arrow setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [stackView addArrangedSubview:arrow];
    [NSLayoutConstraint activateConstraints:@[
           [stackView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:10],
           [stackView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-10],
           [stackView.topAnchor constraintEqualToAnchor:view.topAnchor],
           [stackView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
           [arrow.widthAnchor constraintEqualToConstant:16],
           [arrow.heightAnchor constraintEqualToConstant:16],
           [view.heightAnchor constraintEqualToConstant:42],
           [lab.heightAnchor constraintEqualToConstant:42]
       ]];
    return view;
}

- (UIView *)createContainerView {
    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = RCDynamicColor(@"common_background_color", @"0xffffff", @"0x1a1a1a");
    return view;
}

- (UIStackView *)createVerticalStackView {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 10;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    return stackView;
}

- (UIStackView *)createHorizontalStackView {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.spacing = 6;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    return stackView;
}

- (UILabel *)createLabelWith:(NSString *)title {
    UILabel *lab = [UILabel new];
    lab.translatesAutoresizingMaskIntoConstraints = NO;
    lab.text = title;
    lab.textColor = RCDynamicColor(@"text_primary_color", @"0x020814", @"0xFFFFFF");
    [lab setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    return lab;
}

- (UITextField *)createTextFiled {
    UITextField *txt = [UITextField new];
    txt.translatesAutoresizingMaskIntoConstraints = NO;
    txt.backgroundColor = [UIColor clearColor];
    return txt;
}

- (UIButton *)createButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    return btn;
}

- (UIStackView *)contentStackView {
    if (!_contentStackView) {
        _contentStackView = [[UIStackView alloc] init];
        _contentStackView.axis = UILayoutConstraintAxisVertical;
        _contentStackView.alignment = UIStackViewAlignmentFill;
        _contentStackView.distribution = UIStackViewDistributionFill;
        _contentStackView.spacing = 20;
        _contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentStackView;
}



@end
