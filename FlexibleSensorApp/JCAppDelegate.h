//
//  JCAppDelegate.h
//  FlexibleSensorApp
//
//  Created by Johannes Camin on 02.01.14.
//  Copyright (c) 2014 Johannes Camin. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "JCSensorViewController.h"
#import "JCSensorManager.h"
#import "JCFilterManager.h"
#import "JCLogger.h"

@interface JCAppDelegate : UIResponder <UIApplicationDelegate,JCSensorManagerDelegate>
{
}

// appDelegate
@property (strong, nonatomic) UIWindow *window;



// sensorManager
@property (strong, nonatomic) JCSensorManager *sensorManager;
@property (strong, nonatomic) JCFilterManager *filterManager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)handleRecentData:(id)sender FromSensor:(NSUInteger)sensorID;

// sensorLogger
@property (strong, nonatomic) JCLogger *logger;
- (void)startSensorLogging;
- (void)stopSensorLogging;
- (void)loggingOptionButtonPressedWithIndexPath:(NSIndexPath*)indexPath;

// core data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// SensorViewController
@property (strong, nonatomic) JCSensorViewController *sensorViewController;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)imageButtonPressed:(id)sender;
- (IBAction)sessionButtonPressed:(id)sender;
- (IBAction)toggleOption:(NSUInteger)optionID From:(id)sender;
- (IBAction)toggleLoggingOptionForSensor:(SensorIDs)sensorID Dimension:(NSUInteger)dimensionID From:(id)sender;
- (IBAction)toggleLoggingOptionForCompleteSensor:(SensorIDs)sensorID From:(id)sender;
- (IBAction)toggleLoggingOptionForAllSensors:(id)sender;
- (void)updateHeartRateIcon:(bool)isActive;
@end