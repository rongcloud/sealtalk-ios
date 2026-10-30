//
//  RCNDConversationBackgroundViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDConversationBackgroundViewModel.h"
#import "RCNDCommonCellViewModel.h"
#import "RCNDPreinstallPhotoViewController.h"


@interface RCNDConversationBackgroundViewModel()
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation RCNDConversationBackgroundViewModel

- (void)ready {
    [super ready];
    __weak typeof(self) weakSelf = self;

    RCNDCommonCellViewModel *preinstall = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
        
        RCNDPreinstallPhotoViewController *controller = [[RCNDPreinstallPhotoViewController alloc] init];
        [weakSelf showViewController:controller byViewController:vc];
    }];
    preinstall.title = RCDLocalizedString(@"ConversationBGPreinstalled");
    
    RCNDCommonCellViewModel *album = [[RCNDCommonCellViewModel alloc] initWithTapBlock:^(UIViewController * _Nonnull vc) {
    }];
    album.title = RCDLocalizedString(@"SelectFromAlbum");

    self.dataSource = @[preinstall, album];
    [self removeSeparatorLineIfNeed:@[self.dataSource]];
}

- (void)registerCellForTableView:(UITableView *)tableView {
    [tableView registerClass:[RCNDCommonCell class] forCellReuseIdentifier:RCNDCommonCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.row];
}

@end
