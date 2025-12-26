//
//  RCNDMessageBlockViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDMessageBlockViewController.h"
#import "RCNDMessageBlockView.h"

@interface RCNDMessageBlockViewController()<RCNDMessageBlockViewModelDelegate>
@property (nonatomic, strong) RCNDMessageBlockView *blockView;
@end
@implementation RCNDMessageBlockViewController

- (instancetype)initWithViewModel:(RCNDBaseListViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        self.listView = self.blockView;
    }
    return self;
}
- (void)loadView {
    self.view = self.blockView;
}

- (RCNDMessageBlockViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDMessageBlockViewModel class]]) {
        RCNDMessageBlockViewModel *vm = (RCNDMessageBlockViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self currentViewModel] setDateDelegate:self];
    [[self currentViewModel] fetchAllData];

}

- (void)setupView {
    [super setupView];
    self.viewModel.delegate = self;
    [self configureLeftBackButton];
    self.title = RCDLocalizedString(@"mute_notifications");
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self currentViewModel] titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
     return [[self currentViewModel] heightForHeaderInSection:section];
}

#pragma mark - RCNDMessageBlockViewModelDelegate
- (void)showDatePicker:(NSDate *)date {
    [self.blockView showDatePicker:date];
}

- (void)buttonConfirmClick {
    [[self currentViewModel] refreshTime:self.blockView.datePicker.date];
    [self.blockView hideDatePicker];
}

- (RCNDMessageBlockView *)blockView {
    if (!_blockView) {
        _blockView = [RCNDMessageBlockView new];
        _blockView.tableView.delegate = self;
        _blockView.tableView.dataSource = self;
        [_blockView.confirmButton addTarget:self
                                     action:@selector(buttonConfirmClick)
                           forControlEvents:UIControlEventTouchUpInside];
    }
    return _blockView;
}
@end
