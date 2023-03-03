//
//  RCDUserGroupMemberCell.m
//  SealTalk
//
//  Created by RobinCui on 2023/1/11.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupMemberCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface RCDUserGroupMemberCell()
@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, strong) UILabel *labName;
@end

@implementation RCDUserGroupMemberCell
NSString  * const RCDUserGroupMemberCellIdentifier = @"RCDUserGroupMemberCellIdentifier";


+ (instancetype)memberCell:(UITableView *)tableView
              forIndexPath:(NSIndexPath *)indexPath {
    RCDUserGroupMemberCell *cell = [tableView  dequeueReusableCellWithIdentifier:RCDUserGroupMemberCellIdentifier
                                               forIndexPath:indexPath];
    
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).mas_offset(16);
        make.top.mas_equalTo(self.contentView).mas_offset(8);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-8);
        make.width.height.mas_equalTo(44);
    }];
    
    [self.contentView addSubview:self.labName];
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.imgView);
            make.leading.mas_equalTo(self.imgView.mas_trailing).mas_offset(20);
    }];
}

- (void)updateCell:(RCDUserGroupMemberInfo *)info {
    self.labName.text = [NSString stringWithFormat:@"%@ -> %@", info.name, info.userID];
    if (info.portrait) {
        NSURL *url = [NSURL URLWithString:info.portrait];
        [self.imgView sd_setImageWithURL:url];
    }
    self.accessoryType = info.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.layer.cornerRadius =  22;
        _imgView.layer.masksToBounds = YES;
    }
    return _imgView;
}

- (UILabel *)labName {
    if (!_labName) {
        _labName = [UILabel new];
    }
    return _labName;
}
@end
