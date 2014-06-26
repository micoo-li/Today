//
//  TDEditableLabelTextField.h
//  Today
//
//  Created by Michael on 6/18/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TDEditableLabelTextField : NSTextField
{
    NSTrackingArea *trackingArea;
}

@property (readwrite, assign) BOOL hasMouseOver;

@end
