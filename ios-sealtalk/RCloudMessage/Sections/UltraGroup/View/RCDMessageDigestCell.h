//
//  RCDMessageDigestCell.h
//  SealTalk
//
//  Created by RobinCui on 2022/8/3.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString *const RCDMessageDigestCellIdentifier;

@interface RCDMessageDigestCell : UITableViewCell
@property (nonatomic, strong, readonly) UILabel *labUser;
@property (nonatomic, strong, readonly) UILabel *labTime;
@property (nonatomic, strong, readonly) UILabel *labContent;
@end

NS_ASSUME_NONNULL_END
