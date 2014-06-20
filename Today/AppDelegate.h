//
//  AppDelegate.h
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class INAppStoreWindow, ANSegmentedControl;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
    NSMutableArray *viewControllers;
    
    NSView *currentView;
    
    IBOutlet NSView *titleBar;
    IBOutlet ANSegmentedControl *segmentedControl;
    
    IBOutlet NSButton *addButton;
    
    IBOutlet NSMenuItem *newTaskItem;
    IBOutlet NSMenuItem *deleteTaskItem;
    
}

@property (assign) IBOutlet INAppStoreWindow *window;

-(IBAction)segmentedSelectionChanged:(id)sender;
-(IBAction)changeCurrentView:(id)sender;


@end
