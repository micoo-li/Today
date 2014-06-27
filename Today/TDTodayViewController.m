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
#import "NSTimeFormatter.h"

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
    
    //Setup table view
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2){
        
        NSLog (@"1: %@", obj1);
        NSLog (@"2: %@", obj2);
        
        return NSOrderedAscending;
    
    } ];
    
    [self.tableView setSortDescriptors:@[sortDescriptor]];
    
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
    
    //Time Text Field
    [cellView.taskTime setStringValue:[NSTimeFormatter formattedTimeStringForTimeInterval:task.timeForTask]];
    
    [cellView.taskTime setTarget:self];
    [cellView.taskTime setAction:@selector(changedTaskTime:)];
    
    
    //Completed Checkbox
    
    [cellView.completed setState:task.completed];
    [cellView.completed setTarget:self];
    [cellView.completed setAction:@selector(completedTask:)];
    
    //Set action
    [cellView setObjectValue:task];
    
    //Setup the view controller variable
    cellView.viewController = self;
    
    //Task Time
    [cellView.taskTime setStringValue:[NSTimeFormatter formattedTimeStringForTimeInterval:task.timeForTask]];
    
    NSLog (@"%@", self.todaysTasks);
    
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

-(void) addNewTaskForUndo:(TDTodaysTask *)task atIndex:(NSUInteger)index
{
    [[[self undoManager] prepareWithInvocationTarget:self] removeTaskForUndo:index];
    
    [self addNewTask:task atIndex:index];
    
    [self saveDataToDisk:self.todaysTasks];
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

-(void)removeTaskForUndo:(NSUInteger)row
{
    [[[self undoManager] prepareWithInvocationTarget:self] addNewTaskForUndo:self.todaysTasks[row] atIndex:row];
    
    [self removeTask:row];

    [self saveDataToDisk:self.todaysTasks];
}

-(void)editTaskNameForUndo:(NSString *)string timeInterval:(NSTimeInterval)interval forTaskView:(TDTodaysTaskCellView *)view
{
    TDTodaysTask *task = view.objectValue;
    
    [[[self undoManager] prepareWithInvocationTarget:self] editTaskNameForUndo:task.taskName timeInterval:task.timeForTask forTaskView:view];
    
    [task setTaskName:string];
    [task setTimeForTask:interval];
    
    [[view taskName] setStringValue:string];
    [[view taskTime] setStringValue:[NSTimeFormatter formattedTimeStringForTimeInterval:interval]];
    
    [self saveDataToDisk:self.todaysTasks];
}


-(void)editPriorityForUndo:(NSInteger)priority forTaskView:(TDTodaysTaskCellView *)view
{
    [[[self undoManager] prepareWithInvocationTarget:self] editPriorityForUndo:[(TDTodaysTask *)view.objectValue priority] forTaskView:view];
    
    [(TDTodaysTask *)[view objectValue] setPriority:priority];
    
    [self setPriorityButtonTitle:priority forTaskView:view];
    
    [self saveDataToDisk:self.todaysTasks];
    
}


-(void)completeTaskForUndo:(BOOL)completed forTaskView:(TDTodaysTaskCellView *)view
{
    TDTodaysTask *task = [view objectValue];
    
    [[[self undoManager] prepareWithInvocationTarget:self] completeTaskForUndo:task.completed forTaskView:view];
    
    task.completed = completed;
    
    [[view completed] setState:completed];
    
    [self saveDataToDisk:self.todaysTasks];
    
}

-(void)setPriorityButtonTitle:(NSInteger)priority forTaskView:(TDTodaysTaskCellView *)cellView
{
    TDTodaysTask *task = [cellView objectValue];
    
    if (task.priority)
    {
        [cellView.priorityButton setTitle:[NSString stringWithFormat:@"%li", task.priority]];
        [cellView.priorityButton setHideWhenMouseOver:NO];
        [cellView.priorityButton setTransparent:NO];
        [cellView.priorityButton setState:NSOffState];
    }
    else //If priority = 0
    {
        [cellView.priorityButton setTitle:@""];
        [cellView.priorityButton setHideWhenMouseOver:YES];
        [cellView.priorityButton setTransparent:YES];
        [cellView.priorityButton setState:NSOffState];
    }
}

-(void)changedTaskTimeForUndo:(NSTimeInterval)interval forTaskView:(TDTodaysTaskCellView *)view
{
    TDTodaysTask *task = [view objectValue];
    
    [[[self undoManager] prepareWithInvocationTarget:self] changedTaskTimeForUndo:task.timeForTask forTaskView:view];
    
    task.timeForTask = interval;
    [[view taskTime] setStringValue:[NSTimeFormatter formattedTimeStringForTimeInterval:interval]];
    [self saveDataToDisk:self.todaysTasks];
}
                
#pragma mark IBAction

-(IBAction)addTask:(id)sender
{
    TDTodaysTask *task = [[TDTodaysTask alloc] initWithTaskName:[NSString stringWithFormat:@"New Task"]];
    
    [self addNewTask:task];
    
    [[[self undoManager] prepareWithInvocationTarget:self] removeTaskForUndo:self.todaysTasks.count-1];
    
    [self saveDataToDisk:self.todaysTasks];
}

-(IBAction)deleteTask:(id)sender
{
    [[[self undoManager] prepareWithInvocationTarget:self] addNewTaskForUndo:self.todaysTasks[selectedRow] atIndex:selectedRow];
    
    //Remove the task
    [self removeTask:selectedRow];
    
    [self saveDataToDisk:self.todaysTasks];
}

-(IBAction)completedTask:(id)sender
{
    TDTodaysTaskCellView *cellView = (TDTodaysTaskCellView *)[sender superview];
    
    BOOL completed = [(TDTodaysTask *)[cellView objectValue] completed];
    
    [[[self undoManager] prepareWithInvocationTarget: self] completeTaskForUndo:completed  forTaskView:cellView];
    
    [(TDTodaysTask *)cellView.objectValue setCompleted:!completed];

    [self saveDataToDisk:self.todaysTasks];
}

-(IBAction)changedTaskTime:(id)sender
{
    TDTodaysTask *task = [self.todaysTasks objectAtIndex:selectedRow];
    TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:selectedRow makeIfNecessary:NO];

    NSString *timeString = [[cellView taskTime] stringValue];
    NSTimeInterval interval = [NSTimeFormatter timeIntervalForString:timeString];
    
    if (interval != task.timeForTask)
        [[[self undoManager] prepareWithInvocationTarget:self] changedTaskTimeForUndo:task.timeForTask forTaskView:cellView];
    
    task.timeForTask = interval;
    
    cellView.taskTime.stringValue = [NSTimeFormatter formattedTimeString:timeString];
    
    [self saveDataToDisk:self.todaysTasks];
}

