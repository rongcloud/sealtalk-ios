//
//  RCDMessageDigestCell.m
//  SealTalk
//
//  Created by RobinCui on 2022/8/3.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDMessageDigestCell.h"
#import <Masonry/Masonry.h>

NSString *const RCDMessageDigestCellIdentifier = @"RCDMessageDigestCellIdentifier";

@interface RCDMessageDigestCell()
@property (nonatomic, strong, readwrite) UILabel *labUser;
@property (nonatomic, strong, readwrite) UILabel *labTime;
@property (nonatomic, strong, readwrite) UILabel *labContent;
@end


@implementation RCDMessageDigestCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.labUser = [UILabel new];
    
    self.labTime = [UILabel new];
    self.labTime.textAlignment = NSTextAlignmentRight;
    
    self.labContent = [UILabel new];
    self.labContent.numberOfLines = 0;
    
    [self.contentView addSubview:self.labUser];
    [self.labUser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(12);
        make.top.mas_equalTo(self.contentView).mas_offset(8);
    }];
    
    [self.contentView addSubview:self.labTime];
    [self.labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).mas_offset(-12);
        make.top.mas_equalTo(self.contentView).mas_offset(8);
    }];
    
    [self.contentView addSubview:self.labContent];
    [self.labContent mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.labUser.mas_bottom).mas_offset(8);
        make.left.mas_equalTo(self.labUser).mas_offset(12);
        make.right.mas_equalTo(self.labTime).mas_offset(-12);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-8);
    }];
}
@end
