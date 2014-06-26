//
//  NSTimeFormatter.m
//  Today
//
//  Created by Michael on 6/25/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "NSTimeFormatter.h"
#import "TDConstants.h"


@implementation NSTimeFormatter

+(NSString *)formattedTimeString:(NSString *)textDate
{
    return [NSTimeFormatter formattedTimeStringForTimeInterval:[NSTimeFormatter timeIntervalForString:textDate]];
}

+(NSString *)formattedTimeString:(NSUInteger)hours andMinute:(NSUInteger)minutes
{
    return [NSTimeFormatter formattedTimeStringForTimeInterval:[self timeToInterval:hours andMinutes:minutes]];
}

+(NSString *)formattedTimeStringForTimeInterval:(NSTimeInterval)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:interval];
    
    if (interval < 1)
        [dateFormatter setDateFormat:@""];
    else if (interval == 3600)
        [dateFormatter setDateFormat:@"H' hour'"];
    else if (interval == 3660)
        [dateFormatter setDateFormat:@"H' hour'm' minute'"];
    else if (3600 < interval && interval < 7200) //1 hour (instead of hours)
        [dateFormatter setDateFormat:@"H' hour'm' minutes'"];
    else if ((long)(interval-60)%3600 == 0)
        [dateFormatter setDateFormat:@"H' hour'm' minute'"];
    else if ((long)interval%3600 == 0)
        [dateFormatter setDateFormat:@"H' hours'"];
    else if (interval < 3600)
        [dateFormatter setDateFormat:@"m' minutes'"];
    else
        [dateFormatter setDateFormat:@"H' hours 'm' minutes'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    
    return [dateFormatter stringFromDate:timerDate];
}


+(NSTimeInterval)timeToInterval:(NSUInteger)hours andMinutes:(NSUInteger)minutes
{
    return minutes*60+hours*60*60;
}

+(BOOL)keywordIsInArray:(NSArray *)keywords keyword:(NSString *)word
{
    //Can be switched with binary search later if performance is an issue (non-issue because it's a very small array)
    for (NSString *s in keywords)
    {
        if ([word caseInsensitiveCompare:s] == NSOrderedSame)
            return true;
    }
    return false;
}

+(NSTimeInterval)timeIntervalForString:(NSString *)textDate
{
    NSArray *split = [textDate componentsSeparatedByString:@" "];
    
    NSUInteger hour = 0, minute = 0;
    
    for (int i=1;i<split.count;i++)
    {
        if ([NSTimeFormatter keywordIsInArray:TDHourKeywords keyword:split[i]])
        {
            hour = [split[i-1] intValue];
        }
        else if ([NSTimeFormatter keywordIsInArray:TDMinuteKeywords keyword:split[i]])
        {
            minute = [split[i-1] intValue];
        }
    }

    return [NSTimeFormatter timeToInterval:hour andMinutes:minute];
}


@end
