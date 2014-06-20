//
//  TDTodayViewController.m
//  Today
//
//  Created by Michael on 6/17/14.
//  Copyright (c) 2014 michael. All rights reserved.
//

#import "TDTodaysTaskCellView.h"

#import "TDTodaysTask.h"
#import "TDTodayViewController.h"
#import "TDTableRowView.h"

#import "TDConstants.h"

static NSString *const TDRowIdentifier = @"TDRowIdentifier";

@interface TDTodayViewController ()
{
}

@end

@implementation TDTodayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Check if application support directory exists
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if (![fileManager fileExistsAtPath:TDTodaysTaskDirectory isDirectory:NULL])
            [fileManager createDirectoryAtPath:TDTodaysTaskDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        
        
        
        self.todaysTasks = [self readDataFromDisk];
        //If the file for our todays task does not exist
        /*
        if (!(self.todaysTasks = [self readDataFromDisk]))
        {
            self.todaysTasks = [[NSMutableArray alloc] init];
            for (int i=0;i<2;i++)
            {
                TDTodaysTask *task = [[TDTodaysTask alloc] initWithTaskName:@"Computer Science"];
                [self.todaysTasks addObject:task];
            }
        }
        else
        {
            
            //Create folder
        }
         */
    }
    return self;
}

-(void)viewDidLoad
{
    selectedRow = tableView.selectedRow;
}

#pragma mark Read/Write Methods

-(void)saveDataToDisk:(NSMutableArray *)data
{
    [NSKeyedArchiver archiveRootObject:data toFile:TDTodaysTaskDataDirectory];
}

-(NSMutableArray *)readDataFromDisk
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:TDTodaysTaskDataDirectory];
}

#pragma mark IBAction

-(IBAction)addTask:(id)sender
{
    TDTodaysTask *task = [[TDTodaysTask alloc] initWithTaskName:[NSString stringWithFormat:@"New Task"]];
    
    [self.todaysTasks addObject:task];
    [tableView reloadData];
    
    //Add task should select the new item so user can edit it
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:self.todaysTasks.count-1] byExtendingSelection:NO];
    
    
    //Update application support
    [self saveDataToDisk:self.todaysTasks];
    
}

-(IBAction)deleteTask:(id)sender
{
    [self.todaysTasks removeObjectAtIndex:selectedRow];
    [tableView reloadData];
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];

    //Update application support
    [self saveDataToDisk:self.todaysTasks];
}

-(IBAction)taskNameChanged:(id)sender
{
    TDTodaysTask *task = [self.todaysTasks objectAtIndex:selectedRow];
    
    task.taskName = [[[tableView viewAtColumn:tableView.selectedColumn row:selectedRow makeIfNecessary:NO] taskName] stringValue];
    
    //Update application support
    [self saveDataToDisk:self.todaysTasks];
}

#pragma mark NSTableView DataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.todaysTasks.count;
}

#pragma mark NSTableView Delegate

-(NSView *)tableView:(NSTableView *)tv viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    TDTodaysTaskCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    TDTodaysTask *task = [self.todaysTasks objectAtIndex:row];
    [cellView.completed setState:task.completed];
    [cellView.taskName setStringValue:task.taskName];
    
    [cellView.taskName setFocusRingType:NSFocusRingTypeNone];
    [cellView.taskName setBezeled:NO];

    
    //Use first responder instead
    //Set cell view to attach IBAction
    
    [cellView.taskName setTarget:self];
    [cellView.taskName setAction:@selector(taskNameChanged:)];
    
    return cellView;
}



-(NSTableRowView *)tableView:(NSTableView *)tv rowViewForRow:(NSInteger)row
{
    TDTableRowView *tableRowView = [tableView makeViewWithIdentifier:TDRowIdentifier owner:self];
    
    if (!tableRowView)
    {
        tableRowView = [[TDTableRowView alloc] initWithFrame:NSZeroRect];
        tableRowView.identifier = TDRowIdentifier;
    }
    return tableRowView;
}



-(void)tableViewSelectionIsChanging:(NSNotification *)notification
{
    //Change instance variable
    selectionChanged = true;
    
    if (lastSelectedCellView)
        [lastSelectedCellView.taskName setBackgroundColor:TDTableRowBackgroundColor];
    if (tableView.selectedRow>-1)
    {
        TDTodaysTaskCellView *cellView = [tableView viewAtColumn:tableView.selectedColumn row:tableView.selectedRow makeIfNecessary:NO];
        [cellView.taskName setBackgroundColor:TDTableRowHighlightBackgroundColor];
        lastSelectedCellView = cellView;
    }
    else
        lastSelectedCellView = nil;
    
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return YES;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    selectedRow = [tableView selectedRow];
    
    if (!selectionChanged)
    {
        if (lastSelectedCellView)
            [lastSelectedCellView.taskName setBackgroundColor:TDTableRowBackgroundColor];
        if (tableView.selectedRow>-1)
        {
            TDTodaysTaskCellView *cellView = [tableView viewAtColumn:tableView.selectedColumn row:tableView.selectedRow makeIfNecessary:NO];
            [cellView.taskName setBackgroundColor:TDTableRowHighlightBackgroundColor];
            lastSelectedCellView = cellView;
        }
        else
            lastSelectedCellView = nil;
    }
    selectionChanged = false;
    
}



@end
