//
//  RCDTranslationLanguageViewController.m
//  SealTalk
//
//  Created by RobinCui on 2022/2/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDTranslationLanguageViewController.h"

static NSString * const RCDTranslationLanguageCellIndeitifier = @"RCDTranslationLanguageCellIndeitifier";
@interface RCDTranslationLanguageViewController ()
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) void(^userSelected)(NSString *);
@property (nonatomic, strong) NSDictionary *languagesInfo;
@property (nonatomic, strong) NSArray *languages;
@end

@implementation RCDTranslationLanguageViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
                     language:(NSString *)language
                languagesInfo:(NSDictionary *)info
                   completion:(void(^)(NSString *))completion {
    self = [super initWithStyle:style];
    if (self) {
        self.userSelected = completion;
        self.language = language;
        self.languagesInfo = info;
        self.languages = [self.languagesInfo allKeys];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
        __weak __typeof(self)weakSelf = self;
        self.languages = [self.languages sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            NSString *value1 = weakSelf.languagesInfo[obj1];
            NSString *value2 = weakSelf.languagesInfo[obj2];
        return [value1 localizedCompare:value2];
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.languages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDTranslationLanguageCellIndeitifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:RCDTranslationLanguageCellIndeitifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *key = [self.languages objectAtIndex:indexPath.row];
    cell.textLabel.text = self.languagesInfo[key];
    if ([self.language isEqualToString:key]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.language) {
        NSInteger index = [self.languages indexOfObject:self.language];
        if (index == indexPath.row) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSString *key = [self.languages objectAtIndex:indexPath.row];
    [self languageDidSelect:key];
    
}

#pragma mark -- Private
- (void)languageDidSelect:(NSString *)language {
    self.language = language;
    if (self.userSelected) {
        self.userSelected(language);
    }
    dispatch_after(0.45, dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

@end
