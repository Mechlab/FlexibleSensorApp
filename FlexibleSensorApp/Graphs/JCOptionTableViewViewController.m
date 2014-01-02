//
//  JCOptionTableViewViewController.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 17.11.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCOptionTableViewViewController.h"
#import "IonIcons.h"

@interface JCOptionTableViewViewController ()

@end
@implementation JCOptionTableViewViewController
@synthesize sensorLogOptionItems = _sensorLogOptionItems;

int updatetCellID = -1;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self initColors];
        [self initLoggingFlags];
    }
    return self;
}

- (void)initLoggingOptionsWithSensors:(NSMutableArray*)sensorDescriptions {
    // create Row for each Sensor in Array
    _sensorLogOptionItems=sensorDescriptions;
}

- (void)initLoggingFlags {
    BOOL b = TRUE;
    // TODO: replace with dynamic initializer
    [self setLoggingFlags:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithBool:b],[NSNumber numberWithBool:b],[NSNumber numberWithBool:b],[NSNumber numberWithBool:b],[NSNumber numberWithBool:b], nil]];
}

- (void)setLoggingFlagAtIndex:(int)i {
    [[self loggingFlags] replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:true]];
    [self.tableView reloadData];
}

- (void)resetLoggingFlagAtIndex:(int)i {
    [[self loggingFlags] replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:false]];
    [self.tableView reloadData];
}

- (bool)isLoggingAtIndex:(int)i {
    NSLog(@"logginFlag: %d",i);
    NSNumber* b = (NSNumber*)[[self loggingFlags] objectAtIndex:i];
    return [b boolValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _sensorLogOptionItems.count;
}


// Header for Table
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Sensor-Log";
}


// Accessory Button Pressed
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"TappedForRow");
    updatetCellID = indexPath.row;
    if ([self isLoggingAtIndex:indexPath.row]) {
        [self resetLoggingFlagAtIndex:indexPath.row];
    } else {
        [self setLoggingFlagAtIndex:indexPath.row];
    }
    [self.tableView reloadData];
    id appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate performSelector:@selector(loggingOptionButtonPressedWithIndexPath:) withObject:indexPath];
    
}


// Create Cell in Table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sensorDesc = [_sensorLogOptionItems objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil || indexPath.row == updatetCellID) {
        updatetCellID = -1;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        // UIButton as AccessaryView
        UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(1.0,1.0,15.0,15.0)];
        UIImage *icon;
        // GREEN CHECKMARK - ENABLED
        if ([self isLoggingAtIndex:indexPath.row]) {
            icon = [IonIcons imageWithIcon:icon_ios7_checkmark iconColor:_mechlabOrange
                                iconSize:15.0f
                             imageSize:CGSizeMake(15.0f, 15.0f)];
            [cell.textLabel setTextColor:_mechlabOrange];
        } else {
            // GRAY CIRCLE - DISABLED
            icon = [IonIcons imageWithIcon:icon_ios7_circle_outline
                                          iconColor:_darkGrey
                                           iconSize:15.0f
                                          imageSize:CGSizeMake(15.0f, 15.0f)];
            [cell.textLabel setTextColor:_darkGrey];
        }
        [checkButton setBackgroundImage:icon forState:UIControlStateNormal];
        //
        [checkButton addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = checkButton;

        
        // Selection background
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = _lightGrey;
        bgColorView.layer.cornerRadius = 2;
        bgColorView.layer.masksToBounds = YES;
        [cell setSelectedBackgroundView:bgColorView];
        
        // Font
        cell.textLabel.font = [UIFont fontWithName:@"DidactGothic" size:13.0];
        
        // Text in ContentView
        cell.textLabel.text = sensorDesc;
        

    }
    return cell;
}

// Sensor Logging ausschalten
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"deselect");
}

// Sensor Logging einschalten
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Select");
    [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)accessoryButtonTapped:(UIControl*)button withEvent:(UIEvent *)event {
//    NSLog(@"Button");
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if (indexPath == nil)
        return;
    [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
#pragma mark - Colors
- (void)initColors {
    _orange = [[UIColor alloc] initWithRed:1.0 green:103.0/255 blue:0.0 alpha:1.0];
    _lightGreen = [UIColor colorWithRed:202.0/255 green:242.0/255 blue:120.0/255 alpha:1.0];
    _middleGreen = [UIColor colorWithRed:148.0/255 green:198.0/255 blue:0.0 alpha:1.0];
    _darkGreen = [UIColor colorWithRed:113.0/255 green:104.0/255 blue:90.0/255 alpha:1.0];
    _darkGrey = [UIColor colorWithRed:62.0/255 green:61.0/255 blue:41.0/255 alpha:1.0];
    [self setMechlabOrange:[[UIColor alloc]initWithRed:241/255.0 green:124/255.0 blue:0.0 alpha:1.0]];
    [self setLightGrey:[[UIColor alloc]initWithRed:252/255.0 green:252/255.0 blue:252.0/255 alpha:1.0]];


}

@end
