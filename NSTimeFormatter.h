//
//  NSTimeFormatter.h
//  Today
//
//  Created by Michael on 6/25/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimeFormatter : NSObject

//User input into formatted time
+(NSString *)formattedTimeString:(NSString *)textDate;

//Time interval into formatted time
+(NSString *)formattedTimeStringForTimeInterval:(NSTimeInterval)interval;

//Hours and Minutes into formatted time
+(NSString *)formattedTimeString:(NSUInteger)hours andMinute:(NSUInteger)minutes;

//Hours and minutes into NSTimeInterval
+(NSTimeInterval)timeToInterval:(NSUInteger)hours andMinutes:(NSUInteger)minutes;

//Checks for keywords of hours/minutes
+(BOOL)keywordIsInArray:(NSArray *)keywords keyword:(NSString *)word;

//User input into time interval
+(NSTimeInterval)timeIntervalForString:(NSString *)textDate;

@end
