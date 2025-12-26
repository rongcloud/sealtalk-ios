//
//  RCNDSwitchCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSwitchCellViewModel.h"

@interface RCNDSwitchCellViewModel()
@property (nonatomic, copy) RCNDSwitchCellViewModelOuterBlock switchBlock;
@end

@implementation RCNDSwitchCellViewModel
- (instancetype)initWithSwitchOn:(BOOL)switchOn
                     switchBlock:(RCNDSwitchCellViewModelOuterBlock)switchBlock {
    self = [super init];
    if (self) {
        self.switchOn = switchOn;
        self.switchBlock = switchBlock;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:RCNDSwitchCellIdentifier
                                                                          forIndexPath:indexPath];
    cell.hideSeparatorLine = self.hideSeparatorLine;
    [cell updateWithViewModel:self];
    return cell;
}

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    
}

- (void)switchValueChanged:(UISwitch *)switchView
                completion:(RCNDSwitchCellViewModelInnerBoolBlock)completion {
    if (self.switchOn == switchView.on) {
        return;
    }
    if (self.switchBlock) {
        BOOL switchOn = switchView.on;
        RCNDSwitchCellViewModelInnerBoolBlock block = ^(BOOL ret) {
            if (ret) {
                self.switchOn = switchView.on;
            }
            if (completion) {
                completion(ret);
            }
        };
        self.switchBlock(switchOn, block);
    }
}

@end
