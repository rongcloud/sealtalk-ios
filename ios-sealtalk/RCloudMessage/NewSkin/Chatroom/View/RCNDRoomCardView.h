//
//  RCNDRoomCardView.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseView.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, RCNDRoomCardShape) {
    RCNDRoomCardShapeRounded = 0,
    RCNDRoomCardShapeRightBottomCornerCut,     // 右侧斜切
    RCNDRoomCardShapeLeftTopCornerCut,        // 左上角切角
    RCNDRoomCardShapeWideLeftTopCornerCut
};

@interface RCNDRoomCardView : UIControl
- (instancetype)initWithShape:(RCNDRoomCardShape)shape
                       colors:(NSArray *)colors;
- (void)flipIfNeeded;
@end

NS_ASSUME_NONNULL_END
