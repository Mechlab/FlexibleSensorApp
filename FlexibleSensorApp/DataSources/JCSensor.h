//
//  JCSensor.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCSensor : NSObject{
    NSArray *_units;
    NSArray *_descriptions;
    NSArray *_labels;
    int _readers;
    int _adds;
    int _removes;
}

// get info data describing the sensor and it's dimensions
- (NSString*)descriptionOfDimension:(NSNumber*)id;
- (NSString*)descriptionOfSensor;
- (NSString*)labelOfDimension:(NSNumber*)id;
- (NSString*)unitOfDimension:(NSNumber*)id;

// create info data which describe the sensor and it's dimensions
- (NSArray*)createUnits;
- (NSArray*)createDescriptions;
- (NSArray*)createLabels;
- (int)dimensionCount;
- (NSString*)sensorKey;
- (NSString*)dimensionKey:(NSNumber*)id;
- (int)addReader;
- (int)removeReader;

// availabilaty if data arrived
@property bool firstDataArrived;

@property int readers;
@end
