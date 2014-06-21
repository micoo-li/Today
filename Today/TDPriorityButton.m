//
//  TDPriorityButton.m
//  Today
//
//  Created by Michael on 6/21/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDPriorityButton.h"
#import "TDTodaysTaskCellView.h"
#import "TDTodayViewController.h"

@implementation TDPriorityButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)mouseDown:(NSEvent *)theEvent
{
    NSTableView *tableView = [[(TDTodaysTaskCellView*)[self superview] viewController] tableView];
    
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[tableView rowForView:[self superview]]] byExtendingSelection:NO];
    
    [super mouseDown:theEvent];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    if (self.hideWhenMouseOver)
        [self setTransparent:NO];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    if (self.hideWhenMouseOver)
        [self setTransparent:YES];
}

@end
