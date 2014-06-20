//
//  TDColorView.m
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDColorView.h"

@implementation TDColorView

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
    _backgroundColor = [NSColor whiteColor];
    [_backgroundColor set];
    
    //Set layer backed
   // [self setWantsLayer:YES];
    
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
   
    [_backgroundColor set];
    NSRectFill(dirtyRect);
    
    dirtyRect.origin.y+=dirtyRect.size.height;
    dirtyRect.size.height = 0;
    
    [[NSColor headerColor] set];
    [NSBezierPath strokeRect:dirtyRect];
//    */
}

@end
