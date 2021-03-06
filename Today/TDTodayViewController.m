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

#import "DHCircularProgressView.h"

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

-(void)loadView
{
    TDTodaysTask *task = [[TDTodaysTask alloc] initWithTaskName:@"test"];
    task.timeForTask = 5;
    [self.todaysTasks addObject:task];
    
    //Loads all the stuff
    //Code above this line will run before the view loads
    [super loadView];
    //Code under the line will run after the view loads
    
    //Documentation says loadView may be called multiple times so NSLog here allows easier debugging
    NSLog (@"LOAD VIEW");
    
    //Initialize variables when view loads
    selectedRow = self.tableView.selectedRow;
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
    
    //Setup table view
    //Sorting
    [self sortTableView:TDSortCompleted];
    
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
    [cellView.taskName setBackgroundColor:TDTableRowPriorityBackgroundColor[task.priority]];
    
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
    [cellView.taskTime setBackgroundColor:TDTableRowPriorityBackgroundColor[task.priority]];
    
    
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
    
    //Circular progress view
    [cellView.progressView setMaxValue:1];
    [cellView.progressView setCurrentValue:0];
    
    [cellView.progressView setFillColor:TDTableRowPriorityBackgroundColor[task.priority]];
    
    return cellView;
}

//Setup called by the app delegate so things stay the same even after the view switched back
-(void)switchedToCurrentView
{
    //Select the row that was previously selected
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

//Helper functions for IBAction and undo methods which calls the main add task method
-(void)addNewTask:(TDTodaysTask *)task{
    [self addNewTask:task atIndex:self.todaysTasks.count];
}

//Adds a new task
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

//Add task for undo
-(void) addNewTaskForUndo:(TDTodaysTask *)task atIndex:(NSUInteger)index
{
    [[[self undoManager] prepareWithInvocationTarget:self] removeTaskForUndo:index];
    
    [self addNewTask:task atIndex:index];
    
    [self saveDataToDisk:self.todaysTasks];
}

//Remove task method
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

//
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

-(void)sortTableView:(NSInteger)option
{
    
    TDTodaysTask *task;
    
    if (self.tableView.selectedRow != -1)
         task = self.todaysTasks[selectedRow];
    
    NSSortDescriptor *sortDescriptor;
    
    //Sort by complete
    if (option == TDSortCompleted)
    {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2){
            
            if ([(TDTodaysTask *)obj1 completed] == [(TDTodaysTask *)obj2 completed])
                return NSOrderedSame;
            else if ([(TDTodaysTask *)obj1 completed] < [(TDTodaysTask *)obj2 completed])
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
            
        } ];
        
    }
    else if (option == TDSortPriority)
    {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES comparator:^NSComparisonResult(TDTodaysTask *obj1, TDTodaysTask *obj2) {
    
            //Make sure it is also task complete sorted too
            if ([obj1 completed] == [obj2 completed])
            {
                if ([obj1 priority] == [obj2 priority])
                    return NSOrderedSame;
                //If priority = 0 it should be descending
                else if ((([obj1 priority] != 0) && [obj1 priority] < [obj2 priority]) || [obj2 priority] == 0)
                    return NSOrderedAscending;
                else
                    return NSOrderedDescending;
            }
            else if ([obj1 completed] < [obj2 completed])
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
        }];
    }
    else if (option == TDSortTaskName)
    {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"taskName" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2){
            
            if ([(TDTodaysTask *)obj1 completed] == [(TDTodaysTask *)obj2 completed])
                return [[(TDTodaysTask *)obj1 taskName] compare:[(TDTodaysTask *)obj2 taskName]];
            else if ([(TDTodaysTask *)obj1 completed] < [(TDTodaysTask *)obj2 completed])
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
            
            
        }];
        
    }
    
    [[self.tableView tableColumns][0] setSortDescriptorPrototype:sortDescriptor];
    [self.todaysTasks sortUsingComparator:sortDescriptor.comparator];
    
    //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.todaysTasks.count)] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    
    [self saveDataToDisk:self.todaysTasks];
    
    if (task != nil)
    {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.todaysTasks indexOfObject:task]] byExtendingSelection:NO];
    }
}

