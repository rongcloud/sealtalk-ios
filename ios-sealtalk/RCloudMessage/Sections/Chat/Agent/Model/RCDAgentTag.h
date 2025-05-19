//
//  RCDAgentTag.h
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDAgentTag : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *agentID;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSDictionary *)dictionaryInfo;
@end

NS_ASSUME_NONNULL_END
