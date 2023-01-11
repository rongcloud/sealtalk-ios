//
//  RCDDebugUltraGroupChatSearchViewController.m
//  SealTalk
//
//  Created by shuai shao on 2022/12/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDDebugUltraGroupChatSearchViewController.h"

#import "RCDSearchBar.h"
#import "RCDTableView.h"
#import "UIColor+RCColor.h"
#import "RCDSearchMoreViewCell.h"
#import "RCDSearchResultViewCell.h"

#import "RCDSearchResultModel.h"
#import "RCDDebugUlTraGroupChatViewController.h"

@interface RCDDebugUltraGroupChatSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *resultArray;
@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) RCDTableView *resultTableView;

@end

@implementation RCDDebugUltraGroupChatSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.resultArray = [NSMutableArray array];

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMessage *result = self.resultArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *title = @"消息";
    if ([result.objectName isEqualToString:@"RC:TxtMsg"]) {
        title = [(RCTextMessage *)result.content content];
    }
    cell.textLabel.text = title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.resultArray removeAllObjects];
    
    if (self.channelId.length == 0) {
        NSArray *results = [[RCChannelClient sharedChannelManager] searchMessagesForAllChannel:ConversationType_ULTRAGROUP
                                                                                      targetId:self.targetId
                                                                                       keyword:searchText
                                                                                         count:10
                                                                                     startTime:0];
        [self.resultArray addObjectsFromArray:results];
    } else {
        NSArray *results = [[RCChannelClient sharedChannelManager] searchMessages:ConversationType_ULTRAGROUP
                                                                         targetId:self.targetId
                                                                        channelId:self.channelId
                                                                          keyword:searchText
                                                                            count:10
                                                                        startTime:0];
        [self.resultArray addObjectsFromArray:results];
    }
    
    [self.resultTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
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
    [self dismissViewControllerAnimated:YES completion:nil];
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
        _resultTableView = [[RCDTableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
        _resultTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
        _resultTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
        _resultTableView.backgroundColor = RCDDYCOLOR(0xffffff, 0x191919);
        _resultTableView.delegate = self;
        _resultTableView.dataSource = self;
        [_resultTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    return _resultTableView;
}

- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        CGRect frame = CGRectMake(0, 0, self.searchView.frame.size.width - 75, 44);
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

@end
