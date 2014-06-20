//
//  TDMainView.m
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDMainView.h"

@implementation TDMainView

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
    self.acceptsTouchEvents = YES;
}

-(void)swipeWithEvent:(NSEvent *)event
{
    NSLog (@"Swiped");
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self];
    if (touches.count == 4) {
        NSLog (@"4 finger swipe");
    }
}



- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
