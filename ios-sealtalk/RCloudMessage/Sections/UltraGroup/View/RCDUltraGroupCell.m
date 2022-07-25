//
//  RCDUltraGroupCell.m
//  SealTalk
//
//  Created by 张改红 on 2022/1/19.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUltraGroupCell.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>
@interface RCDUltraGroupCell()
@property (nonatomic, strong) UIView *unreadView;
@end
@implementation RCDUltraGroupCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDUltraGroupCell *cell =
        (RCDUltraGroupCell *)[tableView dequeueReusableCellWithIdentifier:RCDUltraGroupCellIdentifier];
    if (!cell) {
        cell = [[RCDUltraGroupCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews{
    [self.contentView addSubview:self.portraitImageView];
    [self.contentView addSubview:self.unreadView];
    [self.portraitImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.centerX.equalTo(self.contentView);
        make.height.width.offset(42);
    }];
    [self.unreadView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.centerX.equalTo(self.contentView);
        make.height.width.offset(45);
    }];
}

#pragma mark - getter
- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.backgroundColor = [UIColor whiteColor];
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImageView.layer.cornerRadius = 21.f;
        } else {
            _portraitImageView.layer.cornerRadius = 2.f;
        }
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImageView;
}

- (UIView *)unreadView{
    if (!_unreadView) {
        _unreadView = [[UIView alloc] init];
    }
    return _unreadView;
}

- (RCMessageBubbleTipView *)bubbleTipView{
    if (!_bubbleTipView) {
        _bubbleTipView =
        [[RCMessageBubbleTipView alloc] initWithParentView:self.unreadView
                                                 alignment:RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_TOP_RIGHT];
        _bubbleTipView.bubbleTipBackgroundColor = HEXCOLOR(0xf43530);
        _bubbleTipView.isShowNotificationNumber = YES;
    }
    return _bubbleTipView;
}
@end
