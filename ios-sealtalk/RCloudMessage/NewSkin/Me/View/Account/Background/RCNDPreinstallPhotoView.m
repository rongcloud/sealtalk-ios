//
//  RCNDPreinstallPhotoView.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDPreinstallPhotoView.h"

@implementation RCNDPreinstallPhotoView


- (void)setupView {
    [super setupView];
    [self addSubview:self.collectionView];
    
}

- (void)setupConstraints {
    [super setupConstraints];
    [NSLayoutConstraint activateConstraints:@[
            [self.collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor ],
            [self.collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor ],
            [self.collectionView.topAnchor constraintEqualToAnchor:self.topAnchor constant:RCUserManagementPadding],
            [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-RCUserManagementPadding]
        ]];

}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat widthScale = RCDScreenWidth / 375;
        flowLayout.itemSize = CGSizeMake(114 * widthScale, 152 * widthScale);
        flowLayout.minimumLineSpacing = 6.5;
        CGFloat space = (RCDScreenWidth - 114 * widthScale * 3 - 7) / 4 / 2;
        flowLayout.minimumInteritemSpacing = 6;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, space, 15.0, space);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollEnabled = YES;
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _collectionView;
}
@end
