//
//  TDEditableLabelTextField.m
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDEditableLabelTextField.h"
#import "TDConstants.h"

@implementation TDEditableLabelTextField

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
    [self setEditable:YES];
 
    //Background Color of the text field
    [self setDrawsBackground:YES];
    [self setBackgroundColor:TDTableRowBackgroundColor];
    
    [self setFocusRingType:NSFocusRingTypeNone];
    [self setBezeled:NO];
    
    //Tracking Area
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.hasMouseOver)
    {
       // NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:2 yRadius:2];
        //[path stroke];
    }
    
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

//Change color when it becomes first responder
/*
-(BOOL)becomeFirstResponder
{
    [self setBackgroundColor:TDTableRowHighlightBackgroundColor];
    return YES;
}
*/
-(BOOL)resignFirstResponder
{
   // [self setBackgroundColor:TDTableRowBackgroundColor];
    return YES;
}

//So it accepts mouse
-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    self.hasMouseOver = true;
    [self setNeedsDisplay];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    self.hasMouseOver = false;
    [self setNeedsDisplay];
}


@end
