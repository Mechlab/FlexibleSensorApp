//
//  JCLogger.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 25.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "JCSensorManager.h"

@interface JCLogger : NSObject {
	NSString * _path;
	NSFileHandle * _fileHandle;
	NSTimer * _syncTimer;
	NSUInteger _logCounter;
    JCSensorManager * _sensorManager;
    NSMutableArray *_logItems;
    NSMutableArray *_availableSensors;
    NSMutableArray *_buffer;
    int _eventCounter;
    int lineCounter;
    int sessionCount;
}

@property(nonatomic,strong) NSDate * startDate;
@property(readonly,strong) NSString * path;

@property (strong, nonatomic) NSMutableArray  *logItems;
@property (strong, nonatomic) NSMutableArray *availableSensors;
@property (strong, nonatomic) NSMutableArray *buffer;
@property (strong, nonatomic) JCSensorManager *sensorManager;
@property bool isLoggingSensors;
@property bool isLoggingImages;
@property (strong, nonatomic) NSString *dataLine;

- (NSTimeInterval)timestamp;

+ (id)loggerForDocumentName:(NSString*)name;

- initWithPath:(NSString*)path;
+ (NSString*)createLoggingSessionPathFromName:(NSString*)name;
- (void)resetDocumentName:(NSString*)name;
- (void)closeCSV;
- (void)openCSV;

- (void)logWithFormat:(NSString *)format, ...;
- (void)logNewLineWithUpdateFromSensor:(SensorIDs)sensorID;

- (void)logImage:(CGImageRef)image withFormat:(NSString *)format, ...;

// Start Stop Logging to Files
- (void)startSensorLogging;
- (void)stopSensorLogging;
- (void)startImageLogging;
- (void)stopImageLogging;

// Start new Sessions
- (void)startNewSession;

// De/-activate Sensors for Logging
- (void)activateLogForSensor:(NSUInteger)sensorID dimension:(NSUInteger)dimensionID;
- (void)activateLogForCompleteSensor:(NSUInteger)sensorID;
- (void)activateLogForAllSensors;
- (void)deactivateLogForSensor:(NSUInteger)sensorID dimension:(NSUInteger)dimensionID;
- (void)deactivateLogForCompleteSensor:(NSUInteger)sensorID;
- (void)deactivateLogForAllSensors;
- (void)initLogItems;

@end
