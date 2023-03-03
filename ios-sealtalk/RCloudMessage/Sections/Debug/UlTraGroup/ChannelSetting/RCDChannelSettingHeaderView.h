//
//  RCDChannelSetttingHeaderView.h
//  SealTalk
//
//  Created by RobinCui on 2022/6/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString * const  RCDChannelSettingHeaderViewIdentifier;

@interface RCDChannelSettingHeaderView : UITableViewHeaderFooterView
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@end

NS_ASSUME_NONNULL_END
