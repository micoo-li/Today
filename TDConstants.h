//
//  TDConstants.h
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#ifndef Today_TDConstants_h
#define Today_TDConstants_h

@interface NSColor(TDAdditions)

+(NSColor *)colorWithHexColorString:(NSString*)inColorString;

@end

@implementation NSColor(TDAdditions)

+ (NSColor*)colorWithHexColorString:(NSString*)inColorString
{
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
    
    result = [NSColor
              colorWithCalibratedRed:(CGFloat)redByte / 0xff
              green:(CGFloat)greenByte / 0xff
              blue:(CGFloat)blueByte / 0xff
              alpha:1.0];
    return result;
}

@end



#define TDTableRowBorderColor [NSColor colorWithCalibratedWhite:.93 alpha:1.0]
#define TDTableRowBackgroundColor [NSColor whiteColor]
//#define TDTableRowHighlightBackgroundColor [NSColor colorWithCalibratedWhite:0.87 alpha:1.0]
#define TDTableRowHighlightBackgroundColor [NSColor colorWithCalibratedWhite:0.5 alpha:1.0]
#define TDTableRowEditingBackgroundColor [NSColor colorWithCalibratedWhite:.82 alpha:1.0]
//#define TDTableRowWorkingTaskBackgroundColor [NSColor

//0 priority would just be the normal background color
#define TDTableRowPriorityBackgroundColor @[TDTableRowBackgroundColor, \
                                            [NSColor colorWithHexColorString:@"EAEBE6"],\
                                            [NSColor colorWithHexColorString:@"DDDED9"], \
                                            [NSColor colorWithHexColorString:@"C8C9C4"], \
                                            [NSColor colorWithHexColorString:@"B9BAB5"], \
                                            [NSColor colorWithHexColorString:@"B0B0B0"]\
]


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
