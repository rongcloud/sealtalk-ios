//
//  RCDAgentTagCollectionCellViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/4/14.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCDAgentTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDAgentTagCollectionCellViewModel : NSObject
@property (nonatomic, strong) RCDAgentTag *tag;
@property (nonatomic, assign) BOOL selected;

- (instancetype)initWithTag:(RCDAgentTag *)tag;
@end

NS_ASSUME_NONNULL_END
