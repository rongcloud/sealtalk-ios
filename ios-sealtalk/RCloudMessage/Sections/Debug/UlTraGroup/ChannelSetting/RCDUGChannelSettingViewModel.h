//
//  RCDUGChannelSettingViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2022/6/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDChannelUserInfo.h"
#import <UIKit/UIKit.h>
#import "RCDChannelUserInfoCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCDUGChannelSettingRowType){
    RCDUGChannelSettingRowTypeMembers = -1, // 成员
//    RCDUGChannelSettingRowTypeAddAll, // 添加全部
//    RCDUGChannelSettingRowTypeRemoveAll, // 移除全部
    RCDUGChannelSettingRowTypeChannelType = 0, // 修改频道类型
    RCDUGChannelSettingRowTypeUserGroup, // 用户组
    RCDUGChannelSettingRowTypeTotalNumber
};

@protocol RCDUGChannelSettingViewModelDelegate <NSObject>

- (void)memberInfoDidLoaded;
- (void)editChannelTypeFinishedWith:(BOOL)success;
- (void)disbandChannelFinishedWith:(BOOL)success;
@end

@protocol RCDUGChannelTypeDelegate <NSObject>

- (void)channelTypeDidChangedTo:(BOOL)isPrivate;

@end

@interface RCDUGChannelSettingViewModel : NSObject
@property (nonatomic, weak) id<RCDUGChannelSettingViewModelDelegate> delegate;
@property (nonatomic, weak) id<RCDUGChannelTypeDelegate> typeDelegate;
@property (nonatomic, assign, readonly) BOOL isOwner;
@property (nonatomic, assign, readonly) BOOL isPrivate;
@property (nonatomic, copy, readonly) NSString *groupID;
@property (nonatomic, copy, readonly) NSString *channelID;
- (instancetype)initWithGroupID:(NSString *)groupID
                      channelID:(NSString *)channelID
                      isPrivate:(BOOL)isPrivate
                       ownnerID:(NSString *)ownnerID;
- (void)query;
- (CGSize)sizeForItem;
- (CGFloat)headerViewHeight;
- (NSInteger)numberOfMemebers;
- (RCDChannelUserInfoCellViewModel *)viewModelAtIndex:(NSIndexPath *)indexPath;
- (NSString *)stringOfChannelType;
- (void)editChannelType;

- (CGFloat)heightForRowType:(RCDUGChannelSettingRowType)type;
- (void)disband;
@end

NS_ASSUME_NONNULL_END
