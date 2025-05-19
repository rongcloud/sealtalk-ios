//
//  RCDAgentTagCollectionViewCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentTagCollectionViewCell.h"


NSString  * const RCDAgentTagCollectionViewCellIdentifier = @"RCDAgentTagCollectionViewCellIdentifier";

@interface RCDAgentTagCollectionViewCell()
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) RCDAgentTagCollectionCellViewModel *viewModel;
@end

@implementation RCDAgentTagCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundView = [UIView new];
    self.backgroundView.backgroundColor =  RCDYCOLOR(0xffffff, 0x191919);
    self.backgroundView.layer.cornerRadius = 21;
    self.backgroundView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.backgroundView];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.labTitle];
    [self configureGradientLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.labTitle.center = self.imageView.center;
    self.backgroundView.frame = self.imageView.frame;
}

- (void)configureGradientLayer {
    // 创建渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.imageView.bounds;
    
    gradientLayer.colors = @[(id)RCMASKCOLOR(0x7F6AFE,1).CGColor, (id)RCMASKCOLOR(0x6FDEE5,1).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    
    // 创建形状层来模拟边框
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.lineWidth = 1;
    CGFloat cornerRadius = 20; // 设置圆角半径
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.imageView.bounds, 1,1) cornerRadius:cornerRadius].CGPath;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor blackColor].CGColor;
    
    // 将形状层作为渐变层的遮罩
    gradientLayer.mask = borderLayer;
    
    // 将渐变层添加到 UIView 的 layer 上
    [self.imageView.layer addSublayer:gradientLayer];
}

- (void)updateCellWithViewModel:(RCDAgentTagCollectionCellViewModel *)viewModel {
    self.viewModel = viewModel;
    self.labTitle.text = viewModel.tag.name;
    [self.labTitle sizeToFit];
    self.imageView.hidden = !viewModel.selected;
    if (viewModel.selected) {
        self.labTitle.textColor = HEXCOLOR(0x007AFF);
    } else {
        self.labTitle.textColor = RCDYCOLOR(0x020814, 0xFFFFFF);
    }
}

- (UILabel *)labTitle {
    if (!_labTitle) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 42)];
        lab.text = RCDLocalizedString(@"agent_style");
        lab.font = [UIFont systemFontOfSize:14];
        lab.textAlignment = NSTextAlignmentCenter;
        [lab sizeToFit];
        _labTitle = lab;
    }
    return _labTitle;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 42)];
        UIImage *img = [UIImage imageNamed:@"agent_tag_bg"];
        _imageView.image = img;
        _imageView.layer.cornerRadius = 21;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}
@end
