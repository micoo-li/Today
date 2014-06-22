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
#import "TDPriorityButton.h"

#import "TDConstants.h"

static NSString *const TDRowIdentifier = @"TDRowIdentifier";
static NSString *const TDColumnIdntifier = @"TDColumnIdentifier";

@interface TDTodayViewController ()
{
}

-(TDTodaysTaskCellView *)viewForTask:(TDTodaysTask *)task;

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
        
        //Read saved task data from disk
        self.todaysTasks = [self readDataFromDisk];
        
        //If the file for our todays task does not exist, create first list
        if (!(self.todaysTasks = [self readDataFromDisk]))
            self.todaysTasks = [NSMutableArray arrayWithArray:@[[[TDTodaysTask alloc] initWithTaskName:@"New Task"]]];
    }
    return self;
}

-(void)viewDidLoad
{
    //Initialize variables when view loads
    selectedRow = self.tableView.selectedRow;
}

#pragma mark Methods

//Method for NSTableView delegate mainly
//Returns view initialized and setup for a certain task
-(TDTodaysTaskCellView *)viewForTask:(TDTodaysTask *)task
{
    //Method calls awakeFromNib multiple times, so watch out
    TDTodaysTaskCellView *cellView = [self.tableView makeViewWithIdentifier:TDColumnIdntifier owner:self];
    
    //Setup checkbox
    [cellView.completed setState:task.completed];
    
    //Setup task text field
    [cellView.taskName setStringValue:task.taskName];
    [cellView.taskName setFocusRingType:NSFocusRingTypeNone];
    [cellView.taskName setBezeled:NO];
    
    //Attach text field to an IBAction
    [cellView.taskName setTarget:self];
    [cellView.taskName setAction:@selector(taskNameChanged:)];
    
    //Setup priority button
    //Condition so that it displays nothing rather than 0 when priority is undefined
    if (task.priority)
        [cellView.priorityButton setTitle:[NSString stringWithFormat:@"%li", task.priority]];
    else
        [cellView.priorityButton setTitle:@""];
    
    //Attach priority button to an IBAction
    [cellView.priorityButton setTarget:self];
    [cellView.priorityButton setAction:@selector(priorityButtonClicked:)];
    
    //Hide priority button when priority is undefined
    if (task.priority == 0)
    {
        [cellView.priorityButton setTransparent:true];
        cellView.priorityButton.hideWhenMouseOver = true;
    }
    
    //Setup the view controller variable
    cellView.viewController = self;
    
    return cellView;
}

-(void)switchedToCurrentView
{
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
}

#pragma mark Read/Write Methods

//Self-explanatory
-(void)saveDataToDisk:(NSMutableArray *)data
{
    [NSKeyedArchiver archiveRootObject:data toFile:TDTodaysTaskDataDirectory];
}

-(NSMutableArray *)readDataFromDisk
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:TDTodaysTaskDataDirectory];
}

-(void)addNewTask:(TDTodaysTask *)task{
    
    [self addNewTask:task atIndex:self.todaysTasks.count];
    
}

-(void)addNewTask:(TDTodaysTask *)task atIndex:(NSUInteger)index
{
    //Use this method rather than reloadData, faster and better
    [self.todaysTasks insertObject:task atIndex:index];
    
    //Add task should select the new item so user can edit it
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:0];
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    
    //Update disk data
    [self saveDataToDisk:self.todaysTasks];
}

-(void)addNewTaskWithArray:(NSArray *)array
{
    [self addNewTask:array[0] atIndex:[array[1] intValue]];
}

-(void)removeTask:(NSUInteger)row
{
    //Temporary variable because after you delete nothing will be selected
    NSUInteger tempSelectedRow = selectedRow;
    
    [self.todaysTasks removeObjectAtIndex:row];
    [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:0];
    
    
    //Select the last row if the last item is deleted
    if (tempSelectedRow == self.todaysTasks.count)
        tempSelectedRow = self.todaysTasks.count-1;
    
    //Select row
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:tempSelectedRow] byExtendingSelection:NO];
    

    //Update application support
    [self saveDataToDisk:self.todaysTasks];
}

