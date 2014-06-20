//
//  TDConstants.h
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#ifndef Today_TDConstants_h
#define Today_TDConstants_h

#define TDTableRowBorderColor [NSColor colorWithCalibratedWhite:.65 alpha:1.0]
#define TDTableRowBackgroundColor [NSColor whiteColor]
#define TDTableRowHighlightBackgroundColor [NSColor colorWithCalibratedWhite:.82 alpha:1.0]

#define TDTodaysTaskDirectory [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask,YES)[0] stringByAppendingPathComponent:@"Today"]

#define TDTodaysTaskDataFileName @"Today.data"
#define TDTodaysTaskDataDirectory [TDTodaysTaskDirectory stringByAppendingPathComponent:TDTodaysTaskDataFileName]


#endif
