//
//  TDTodaysTaskCellView.m
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDTodaysTaskCellView.h"

@implementation TDTodaysTaskCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)viewDidLoad
{   
    [[self window] makeFirstResponder:self.taskName];
    
    NSText* textEditor = [self.window fieldEditor:YES forObject:self.taskName];
    NSRange range = {0, self.taskTime.stringValue.length};
    [textEditor setSelectedRange:range];
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [[NSColor gridColor] set];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(0, 0)];
    [path lineToPoint:NSMakePoint(dirtyRect.size.width, 0)];
    [path stroke];
    
}

@end
