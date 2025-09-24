//
//  RCDSearchViewController.m
//  RCloudMessage
//
//  Created by 张改红 on 16/9/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchViewController.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDLabel.h"
#import "RCDSearchBar.h"
#import "RCDSearchDataManager.h"
#import "RCDSearchMoreController.h"
#import "RCDSearchMoreViewCell.h"
#import "RCDSearchResultModel.h"
#import "RCDSearchResultViewCell.h"
#import "UIColor+RCColor.h"
#import "RCDLanguageManager.h"
#import "RCDTableView.h"
#import "RCDSemanticContext.h"
@interface RCDSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,
                                       UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableDictionary *resultDictionary;
@property (nonatomic, strong) NSMutableArray *groupTypeArray;
@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) RCDTableView *resultTableView;
@property (nonatomic, strong) RCDLabel *emptyLabel;
@end

@implementation RCDSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.groupTypeArray = [NSMutableArray array];
    self.resultDictionary = [NSMutableDictionary dictionary];

    [self loadSearchView];

    self.navigationItem.titleView = self.searchView;

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSerchBarWhenTapBackground:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.resultTableView.frame = self.view.bounds;
    //隐藏导航栏下那条线
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)loadSearchView {
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 44)];

    [self.view addSubview:self.resultTableView];
    [self.searchView addSubview:self.searchBar];

    [self.searchView addSubview:self.cancelButton];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.groupTypeArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.resultDictionary[self.groupTypeArray[section]];
    if (array.count > 3) {
        return 4;
    }
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        RCDSearchMoreViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreCell"];
        if (!cell) {
            cell = [[RCDSearchMoreViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"moreCell"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (self.groupTypeArray.count > indexPath.section) {
            cell.moreLabel.text =
                [NSString stringWithFormat:RCDLocalizedString(@"see_more"), self.groupTypeArray[indexPath.section]];
        }
        return cell;
    } else {
        RCDSearchResultViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[RCDSearchResultViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        if (self.groupTypeArray.count > indexPath.section) {
            NSArray *array = self.resultDictionary[self.groupTypeArray[indexPath.section]];
            cell.searchString = self.searchBar.text;
            if (array.count > indexPath.row) {
                [cell setDataModel:array[indexPath.row]];
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return SearchMoreViewCellHeight;
    }
    return [RCDSearchResultViewCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor = RCDYCOLOR(0xffffff, 0x191919);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, view.frame.size.height)];
    label.font = [UIFont systemFontOfSize:14.];
    label.text = self.groupTypeArray[section];
    label.textColor = RCDDYCOLOR(0x999999, 0x8B8B8B);
    [view addSubview:label];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == self.groupTypeArray.count - 1) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor = RCDDYCOLOR(0xf5f6f9, 0x111111);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.groupTypeArray.count - 1) {
        return 0;
    }
    return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    NSString *type = self.groupTypeArray[indexPath.section];
    NSArray *array = self.resultDictionary[type];
    if (indexPath.row == 3) {
        [self pushToSearchMoreVC:type result:array];
    } else {
        if (array.count > indexPath.row) {
            RCDSearchResultModel *model = array[indexPath.row];
            if (model.count > 1) {
                [self pushToSearchMoreMessageVC:model];
                return;
            } else {
                [self pushToChatVC:model];
            }
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.resultDictionary removeAllObjects];
    [self.groupTypeArray removeAllObjects];
    [[RCDSearchDataManager sharedInstance] searchDataWithSearchText:searchText
                                                       bySearchType:RCDSearchAll
                                                           complete:^(NSDictionary *dic, NSArray *array) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [self.resultDictionary setDictionary:dic];
                                                                   [self.groupTypeArray setArray:array];
                                                                   [self refreshSearchView:searchText];
                                                               });
                                                           }];
}

- (void)pushToSearchMoreVC:(NSString *)type result:(NSArray *)results {
    RCDSearchMoreController *viewController = [[RCDSearchMoreController alloc] init];
    viewController.searchString = self.searchBar.text;
    viewController.type = type;
    viewController.resultArray = results;
    __weak typeof(self) weakSelf = self;
    [viewController setCancelBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf cancelButtonClicked];
        });
    }];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pushToSearchMoreMessageVC:(RCDSearchResultModel *)model {
    RCDSearchMoreController *viewController = [[RCDSearchMoreController alloc] init];
    viewController.searchString = self.searchBar.text;
    viewController.type = [NSString stringWithFormat:RCDLocalizedString(@"total_related_message"), model.count];
    NSArray *msgArray = [[RCCoreClient sharedCoreClient] searchMessages:model.conversationType
                                                             targetId:model.targetId
                                                              keyword:self.searchBar.text
                                                                count:model.count
                                                            startTime:0];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (RCMessage *message in msgArray) {
        RCDSearchResultModel *messegeModel = [RCDSearchResultModel modelForMessage:message];
        messegeModel.searchType = model.searchType;
        [resultArray addObject:messegeModel];
    }
    viewController.title = model.name;
    viewController.isShowSeachBar = NO;
    viewController.resultArray = resultArray;
    __weak typeof(self) weakSelf = self;
    [viewController setCancelBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf cancelButtonClicked];
        });
    }];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pushToChatVC:(RCDSearchResultModel *)model {
    RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
    _conversationVC.conversationType = model.conversationType;
    _conversationVC.targetId = model.targetId;
    _conversationVC.title = model.name;
    NSArray *array = [[RCCoreClient sharedCoreClient] searchMessages:model.conversationType
                                                          targetId:model.targetId
                                                           keyword:self.searchBar.text
                                                             count:model.count
                                                         startTime:0];
    if (array.count != 0) {
        RCMessage *message = [array firstObject];
        _conversationVC.locatedMessageSentTime = message.sentTime;
    }
    int unreadCount = [[RCCoreClient sharedCoreClient] getUnreadCount:model.conversationType targetId:model.targetId];
    _conversationVC.unReadMessage = unreadCount;
    _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
    _conversationVC.enableUnreadMessageIcon = YES;
    //如果是单聊，不显示发送方昵称
    if (model.conversationType == ConversationType_PRIVATE) {
        _conversationVC.displayUserNameInCell = NO;
    }
    [self.navigationController pushViewController:_conversationVC animated:YES];
}

