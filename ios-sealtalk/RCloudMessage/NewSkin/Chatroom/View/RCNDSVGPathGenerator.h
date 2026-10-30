//
//  RCDSVGPathGenerator.h
//  NewSkin
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCNDSVGShapeType) {
    RCNDSVGShapeTypeRounded = 0,
    RCNDSVGShapeTypeRightBottomCornerCut = 1,// 右下斜切
    RCNDSVGShapeTypeLeftTopCornerCut = 2, // 左上角切角
    RCNDSVGShapeTypeWideLeftTopCornerCut = 3 // 宽版左上角切角
};

@interface RCNDSVGPathGenerator : NSObject

/**
 * 根据形状类型和尺寸生成对应的 UIBezierPath
 * 缩放比例会根据目标rect和原始SVG尺寸自动计算
 * @param shapeType SVG 形状类型
 * @param rect 目标矩形尺寸
 * @return 生成的 UIBezierPath
 */
+ (UIBezierPath *)pathForShapeType:(RCNDSVGShapeType)shapeType inRect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
