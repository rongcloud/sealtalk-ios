//
//  RCDUGChannelSettingCell.m
//  SealTalk
//
//  Created by RobinCui on 2022/6/21.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUGChannelSettingCell.h"
#import <Masonry/Masonry.h>

NSString * const RCDUGChannelSettingCellIdentifier = @"RCDUGChannelSettingCellIdentifier";

@interface RCDUGChannelSettingCell()
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *subtitleLab;
@end

@implementation RCDUGChannelSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellWith:(NSString *)title subtitle:(NSString *)subtitle {
    self.titleLab.text = title;
    self.subtitleLab.text = subtitle;
}

- (void)setupView {
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).mas_offset(12);
    }];
    
    [self.contentView addSubview:self.subtitleLab];
    [self.subtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-12);
        make.centerY.mas_equalTo(self);
    }];
}

- (UILabel *)subtitleLab {
    if (!_subtitleLab) {
        _subtitleLab = [UILabel new];
        _subtitleLab.font = [UIFont systemFontOfSize:14];
        _subtitleLab.textAlignment = NSTextAlignmentRight;
        _subtitleLab.textColor = [UIColor darkGrayColor];
    }
    return _subtitleLab;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.textColor = [UIColor blackColor];
    }
    return _titleLab;
}

@end