- (void)refreshSearchView:(NSString *)searchText {
    [self.resultTableView reloadData];
    NSString *searchStr = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!self.groupTypeArray.count && searchText.length > 0 && searchStr.length > 0) {
        NSString *text = RCDLocalizedString(@"no_search_result");
        NSString *str = [NSString stringWithFormat:text, searchText];
        self.emptyLabel.textColor = RCDDYCOLOR(0x999999, 0x8b8b8b);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        int index = 0;
        NSString *currentlanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
        if ([currentlanguage isEqualToString:@"en"]) {
            index = 24;
        } else if ([currentlanguage isEqualToString:@"zh-Hans"]) {
            index = 6;
        } else {
            NSLog(@"%s 不支持当前语言的高亮显示", __func__);
        }
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:HEXCOLOR(0x0099ff)
                                 range:NSMakeRange(index, searchText.length)];
        self.emptyLabel.attributedText = attributedString;
        CGFloat height = [self labelAdaptive:str];
        CGRect rect = self.emptyLabel.frame;
        rect.size.height = height;
        self.emptyLabel.frame = rect;
        self.emptyLabel.hidden = NO;
    } else {
        self.emptyLabel.hidden = YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (CGFloat)labelAdaptive:(NSString *)string {
    float maxWidth = self.view.frame.size.width - 20;
    CGRect textRect =
        [string boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                             options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                      NSStringDrawingUsesFontLeading)
                          attributes:@{
                              NSFontAttributeName : self.emptyLabel.font
                          }
                             context:nil];
    textRect.size.height = ceilf(textRect.size.height);
    return textRect.size.height + 5;
}

- (NSString *)changeString:(NSString *)str appendStr:(NSString *)appendStr {
    if (str.length > 0) {
        str = [NSString stringWithFormat:@"%@,%@", str, appendStr];
    } else {
        str = appendStr;
    }
    return str;
}

- (void)cancelButtonClicked {
    if ([self.delegate respondsToSelector:@selector(searchViewControllerDidClickCancel)]) {
        [self.delegate searchViewControllerDidClickCancel];
    }
    [self.searchBar resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

- (void)hideSerchBarWhenTapBackground:(id)sender {
    [self.searchBar resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - getter
- (RCDTableView *)resultTableView {
    if (!_resultTableView) {
        _resultTableView = [[RCDTableView alloc] initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
        _resultTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
        _resultTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
        _resultTableView.backgroundColor = RCDDYCOLOR(0xffffff, 0x191919);
        _resultTableView.delegate = self;
        _resultTableView.dataSource = self;
    }
    return _resultTableView;
}

- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        CGRect frame = CGRectMake(0, 0, self.searchView.frame.size.width - 75, 44);
        if ([RCDSemanticContext isRTL]) {
            frame = CGRectMake(63, 0, self.searchView.frame.size.width - 75, 44);
        }
        _searchBar = [[RCDSearchBar alloc] initWithFrame:frame];
        _searchBar.delegate = self;
        _searchBar.tintColor = [UIColor blueColor];
        [_searchBar becomeFirstResponder];
    }
    return _searchBar;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        CGRect frame = CGRectMake(CGRectGetMaxX(_searchBar.frame) - 3, CGRectGetMinY(self.searchBar.frame), 60, 44);
        if ([RCDSemanticContext isRTL]) {
            frame = CGRectMake(3, 0, 60, 44);
        }
        _cancelButton = [[UIButton alloc]
            initWithFrame:frame];
        [_cancelButton setTitle:RCDLocalizedString(@"cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:HEXCOLOR(0x0099ff) forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.];
        [_cancelButton addTarget:self
                          action:@selector(cancelButtonClicked)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[RCDLabel alloc] initWithFrame:CGRectMake(10, 45, self.view.frame.size.width - 20, 19)];
        _emptyLabel.font = [UIFont systemFontOfSize:17.f];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
        [self.resultTableView addSubview:_emptyLabel];
    }
    return _emptyLabel;
}
@end
