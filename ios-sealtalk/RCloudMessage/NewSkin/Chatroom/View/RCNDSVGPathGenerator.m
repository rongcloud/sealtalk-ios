//
//  RCDSVGPathGenerator.m
//  NewSkin
//

#import "RCNDSVGPathGenerator.h"

@implementation RCNDSVGPathGenerator

+ (UIBezierPath *)pathForShapeType:(RCNDSVGShapeType)shapeType inRect:(CGRect)rect {
    switch (shapeType) {
        case RCNDSVGShapeTypeRightBottomCornerCut:
            return [self createRightBottomCornerCutPathInRect:rect];
        case RCNDSVGShapeTypeLeftTopCornerCut:
            return [self createLeftTopCornerCutPathInRect:rect];
        case RCNDSVGShapeTypeWideLeftTopCornerCut:
            return [self createWideLeftTopCornerCutPathInRect:rect];
        default:
            return [self createRoundedCardPathInRect:rect];
    }
}

#pragma mark - Private Methods

+ (UIBezierPath *)createRoundedCardPathInRect:(CGRect)rect {
    return [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:13];
}

+ (UIBezierPath *)createRightBottomCornerCutPathInRect:(CGRect)rect {
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    // 原始 SVG 尺寸：167x206
    CGFloat originalWidth = 167.0;
    CGFloat originalHeight = 206.0;
    
    // 根据目标尺寸自动计算缩放比例
    CGFloat scaleX = width / originalWidth;
    CGFloat scaleY = height / originalHeight;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 根据第一个 SVG 路径数据重建路径
    // M13 1H153.467C161.24 1 166.962 8.27665 165.129 15.8301L121.439 195.83C120.133 201.211 115.315 205 109.778 205H13C6.37258 205 1 199.627 1 193V13L1.00391 12.6904C1.1681 6.20608 6.47608 1 13 1Z
    
    [path moveToPoint:CGPointMake(13 * scaleX, 1 * scaleY)]; // M13 1 起点
    
    // H153.467 水平线
    [path addLineToPoint:CGPointMake(153.467 * scaleX, 1 * scaleY)];
    
    // C161.24 1 166.962 8.27665 165.129 15.8301 右上角曲线
    [path addCurveToPoint:CGPointMake(165.129 * scaleX, 15.8301 * scaleY)
            controlPoint1:CGPointMake(161.24 * scaleX, 1 * scaleY)
            controlPoint2:CGPointMake(166.962 * scaleX, 8.27665 * scaleY)];
    
    // L121.439 195.83 右侧斜线
    [path addLineToPoint:CGPointMake(121.439 * scaleX, 195.83 * scaleY)];
    
    // C120.133 201.211 115.315 205 109.778 205 右下角曲线
    [path addCurveToPoint:CGPointMake(109.778 * scaleX, 205 * scaleY)
            controlPoint1:CGPointMake(120.133 * scaleX, 201.211 * scaleY)
            controlPoint2:CGPointMake(115.315 * scaleX, 205 * scaleY)];
    
    // H13 水平线到左下角
    [path addLineToPoint:CGPointMake(13 * scaleX, 205 * scaleY)];
    
    // C6.37258 205 1 199.627 1 193 左下圆角
    [path addCurveToPoint:CGPointMake(1 * scaleX, 193 * scaleY)
            controlPoint1:CGPointMake(6.37258 * scaleX, 205 * scaleY)
            controlPoint2:CGPointMake(1 * scaleX, 199.627 * scaleY)];
    
    // V13 垂直线到左上角
    [path addLineToPoint:CGPointMake(1 * scaleX, 13 * scaleY)];
    
    // L1.00391 12.6904 微调点
    [path addLineToPoint:CGPointMake(1.00391 * scaleX, 12.6904 * scaleY)];
    
    // C1.1681 6.20608 6.47608 1 13 1 左上圆角回到起点
    [path addCurveToPoint:CGPointMake(13 * scaleX, 1 * scaleY)
            controlPoint1:CGPointMake(1.1681 * scaleX, 6.20608 * scaleY)
            controlPoint2:CGPointMake(6.47608 * scaleX, 1 * scaleY)];
    
    [path closePath];
    
    return path;
}

