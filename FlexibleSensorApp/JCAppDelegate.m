//
//  JCAppDelegate.m
//  FlexibleSensorApp
//
//  Created by Johannes Camin on 02.01.14.
//  Copyright (c) 2014 Johannes Camin. All rights reserved.
//

#import "JCAppDelegate.h"
#import "JCSensorManager.h"

@implementation JCAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize sensorManager = _sensorManager;
@synthesize logger = _logger;
@synthesize sensorViewController = _sensorViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // View Controller
    _sensorViewController = [[JCSensorViewController alloc] init];
    self.window.rootViewController = self.sensorViewController;
    
    
    //Initialisierung der Sensoren und SensorDaten
    _sensorManager = [JCSensorManager sharedSensorManager];
    [_sensorManager setSensorManagerDelegate:self];
    
    
    //Logger mit Ordnername initialisieren
    _logger = [JCLogger loggerForDocumentName:@"Loggin Session"];
    [_logger initLogItems];
    [self initLoggerWithSessionFlags];
    
    
    // Sensor Daten als Input für GraphView festlegen
    [_sensorViewController.graphViewTopLeft setXAxisSensorInput:SENSOR_Accelerometer dimension:DIMENSION_Accelerometer_AccelerationY];
    [_sensorViewController.graphViewTopLeft setYAxisSensorInput:SENSOR_Accelerometer dimension:DIMENSION_Accelerometer_AccelerationZ];
    
    [_sensorViewController.graphViewTopRight setXAxisSensorInput:SENSOR_Location dimension:DIMENSION_Location_Speed];
    [_sensorViewController.graphViewTopRight setYAxisSensorInput:SENSOR_Accelerometer dimension:DIMENSION_Accelerometer_AccelerationZ];
    
    [_sensorViewController.graphViewBottomLeft setXAxisSensorInput:SENSOR_Location dimension:DIMENSION_Location_Speed];
    [_sensorViewController.graphViewBottomLeft setYAxisSensorInput:SENSOR_Accelerometer dimension:DIMENSION_Accelerometer_AccelerationY];
    
    [_sensorViewController.graphViewBottomRight setXAxisSensorInput:SENSOR_Location dimension:DIMENSION_Location_Speed];
    [_sensorViewController.graphViewBottomRight setYAxisSensorInput:SENSOR_Gyroscope dimension:DIMENSION_Gyroscope_GyroRotationRateY];
    
    // Alle GraphViews initialisieren
    [_sensorViewController initGraphViews];
    
    
    // Option View initialisieren
    //[_sensorViewController initOptionView];
    
    // View anzeigen
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Sensor Loggin Stoppen
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(stopSensorLogging)]) {
        [appDelegate stopSensorLogging];
    }
    
    // Warnung anzeigen
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Zu wenig Speicher!"
                                                        message:@"The device is running out of memory. Logging has been stopped and the files have been saved. Feel free to start again!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Weiter"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack
/*
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SensorToCoreDataTest" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SensorToCoreDataTest.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         *//*
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
*/
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - SensorManagerDelegate

// Is called when new sensordata updates
- (void)handleRecentData:(id)sender FromSensor:(NSUInteger)sensorID {
    
    // Update Views
    [[self sensorViewController] updateView];
    
    // If Logging Session has started
    if ([_logger isLoggingSensors]) {
        // Pass new data to logger instance and serialize tasks
        [_logger logNewLineWithUpdateFromSensor:sensorID];
    }
}



#pragma mark - SensorLogging
- (void)startSensorLogging {
    
    [_logger startSensorLogging];
    [_sensorManager startUpdatesForAllSensors];
    
    // View Controller highlights updaten
    [_sensorViewController togglePlayButtonWithLogginConstraint:true];
}

- (void)stopSensorLogging {
    [_sensorManager stopAllSensorUpdates];
    [_logger stopSensorLogging];
    
    // View Controller highlights updaten
    [_sensorViewController togglePlayButtonWithLogginConstraint:false];
}

#pragma mark - SensorViewControllerDelegate

- (void)playButtonPressed:(id)sender {
    
    // Stop if is logging
    if([_logger isLoggingSensors]) {
        [self stopSensorLogging];
    }
    // Start if is not logging
    else {
        [self initLoggerWithSessionFlags];
        [self startSensorLogging];
    }
}

- (void)stopButtonPressed:(id)sender {
    [self stopSensorLogging];
    [_logger startNewSession];
}

- (void)imageButtonPressed:(id)sender {
    if ([_logger isLoggingImages]) {
        NSLog(@"stop");
        [_logger stopImageLogging];
    }
    else {
        NSLog(@"start");
        [_logger startImageLogging];
    }
}

- (void)sessionButtonPressed:(id)sender {
    [_logger startNewSession];
    
}

- (void)resetButtonPressed:(id)sender {
    // View Controller reseten
    // Stop Logging Session
    [self stopSensorLogging];
}

