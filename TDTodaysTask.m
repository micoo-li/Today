//
//  TDTodaysTask.m
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDTodaysTask.h"

#define TDCompletedKey @"completed"
#define TDTaskNameKey @"taskname"
#define TDPriorityKey @"priority"

@implementation TDTodaysTask

-(id)init
{
    return [self initWithTaskName:@"New Task"];
}

-(id)initWithTaskName:(NSString *)name
{
    if ((self = [super init]))
    {
        self.taskName = name;
        self.completed = false;
        
        self.priority = 0;
    }
    return self;
}

-(NSString *)description
{
    return self.taskName;
}


#pragma mark NSCoder Delegates

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        self.completed = [aDecoder decodeBoolForKey:TDCompletedKey];
        self.taskName = [aDecoder decodeObjectForKey:TDTaskNameKey];
        self.priority = [aDecoder decodeIntegerForKey:TDPriorityKey];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.completed forKey:TDCompletedKey];
    [aCoder encodeObject:self.taskName forKey:TDTaskNameKey];
    [aCoder encodeInteger:self.priority forKey:TDPriorityKey];
}


@end