#pragma mark NSTimer Methods

-(void)taskTimer:(NSTimer *)timer
{
    //Key: "view"
    //Key: "task"
    
    
  //  task.timeWorkedOnTask = [[NSDate date] timeIntervalSinceDate:task.timerStartDate];
    
    currentWorkingView.progressView.currentValue = currentWorkingTask.timeWorkedOnTask + [[NSDate date] timeIntervalSinceDate:currentWorkingTask.timerStartDate];
    
    //NSLog (@"%f", currentWorkingTask.timeWorkedOnTask + [[NSDate date] timeIntervalSinceDate:currentWorkingTask.timerStartDate]);
    
    NSTimeInterval secondsRemaining = currentWorkingTask.timeForTask - [[NSDate date] timeIntervalSinceDate:currentWorkingTask.timerStartDate];
    
    NSString *dockLabelString = [self secondsToString:secondsRemaining];
    
  //  [[NSApp dockTile] setShowsApplicationBadge:YES];
    [[NSApp dockTile] setBadgeLabel: dockLabelString];
    
    if (currentWorkingView.progressView.currentValue >= currentWorkingView.progressView.maxValue)
    {
        
        [[NSApp dockTile] setBadgeLabel:@""];
        
    //    [[NSApp dockTile] setShowsApplicationBadge:NO];
        
        [currentWorkingTask.taskTimer invalidate];
        [self displayCompleteNotificationWithInfo:nil];
    }
}


-(NSString *)secondsToString:(NSTimeInterval)time
{
    NSString *label = @"";
    
    if (time < 60)
        label = [NSString stringWithFormat:@"%is", (int)time];
    else if (time < 3600)
        label = [NSString stringWithFormat:@"00:%i", (int)time/60];
    else
        label = [NSString stringWithFormat:@"%i:%i", (int)time/3600, ((int)time%3600)/60];
    
    
    return label;
}


-(void)displayCompleteNotificationWithInfo:(NSDictionary *)userInfo
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Today";
    notification.informativeText = [NSString stringWithFormat:@"Task \"%@\" completed", currentWorkingTask.taskName];
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.hasActionButton = YES;
    notification.actionButtonTitle = @"Mark as Complete";
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
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

