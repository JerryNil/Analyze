//
//  ViewController.h
//  Analyze
//
//  Created by mamba on 2016/9/27.
//  Copyright © 2016年 BT77.Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTextField *searchFilePathTextFiled;

@property (weak) IBOutlet NSButtonCell *browseButton;

@property (weak) IBOutlet NSTableView *resultTableView;

@property (weak) IBOutlet NSButton *analyzeButton;

@property (weak) IBOutlet NSTextField *resultLabel;

@end

