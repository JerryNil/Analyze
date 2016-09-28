//
//  BTSymbolItem.h
//  Analyze
//
//  Created by mamba on 2016/9/27.
//  Copyright © 2016年 BT77.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTSymbolItem : NSObject

/// 所属模块名
@property (readwrite, nonatomic, copy) NSString *moduleName;
/// 文件名
@property (readwrite, nonatomic, copy) NSString *fileName;
/// 文件大小
@property (readwrite, nonatomic, assign) NSUInteger size;
/// 大小字符串
@property (readwrite, nonatomic, copy) NSString *sizeString;
/// 子symbol的集合
@property (readwrite, nonatomic, strong) NSMutableArray<BTSymbolItem *> *symbols;

@end
