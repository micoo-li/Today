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

-(void) addNewTaskForUndo:(TDTodaysTask *)task atIndex:(NSUInteger)index
{
    [[[self undoManager] prepareWithInvocationTarget:self] removeTaskForUndo:index];
    
    [self addNewTask:task atIndex:index];
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
}

-(void)editTaskNameForUndo:(NSString *)string forTaskIndex:(NSUInteger)index
{
    //Casting because yolo
    [[[self undoManager] prepareWithInvocationTarget:self] editTaskNameForUndo:(NSString *)[self.todaysTasks[index] taskName] forTaskIndex:index];
    
    //have to edit the text field
    //More casting :(
    [(TDTodaysTask*)[[self todaysTasks] objectAtIndex:index] setTaskName:string];
    
    //rofl objective-c
    [[[[self tableView] viewAtColumn:0 row:index makeIfNecessary:NO] taskName] setStringValue:string];
    
}

-(void)editPriorityForUndo:(NSInteger)priority forTaskIndex:(NSUInteger)index
{
    [[[self undoManager] prepareWithInvocationTarget:self] editPriorityForUndo:[(TDTodaysTask *)self.todaysTasks[index] priority] forTaskIndex:index];
    
    [(TDTodaysTask *)self.todaysTasks[index] setPriority:priority];
    
    [self setPriorityButtonTitle:priority forTaskIndex:index];
    
}

-(void)setPriorityButtonTitle:(NSInteger)priority forTaskIndex:(NSUInteger)index
{
    TDTodaysTask *task = self.todaysTasks[index];
    TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:0 row:index makeIfNecessary:NO];
    
    
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

-(void)completeTaskForUndo:(BOOL)completed forTaskIndex:(NSUInteger)index
{
    
}
                
#pragma mark IBAction

-(IBAction)addTask:(id)sender
{
    TDTodaysTask *task = [[TDTodaysTask alloc] initWithTaskName:[NSString stringWithFormat:@"New Task"]];
    
    [self addNewTask:task];
    
    [[[self undoManager] prepareWithInvocationTarget:self] removeTaskForUndo:self.todaysTasks.count-1];
}

-(IBAction)deleteTask:(id)sender
{
    [[[self undoManager] prepareWithInvocationTarget:self] addNewTaskForUndo:self.todaysTasks[selectedRow] atIndex:selectedRow];
    
    //Remove the task
    [self removeTask:selectedRow];
}

-(IBAction)completedTask:(id)sender
{
    BOOL completed = [(TDTodaysTask *)self.todaysTasks[selectedRow] completed];
    
    [[[self undoManager] prepareWithInvocationTarget: self] completeTaskForUndo:completed  forTaskIndex:selectedRow];
    
    [(TDTodaysTask *)self.todaysTasks[selectedRow] setCompleted:!completed];
    
}

-(IBAction)changedTaskTime:(id)sender
{
    TDTodaysTask *task = [self.todaysTasks objectAtIndex:selectedRow];
    
    TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:selectedRow makeIfNecessary:NO];
    
    NSString *timeString = [[cellView taskTime] stringValue];
    
    task.timeForTask = [NSTimeFormatter timeIntervalForString:timeString];
    
    cellView.taskTime.stringValue = [NSTimeFormatter formattedTimeString:timeString];
    
}

-(IBAction)changedTaskPariority:(id)sender
{
    
    NSInteger priority = [[sender title] intValue];
    
    TDTodaysTask *task = [self.todaysTasks objectAtIndex:selectedRow];
    
    if (priority != task.priority)
        [[[self undoManager]  prepareWithInvocationTarget:self] editPriorityForUndo:task.priority forTaskIndex:selectedRow];
    
    task.priority = priority;
    
    [self setPriorityButtonTitle:priority forTaskIndex:selectedRow];
    
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
    if (![task.taskName isEqualToString:newTaskName])
        [[[self undoManager] prepareWithInvocationTarget:self] editTaskNameForUndo:task.taskName forTaskIndex:selectedRow];
    
    NSMutableArray *split = [NSMutableArray arrayWithArray:[newTaskName componentsSeparatedByString:@" "]];
    
    NSUInteger hour = 0, minute = 0;
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
    
    
    if (prepositionIndex >= 0 && [NSTimeFormatter keywordIsInArray:TDPrepositionKeywords keyword:split[prepositionIndex]])
        split = [NSMutableArray arrayWithArray:[split subarrayWithRange:NSMakeRange(0, prepositionIndex)]];
    
    
    
    task.taskName = [split componentsJoinedByString:@" "];
    task.timeForTask = [NSTimeFormatter timeToInterval:hour andMinutes:minute];
    
    
    cellView.taskName.stringValue = task.taskName;
    cellView.taskTime.stringValue = [NSTimeFormatter formattedTimeString:hour andMinute:minute];
    
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
