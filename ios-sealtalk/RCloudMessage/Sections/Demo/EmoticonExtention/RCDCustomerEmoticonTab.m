//
//  RCDCustomerEmoticonTab.m
//  RCloudMessage
//
//  Created by 杜立召 on 16/9/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCustomerEmoticonTab.h"

@interface RCDCustomerEmoticonTab ()
@property (nonatomic, strong) NSArray *btnTitles;

@property (nonatomic, weak) id<RCEmojiViewDelegate> delegate;
@property (nonatomic, weak) RCEmojiBoardView *emojiBoardView;
@end

@implementation RCDCustomerEmoticonTab

- (instancetype)initWith:(RCEmojiBoardView *)emojiBoardView
{
    self = [super init];
    if (self) {
        self.emojiBoardView = emojiBoardView;
        self.delegate = emojiBoardView.delegate;
    }
    return self;
}

- (UIView *)loadEmoticonView:(NSString *)identify index:(int)index {
    UIView *view11 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 186)];
    UIButton *btn = nil;
    if (index<self.btnTitles.count) {
        btn = [self btnFaceWithTitle:self.btnTitles[index]];
    }
    view11.backgroundColor = [UIColor blackColor];
    [view11 addSubview:btn];
    switch (index) {
    case 1:
        view11.backgroundColor = [UIColor yellowColor];
        break;
    case 2:
        view11.backgroundColor = [UIColor redColor];
        break;
    case 3:
        view11.backgroundColor = [UIColor greenColor];
        break;
    case 4:
        view11.backgroundColor = [UIColor grayColor];
        break;

    default:
        break;
    }
    return view11;
}

- (UIButton *)btnFaceWithTitle:(NSString *)title {
    UIButton *emojiBtn =
        [[UIButton alloc] initWithFrame:CGRectMake(10 , 10, 41, 41)];
    emojiBtn.titleLabel.font = [[RCKitConfig defaultConfig].font fontOfSize:26];
    [emojiBtn setTitle:title forState:UIControlStateNormal];
    [emojiBtn addTarget:self action:@selector(emojiBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    return emojiBtn;
}

- (void)emojiBtnHandle:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didTouchEmojiView:touchedEmoji:)]) {
        [self.delegate didTouchEmojiView:self.emojiBoardView touchedEmoji:sender.titleLabel.text];
    }
}

- (NSArray *)btnTitles{
    if (!_btnTitles) {
        _btnTitles = @[@"☕",
                       @"🏀",
                       @"⚽",
                       @"🏂",@"☕",@"⚽"];
    }
    return _btnTitles;
}
@end