- (void)toggleOption:(NSUInteger)optionID From:(id)sender {
    // toggle option in app-settings
}

- (void)loggingOptionButtonPressedWithIndexPath:(NSIndexPath *)indexPath {
    int sensor = indexPath.row;
    [self toggleLoggingOptionForCompleteSensor:sensor From:self];
    NSLog(@"TOGGLE");
}

- (void)toggleLoggingOptionForSensor:(SensorIDs)sensorID Dimension:(NSUInteger)dimensionID From:(id)sender {
    NSLog(@"Toggle Logging Option For Sensor: %@ Dimension: %@",[_sensorManager.sensorData keyForSensor:sensorID], [_sensorManager.sensorData descriptionFromSensor:sensorID dimension:dimensionID]);
    
    // get bool in logItem Array and invert it
    if ([[[_logger.logItems objectAtIndex:sensorID] objectAtIndex:dimensionID] boolValue]) {
        [_logger deactivateLogForSensor:sensorID dimension:dimensionID];
    } else {
        [_logger activateLogForSensor:sensorID dimension:dimensionID];
    }
}

- (void)toggleLoggingOptionForCompleteSensor:(SensorIDs)sensorID From:(id)sender {
    NSLog(@"Toggle Logging Option For All Dimensions from Sensor: %@",[_sensorManager.sensorData keyForSensor:sensorID]);
    
    bool allDeactivated= TRUE;
    id sensor = [_logger.logItems objectAtIndex:sensorID];
    int dimensionCount = [_sensorManager.sensorData dimensionCountForSensor:sensorID];
    
    // Schauen, ob alle Dimensionen deaktiviert sind
    for (int i = 0; i < dimensionCount; i++) {
        if([[sensor objectAtIndex:i] boolValue]) {
            // Sobald eine aktivierte gefunden, bool setzen und Suche abbrechen
            allDeactivated = FALSE;
            break;
        }
    }
    
    // wenn alle deaktivert, dann aktiverien
    if(allDeactivated) {
        [_logger activateLogForCompleteSensor:sensorID];
        [[_sensorViewController optionViewController] setLoggingFlagAtIndex:sensorID];
    } else {
        // ansonsten alle deaktiveren
        [_logger deactivateLogForCompleteSensor:sensorID];
        [[_sensorViewController optionViewController] resetLoggingFlagAtIndex:sensorID];
    }
}

- (void)toggleLoggingOptionForAllSensors:(id)sender {
    
    // Reconfigure
    NSLog(@"Toggle Logging Option For all Sensors");
    
    bool allDeactivated= TRUE;
    int sensorCount = [_sensorManager.sensorData sensorCount];
    id sensor;
    int dimensionCount;
    
    // Schauen, ob alle Dimensionen deaktiviert sind
    for (int h = 0; h < sensorCount; h++)
    {
        sensor =[_logger.logItems objectAtIndex:h];
        dimensionCount = [_sensorManager.sensorData dimensionCountForSensor:h];
        
        // Alle Dimensionen aller Sensoren
        for (int i = 0; i < dimensionCount; i++) {
            if([[sensor objectAtIndex:i] boolValue]) {
                // Sobald eine aktivierte gefunden, bool setzen und innere Schleife beenden
                allDeactivated = FALSE;
                break;
            }
        }
        // Wenn einer aktiviert, dann äußerer Schleife beenden
        if(allDeactivated == FALSE) {
            break;
        }
        
    }
    
    // wenn alle deaktivert, dann aktiverien
    if(allDeactivated) {
        for (int i = 0; i < sensorCount; i++) {
            [_logger activateLogForCompleteSensor:i];
            [[_sensorViewController optionViewController] setLoggingFlagAtIndex:i];
        }
    } else {
        // ansonsten alle deaktiveren
        for (int i = 0; i < sensorCount; i++) {
            [_logger deactivateLogForCompleteSensor:i];
            [[_sensorViewController optionViewController] setLoggingFlagAtIndex:i];
            
        }
    }
}

- (void)initLoggerWithSessionFlags {
    // Stop actual Logging Session
    [self stopButtonPressed:self];
    
    int sensorCount = [_sensorManager.sensorData sensorCount];
    id sensor;
    
    // Für jeden Sensor schauen, ob Option selektiert
    for (int i = 0; i < sensorCount; i++) {
        sensor =[_logger.logItems objectAtIndex:i];
        // bool loggerFlag = [[sensor objectAtIndex:i] boolValue];
        bool optionFlag = [[_sensorViewController optionViewController] isLoggingAtIndex:i];
        // if(loggerFlag != optionFlag) {
        if (optionFlag) {
            [_logger activateLogForCompleteSensor:i];
        } else {
            [_logger deactivateLogForCompleteSensor:i];
        }
        //}
    }
}

- (void)updateHeartRateIcon:(bool)isActive {
    [[self sensorViewController] setHeartButtonActive:isActive];
}


@end
