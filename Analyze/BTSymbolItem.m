//
//  BTSymbolItem.m
//  Analyze
//
//  Created by mamba on 2016/9/27.
//  Copyright © 2016年 BT77.Inc. All rights reserved.
//

#import "BTSymbolItem.h"

@implementation BTSymbolItem

- (void)setFileName:(NSString *)fileName {
    if (!fileName) {
        return;
    }
    _fileName = [[fileName componentsSeparatedByString:@"/"] lastObject];
    if ([_fileName containsString:@")"]) {
        NSString *temp = [_fileName stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSRange range = [temp rangeOfString:@"("];
        _fileName = [temp substringFromIndex:range.location+1];
        _moduleName = [temp substringToIndex:range.location];
    }
}

- (void)setSize:(NSUInteger)size {
    _size = size;

    _sizeString = [NSString stringWithFormat:@"%lu", (unsigned long)_size];
}

@end
