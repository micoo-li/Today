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

#define TODAY_VIEW_CONTROLLER [viewControllers objectAtIndex:0]
#define INBOX_VIEW_CONTROLLER [viewControllers objectAtIndex:1]

@interface AppDelegate()
{
    
}

-(void)switchView:(NSInteger)viewNumber;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{   
    //Initialize View Controllers
    viewControllers = [NSMutableArray array];
    TDTodayViewController *todayVC = [[TDTodayViewController alloc] initWithNibName:@"TDTodayView" bundle:[NSBundle mainBundle]];
    [viewControllers addObject:todayVC];
    
    TDInboxViewController *inboxVC = [[TDInboxViewController alloc] initWithNibName:@"TDInboxView" bundle:[NSBundle mainBundle]];
    [viewControllers addObject:inboxVC];
    
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
    [self.window.contentView addSubview:todayVC.view];
    currentView = todayVC.view;
    
    //Setup top bar add task actions
    [addButton setTarget:TODAY_VIEW_CONTROLLER];
    [addButton setAction:@selector(addTask:)];
    
    //Setup new task menu item action
    [newTaskItem setTarget:TODAY_VIEW_CONTROLLER];
    [newTaskItem setAction:@selector(addTask:)];
    
    //Setup delete task menu item action
    [deleteTaskItem setTarget:TODAY_VIEW_CONTROLLER];
    [deleteTaskItem setAction:@selector(deleteTask:)];
    
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
            [self.window.contentView replaceSubview:currentView with:[TODAY_VIEW_CONTROLLER view]];
            currentView = [TODAY_VIEW_CONTROLLER view];
            //Setup menubar buttons
            [addButton setTarget:TODAY_VIEW_CONTROLLER];
            [addButton setAction:@selector(addTask:)];
            
            
            break;
        case 1:
            [self.window.contentView replaceSubview:currentView with:[INBOX_VIEW_CONTROLLER view]];
            currentView = [INBOX_VIEW_CONTROLLER view];
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
    
    for (NSViewController *viewController in viewControllers)
    {
        [viewController.view setFrame:newRect];
    }
}

@end
