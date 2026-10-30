//
//  RCNDChatroomView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/27.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDChatroomView.h"
#import "RCNDRoomCardView.h"
#import "RCNDPaddingLabel.h"

@implementation RCNDChatroomView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}


- (void)setupView {
    [super setupView];
    UIImageView *imageView = [self imageViewWithName:@"sealtalk_background"];
    [self addSubview:imageView];
    [self addSubview:self.warmHomeControl];
    [self addSubview:self.futureTouchControl];
    [self addSubview:self.musicHeavenControl];
    [self addSubview:self.gameInfoControl];
    UILayoutGuide *margins = self.layoutMarginsGuide;
    CGFloat gap = 10.0;
    [NSLayoutConstraint activateConstraints:@[
        [imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        
        [self.warmHomeControl.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.warmHomeControl.topAnchor constraintEqualToAnchor:margins.topAnchor constant:20],
        [self.warmHomeControl.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:170.0/375.0],
        [self.warmHomeControl.heightAnchor constraintEqualToAnchor:self.warmHomeControl.widthAnchor multiplier:206.0/170.0],
        
        [self.futureTouchControl.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.futureTouchControl.topAnchor constraintEqualToAnchor:self.warmHomeControl.topAnchor constant:0],

        [self.futureTouchControl.heightAnchor constraintEqualToAnchor:self.warmHomeControl.heightAnchor multiplier:98.0/206.0],
        [self.futureTouchControl.widthAnchor constraintEqualToAnchor:self.futureTouchControl.heightAnchor multiplier:187.0/98.0],

        [self.musicHeavenControl.trailingAnchor constraintEqualToAnchor:self.futureTouchControl.trailingAnchor],
        [self.musicHeavenControl.bottomAnchor constraintEqualToAnchor:self.warmHomeControl.bottomAnchor],
        [self.musicHeavenControl.heightAnchor constraintEqualToAnchor:self.futureTouchControl.heightAnchor],
        [self.musicHeavenControl.widthAnchor constraintEqualToAnchor:self.musicHeavenControl.heightAnchor multiplier:212.0/98.0],
        
        [self.gameInfoControl.leadingAnchor constraintEqualToAnchor:self.warmHomeControl.leadingAnchor],
        [self.gameInfoControl.trailingAnchor constraintEqualToAnchor:self.futureTouchControl.trailingAnchor],
        [self.gameInfoControl.topAnchor constraintEqualToAnchor:self.warmHomeControl.bottomAnchor constant:gap],
        [self.gameInfoControl.heightAnchor constraintEqualToAnchor:self.gameInfoControl.widthAnchor multiplier:98.0/343.0]
    ]];
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *lab = [UILabel new];
    lab.text = text;
    lab.font = [UIFont systemFontOfSize:16];
    [lab sizeToFit];
    lab.textColor = RCDYCOLOR(0x020814, 0xFFFFFF);
    lab.translatesAutoresizingMaskIntoConstraints = NO;
    return lab;
}

- (UILabel *)labelBadgeWithText:(NSString *)text backgroundColor:(UIColor *)color {
    // 创建自定义 UILabel 子类来支持内边距
    RCNDPaddingLabel *lab = [RCNDPaddingLabel new];
    lab.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 设置内边距（上、左、下、右）
    lab.textInsets = UIEdgeInsetsMake(2, 6, 2, 6);
    
    text = [NSString stringWithFormat:RCDLocalizedString(@"ChatroomMemberInChat"), [text intValue]];
    lab.text = text;
    lab.font = [UIFont systemFontOfSize:12];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.layer.cornerRadius = 10;
    lab.layer.masksToBounds = YES;  // 启用圆角裁剪
    lab.backgroundColor = color;
    lab.textColor = [UIColor whiteColor];
    return lab;
}

- (UIImageView *)imageViewWithName:(NSString *)name {
    UIImage *img = [UIImage imageNamed:name];
    UIImageView *view = [[UIImageView alloc] initWithImage:img];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}


- (UIControl *)warmHomeControl{
    if (!_warmHomeControl) {
        UIColor *colorTop = RCDYCOLOR(0xFFFFFF, 0xFFFFFF);
        UIColor *colorBottom = [RCKitUtility generateDynamicColor:RCMASKCOLOR(0xffffff, 0) darkColor:HEXCOLOR(0xB2C9FB)];
        NSArray *colors = @[colorTop,colorBottom];
        RCNDRoomCardView *view = [[RCNDRoomCardView alloc] initWithShape:RCNDRoomCardShapeRightBottomCornerCut
                                                                colors:colors];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view flipIfNeeded];
        UILabel *labTitle = [self labelWithText:RCDLocalizedString(@"ChatroomWarmHome")];
        [view addSubview:labTitle];
        
        UIColor *bgColor = RCDYCOLOR(0xffffff, 0xffffff);
        UILabel *labBadge = [self labelBadgeWithText:@"345" backgroundColor:bgColor];
        labBadge.textColor = [UIColor blackColor];
        [view addSubview:labBadge];
        
        UIImageView *icon = [self imageViewWithName:@"chatroom_card_home"];
        [view addSubview:icon];
        
        [NSLayoutConstraint activateConstraints:@[
            [labBadge.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:25],
            [labBadge.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-25],
            
            [labTitle.leadingAnchor constraintEqualToAnchor:labBadge.leadingAnchor],
            [labTitle.bottomAnchor constraintEqualToAnchor:labBadge.topAnchor constant:-6],
            
            [icon.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:32],
            [icon.topAnchor constraintEqualToAnchor:view.topAnchor constant:30],
            [icon.widthAnchor constraintEqualToConstant:64],
            [icon.heightAnchor constraintEqualToConstant:73]

        ]];
        _warmHomeControl = view;
        
    }
    return _warmHomeControl;
}

