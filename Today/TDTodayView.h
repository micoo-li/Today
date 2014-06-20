//
//  TDTodayView.h
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDTodayViewController;

@interface TDTodayView : NSView
{
    //View controller of this view
    IBOutlet TDTodayViewController *viewController;
}


//Method tells view controller to execute addTask: (because view controller is not part of the first responder chain)
-(IBAction)addTask:(id)sender;

@end
