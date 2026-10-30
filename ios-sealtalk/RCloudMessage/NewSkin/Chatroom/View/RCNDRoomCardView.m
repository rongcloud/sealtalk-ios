//
//  RCNDRoomCardView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDRoomCardView.h"
#import "RCNDSVGPathGenerator.h"

@interface RCNDRoomCardView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (nonatomic, assign) RCNDRoomCardShape shape;
@property (nonatomic, strong) NSArray<UIColor *> *colors;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation RCNDRoomCardView

- (instancetype)initWithShape:(RCNDRoomCardShape)shape
                       colors:(NSArray *)colors
{
    self = [super init];
    if (self) {
        self.shape = shape;
        self.colors = colors;
        [self setupView];
    }
    return self;
}
- (void)setupView {
    [self addSubview:self.containerView];
    [self.containerView.layer addSublayer:self.gradientLayer];
    [self.containerView.layer addSublayer:self.borderLayer];
}

- (void)flipIfNeeded {
    if ([RCKitUtility isRTL]) {
        self.containerView.transform = CGAffineTransformMakeScale(-1, 1);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.containerView.frame = self.bounds;
    self.gradientLayer.frame = self.bounds;
    self.borderLayer.frame = self.bounds;
    self.path = [RCNDSVGPathGenerator pathForShapeType:(RCNDSVGShapeType)self.shape
                                               inRect:self.bounds];
    [self applyMaskPath];
}


- (void)applyMaskPath {
    // 应用遮罩到渐变层
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = self.path.CGPath;
    self.gradientLayer.mask = mask;
    
    // 设置边框路径
    self.borderLayer.path = self.path.CGPath;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:self.colors.count];
        for (UIColor *c in self.colors) {
            if (![c isKindOfClass:[UIColor class]]) { continue; }
            [cgColors addObject:(__bridge id)c.CGColor];
        }
        _gradientLayer.colors = [cgColors copy];
        _gradientLayer.locations = @[@(0), @(1)];
        _gradientLayer.startPoint = CGPointMake(0.5, 0.05);

        _gradientLayer.endPoint = CGPointMake(0.5, 0.95);
    }
    return _gradientLayer;
}

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        UIColor *color = RCDynamicColor(@"common_background_color", @"0xffffff", @"0x2D2D32");
        _borderLayer.strokeColor = color.CGColor;
        _borderLayer.lineWidth = 2.0;
    }
    return _borderLayer;
}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL res = [super pointInside:point withEvent:event];
    if (res) {
        if (!self.path || [self.path containsPoint:point]) {
            return YES;
        }
        return NO;
    }
    return res;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.userInteractionEnabled = NO;
    }
    return _containerView;
}
@end
