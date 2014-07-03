//
//  AppDelegate.h
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define TODAY_VIEW 1
#define INBOX_VIEW 2

@class INAppStoreWindow, ANSegmentedControl;

@class TDTodayViewController, TDInboxViewController;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
    //View Controllers
    TDTodayViewController *todayViewController;
    TDInboxViewController *inboxViewController;
    
    //Undo Manager for each view controllers
    NSUndoManager *todayUndoManager;
    NSUndoManager *inboxUndoManager;
    
    //Selected View
    NSView *currentView;
    int selectedView;
    
    
    IBOutlet NSView *titleBar;
    IBOutlet ANSegmentedControl *segmentedControl;
    
    IBOutlet NSButton *addButton;
    
    IBOutlet NSMenuItem *newTaskItem;
    IBOutlet NSMenuItem *deleteTaskItem;
    
    IBOutlet NSMenuItem *sortByMenuItem;
    
    IBOutlet NSMenuItem *startTaskMenuItem;
}

@property (assign) IBOutlet INAppStoreWindow *window;

-(IBAction)segmentedSelectionChanged:(id)sender;
-(IBAction)changeCurrentView:(id)sender;


@end
