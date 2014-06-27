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
#define TDTimeKey @"time"

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
        
        self.timeForTask = 0;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    TDTodaysTask *copy = [[[self class] alloc] init];
    
    if (copy)
    {
        copy.completed = self.completed;
        copy.taskName = [self.taskName copyWithZone:zone];
        copy.priority = self.priority;
        copy.timeForTask = self.timeForTask;
    }
    
    return copy;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Task Name:%@ Completed:%i Time:%f hours Priority:%lu", self.taskName, self.completed, self.timeForTask/3600, self.priority];
}


#pragma mark NSCoder Delegates

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        self.completed = [aDecoder decodeBoolForKey:TDCompletedKey];
        self.taskName = [aDecoder decodeObjectForKey:TDTaskNameKey];
        self.priority = [aDecoder decodeIntegerForKey:TDPriorityKey];
        self.timeForTask = [aDecoder decodeDoubleForKey:TDTimeKey];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.completed forKey:TDCompletedKey];
    [aCoder encodeObject:self.taskName forKey:TDTaskNameKey];
    [aCoder encodeInteger:self.priority forKey:TDPriorityKey];
    [aCoder encodeDouble:self.timeForTask forKey:TDTimeKey];
}


@end
