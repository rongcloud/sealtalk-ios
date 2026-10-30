//
//  RCNDBaseListViewModel.h
//  SealTalk
//
//  Created by RobinCui on 2025/11/20.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewModel.h"
#import "RCNDBaseCellViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol RCNDBaseListViewModelDelegate <NSObject>
@optional

- (void)reloadData:(BOOL)empty;

- (void)showTips:(NSString *)tips;

- (void)showAlert:(NSString *)tips;
@end

@interface RCNDBaseListViewModel : RCNDBaseViewModel
@property (nonatomic, weak) id<RCNDBaseListViewModelDelegate> delegate;

- (void)registerCellForTableView:(UITableView *)tableView;

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
   viewController:(UIViewController *)controller;

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

- (void)ready;

- (RCNDBaseCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

- (void)removeSeparatorLineIfNeed:(NSArray *)array;

- (void)showViewController:(UIViewController *)vc
          byViewController:(UIViewController *)controller;


@end

NS_ASSUME_NONNULL_END
