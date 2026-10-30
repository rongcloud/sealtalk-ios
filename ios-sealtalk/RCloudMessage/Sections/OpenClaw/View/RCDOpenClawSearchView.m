//
//  RCDOpenClawSearchView.m
//  SealTalk
//
//  Created by RongCloud on 2026/5/9.
//  Copyright © 2026 RongCloud. All rights reserved.
//

#import "RCDOpenClawSearchView.h"
#import "RCDUtilities.h"

static CGFloat const RCDOpenClawSearchViewHeight = 40.f;
static CGFloat const RCDOpenClawSearchContentLeading = 16.f;
static CGFloat const RCDOpenClawSearchIconWidth = 20.f;
static CGFloat const RCDOpenClawSearchIconTextSpacing = 6.f;
static CGFloat const RCDOpenClawSearchContentTrailing = 16.f;

@interface RCDOpenClawSearchView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *searchTextField;

@end

@implementation RCDOpenClawSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = RCDDYCOLOR(0xFFFFFF, 0x000000);
    self.layer.cornerRadius = RCDOpenClawSearchViewHeight / 2;
    self.layer.masksToBounds = YES;

    [self addSubview:self.searchTextField];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.searchTextField.frame = self.bounds;
}

- (void)resignSearchFirstResponder {
    [self.searchTextField resignFirstResponder];
}

- (void)searchTextFieldDidChange:(UITextField *)textField {
    if (self.textChangedBlock) {
        self.textChangedBlock(textField.text ?: @"");
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (UITextField *)searchTextField {
    if (!_searchTextField) {
        _searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _searchTextField.delegate = self;
        _searchTextField.backgroundColor = [UIColor clearColor];
        _searchTextField.borderStyle = UITextBorderStyleNone;
        _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchTextField.leftView = [self searchIconLeftView];
        _searchTextField.leftViewMode = UITextFieldViewModeAlways;
        _searchTextField.returnKeyType = UIReturnKeySearch;
        _searchTextField.font = [UIFont systemFontOfSize:17.f];
        _searchTextField.textColor = RCDDYCOLOR(0x020814, 0xFFFFFF);
        _searchTextField.textAlignment = NSTextAlignmentLeft;
        _searchTextField.attributedPlaceholder =
            [[NSAttributedString alloc] initWithString:RCDLocalizedString(@"OpenClawSearch")
                                            attributes:@{NSForegroundColorAttributeName: RCDDYCOLOR(0x8D95A1, 0x8D95A1)}];
        [_searchTextField addTarget:self
                             action:@selector(searchTextFieldDidChange:)
                   forControlEvents:UIControlEventEditingChanged];
    }
    return _searchTextField;
}

- (UIView *)searchIconLeftView {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     RCDOpenClawSearchContentLeading + RCDOpenClawSearchIconWidth + RCDOpenClawSearchIconTextSpacing,
                                                                     RCDOpenClawSearchViewHeight)];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(RCDOpenClawSearchContentLeading,
                                                                          (RCDOpenClawSearchViewHeight - RCDOpenClawSearchIconWidth) / 2,
                                                                          RCDOpenClawSearchIconWidth,
                                                                          RCDOpenClawSearchIconWidth)];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.tintColor = RCDDYCOLOR(0x0057FF, 0x0057FF);
    if (@available(iOS 13.0, *)) {
        iconView.image = [UIImage systemImageNamed:@"magnifyingglass"];
    }
    [containerView addSubview:iconView];
    return containerView;
}

@end
