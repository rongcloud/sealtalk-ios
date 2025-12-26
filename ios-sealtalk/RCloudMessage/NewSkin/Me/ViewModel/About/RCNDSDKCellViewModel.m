//
//  RCNDSDKCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/11/24.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSDKCellViewModel.h"

NSInteger RCNDSDKCellViewModelMaxCount = 5;

@interface RCNDSDKCellViewModel()
@property (nonatomic, strong) NSMutableArray *touchCounter;
/// GCD 延迟任务句柄（用于取消）
@property (nonatomic, strong) dispatch_block_t touchesTimerBlock;
@end

@implementation RCNDSDKCellViewModel

- (void)itemDidSelectedByViewController:(UIViewController *)vc {
    if (self.touchCounter.count >= RCNDSDKCellViewModelMaxCount) {
        if (self.tapBlock) {
            self.tapBlock(vc);
        }
    } else {
        [self activeDelayBlockIfNeed];
        [self.touchCounter addObject:@(1)];
    }
}

- (void)activeDelayBlockIfNeed {
    if (self.touchCounter.count != 0) {
        return;
    }
    if (self.touchesTimerBlock) {
        dispatch_block_cancel(self.touchesTimerBlock);
        self.touchesTimerBlock = nil;
    }
    
    // 创建新的延迟任务
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = dispatch_block_create(0, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf clean];
        }
    });
    
    self.touchesTimerBlock = block;
    // 延迟执行（在锁外安排，避免阻塞）
    NSTimeInterval delay = 5;  // 直接访问 ivar，因为在锁内
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   block);
}
    
- (void)clean {
    [self.touchCounter removeAllObjects];
    if (self.touchesTimerBlock) {
        dispatch_block_cancel(self.touchesTimerBlock);
        self.touchesTimerBlock = nil;
    }
    
}
- (NSMutableArray *)touchCounter {
    if (!_touchCounter) {
        _touchCounter = [NSMutableArray array];
    }
    return _touchCounter;
}
@end
