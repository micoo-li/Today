//
//  TDTableView.m
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDTableView.h"
#import "TDTodaysTaskCellView.h"

@implementation TDTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    // Only take effect for double clicks; remove to allow for single clicks
    if (theEvent.clickCount < 2) {
        return;
    }
    
    // Get the row on which the user clicked
    NSPoint localPoint = [self convertPoint:theEvent.locationInWindow
                                   fromView:nil];
    NSInteger row = [self rowAtPoint:localPoint];
    
    // If the user didn't click on a row, we're done
    if (row < 0) {
        return;
    }
    
    // Get the view clicked on
    TDTodaysTaskCellView *view = [self viewAtColumn:0 row:row makeIfNecessary:NO];
    
    // If the field can be edited, pop the editor into edit mode
    //Checks if mouse location is within the range of the text field
    
    NSPoint mouseLocation = [view convertPoint:[theEvent locationInWindow] fromView:nil];
    CGFloat nameOrigin = view.taskName.frame.origin.x;
    CGFloat nameWidth = view.taskName.frame.size.width;
    
    CGFloat timeOrigin = view.taskTime.frame.origin.x;
    CGFloat timeWidth = view.taskTime.frame.size.width;
    
    
    if (view.taskName.isEditable && (nameOrigin < mouseLocation.x && mouseLocation.x < (nameOrigin+nameWidth))) {
        [[view window] makeFirstResponder:view.textField];
    }
    else if (view.taskTime.isEditable && (timeOrigin < mouseLocation.x && mouseLocation.x < (timeOrigin+timeWidth)))
    {
        [[view window] makeFirstResponder:view.taskTime];
    }
}



- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
