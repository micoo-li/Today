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
}

- (void)drawRect:(NSRect)dirtyRect
{
    
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


@end
