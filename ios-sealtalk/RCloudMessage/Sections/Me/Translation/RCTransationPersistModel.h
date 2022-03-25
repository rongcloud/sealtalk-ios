//
//  RCTransationPersistModel.h
//  RongTranslation
//
//  Created by RobinCui on 2022/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTransationPersistModel : NSObject
@property (nonatomic, copy) NSString *srcLanguage;
@property (nonatomic, copy) NSString *targetLanguage;
+ (instancetype)loadTranslationConfig;
- (void)save;
@end

NS_ASSUME_NONNULL_END
