//
//  ViewController.m
//  Analyze
//
//  Created by mamba on 2016/9/27.
//  Copyright © 2016年 BT77.Inc. All rights reserved.
//

#import "ViewController.h"
#import "BTSymbolItem.h"

@implementation ViewController {
    NSArray *_results;
}

///--------------------------------------
#pragma mark - Lifecycle
///--------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

///--------------------------------------
#pragma mark - Event Handler
///--------------------------------------
- (IBAction)browseButtonDidClicked:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];

    BOOL okButtonPressed = ([openPanel runModal] == NSModalResponseOK);
    if (okButtonPressed) {
        NSLog(@"directoryURL = %@", [openPanel URL]);
        NSString *path = [[openPanel URL] path];

        [self.searchFilePathTextFiled setStringValue:path];
    }
}

- (IBAction)analyzeButtonDidClicked:(id)sender {
    NSString *filePath = [self.searchFilePathTextFiled stringValue];
    BOOL fileExists = ![filePath isEqualToString:@""];
    if (!fileExists) {
        [self showAlertWithStyle:NSAlertStyleWarning title:@"未选择文件" subtitle:@"请先选择有效的文件"];
        return;
    }

    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
    if ([content isEqualToString:@""]) {
        [self showAlertWithStyle:NSAlertStyleWarning title:@"文件无内容" subtitle:@"文件中没有内容"];
        return;
    }

    _results = nil;
    [self.resultTableView reloadData];

    NSMutableDictionary<NSString *, BTSymbolItem *> *sizeMap = [NSMutableDictionary new];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];

    BOOL isFile = NO;
    BOOL isSymbols = NO;
    BOOL isSections = NO;

    NSString *project = nil;
    // 开始扫描文件
    for(NSString *line in lines) {
        if([line hasPrefix:@"#"]) {
            // 扫描二进制文件
            if ([line hasPrefix:@"# Path:"]) {
                project = [[line componentsSeparatedByString:@"/"] lastObject];
            }
            if([line hasPrefix:@"# Object files:"]) {
                isFile = YES;
            } else if ([line hasPrefix:@"# Sections:"]) {
                isSymbols = YES;
            } else if ([line hasPrefix:@"# Symbols:"]) {
                isSections = YES;
            }
        } else {
            if(isFile == YES && isSymbols == NO && isSections == NO) { // 扫描所有文件
                NSRange range = [line rangeOfString:@"]"];
                if(range.location != NSNotFound) {
                    BTSymbolItem *symbolItem = [BTSymbolItem new];
                    symbolItem.moduleName = project;
                    symbolItem.fileName = [line substringFromIndex:range.location+1];
                    NSString *key = [line substringToIndex:range.location+1];
                    sizeMap[key] = symbolItem;
                }
            } else if (isFile == YES && isSymbols == YES && isSections == YES) { // 计算大小
                NSArray <NSString *>*symbolsArray = [line componentsSeparatedByString:@"\t"];
                if(symbolsArray.count == 3) {
                    //Address Size File Name
                    NSString *fileKeyAndName = symbolsArray[2];
                    NSUInteger size = strtoul([symbolsArray[1] UTF8String], nil, 16);

                    NSRange range = [fileKeyAndName rangeOfString:@"]"];
                    if(range.location != NSNotFound) {
                        BTSymbolItem *symbol = sizeMap[[fileKeyAndName substringToIndex:range.location+1]];
                        if(symbol) {
                            symbol.size = size;
                        }
                    }
                }
            }
        }
    }

    // 递归出所有模块，模块中含有各个二进制文件的symbolItem的数组
    NSArray<BTSymbolItem *> *symbols = [sizeMap allValues];
    NSMutableDictionary<NSString *, BTSymbolItem *> *tempSymbols = [NSMutableDictionary new];
    [symbols enumerateObjectsUsingBlock:^(BTSymbolItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (tempSymbols[obj.moduleName]) {
            BTSymbolItem *item = tempSymbols[obj.moduleName];
            item.size += obj.size;
            [item.symbols addObject:obj];
        } else {
            NSMutableArray<BTSymbolItem *> *subItems = [NSMutableArray new];

            BTSymbolItem *item = [BTSymbolItem new];
            item.moduleName = project;
            item.fileName = obj.moduleName;
            item.size += obj.size;
            [subItems addObject:item];
            item.symbols = subItems;

            tempSymbols[obj.moduleName] = item;
        }
    }];

    // 计算总的包大小
    __block CGFloat totalSize = 0;
    [tempSymbols enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, BTSymbolItem * _Nonnull symbolItem, BOOL * _Nonnull stop) {
        totalSize += symbolItem.size;
    }];
    self.resultLabel.stringValue = [NSString stringWithFormat:@"总的二进制文件大小：%.2fMB", totalSize / 1024.0];

    _results = [tempSymbols allValues];
    [self.resultTableView reloadData];

}

- (void)showAlertWithStyle:(NSAlertStyle)style title:(NSString *)title subtitle:(NSString *)subtitle {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = style;
    [alert setMessageText:title];
    [alert setInformativeText:subtitle];
    [alert runModal];
}

///--------------------------------------
#pragma mark - NSTableViewDatasource
///--------------------------------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _results.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    BTSymbolItem *item = [_results objectAtIndex:row];
    NSString *columnIdentifier = [tableColumn identifier];
    if ([columnIdentifier isEqualToString:@"Module"]) {
        columnIdentifier = item.moduleName;
    } else if ([columnIdentifier isEqualToString:@"FileName"]) {
        columnIdentifier = item.fileName;
    } else if ([columnIdentifier isEqualToString:@"Size"]) {
        columnIdentifier = item.sizeString;
    }
    return columnIdentifier;
}

@end
