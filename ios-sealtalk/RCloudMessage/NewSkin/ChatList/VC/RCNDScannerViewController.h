//
//  RCNDSScanViewController.h
//  SealTalk
//
//  Created by RobinCui on 2025/12/1.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDBaseViewController.h"
#import "RCNDScannerViewModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface RCNDScannerViewController : RCNDBaseViewController
@property (nonatomic, weak) id<RCNDScannerViewModelDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