-(IBAction)changedTaskPariority:(id)sender
{
    //Maybe change this later
    //TDTodaysTaskCellView *cellView = (TDTodaysTaskCellView *)[sender superview];
    TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:0 row:selectedRow makeIfNecessary:NO];
    
    NSInteger priority = [[sender title] intValue];
    
    TDTodaysTask *task = [cellView objectValue];
    
    if (priority != task.priority)
        [[[self undoManager] prepareWithInvocationTarget:self] editPriorityForUndo:[(TDTodaysTask *)cellView.objectValue priority] forTaskView:cellView];
    
    task.priority = priority;
    
    [self setPriorityButtonTitle:priority forTaskView:cellView];
    
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
    
    TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:selectedRow makeIfNecessary:NO];
    
    NSString *newTaskName = [[cellView taskName] stringValue];
    
    //Undo bs
    
    NSMutableArray *split = [NSMutableArray arrayWithArray:[newTaskName componentsSeparatedByString:@" "]];
    
    NSUInteger hour = -1, minute = -1;
    NSInteger prepositionIndex = -1;
    
    for (int i=1;i<split.count;i++)
    {
        if ([NSTimeFormatter keywordIsInArray:TDHourKeywords keyword:split[i]])
        {
            hour = [split[i-1] intValue];
            if (!(hour == 0 && ![split[i-1] isEqualToString:@"0"]))
            {
                [split removeObjectAtIndex:i];
                [split removeObjectAtIndex:i-1];
            }
            
            if (prepositionIndex == -1)
                prepositionIndex = i-2;
        }
        else if ([NSTimeFormatter keywordIsInArray:TDMinuteKeywords keyword:split[i]])
        {
            minute = [split[i-1] intValue];
            if (!(minute == 0 && ![split[i-1] isEqualToString:@"0"]))
            {
                [split removeObjectAtIndex:i];
                [split removeObjectAtIndex:i-1];
            }
            
            if (prepositionIndex == -1)
                prepositionIndex = i-2;
        }
    }
    
    if (!(hour == -1 && minute == -1))
    {
        if (prepositionIndex >= 0 && [NSTimeFormatter keywordIsInArray:TDPrepositionKeywords keyword:split[prepositionIndex]])
            split = [NSMutableArray arrayWithArray:[split subarrayWithRange:NSMakeRange(0, prepositionIndex)]];
        
        
        NSTimeInterval interval = [NSTimeFormatter timeToInterval:hour andMinutes:minute];

        if (![task.taskName isEqualToString:newTaskName] || task.timeForTask!= interval)
            [[[self undoManager] prepareWithInvocationTarget:self] editTaskNameForUndo:task.taskName timeInterval:task.timeForTask forTaskView:cellView];
        
        
        task.taskName = [split componentsJoinedByString:@" "];
        task.timeForTask = interval;
        
        
        cellView.taskName.stringValue = task.taskName;
        cellView.taskTime.stringValue = [NSTimeFormatter formattedTimeString:hour andMinute:minute];
        
        
        
    }
    else{
        
        
        if (![task.taskName isEqualToString:newTaskName])
            [[[self undoManager] prepareWithInvocationTarget:self] editTaskNameForUndo:task.taskName timeInterval:task.timeForTask forTaskView:cellView];
        task.taskName = newTaskName;
        
    }
    
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
    {
        [lastSelectedCellView.taskName setBackgroundColor:TDTableRowBackgroundColor];
        [lastSelectedCellView.taskTime setBackgroundColor:TDTableRowBackgroundColor];
    }
    if (self.tableView.selectedRow>-1)
    {
        TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:self.tableView.selectedRow makeIfNecessary:NO];
        [cellView.taskName setBackgroundColor:TDTableRowHighlightBackgroundColor];
        [cellView.taskTime setBackgroundColor:TDTableRowHighlightBackgroundColor];
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
        {
            [lastSelectedCellView.taskName setBackgroundColor:TDTableRowBackgroundColor];
            [lastSelectedCellView.taskTime setBackgroundColor:TDTableRowBackgroundColor];
        }
        if (self.tableView.selectedRow>-1)
        {
            TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:self.tableView.selectedRow makeIfNecessary:NO];
            [cellView.taskName setBackgroundColor:TDTableRowHighlightBackgroundColor];
            [cellView.taskTime setBackgroundColor:TDTableRowHighlightBackgroundColor];
            lastSelectedCellView = cellView;
        }
        else
            lastSelectedCellView = nil;
    }
    selectionChanged = false;
    
}

#pragma mark Inherited Methods

//Why is this such a bitch
-(NSUndoManager *)undoManager
{
    return [[[self view] window] undoManager];
}

@end
