//
//  RCNDContactViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/19.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDContactViewController.h"
#import "RCNDContactViewModel.h"
#import "RCDChatViewController.h"
#import "RCDCommonString.h"

@interface RCNDContactViewController ()
@property (nonatomic, strong) UIButton *buttonConfirm;
@end

@implementation RCNDContactViewController

- (RCNDContactViewModel *)currentViewModel {
    if ([self.viewModel isKindOfClass:[RCNDContactViewModel class]]) {
        RCNDContactViewModel *vm = (RCNDContactViewModel *)self.viewModel;
        return vm;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self currentViewModel] fetchData];
}

- (void)setupView {
    [super setupView];
    [self configureLeftBackButton];
    self.title = RCDLocalizedString(@"SelectedFriend");
    [self.listView configureSearchBar:[[self currentViewModel] searchBarView]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:RCDLocalizedString(@"ConfirmBtnTitle") forState:UIControlStateNormal];
    [btn setTitleColor:RCDynamicColor(@"primary_color",@"0x0099ff", @"0x007acc")
              forState:UIControlStateNormal];
    [btn setTitleColor:RCDynamicColor(@"disabled_color",@"0xa0a5ab", @"0xa0a5ab") forState:(UIControlStateDisabled)];
    btn.enabled = NO;
    [btn addTarget:self
            action:@selector(confirm)
  forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
    self.buttonConfirm = btn;
}

- (void)confirm {
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [viewControllers removeObject:self];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL enable = [[userDefault valueForKey:RCDDebugDisableSystemEmoji] boolValue];
    RCNDContactCellViewModel *vm = [[self currentViewModel] currentContactCellViewModel];
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.conversationType = ConversationType_PRIVATE;
    chatVC.targetId = vm.info.userId;
    chatVC.title = vm.displayName;
    chatVC.enableNewComingMessageIcon = YES; //开启消息提醒
    chatVC.enableUnreadMessageIcon = YES;
    
    chatVC.displayUserNameInCell = [[userDefault valueForKey:RCDDebugDisplayUserName] boolValue];
    NSInteger num = [DEFAULTS integerForKey:RCDChatroomDefalutHistoryMessageCountKey];
    if (num > 0) {
        chatVC.defaultMessageCount = [@(num) intValue];
    }

    chatVC.disableSystemEmoji = enable;
    [viewControllers addObject:chatVC];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    RCNDContactCellViewModel *vm = [[self currentViewModel] currentContactCellViewModel];
    self.buttonConfirm.enabled = vm.selected;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =  [self.viewModel tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[RCPaddingTableViewCell class]]) {
        RCPaddingTableViewCell *paddingCell = (RCPaddingTableViewCell *)cell;
        [paddingCell updatePaddingContainer:RCUserManagementPadding trailing:-1];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self currentViewModel] sectionIndexTitles] objectAtIndex:section];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[self currentViewModel] endEditingState];
}

#pragma mark - UITableViewDataSource
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self currentViewModel] sectionIndexTitles];
}

@end
