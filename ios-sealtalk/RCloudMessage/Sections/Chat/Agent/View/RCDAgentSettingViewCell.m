//
//  RCDAgentSettingViewCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentSettingViewCell.h"
#import "RCDAgentSettingCellViewModel.h"
#import "RCDAgentSettingSwitchCellViewModel.h"


NSString  * const RCDAgentSettingViewCellIdentifier = @"RCDAgentSettingViewCellIdentifier";
@interface RCDAgentSettingViewCell()
@property (nonatomic, strong) RCDAgentSettingSwitchCellViewModel *viewModel;
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labSubtitle;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) RCDAgentSettingViewCellType type;
@property (nonatomic, strong) UIImageView *switchBGView;
@end
@implementation RCDAgentSettingViewCell

- (void)setupView {
    [super setupView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.labTitle];
    [self.containerView addSubview:self.labSubtitle];
    [self.containerView addSubview:self.switchBGView];
    [self.containerView addSubview:self.switchView];
    
    UIView *line = [UIView new];
    line.backgroundColor = HEXCOLOR(0xE4E7ED);
    self.lineView = line;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.containerView.frame = CGRectMake(12, 0, self.bounds.size.width-12*2, self.bounds.size.height);
    
    self.labTitle.frame = CGRectMake(12,12, self.labTitle.frame.size.width, self.labTitle.frame.size.height);
    
    self.labSubtitle.frame = CGRectMake(12, self.containerView.center.y, self.labSubtitle.frame.size.width, self.labSubtitle.frame.size.height);
    
    self.switchView.center = CGPointMake(self.containerView.bounds.size.width-12-self.switchView.frame.size.width/2, self.bounds.size.height/2);
    
    if (self.lineView.superview) {
        self.lineView.frame = CGRectMake(12, self.containerView.bounds.size.height-1, self.containerView.bounds.size.width-24, 1);
    }
    self.switchBGView.center = self.switchView.center;
    [self refreshCorner];
}

- (void)refreshCorner {
    // 设置部分圆角
    CGFloat cornerRadius = 10;
    if (self.type == RCDAgentSettingViewCellTypeMiddle) {
        self.containerView.layer.mask = nil;
    } else {
        UIRectCorner rectCorner = UIRectCornerTopLeft | UIRectCornerTopRight; // 左上角和右上角
        if (self.type == RCDAgentSettingViewCellTypeBottom) {
            rectCorner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
        }
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.path = maskPath.CGPath;
        self.containerView.layer.mask = maskLayer;
    }

}

- (void)updateCellWithViewModel:(RCDAgentSettingSwitchCellViewModel *)viewModel
                           type:(RCDAgentSettingViewCellType)type {
    self.type = type;
    self.viewModel = viewModel;
    self.labTitle.text = viewModel.title;
    [self.labTitle sizeToFit];
    self.labSubtitle.text = viewModel.subtitle;
    [self.labSubtitle sizeToFit];
    self.switchView.on = viewModel.enable;
    self.switchBGView.hidden = !viewModel.enable;
}

- (void)switchViewChanged:(UISwitch *)switchView {
    [self.viewModel switchValueChanged:switchView.isOn];
    self.switchBGView.hidden = !switchView.isOn;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = RCDYCOLOR(0xffffff, 0x191919);
    }
    return _containerView;
}
- (void)setType:(RCDAgentSettingViewCellType)type {
    _type = type;
    
    if (type != RCDAgentSettingViewCellTypeBottom) {
        if (!self.lineView.superview) {
            [self.containerView addSubview:self.lineView];
        }
    }
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        [_switchView setOnTintColor:[UIColor clearColor]];
        [_switchView addTarget:self
                        action:@selector(switchViewChanged:)
              forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (UIImageView *)switchBGView {
    if (!_switchBGView) {
        _switchBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 30)];
        UIImage *img = [UIImage imageNamed:@"agent_tag_bg"];
        _switchBGView.image = img;
        _switchBGView.layer.cornerRadius = 14;
        _switchBGView.layer.masksToBounds = YES;
    }
    return _switchBGView;
}

- (UILabel *)labTitle {
    if (!_labTitle) {
        UILabel *lab = [UILabel new];
        lab.font = [UIFont systemFontOfSize:16];
        lab.textColor = RCDYCOLOR(0x020814, 0xFFFFFF);
        _labTitle = lab;
    }
    return _labTitle;
}


- (UILabel *)labSubtitle {
    if (!_labSubtitle) {
        UILabel *lab = [UILabel new];
        lab.font = [UIFont systemFontOfSize:12];
        lab.textColor = RCDYCOLOR(0x41464F, 0xA7A8AA);
        _labSubtitle = lab;
    }
    return _labSubtitle;
}
@end
