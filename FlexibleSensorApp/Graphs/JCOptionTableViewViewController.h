//
//  JCOptionTableViewViewController.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 17.11.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCSensorManager.h"
#import "JCFilterManager.h"

@interface JCOptionTableViewViewController : UITableViewController


- (void)initLoggingOptionsWithSensors:(NSMutableArray*)sensorIDs;
@property NSMutableArray* sensorLogOptionItems;
@property NSMutableArray* loggingFlags;
- (void)setLoggingFlagAtIndex:(int)i;
- (void)resetLoggingFlagAtIndex:(int)i;
- (bool)isLoggingAtIndex:(int)i;

// Colors
@property (strong) UIColor *lightGreen;
@property (strong) UIColor *orange;
@property (strong) UIColor *middleGreen;
@property (strong) UIColor *darkGrey;
@property (strong) UIColor *lightGrey;
@property (strong) UIColor *darkGreen;
@property (strong) UIColor *mechlabOrange;
- (void)initColors;


@end