- (UIView *)futureTouchControl {
    if (!_futureTouchControl) {
        UIColor *colorTop = RCDYCOLOR(0xCC9BFF, 0x9735FF);
        UIColor *colorBottom = RCDYCOLOR(0xFEFEFF, 0xE1C5FF);
        NSArray *colors = @[colorTop,colorBottom];
        RCNDRoomCardView *view = [[RCNDRoomCardView alloc] initWithShape:RCNDRoomCardShapeLeftTopCornerCut
                                                                colors:colors];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view flipIfNeeded];
        UILabel *labTitle = [self labelWithText:RCDLocalizedString(@"ChatroomTechnicalFuture")];
        [view addSubview:labTitle];
        
        
        UIColor *bgColor = RCDYCOLOR(0xB683EC, 0x9E45FF);

        UILabel *labBadge = [self labelBadgeWithText:@"201" backgroundColor:bgColor];
        [view addSubview:labBadge];
        
        UIImageView *icon = [self imageViewWithName:@"chatroom_card_future"];
        [view addSubview:icon];
        
        [NSLayoutConstraint activateConstraints:@[
            [labBadge.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:39],
            [labBadge.bottomAnchor constraintEqualToAnchor:icon.bottomAnchor],
            
            [labTitle.leadingAnchor constraintEqualToAnchor:labBadge.leadingAnchor],
            [labTitle.topAnchor constraintEqualToAnchor:icon.topAnchor],
            
            [icon.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-8],
            [icon.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
            [icon.widthAnchor constraintEqualToConstant:50],
            [icon.heightAnchor constraintEqualToConstant:50]

        ]];
        
        _futureTouchControl = view;
    }
    return _futureTouchControl;
}

- (UIView *)musicHeavenControl {
    if (!_musicHeavenControl) {
        UIColor *colorTop = RCDYCOLOR(0x82DAFF, 0x27BEFF);
        UIColor *colorBottom = RCDYCOLOR(0xF1FBFF, 0xCFF1FF);
        NSArray *colors = @[colorTop, colorBottom];
        RCNDRoomCardView *view = [[RCNDRoomCardView alloc] initWithShape:RCNDRoomCardShapeWideLeftTopCornerCut
                                                                colors:colors];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view flipIfNeeded];
        UILabel *labTitle = [self labelWithText:RCDLocalizedString(@"ChatroomMusicHeaven")];
        [view addSubview:labTitle];
        
        
        UIColor *bgColor = RCDYCOLOR(0x2DB2EC, 0x0099FF);

        UILabel *labBadge = [self labelBadgeWithText:@"135" backgroundColor:bgColor];
        [view addSubview:labBadge];
        
        UIImageView *icon = [self imageViewWithName:@"chatroom_card_music"];
        [view addSubview:icon];
        
        [NSLayoutConstraint activateConstraints:@[
            [labBadge.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:39],
            [labBadge.bottomAnchor constraintEqualToAnchor:icon.bottomAnchor],
            
            [labTitle.leadingAnchor constraintEqualToAnchor:labBadge.leadingAnchor],
            [labTitle.topAnchor constraintEqualToAnchor:icon.topAnchor],
            
            [icon.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-8],
            [icon.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
            [icon.widthAnchor constraintEqualToConstant:50],
            [icon.heightAnchor constraintEqualToConstant:50]

        ]];
        _musicHeavenControl = view;
    }
    return _musicHeavenControl;
}

- (UIView *)gameInfoControl {
    if (!_gameInfoControl) {
        UIColor *colorTop = RCDYCOLOR(0xA8D8FF, 0x58B4FF);
        UIColor *colorBottom = RCDYCOLOR(0xEFF8FF, 0xD1EAFF);
        NSArray *colors = @[colorTop, colorBottom];
        RCNDRoomCardView *view = [[RCNDRoomCardView alloc] initWithShape:RCNDRoomCardShapeRounded
                                                                colors:colors];
        view.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel *labTitle = [self labelWithText:RCDLocalizedString(@"ChatroomGameCenter")];
        [view addSubview:labTitle];
        
        
        UIColor *bgColor = RCDYCOLOR(0x418DFF, 0x279EFF);

        UILabel *labBadge = [self labelBadgeWithText:@"135" backgroundColor:bgColor];
        [view addSubview:labBadge];
        
        UIImageView *icon = [self imageViewWithName:@"chatroom_card_game"];
        [view addSubview:icon];
        
        [NSLayoutConstraint activateConstraints:@[
            [labBadge.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:14],
            [labBadge.bottomAnchor constraintEqualToAnchor:icon.bottomAnchor constant:-4],
            
            [labTitle.leadingAnchor constraintEqualToAnchor:labBadge.leadingAnchor],
            [labTitle.topAnchor constraintEqualToAnchor:icon.topAnchor constant:4],
            
            [icon.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:20],
            [icon.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
            [icon.widthAnchor constraintEqualToConstant:56],
            [icon.heightAnchor constraintEqualToConstant:56]

        ]];
        _gameInfoControl = view;
    }
    return _gameInfoControl;
}

@end
