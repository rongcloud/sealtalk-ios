//
//  RCNDSearchMoreView.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchMoreView.h"
@interface RCNDSearchMoreView()

@end

@implementation RCNDSearchMoreView

- (void)setupView {
    [super setupView];
    self.tableView.mj_footer = self.footer;
}

- (MJRefreshAutoNormalFooter *)footer {
    if(!_footer) {
        _footer = [[MJRefreshAutoNormalFooter alloc] init];
        _footer.refreshingTitleHidden = YES;
        _footer.automaticallyHidden = YES;
        [_footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    }
    return _footer;
}
@end
