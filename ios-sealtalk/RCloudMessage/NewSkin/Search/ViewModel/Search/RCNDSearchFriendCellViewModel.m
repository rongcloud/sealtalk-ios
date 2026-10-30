//
//  RCNDSearchFriendCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchFriendCellViewModel.h"
#import "RCNDSearchFriendResultCell.h"
#import "RCUChatViewController.h"

@implementation RCNDSearchFriendCellViewModel

- (instancetype)initWithFriendInfo:(RCFriendInfo *)info
                           keyword:(NSString *)keyword
{
    self = [super init];
    if (self) {
        self.info = info;
        self.keyword = keyword;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDSearchFriendResultCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDSearchFriendResultCellIdentifier forIndexPath:indexPath];
    [cell updateWithViewModel:self];
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = self.info.userId;
    chatVC.title = self.info.name;
    [vc.navigationController pushViewController:chatVC animated:YES];
}

- (NSMutableAttributedString *)title {
    if (!_title) {
        _title = [self attributedTextWith:self.info.name highlightedText:self.keyword] ;
    }
    return _title;
}

- (BOOL)shouldShowRemark {
    return self.info.remark.length == 0;
}

- (NSString *)remark {
    if (!_remark) {
        _remark = [NSString stringWithFormat:@"%@: %@",RCDLocalizedString(@"Remark_name"), self.info.remark];
    }
    return _remark;
}
@end