//When complete task it
-(IBAction)completedTask:(id)sender
{
    TDTodaysTaskCellView *cellView = (TDTodaysTaskCellView *)[sender superview];
    
    BOOL completed = [(TDTodaysTask *)[cellView objectValue] completed];
    
    [[[self undoManager] prepareWithInvocationTarget: self] completeTaskForUndo:completed  forTaskView:cellView];
    
    [(TDTodaysTask *)cellView.objectValue setCompleted:!completed];
    
    [self sortTableView:TDSortCompleted];

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


-(IBAction)sortByMenu:(id)sender
{
    NSString *title = [sender title];
    
    if ([title isEqualToString:@"Priority"])
    {
        [self sortTableView:TDSortPriority];
    }
    else if ([title isEqualToString:@"Task Name"])
    {
        [self sortTableView:TDSortTaskName];
    }
}

-(IBAction)toggleTask:(NSMenuItem *)sender
{
    if ([sender.title isEqualToString:@"Start Task"]) //Start a task
    {
        TDTodaysTask *task = self.todaysTasks[selectedRow];
        TDTodaysTaskCellView *view = [self.tableView viewAtColumn:0 row:selectedRow makeIfNecessary:NO];
    
        //So the controller knows which task is currently running
        currentWorkingTask = task;
        currentWorkingView = view;
        
        //Setup menu item so it says pause instead of start
        self.startTaskMenuItem.title = @"Pause Task";
    
        task.timerStartDate = [NSDate date];
        [view.progressView setMaxValue:task.timeForTask];
        [view.progressView setCurrentValue:task.timeWorkedOnTask];
        
        //Change view to task timer view
        
        
    
        task.taskTimer = [NSTimer timerWithTimeInterval:1.0/3.0 target:self selector:@selector(taskTimer:) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:task.taskTimer forMode:NSRunLoopCommonModes];
        
    }
    else //sender.title is equal to @"Pause"
    {
        self.startTaskMenuItem.title = @"Start Task";
        [currentWorkingTask.taskTimer invalidate];
        
        currentWorkingTask.timeWorkedOnTask += [[NSDate date] timeIntervalSinceDate:currentWorkingTask.timerStartDate];
        
    }
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

-(void)tableViewSelectionIsChanging:(NSNotification *)notification
{
    NSLog (@"Selection is Changing");
    
    //Change instance variable
    selectionChanged = true;
    
    TDTodaysTask *task = lastSelectedCellView.objectValue;
    
    
    if (lastSelectedCellView)
    {
        [lastSelectedCellView.taskName setBackgroundColor:TDTableRowPriorityBackgroundColor[task.priority]];
        [lastSelectedCellView.taskTime setBackgroundColor:TDTableRowPriorityBackgroundColor[task.priority]];
        
        [lastSelectedCellView.progressView setBackgroundColor:TDTableRowPriorityBackgroundColor[task.priority]];
    }
    if (self.tableView.selectedRow>-1)
    {
        TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:self.tableView.selectedRow makeIfNecessary:NO];
        [cellView.taskName setBackgroundColor:TDTableRowHighlightBackgroundColor];
        [cellView.taskTime setBackgroundColor:TDTableRowHighlightBackgroundColor];
        
        [cellView.progressView setBackgroundColor:TDTableRowHighlightBackgroundColor];
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
    NSLog (@"Selection is Changing");
    
    selectedRow = [self.tableView selectedRow];
    
    TDTodaysTask *task = lastSelectedCellView.objectValue;
    
    
    if (!selectionChanged)
    {
        if (lastSelectedCellView)
        {
            [lastSelectedCellView.taskName setBackgroundColor:TDTableRowPriorityBackgroundColor[task.priority]];
            [lastSelectedCellView.taskTime setBackgroundColor:TDTableRowPriorityBackgroundColor[task.priority]];
            
            [lastSelectedCellView.progressView setBackgroundColor:TDTableRowPriorityBackgroundColor[task.priority]];
            
        }
        if (self.tableView.selectedRow>-1)
        {
            TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:self.tableView.selectedColumn row:self.tableView.selectedRow makeIfNecessary:NO];
            [cellView.taskName setBackgroundColor:TDTableRowHighlightBackgroundColor];
            [cellView.taskTime setBackgroundColor:TDTableRowHighlightBackgroundColor];
            [cellView.progressView setBackgroundColor:TDTableRowHighlightBackgroundColor];
            lastSelectedCellView = cellView;
        }
        else
            lastSelectedCellView = nil;
    }
    selectionChanged = false;
    
}

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [self.todaysTasks sortUsingComparator:[self.tableView sortDescriptors][0]];
    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.todaysTasks.count)] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    for (int i = 0; i < self.todaysTasks.count; i++)
    {
        TDTodaysTaskCellView *cellView = [self.tableView viewAtColumn:0 row:i makeIfNecessary:NO];
        [cellView.taskName setBackgroundColor:TDTableRowPriorityBackgroundColor[[(TDTodaysTask *)self.todaysTasks[i] priority]]];
    }
    
}

#pragma mark NSUserNotificationDelegate

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked)
    {
        NSLog (@"Activated");
        currentWorkingTask.completed = YES;
        currentWorkingView.completed.state = NSOnState;
        
        currentWorkingTask = nil;
        currentWorkingView = nil;
        
        [self saveDataToDisk:self.todaysTasks];
    }
}

#pragma mark Inherited Methods

//Why is this such a bitch
-(NSUndoManager *)undoManager
{
    return [[[self view] window] undoManager];
}

@end
