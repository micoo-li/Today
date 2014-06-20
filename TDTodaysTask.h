//
//  TDTodaysTask.h
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDTodaysTask : NSObject <NSCoding>

@property (readwrite, assign) BOOL completed;
@property (readwrite, copy) NSString *taskName;

-(id)initWithTaskName:(NSString *)name;

@end
