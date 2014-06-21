//
//  TDPriorityButton.h
//  Today
//
//  Created by Michael on 6/21/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDPriorityButton : NSButton
{
    NSTrackingArea *trackingArea;
}

@property (readwrite, assign) BOOL hideWhenMouseOver;

@end
