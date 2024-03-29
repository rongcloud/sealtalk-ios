//
//  RCDShareChatListController.m
//  RCloudMessage
//
//  Created by 张改红 on 16/8/4.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDShareChatListController.h"
#import "RCDShareChatListCell.h"

@interface RCDShareChatListController ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@end

#define ReuseIdentifier @"cellReuseIdentifier"
#define RCDLocalizedString(key) NSLocalizedStringFromTable(key, @"SealTalk", nil)

@implementation RCDShareChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"choose");

    self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"send")
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(sendMessageTofriend:)];
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    if (self.titleString != nil && self.contentString != nil && self.imageString != nil && self.url != nil) {
        self.rightBarButton.enabled = YES;
    } else {
        self.rightBarButton.enabled = NO;
    }
    self.tableView.tableFooterView = [UIView new];
    NSURL *groupURL = [[NSFileManager defaultManager]
        containerURLForSecurityApplicationGroupIdentifier:MCShareExtensionKey];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"rongcloudShare.plist"];
    self.dataArray = [NSArray arrayWithContentsOfURL:fileURL];
    [self.tableView registerClass:[RCDShareChatListCell class] forCellReuseIdentifier:ReuseIdentifier];
}

- (void)enableSendMessage:(BOOL)sender {
    if (sender && self.selectIndexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.rightBarButton.enabled = YES;
        });
    }
}

- (void)sendMessageTofriend:(id)sender {
    NSDictionary *dic = self.dataArray[self.selectIndexPath.row];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:MCShareExtensionKey];
    NSString *demoServer = [userDefaults valueForKey:@"RCDDemoServer"];
    NSString *cookie = [userDefaults valueForKey:@"Cookie"];

    // 1.创建URL
    NSString *urlStr = [NSString stringWithFormat:@"%@misc/send_message", demoServer];
    NSURL *url = [NSURL URLWithString:urlStr];

    // 2.准备请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setHTTPMethod:@"POST"];


    [request setValue:cookie forHTTPHeaderField:@"Cookie"];

    request.HTTPShouldHandleCookies = YES;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // 3.准备参数
    NSString *objectName = @"RC:ImgTextMsg";
    NSDictionary *messageContentDict = @{
        @"title" : self.titleString,
        @"content" : self.contentString,
        @"imageUri" : self.imageString,
        @"url" : self.url,
    };
    NSString *conversationType = nil;
    if ([dic[@"conversationType"] intValue] == 1) {
        conversationType = @"PRIVATE";
    } else {
        conversationType = @"GROUP";
    }
    NSDictionary *sendMessageDict = @{
        @"conversationType" : conversationType,
        @"targetId" : dic[@"targetId"],
        @"objectName" : objectName,
        @"content" : messageContentDict
    };

    NSString *time = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
    NSDictionary *insertMessageDict = @{
        @"conversationType" : dic[@"conversationType"],
        @"targetId" : dic[@"targetId"],
        @"title" : self.titleString,
        @"content" : self.contentString,
        @"imageURL" : self.imageString,
        @"url" : self.url,
        @"objectName" : @"RC:ImgTextMsg",
        @"sharedTime" : time
    };

    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:sendMessageDict options:0 error:nil]];
    [request setTimeoutInterval:10.0];
    self.rightBarButton.title = RCDLocalizedString(@"sending");
    self.rightBarButton.enabled = NO;

    // 4.建立连接
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSString *notify = nil;
                               if (!connectionError) {
                                   NSUserDefaults *shareUserDefaults =
                                       [[NSUserDefaults alloc] initWithSuiteName:MCShareExtensionKey];
                                   NSMutableArray *array = [NSMutableArray
                                       arrayWithArray:[shareUserDefaults valueForKey:@"sharedMessages"]];
                                   [array addObject:insertMessageDict];
                                   [shareUserDefaults setValue:array forKey:@"sharedMessages"];
                                   [shareUserDefaults synchronize];
                                   notify = RCDLocalizedString(@"send_success");
                               } else {
                                   notify = RCDLocalizedString(@"send_fail");
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   UIAlertController *alertController =
                                       [UIAlertController alertControllerWithTitle:@""
                                                                           message:notify
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                   [self presentViewController:alertController animated:YES completion:nil];
                                   [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                    target:self
                                                                  selector:@selector(creatAlert:)
                                                                  userInfo:alertController
                                                                   repeats:NO];
                               });
                           }];
}

- (void)creatAlert:(NSTimer *)timer {
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDShareChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[RCDShareChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = self.dataArray[indexPath.row];
    [cell setDataDic:dic];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDShareChatListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES animated:YES];
    self.selectIndexPath = indexPath;
    if (self.titleString != nil && self.contentString != nil && self.imageString != nil && self.url != nil) {
        self.rightBarButton.enabled = YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

@end
