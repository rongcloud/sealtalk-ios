//
//  RCNDCleanHistoryViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDCleanHistoryViewController.h"
#import "RCNDCleanHistoryView.h"

@interface RCNDCleanHistoryViewController()
@property (nonatomic, strong) RCNDCleanHistoryView *cleanView;
@end


@implementation RCNDCleanHistoryViewController
- (instancetype)initWithViewModel:(RCNDBaseListViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.listView = self.cleanView;
    }
    return self;
}

- (void)loadView {
    self.view = self.cleanView;
}

- (RCNDCleanHistoryViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDCleanHistoryViewModel class]]) {
        RCNDCleanHistoryViewModel *vm = (RCNDCleanHistoryViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self currentViewModel] fetchAllData];
}

- (void)setupView {
    [super setupView];
    [self configureLeftBackButton];
    self.title = RCDLocalizedString(@"CleanChatHistory");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    NSInteger count = [[self currentViewModel] numberOfConversationSelected];
    BOOL isAll = [self currentViewModel].dataSource.count == count;
    [self.cleanView changeButtonsStatusBy:count isAllSelected:count == isAll];
}

- (void)buttonDeleteClick {
    NSInteger count = [[self currentViewModel] numberOfConversationSelected];
    if (count > 0) {
        [RCAlertView showAlertController:nil message:RCDLocalizedString(@"clear_chat_history_alert") actionTitles:nil cancelTitle:RCLocalizedString(@"Cancel") confirmTitle:RCLocalizedString(@"Confirm") preferredStyle:(UIAlertControllerStyleAlert) actionsBlock:nil cancelBlock:^{
        } confirmBlock:^{
            [[self currentViewModel] cleanHistoryOfConversationSelected:nil];
        } inViewController:self];
    }
    [self.cleanView changeButtonsStatusBy:0 isAllSelected:NO];
}

- (void)buttonSelectAllClick {
   NSInteger count = [[self currentViewModel] changeAllConversationsStatus];
    BOOL isAll = [self currentViewModel].dataSource.count == count;
    [self.cleanView changeButtonsStatusBy:count isAllSelected:isAll];
}

- (RCNDCleanHistoryView *)cleanView {
    if (!_cleanView) {
        _cleanView = [RCNDCleanHistoryView new];
        _cleanView.tableView.delegate = self;
        _cleanView.tableView.dataSource = self;
        [_cleanView.buttonDelete addTarget:self
                                     action:@selector(buttonDeleteClick)
                           forControlEvents:UIControlEventTouchUpInside];
        [_cleanView.buttonSelectAll addTarget:self
                                     action:@selector(buttonSelectAllClick)
                           forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanView;
}
@end
