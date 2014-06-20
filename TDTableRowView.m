//
//  TDTableRowView.m
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDTableRowView.h"
#import "TDConstants.h"

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
    
    
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone && self.selected) {
        NSRect selectionRect = NSInsetRect(self.bounds, 5, 3);
        [TDTableRowBorderColor setStroke];
        [TDTableRowHighlightBackgroundColor setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:4 yRadius:4];
        [selectionPath fill];
        [selectionPath stroke];
    }
    
}

@end
