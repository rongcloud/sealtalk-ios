//
//  RCNDPreinstallPhotoViewController.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/21.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDPreinstallPhotoViewController.h"
#import "RCNDPreinstallPhotoView.h"
#import "RCNDPreinstallPhotoViewModel.h"
#import "RCNDBackgroundDetailViewController.h"


@interface RCNDPreinstallPhotoViewController()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) RCNDPreinstallPhotoView *photoView;
@property (nonatomic, strong) RCNDPreinstallPhotoViewModel *viewModel;

@end

@implementation RCNDPreinstallPhotoViewController

- (void)loadView {
    self.view = self.photoView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel refresh];
    [self.photoView.collectionView reloadData];
}

- (void)setupView {
    [super setupView];
    self.title = RCDLocalizedString(@"ConversationBGPreinstalled");
    [self configureLeftBackButton];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RCNDPreinstallPhotoCellViewModel *vm = self.viewModel.dataSource[indexPath.row];
    RCNDBackgroundDetailViewController *detailVC = [[RCNDBackgroundDetailViewController alloc] initWithViewModel:vm];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCNDPreinstallPhotoCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:RCNDPreinstallPhotoCellIdentifier forIndexPath:indexPath];
    RCNDPreinstallPhotoCellViewModel *vm = self.viewModel.dataSource[indexPath.row];
    [cell updateWithViewModel:vm];
    return cell;
}

- (RCNDPreinstallPhotoView *)photoView {
    if (!_photoView) {
        _photoView = [RCNDPreinstallPhotoView new];
        [_photoView.collectionView registerClass:[RCNDPreinstallPhotoCell class] forCellWithReuseIdentifier:RCNDPreinstallPhotoCellIdentifier];
        _photoView.collectionView.delegate = self;
        _photoView.collectionView.dataSource = self;
    }
    return _photoView;
}

- (RCNDPreinstallPhotoViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [RCNDPreinstallPhotoViewModel new];
    }
    return _viewModel;
}
@end
