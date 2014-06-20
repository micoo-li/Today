//
//  TDTodayViewController.h
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDTodaysTaskCellView;

@interface TDTodayViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTableView *tableView;
    
    TDTodaysTaskCellView *lastSelectedCellView;
    
    
    //No delegate method that gives us if tableview will switch selection so a workaround here with 2 variables
    NSUInteger selectedRow;
    
    //Sometimes it only activates didchange and not changing, yet implementing changing is crucial so 
    BOOL selectionChanged;
    
}

@property (readwrite, retain) NSMutableArray *todaysTasks;

-(void)setTodaysTasks:(NSMutableArray *)todaysTasks;
-(NSMutableArray *)todaysTasks;

-(IBAction)addTask:(id)sender;
-(IBAction)deleteTask:(id)sender;
-(IBAction)taskNameChanged:(id)sender;

-(void)saveDataToDisk:(NSMutableArray *)data;
-(NSMutableArray *)readDataFromDisk;

@end
