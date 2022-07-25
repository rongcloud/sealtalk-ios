//
//  RCDCreateGroupViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
typedef NS_ENUM(NSInteger, RCDCreateType) {
    RCDCreateTypeNormalGroup = 0,
    RCDCreateTypeUltraGroup = 1,
    RCDCreateTypeUltraGroupChannel = 2,
};
@interface RCDCreateGroupViewController : RCDViewController
@property (nonatomic, strong) NSMutableArray *groupMemberIdList;
@property (nonatomic, assign) RCDCreateType groupType;
@property (nonatomic, copy) NSString *groupId;
@end
