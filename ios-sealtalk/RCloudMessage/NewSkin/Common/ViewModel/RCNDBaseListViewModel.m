//
//  RCNDBaseListViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseListViewModel.h"
#import "RCNDBaseCellViewModel.h"

@implementation RCNDBaseListViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self ready];
    }
    return self;
}

- (void)ready {
    
}
#pragma mark - Public
- (void)registerCellForTableView:(UITableView *)tableView {
    
}

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"子类 %@ 必须重写类方法 +[%@ %@]！",
                NSStringFromClass([self class]),
                NSStringFromClass([self superclass]),
                NSStringFromSelector(_cmd));
    return nil;
}


#pragma mark - Table

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RCNDBaseCellViewModel *vm = [self cellViewModelAtIndexPath:indexPath];
    return [vm tableView:tableView cellForRowAtIndexPath:indexPath];;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSAssert(NO, @"子类 %@ 必须重写类方法 +[%@ %@]！",
                NSStringFromClass([self class]),
                NSStringFromClass([self superclass]),
                NSStringFromSelector(_cmd));
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCNDBaseCellViewModel *vm = [self cellViewModelAtIndexPath:indexPath];
    return [vm heightForRowAtIndexPath:indexPath];;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
   viewController:(UIViewController *)controller {
    RCNDBaseCellViewModel *vm = [self cellViewModelAtIndexPath:indexPath];
    [vm itemDidSelectedByViewController:controller];
}

- (void)removeSeparatorLineIfNeed:(NSArray *)array {
    for (NSArray *tmp in array) {
        if ([tmp isKindOfClass:[NSArray class]]) {
            RCNDBaseCellViewModel *vm = tmp.lastObject;
            if ([vm isKindOfClass:[RCNDBaseCellViewModel class]]) {
                vm.hideSeparatorLine = YES;
            }
        }
    }
}

- (void)showViewController:(UIViewController *)vc
          byViewController:(UIViewController *)controller {
    [controller.navigationController pushViewController:vc animated:YES];
}

@end
