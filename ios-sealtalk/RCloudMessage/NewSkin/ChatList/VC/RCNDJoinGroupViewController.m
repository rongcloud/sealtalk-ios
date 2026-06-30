//
//  RCNDJoinGroupViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDJoinGroupViewController.h"
#import "RCNDJoinGroupView.h"
#import <SDWebImage/SDWebImage.h>


@interface RCNDJoinGroupViewController ()
@property (nonatomic, strong) RCNDJoinGroupView *joinView;
@property (nonatomic, strong) RCGroupInfo *info;
@end

@implementation RCNDJoinGroupViewController

- (instancetype)initWithGroupInfo:(RCGroupInfo *)info
{
    self = [super init];
    if (self) {
        self.info = info;
    }
    return self;
}

- (void)loadView {
    self.view = self.joinView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupView {
    [super setupView];
    self.title = RCDLocalizedString(@"JoinGroup");
    NSURL *url = [NSURL URLWithString:self.info.portraitUri];
    [self.joinView.portraitView sd_setImageWithURL:url
                                  placeholderImage:RCDynamicImage(@"conversation-list_cell_group_portrait_img", @"default_group_portrait")];
    self.joinView.labelTitle.text = [NSString stringWithFormat:@"%@(%ld)", self.info.groupName, self.info.membersCount];
}

- (void)joinGroup {
    [[RCCoreClient sharedCoreClient] joinGroup:self.info.groupId success:^(RCErrorCode processCode) {
        [self showTips:RCDLocalizedString(@"AddSuccess")];
    } error:^(RCErrorCode errorCode) {
        [self showTips:RCDLocalizedString(@"GroupJoinFail")];
    }];
}

- (RCNDJoinGroupView *)joinView {
    if (!_joinView) {
        _joinView = [RCNDJoinGroupView new];
        [_joinView.buttonJoin addTarget:self
                                 action:@selector(joinGroup)
                       forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _joinView;
}
@end