+ (UIBezierPath *)createLeftTopCornerCutPathInRect:(CGRect)rect {
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    // 原始 SVG 尺寸：184x98
    CGFloat originalWidth = 184.0;
    CGFloat originalHeight = 98.0;
    
    // 根据目标尺寸自动计算缩放比例
    CGFloat scaleX = width / originalWidth;
    CGFloat scaleY = height / originalHeight;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 根据第二个 SVG 路径数据重建路径
    // M31.2002 1H171C177.627 1 183 6.37258 183 13V85C183 91.6274 177.627 97 171 97H13.5674C5.78456 96.9997 0.0607993 89.705 1.91211 82.1455L19.5449 10.1455C20.8598 4.77637 25.6724 1.00013 31.2002 1Z
    
    [path moveToPoint:CGPointMake(31.2002 * scaleX, 1 * scaleY)]; // M31.2002 1 起点
    
    // H171 水平线到右上角开始
    [path addLineToPoint:CGPointMake(171 * scaleX, 1 * scaleY)];
    
    // C177.627 1 183 6.37258 183 13 右上圆角
    [path addCurveToPoint:CGPointMake(183 * scaleX, 13 * scaleY)
            controlPoint1:CGPointMake(177.627 * scaleX, 1 * scaleY)
            controlPoint2:CGPointMake(183 * scaleX, 6.37258 * scaleY)];
    
    // V85 垂直线到右下角开始
    [path addLineToPoint:CGPointMake(183 * scaleX, 85 * scaleY)];
    
    // C183 91.6274 177.627 97 171 97 右下圆角
    [path addCurveToPoint:CGPointMake(171 * scaleX, 97 * scaleY)
            controlPoint1:CGPointMake(183 * scaleX, 91.6274 * scaleY)
            controlPoint2:CGPointMake(177.627 * scaleX, 97 * scaleY)];
    
    // H13.5674 水平线到左下角
    [path addLineToPoint:CGPointMake(13.5674 * scaleX, 97 * scaleY)];
    
    // C5.78456 96.9997 0.0607993 89.705 1.91211 82.1455 左下曲线转折
    [path addCurveToPoint:CGPointMake(1.91211 * scaleX, 82.1455 * scaleY)
            controlPoint1:CGPointMake(5.78456 * scaleX, 96.9997 * scaleY)
            controlPoint2:CGPointMake(0.0607993 * scaleX, 89.705 * scaleY)];
    
    // L19.5449 10.1455 左侧斜线（这里是关键的梯形斜边）
    [path addLineToPoint:CGPointMake(19.5449 * scaleX, 10.1455 * scaleY)];
    
    // C20.8598 4.77637 25.6724 1.00013 31.2002 1 左上曲线回到起点
    [path addCurveToPoint:CGPointMake(31.2002 * scaleX, 1 * scaleY)
            controlPoint1:CGPointMake(20.8598 * scaleX, 4.77637 * scaleY)
            controlPoint2:CGPointMake(25.6724 * scaleX, 1.00013 * scaleY)];
    
    [path closePath];
    
    return path;
}

+ (UIBezierPath *)createWideLeftTopCornerCutPathInRect:(CGRect)rect {
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    // 原始 SVG 尺寸：209x98
    CGFloat originalWidth = 209.0;
    CGFloat originalHeight = 98.0;
    
    // 根据目标尺寸自动计算缩放比例
    CGFloat scaleX = width / originalWidth;
    CGFloat scaleY = height / originalHeight;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 根据新的 SVG 路径数据重建路径
    // M31.2002 1H196C202.627 1 208 6.37258 208 13V85C208 91.6274 202.627 97 196 97H13.5674C5.78456 96.9997 0.0607999 89.705 1.91211 82.1455L19.5449 10.1455C20.8598 4.77637 25.6724 1.00013 31.2002 1Z
    
    [path moveToPoint:CGPointMake(31.2002 * scaleX, 1 * scaleY)]; // M31.2002 1 起点
    
    // H196 水平线到右上角开始
    [path addLineToPoint:CGPointMake(196 * scaleX, 1 * scaleY)];
    
    // C202.627 1 208 6.37258 208 13 右上圆角
    [path addCurveToPoint:CGPointMake(208 * scaleX, 13 * scaleY)
            controlPoint1:CGPointMake(202.627 * scaleX, 1 * scaleY)
            controlPoint2:CGPointMake(208 * scaleX, 6.37258 * scaleY)];
    
    // V85 垂直线到右下角开始
    [path addLineToPoint:CGPointMake(208 * scaleX, 85 * scaleY)];
    
    // C208 91.6274 202.627 97 196 97 右下圆角
    [path addCurveToPoint:CGPointMake(196 * scaleX, 97 * scaleY)
            controlPoint1:CGPointMake(208 * scaleX, 91.6274 * scaleY)
            controlPoint2:CGPointMake(202.627 * scaleX, 97 * scaleY)];
    
    // H13.5674 水平线到左下角
    [path addLineToPoint:CGPointMake(13.5674 * scaleX, 97 * scaleY)];
    
    // C5.78456 96.9997 0.0607999 89.705 1.91211 82.1455 左下曲线转折
    [path addCurveToPoint:CGPointMake(1.91211 * scaleX, 82.1455 * scaleY)
            controlPoint1:CGPointMake(5.78456 * scaleX, 96.9997 * scaleY)
            controlPoint2:CGPointMake(0.0607999 * scaleX, 89.705 * scaleY)];
    
    // L19.5449 10.1455 左侧斜线（这里是关键的梯形斜边）
    [path addLineToPoint:CGPointMake(19.5449 * scaleX, 10.1455 * scaleY)];
    
    // C20.8598 4.77637 25.6724 1.00013 31.2002 1 左上曲线回到起点
    [path addCurveToPoint:CGPointMake(31.2002 * scaleX, 1 * scaleY)
            controlPoint1:CGPointMake(20.8598 * scaleX, 4.77637 * scaleY)
            controlPoint2:CGPointMake(25.6724 * scaleX, 1.00013 * scaleY)];
    
    [path closePath];
    
    return path;
}

@end