-(void)removeTaskForNumber:(NSNumber *)number
{
    [self removeTask:number.integerValue-1];
}
                
#pragma mark IBAction

-(IBAction)addTask:(id)sender
{
    TDTodaysTask *task = [[TDTodaysTask alloc] initWithTaskName:[NSString stringWithFormat:@"New Task"]];
    
    [self addNewTask:task];
    
    //Seriously fuck undo
    [[[[self view] window] undoManager] registerUndoWithTarget:self selector:@selector(removeTaskForNumber:) object:@(self.todaysTasks.count)];
    
}

-(IBAction)deleteTask:(id)sender
{
    //Add to undo manager
    //Fuck this method
    [[[[self view] window] undoManager] registerUndoWithTarget:self selector:@selector(addNewTaskWithArray:) object:@[[self.todaysTasks objectAtIndex:selectedRow], @(selectedRow)]];
    
    //Remove the task
    [self removeTask:selectedRow];
    
}

-(IBAction)changedTaskPariority:(id)sender
{
    
    NSInteger priority = [[sender title] intValue];
    TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:selectedRow makeIfNecessary:NO];
    TDTodaysTask *task = [self.todaysTasks objectAtIndex:selectedRow];
    
    task.priority = priority;
    
    //Change button priority
    if (task.priority)
    {
        [cellView.priorityButton setTitle:[NSString stringWithFormat:@"%li", task.priority]];
        [cellView.priorityButton setHideWhenMouseOver:NO];
    }
    else //If priority = 0
    {
        [cellView.priorityButton setTitle:@""];
        [cellView.priorityButton setHideWhenMouseOver:YES];
    }
    
    //Update
    [self saveDataToDisk:self.todaysTasks];
}

-(IBAction)priorityButtonClicked:(id)sender
{
    //Popup the menu when the button is clicked
    [priorityMenu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

-(IBAction)taskNameChanged:(id)sender
{
    TDTodaysTask *task = [self.todaysTasks objectAtIndex:selectedRow];
    
    task.taskName = [[[self.tableView viewAtColumn:self.tableView.selectedColumn row:selectedRow makeIfNecessary:NO] taskName] stringValue];
    
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
    return  [self viewForTask:[self.todaysTasks objectAtIndex:row]];
}



-(NSTableRowView *)tableView:(NSTableView *)tv rowViewForRow:(NSInteger)row
{
    TDTableRowView *tableRowView = [self.tableView makeViewWithIdentifier:TDRowIdentifier owner:self];
    
    if (!tableRowView)
    {
        tableRowView = [[TDTableRowView alloc] initWithFrame:NSZeroRect];
        tableRowView.identifier = TDRowIdentifier;
    }
    return tableRowView;
}

-(void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    
}


-(void)tableViewSelectionIsChanging:(NSNotification *)notification
{
    //Change instance variable
    selectionChanged = true;
    
    if (lastSelectedCellView)
        [lastSelectedCellView.taskName setBackgroundColor:TDTableRowBackgroundColor];
    if (self.tableView.selectedRow>-1)
    {
        TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:self.tableView.selectedRow makeIfNecessary:NO];
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
    selectedRow = [self.tableView selectedRow];
    if (!selectionChanged)
    {
        if (lastSelectedCellView)
            [lastSelectedCellView.taskName setBackgroundColor:TDTableRowBackgroundColor];
        if (self.tableView.selectedRow>-1)
        {
            TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:self.tableView.selectedRow makeIfNecessary:NO];
            [cellView.taskName setBackgroundColor:TDTableRowHighlightBackgroundColor];
            lastSelectedCellView = cellView;
        }
        else
            lastSelectedCellView = nil;
    }
    selectionChanged = false;
    
}



@end
