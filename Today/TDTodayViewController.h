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

@property (readwrite, retain) IBOutlet NSMenu *sortMenu;

//Todays View is now the selected view
-(void)switchedToCurrentView;


-(void)addNewTask:(TDTodaysTask *)task;
-(void)addNewTask:(TDTodaysTask *)task atIndex:(NSUInteger)index;


//Rewrite all this into view
-(void)addNewTaskForUndo:(TDTodaysTask *)task atIndex:(NSUInteger)index;
-(void)removeTaskForUndo:(NSUInteger)row;

-(void)editTaskNameForUndo:(NSString *)string timeInterval:(NSTimeInterval)interval forTaskView:(TDTodaysTaskCellView *)view;
-(void)editPriorityForUndo:(NSInteger)priority forTaskView:(TDTodaysTaskCellView *)view;
-(void)completeTaskForUndo:(BOOL)completed forTaskView:(TDTodaysTaskCellView *)view;
-(void)changedTaskTimeForUndo:(NSTimeInterval)interval forTaskView:(TDTodaysTaskCellView *)view;

-(void)removeTask:(NSUInteger)row;

-(void)setPriorityButtonTitle:(NSInteger)priority forTaskView:(TDTodaysTaskCellView *)cellView;

//Sort table view by options
-(void)sortTableView:(NSInteger)option;


//Obvious IBAction methods
-(IBAction)addTask:(id)sender;
-(IBAction)deleteTask:(id)sender;
-(IBAction)completedTask:(id)sender;
-(IBAction)changedTaskTime:(id)sender;
-(IBAction)changedTaskPariority:(id)sender;
-(IBAction)priorityButtonClicked:(id)sender;
-(IBAction)taskNameChanged:(id)sender;

-(IBAction)sortByMenu:(id)sender;

//Read write methods
//Each view controller will control its own disk data, no need for a central singleton class
-(void)saveDataToDisk:(NSMutableArray *)data;
-(NSMutableArray *)readDataFromDisk;

@end
