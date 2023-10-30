//
//  RCDDebugSliceResumeDownloadVC.m
//  SealTalk
//
//  Created by Lang on 2023/9/7.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDDebugSliceResumeDownloadVC.h"
#import <Masonry/Masonry.h>

@interface RCDDebugSliceResumeDownloadVC ()

@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation RCDDebugSliceResumeDownloadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"分片断点续传测试";
    
    [self setupSubviews];
    
    RCMediaMessageContent *content = (RCMediaMessageContent *)self.messageModel.content;
    if ([[NSFileManager defaultManager] fileExistsAtPath:content.localPath]) {
        self.clearButton.hidden = NO;
        self.playButton.hidden = NO;
        self.progressLabel.text = @"已下载";
        self.startButton.enabled = NO;
    }
}

- (void)setupSubviews {
    [self.view addSubview:self.progressLabel];
    [self.view addSubview:self.startButton];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.pauseButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.clearButton];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(140, 20));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).mas_offset(20);
    }];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.progressLabel.mas_bottom).mas_offset(40);
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.startButton.mas_bottom).mas_offset(40);
    }];
    [self.pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.cancelButton.mas_bottom).mas_offset(40);
    }];
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.pauseButton.mas_bottom).mas_offset(40);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.clearButton.mas_bottom).mas_offset(40);
    }];
}

- (void)startButtonAction:(UIButton *)button {
//    self.startButton.enabled = NO;
    RCMessage *message = [self getMessageWithModel:self.messageModel];
    
    [[RCCoreClient sharedCoreClient] downloadMediaMessage:message progressBlock:^(int progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressLabel.text = [NSString stringWithFormat:@"下载进度: %@ %%", @(progress)];
        });
    } successBlock:^(NSString * _Nonnull mediaPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self success:mediaPath];
        });
    } errorBlock:^(RCErrorCode errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressLabel.text = [NSString stringWithFormat:@"下载失败:%@", @(errorCode)];
        });
    } cancelBlock:^{
        
    }];
}

- (void)cancelButtonAction:(UIButton *)button {
    self.startButton.enabled = YES;
    RCMessage *message = [self getMessageWithModel:self.messageModel];
    
    [[RCCoreClient sharedCoreClient] cancelDownloadMediaMessage:message successBlock:^{
        self.progressLabel.text = @"取消成功";
    } errorBlock:^(RCErrorCode errorCode) {
        self.progressLabel.text = [NSString stringWithFormat:@"取消失败: %@", @(errorCode)];
    }];
}

- (void)pauseButtonAction:(UIButton *)button {
    self.startButton.enabled = YES;
    RCMessage *message = [self getMessageWithModel:self.messageModel];
    
    [[RCCoreClient sharedCoreClient] pauseDownloadMediaMessage:message successBlock:^{
        self.progressLabel.text = @"暂停成功";
    } errorBlock:^(RCErrorCode errorCode) {
        self.progressLabel.text = [NSString stringWithFormat:@"暂停失败: %@", @(errorCode)];
    }];
}

- (void)playButtonAction:(UIButton *)button {
    if (self.playAction) {
        self.playAction(self.messageModel);
    }
}

- (void)clearButtonAction:(UIButton *)button {
    RCMediaMessageContent *content = (RCMediaMessageContent *)self.messageModel.content;
    if (content.localPath) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:content.localPath error:&error];
        if (error) {
            self.progressLabel.text = @"删除文件失败";
            return;
        }
    }
    content.localPath = @"";
    self.progressLabel.text = @"";
    self.clearButton.hidden = YES;
    self.playButton.hidden = YES;
    self.startButton.enabled = YES;
}

- (void)success:(NSString *)mediaPath {
    RCMediaMessageContent *content = (RCMediaMessageContent *)self.messageModel.content;
    content.localPath = mediaPath;
    self.playButton.hidden = NO;
    self.clearButton.hidden = NO;
}

- (RCMessage *)getMessageWithModel:(RCMessageModel *)model {
    RCMessage *message = [[RCMessage alloc] initWithType:model.conversationType
                                                targetId:model.targetId
                                               direction:model.messageDirection
                                                 content:model.content];
    message.messageId = model.messageId;
    message.messageUId = model.messageUId;
    return message;
}

#pragma mark - getter

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.text = @"下载进度: ";
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.textColor = [UIColor blueColor];
    }
    return _progressLabel;
}

- (UIButton *)startButton {
    if (!_startButton) {
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startButton setTitle:@"开始" forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _startButton.backgroundColor = [UIColor blueColor];
        [_startButton addTarget:self action:@selector(startButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor blueColor];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        _pauseButton.backgroundColor = [UIColor blueColor];
        [_pauseButton addTarget:self action:@selector(pauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseButton;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _clearButton.hidden = YES;
        [_clearButton setTitle:@"删除文件" forState:UIControlStateNormal];
        _clearButton.backgroundColor = [UIColor blueColor];
        [_clearButton addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.hidden = YES;
        [_playButton setTitle:@"播放" forState:UIControlStateNormal];
        _playButton.backgroundColor = [UIColor blueColor];
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}



@end
