//
//  RCNDSearchGroupCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/2.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchGroupCellViewModel.h"
#import "RCNDSearchGroupResultCell.h"
#import "RCUChatViewController.h"

@implementation RCNDSearchGroupCellViewModel
- (instancetype)initWithGroupInfo:(RCGroupInfo *)info
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
    RCNDSearchGroupResultCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDSearchGroupResultCellIdentifier forIndexPath:indexPath];
    [cell updateWithViewModel:self];
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    RCUChatViewController *chatVC = [[RCUChatViewController alloc] init];
    chatVC.conversationType = ConversationType_GROUP;
    chatVC.targetId = self.info.groupId;
    chatVC.title = self.info.groupName;
    [vc.navigationController pushViewController:chatVC animated:YES];
}

- (NSMutableAttributedString *)title {
    if (!_title) {
        _title = [self attributedTextWith:self.info.groupName highlightedText:self.keyword];
    }
    return _title;
}
@end
