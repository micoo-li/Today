//
//  TDTodaysTaskCellView.h
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDPriorityButton, TDTodayViewController;

@interface TDTodaysTaskCellView : NSTableCellView


@property (readwrite, assign) IBOutlet NSButton *completed;
@property (readwrite, assign) IBOutlet NSTextField *taskName;
@property (readwrite, assign) IBOutlet TDPriorityButton *priorityButton;

@property (readwrite, retain) TDTodayViewController *viewController;

@end
