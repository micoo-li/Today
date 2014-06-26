//
//  TDTodaysTask.h
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDTodaysTask : NSObject <NSCoding, NSCopying>

@property (readwrite, assign) BOOL completed;
@property (readwrite, copy) NSString *taskName;


@property (readwrite, assign) NSTimeInterval timeForTask;

//Priority ranges from 1 - 5, where 1 is the most important, and 0 means no priority has been given
@property (readwrite, assign) NSInteger priority;

-(id)initWithTaskName:(NSString *)name;

@end
