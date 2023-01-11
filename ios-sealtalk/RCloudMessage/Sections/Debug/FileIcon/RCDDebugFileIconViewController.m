//
//  RCDDebugFileIconViewController.m
//  SealTalk
//
//  Created by shuai shao on 2022/12/28.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import <RongIMKit/RCKitConfig.h>
#import <RongIMKit/RCKitUtility.h>

#import "RCDDebugFileIconViewController.h"

#import "UIImage+RCImage.h"

@interface RCDDebugFileIconViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, copy) NSArray *types;

@end

@implementation RCDDebugFileIconViewController

- (NSArray *)types {
    if (!_types) {
        _types = @[
            @{
                @"title": @"图片",
                @"items": @[
                    @"bmp",@"cod",@"gif",@"ief",@"jpe",@"jpeg",@"jpg",@"jfif",@"svg",@"tif",@"tiff",@"ras",@"ico",@"pbm",@"pgm",@"png",@"pnm",@"ppm",@"xbm",@"xpm",@"xwd",@"rgb"
                ]
            },
            @{
                @"title": @"文本",
                @"items": @[
                    @"txt",@"log",@"html",@"stm",@"uls",@"bas",@"c",@"h",@"rtx",@"sct",@"tsv",@"htt",@"htc",@"etx",@"vcf"
                ]
            },
            @{
                @"title": @"视频",
                @"items": @[
                    @"rmvb",@"avi",@"mp4",@"mp2",@"mpa",@"mpe",@"mpeg",@"mpg",@"mpv2",@"mov",@"qt",@"lsf",@"lsx",@"asf",@"asr",@"asx",@"avi",@"movie",@"wmv"
                ]
            },
            @{
                @"title": @"音频",
                @"items": @[
                    @"mp3",@"au",@"snd",@"mid",@"rmi",@"aif",@"aifc",@"aiff",@"m3u",@"ra",@"ram",@"wav",@"wma"
                ]
            },
            @{
                @"title": @"Word",
                @"items": @[
                    @"doc",@"dot",@"docx"
                ]
            },
            @{
                @"title": @"Excel",
                @"items": @[
                    @"xla",@"xlc",@"xlm",@"xls",@"xlt",@"xlw",@"xlsx"
                ]
            },
        ];
    }
    return _types;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"自定义文件图标";
    self.picker = [[UIImagePickerController alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.types.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = self.types[section][@"items"];
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = self.types[section][@"title"];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor grayColor];
    label.text = title;
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = self.types[indexPath.section][@"items"];
    NSString *type = items[indexPath.row];
    //    根据indexPath准确地取出一行，而不是从cell重用队列中取出
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    cell.textLabel.text = type;
    cell.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                    darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    cell.detailTextLabel.text = @"";
    cell.textLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    cell.imageView.image = [RCKitUtility imageWithFileSuffix:type];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self pushToImagePickerController:UIImagePickerControllerSourceTypeCamera];
}

- (void)pushToImagePickerController:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = sourceType;
        } else {
            NSLog(@"模拟器无法连接相机");
        }
    } else {
        picker.sourceType = sourceType;
    }
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (![mediaType isEqual:@"public.image"]) {
        return;
    }
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    image = [UIImage image:image byScalingToSize:CGSizeMake(250, 250)];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    if (!imageData) {
        return;
    }
    
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (!indexPath) return;
    
    NSArray *items = self.types[indexPath.section][@"items"];
    NSString *type = items[indexPath.row];
    NSString *filePath = [self fileIconPath:type];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    if ([imageData writeToFile:filePath atomically:YES]) {
        NSMutableDictionary *types = [NSMutableDictionary dictionary];
        [types addEntriesFromDictionary:RCKitConfigCenter.ui.fileSuffixDictionary];
        [types setObject:filePath forKey:type];
        [RCKitConfigCenter.ui registerFileSuffixTypes:types];
    }
    
    [self.tableView reloadData];
}

- (NSString *)fileIconPath:(NSString *)type {
    NSString *folderPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    folderPath = [folderPath stringByAppendingPathComponent:@"FileIcon"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [folderPath stringByAppendingPathComponent:type];
}

@end
