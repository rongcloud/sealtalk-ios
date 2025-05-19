//
//  RCDAgentTagViewCell.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentTagViewCell.h"
#import "RCDAgentTagCollectionViewCell.h"
#import "RCDAgentTagCollectionViewModel.h"

NSString  * const RCDAgentTagViewCellIdentifier = @"RCDAgentTagViewCellIdentifier";

@interface RCDAgentTagViewCell()
@property (nonatomic, strong) RCDAgentTagCollectionView *collectionView;
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) RCDAgentTagCollectionViewModel *viewModel;
@end

@implementation RCDAgentTagViewCell

- (void)setupView {
    [super setupView];
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.labTitle];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.labTitle.frame = CGRectMake(12, 20, self.labTitle.frame.size.width, self.labTitle.frame.size.height);
    CGFloat yOffset = self.labTitle.frame.origin.y +self.labTitle.frame.size.height;
    self.collectionView.frame = CGRectMake(0, yOffset, self.bounds.size.width, self.bounds.size.height-yOffset-20);
}

- (void)updateCellWithViewModel:(RCDAgentTagCollectionViewModel *)viewModel {
    if ([viewModel isKindOfClass:[RCDAgentTagCollectionViewModel class]]) {
        self.viewModel = viewModel;
        self.collectionView.dataSource = viewModel;
        self.collectionView.delegate = viewModel;
        [self.collectionView reloadData];
    }

}

- (RCDAgentTagCollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(100, 42);
        layout.minimumLineSpacing = 12;
        _collectionView = [[RCDAgentTagCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[RCDAgentTagCollectionViewCell class] forCellWithReuseIdentifier:RCDAgentTagCollectionViewCellIdentifier];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInset = UIEdgeInsetsMake(8, 12, 8, 12);
        _collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}

- (UILabel *)labTitle {
    if (!_labTitle) {
        UILabel *lab = [UILabel new];
        lab.text = RCDLocalizedString(@"agent_style");
        lab.font = [UIFont systemFontOfSize:16];
        [lab sizeToFit];
        _labTitle = lab;
    }
    return _labTitle;
}
@end
