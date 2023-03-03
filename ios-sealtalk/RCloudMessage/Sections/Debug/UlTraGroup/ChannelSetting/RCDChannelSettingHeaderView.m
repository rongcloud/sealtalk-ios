//
//  RCDChannelSettingHeaderView.m
//  SealTalk
//
//  Created by RobinCui on 2022/6/17.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDChannelSettingHeaderView.h"
#import <Masonry/Masonry.h>

NSString * const RCDChannelSettingHeaderViewIdentifier = @"RCDChannelSettingHeaderViewIdentifier";

@interface RCDChannelSettingHeaderView()
@property (nonatomic, strong, readwrite) UICollectionView *collectionView;
@end

@implementation RCDChannelSettingHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
        fl.minimumLineSpacing = 8;
        fl.minimumInteritemSpacing = 0;
        fl.sectionInset = UIEdgeInsetsMake(8, 12, 8, 12);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fl];
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
        if (@available(iOS 13.0, *)) {
            _collectionView.backgroundColor = [UIColor systemBackgroundColor];
        } else {
#endif
            _collectionView.backgroundColor = [UIColor lightGrayColor];
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
        }
#endif
    
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
    }
    
    return _collectionView;
}
@end
