//
//  RCDUltraModel.h
//  SealTalk
//
//  Created by 张改红 on 2022/1/20.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDUltraGroup : NSObject

@property (nonatomic, copy) NSString *groupId;

@property (nonatomic, copy) NSString *groupName;

@property (nonatomic, copy) NSString *portraitUri;

@property (nonatomic, copy) NSString *creatorId;

@property (nonatomic, copy) NSString *summary;

- (instancetype)initWithJson:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END
