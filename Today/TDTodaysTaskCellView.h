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


@property (readwrite, retain) IBOutlet NSButton *completed;
@property (readwrite, retain) IBOutlet NSTextField *taskName;
@property (readwrite, retain) IBOutlet TDPriorityButton *priorityButton;
@property (readwrite, retain) IBOutlet NSTextField *taskTime;

@property (readwrite, retain) TDTodayViewController *viewController;

@end
