//
//  RCNDQRForwardSelectCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDQRForwardSelectCellViewModel.h"
#import "RCNDQRForwardCell.h"

@implementation RCNDQRForwardSelectCellViewModel

- (instancetype)initWithTapBlock:(RCNDCommonCellViewModelBlock)tapBlock {
    self = [super init];
    if (self) {
        self.tapBlock = tapBlock;
    }
    return self;
}

- (void)refreshCell {
    if ([self.cellDelegate respondsToSelector:@selector(refreshCellWith:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cellDelegate refreshCellWith:self];
        });
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDQRForwardCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDQRForwardCellIdentifier forIndexPath:indexPath];
    [self fetchDataIfNeed];
    [cell updateWithViewModel:self];
    return cell;
}

- (void)fetchData:(void(^)(void))completion {
    
}

- (void)fetchDataIfNeed {
    if (self.title) {
        return;
    }
    [self fetchData:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshCell];
        });
    }];
}
@end
