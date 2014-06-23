//
//  TDTodayViewController.h
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDTodaysTaskCellView, TDTodaysTask;

@interface TDTodayViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
    
    TDTodaysTaskCellView *lastSelectedCellView;
    
    
    //No delegate method that gives us if tableview will switch selection so a workaround here with 2 variables
    NSUInteger selectedRow;
    
    //Sometimes it only activates didchange and not changing, yet implementing changing is crucial so 
    BOOL selectionChanged;
    
    
    //Menu so users can pick the priority
    IBOutlet NSMenu *priorityMenu;
    
    
}

@property (readwrite, retain) IBOutlet NSTableView *tableView;
@property (readwrite, retain) NSMutableArray *todaysTasks;


//Todays View is now the selected view
-(void)switchedToCurrentView;


-(void)addNewTask:(TDTodaysTask *)task;
-(void)addNewTask:(TDTodaysTask *)task atIndex:(NSUInteger)index;

-(void)addNewTaskForUndo:(TDTodaysTask *)task atIndex:(NSUInteger)index;

-(void)removeTask:(NSUInteger)row;
-(void)removeTaskForUndo:(NSUInteger)row;

-(void)editTaskNameForUndo:(NSString *)string forTaskIndex:(NSUInteger)index;

-(void)editPriorityForUndo:(NSInteger)priority forTaskIndex:(NSUInteger)index;

-(void)setPriorityButtonTitle:(NSInteger)priority forTaskIndex:(NSUInteger)index;

//Obvious IBAction methods
-(IBAction)addTask:(id)sender;
-(IBAction)deleteTask:(id)sender;
-(IBAction)changedTaskPariority:(id)sender;
-(IBAction)priorityButtonClicked:(id)sender;
-(IBAction)taskNameChanged:(id)sender;

//Read write methods
//Each view controller will control its own disk data, no need for a central singleton class
-(void)saveDataToDisk:(NSMutableArray *)data;
-(NSMutableArray *)readDataFromDisk;

@end
