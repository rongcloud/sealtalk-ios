//
//  RCNDSearchResultCellViewModel.m
//  SealTalk
//
//  Created by RobinCui on 2025/12/3.
//  Copyright © 2025 RongCloud. All rights reserved.
//

#import "RCNDSearchResultCellViewModel.h"
#import "RCDUtilities.h"
#import <RongIMKit/RCKitCommonDefine.h>

@implementation RCNDSearchResultCellViewModel

- (NSMutableAttributedString *)attributedTextWith:(NSString *)textString
                                  highlightedText:(NSString *)highlightedText {
    NSRange range = [self getRange:highlightedText inText:textString];
    NSString *string = [self isBeyond:textString range:range];
    if (![string isEqualToString:textString]) {
        range = [self getRange:highlightedText inText:string];
    }

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];

    [attributedString addAttribute:NSForegroundColorAttributeName value:
     RCDynamicColor(@"primary_color",@"0x0099ff", @"0x0099ff") range:range];
    return attributedString;
}

- (NSRange)getRange:(NSString *)searchText inText:(NSString *)text {
    NSRange range = NSMakeRange(0, 0);
    NSString *twoStr = [[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    if ([[text lowercaseString] containsString:[searchText lowercaseString]]) {
        range = [[text lowercaseString] rangeOfString:[searchText lowercaseString]];
    } else if ([[text lowercaseString] containsString:twoStr]) {
        range = [[text lowercaseString] rangeOfString:twoStr];
    } else if ([[[RCDUtilities hanZiToPinYinWithString:text] lowercaseString] containsString:twoStr]) {
        NSString *str = [RCDUtilities hanZiToPinYinWithString:text];
        range = [str rangeOfString:[searchText uppercaseString]];
    }
    return range;
}

- (NSString *)isBeyond:(NSString *)text range:(NSRange)range {
    NSString *string = nil;
    if (range.location + range.length < 16) {
        self.lineBreakMode = NSLineBreakByTruncatingTail;
        string = text;
    } else if (text.length - range.location < 16) {
        self.lineBreakMode = NSLineBreakByTruncatingHead;
        string = text;
    } else {
        self.lineBreakMode = NSLineBreakByTruncatingTail;
        if (range.length > 16) {
            string = [self
                relaceEnterBySpace:[NSString
                                       stringWithFormat:@"...%@", [text substringWithRange:NSMakeRange(range.location,
                                                                                                       range.length)]]];
        } else {
            string = [self
                relaceEnterBySpace:[NSString
                                       stringWithFormat:@"...%@",
                                                        [text substringWithRange:NSMakeRange(
                                                                                     range.location -
                                                                                         (16 - range.length) / 2,
                                                                                     text.length -
                                                                                         (range.location -
                                                                                          (16 - range.length) / 2))]]];
        }
    }
    return string;
}

- (NSString *)relaceEnterBySpace:(NSString *)originalString {
    NSString *string = [originalString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    return string;
}

@end
