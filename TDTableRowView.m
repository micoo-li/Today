//
//  TDTableRowView.m
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDTableRowView.h"
#import "TDConstants.h"
#import "TDTodaysTask.h"

@implementation TDTableRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
//    [super drawRect:dirtyRect];
    
    NSRect selectionRect = NSInsetRect(self.bounds, 5, 2);
    NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:2 yRadius:2];
    
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone && self.selected) {
        
        [TDTableRowBorderColor setStroke];
        [TDTableRowHighlightBackgroundColor setFill];
        [selectionPath fill];
       // [selectionPath setLineWidth:1];
        [selectionPath stroke];
    }
    else if (!self.selected)
    {
        TDTodaysTask *task = [[self viewAtColumn:0] objectValue];
        
        [TDTableRowPriorityBackgroundColor[task.priority] setFill];
        [selectionPath fill];
    }
    if (self.editing)
    {
        [TDTableRowEditingBackgroundColor setFill];
    }
    
}

@end
