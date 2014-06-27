//
//  TDConstants.h
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#ifndef Today_TDConstants_h
#define Today_TDConstants_h

#define TDTableRowBorderColor [NSColor colorWithCalibratedWhite:.93 alpha:1.0]
#define TDTableRowBackgroundColor [NSColor whiteColor]
#define TDTableRowHighlightBackgroundColor [NSColor colorWithCalibratedWhite:0.87 alpha:1.0]
#define TDTableRowEditingBackgroundColor [NSColor colorWithCalibratedWhite:.82 alpha:1.0]

#define TDTodaysTaskDirectory [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask,YES)[0] stringByAppendingPathComponent:@"Today"]

#define TDTodaysTaskDataFileName @"Today.data"
#define TDTodaysTaskDataDirectory [TDTodaysTaskDirectory stringByAppendingPathComponent:TDTodaysTaskDataFileName]

#define TDHourKeywords @[@"H", @"HH", @"Hour", @"Hours"]
#define TDMinuteKeywords @[@"M", @"MM", @"Minute", @"Minutes"]
#define TDPrepositionKeywords @[@"for", @"-"]

enum
{
    TDSortCompleted = 1,
    TDSortPriority,
    TDSortTaskName
};

#endif
