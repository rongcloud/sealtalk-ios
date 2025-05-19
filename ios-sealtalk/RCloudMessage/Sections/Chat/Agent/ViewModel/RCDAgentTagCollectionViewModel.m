//
//  RCDAgentTagCollectionViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/4/11.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCDAgentTagCollectionViewModel.h"
#import "RCDAgentContext.h"
#import "RCDAgentTagCollectionCellViewModel.h"
#import "RCDAgentTagCollectionViewCell.h"
#import "RCDAgentTagCollectionCellViewModel.h"

@interface RCDAgentTagCollectionViewModel()
@property (nonatomic, strong) RCDAgentTag *currentTag;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation RCDAgentTagCollectionViewModel

- (instancetype)initWithIdentifier:(RCConversationIdentifier*)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.currentTag = [RCDAgentContext agentTagFor:identifier];
        [self fetchData];
    }
    return self;
}

- (void)fetchData {
    NSMutableArray *tmp = [NSMutableArray array];
    NSArray *array = [RCDAgentContext agentTags];
    for (int i = 0; i<array.count; i++) {
        RCDAgentTag *tag = array[i];
        if (i == 0 && !self.currentTag) {
            self.currentTag = tag;
        }
        RCDAgentTagCollectionCellViewModel *vm = [[RCDAgentTagCollectionCellViewModel alloc] initWithTag:tag];
        if ([tag.agentID isEqualToString:self.currentTag.agentID]) {
            vm.selected = YES;
            [RCDAgentContext saveAgentTag:vm.tag forIdentifier:self.identifier];
        }
        [tmp addObject:vm];
    }
    self.dataSource = tmp;
}

- (CGFloat)cellHeight {
    NSInteger count = self.dataSource.count;
    CGFloat rowHeight = 42;
    NSInteger row = count / 3;
    if (count % 3 != 0) {
        row += 1;
    }
    
    CGFloat height = 50 + rowHeight*row + 20;
    if (row > 1) {
        height += (row-1)*12;
    }
    return height;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < self.dataSource.count ; i++) {
        RCDAgentTagCollectionCellViewModel *vm = self.dataSource[i];
        if (i == indexPath.row) {
            vm.selected = YES;
            [RCDAgentContext saveAgentTag:vm.tag forIdentifier:self.identifier];
        } else {
            vm.selected = NO;
        }
    }
    [collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCDAgentTagCollectionCellViewModel *vm = self.dataSource[indexPath.row];
    RCDAgentTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RCDAgentTagCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell updateCellWithViewModel:vm];
    return cell;
}

@end
