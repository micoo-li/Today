//
//  AppDelegate.m
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "AppDelegate.h"

#import "INAppStoreWindow/INAppStoreWindow.h"
#import "ANSegmentedControl.h"

#import "TDTodayViewController.h"
#import "TDInboxViewController.h"

#import "TDUndoManager.h"

#define INBOX_VIEW_CONTROLLER [viewControllers objectAtIndex:1]

@interface AppDelegate()
{
    
}

-(void)switchView:(NSInteger)viewNumber;

@end



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    todayViewController = [[TDTodayViewController alloc] initWithNibName:@"TDTodayView" bundle:[NSBundle mainBundle]];
    inboxViewController = [[TDInboxViewController alloc] initWithNibName:@"TDInboxView" bundle:[NSBundle mainBundle]];
    
    todayUndoManager = [[TDUndoManager alloc] init];
    inboxUndoManager = [[TDUndoManager alloc] init];
    
    selectedView = TODAY_VIEW;
    
    //Change title bar so it's thicker
    self.window.titleBarHeight = 40;
    self.window.centerFullScreenButton = true;
    [self.window.titleBarView addSubview:titleBar];
    
    //self.window.bottom
    
    /*
    //Add button
    //Temporary tests, change this later
    NSView *titleBarView = self.window.titleBarView;
    NSSize buttonSize = NSMakeSize(50.f, 25.f);
    NSRect buttonFrame = NSMakeRect(NSMidX(titleBarView.bounds) - (buttonSize.width / 2.f), NSMidY(titleBarView.bounds) - (buttonSize.height / 2.f), buttonSize.width, buttonSize.height);
    NSButton *button = [[NSButton alloc] initWithFrame:buttonFrame];
    [button setImage:[NSImage imageNamed:@"NSAddTemplate"]];
    //[button setTitle:@"A Button"];
    [titleBarView addSubview:button];
    */
    
    
    //Setup current view
    [self.window.contentView addSubview:todayViewController.view];
    currentView = todayViewController.view;
    
    //Set first responder
    [self.window makeFirstResponder:todayViewController.tableView];
    
    //Setup top bar add task actions
    [addButton setTarget:todayViewController];
    [addButton setAction:@selector(addTask:)];
    
    //Setup new task menu item action
    [newTaskItem setTarget:todayViewController];
    [newTaskItem setAction:@selector(addTask:)];
    
    //Setup delete task menu item action
    [deleteTaskItem setTarget:todayViewController];
    [deleteTaskItem setAction:@selector(deleteTask:)];
    
    //Setup sort menu
    [sortByMenuItem setSubmenu:todayViewController.sortMenu];
    
    //Select view (other setup)
    [self switchView:0];
    
    //Setup I-variables
    todayViewController.startTaskMenuItem = startTaskMenuItem;
    
    //Setup segmented control
    [segmentedControl setSelectedSegment:0];
    
    
}

#pragma mark IBAction

-(IBAction)segmentedSelectionChanged:(id)sender
{
    NSInteger state = [segmentedControl selectedSegment];
    [self switchView:state];
}

-(IBAction)changeCurrentView:(id)sender
{
    [segmentedControl setSelectedSegment:[sender tag] animate:YES];
    [self switchView:[sender tag]];
}


#pragma mark Private Methods

-(void)switchView:(NSInteger)viewNumber
{
    switch (viewNumber) {
        case 0:
            [self.window.contentView replaceSubview:currentView with:[todayViewController view]];
            currentView = [todayViewController view];
            [todayViewController switchedToCurrentView];
            
            //Setup menubar buttons
            [addButton setTarget:todayViewController];
            [addButton setAction:@selector(addTask:)];
            
            //setup menubar items
            [sortByMenuItem setSubmenu:todayViewController.sortMenu];
            
            //setp up start task menu item
            [startTaskMenuItem setTarget:todayViewController];
            [startTaskMenuItem setAction:@selector(toggleTask:)];
            
            //Set table view to be first responder
            [self.window makeFirstResponder:todayViewController.tableView];
            
            
            break;
        case 1:
            [self.window.contentView replaceSubview:currentView with:[inboxViewController view]];
            currentView = [inboxViewController view];
        default:
            break;
    }
}


#pragma mark NSWindow Delegate Methods

-(void)windowDidResize:(NSNotification *)notification
{
    NSRect newRect = [_window.contentView frame];
    newRect.size.height-=21;
    newRect.origin.y+=21;
    
    [todayViewController.view setFrame:newRect];
    [inboxViewController.view setFrame:newRect];

}

-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    switch (selectedView) {
        case TODAY_VIEW:
            return todayUndoManager;
            break;
        case INBOX_VIEW:
            return inboxUndoManager;
            break;
            
        default:
            break;
    }
    return nil;
}

@end
