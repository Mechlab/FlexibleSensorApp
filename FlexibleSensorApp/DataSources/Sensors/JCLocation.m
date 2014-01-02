//
//  JCLocation.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCLocation.h"

@implementation JCLocation

- (id)init {
    // init Location Info
    self = [super init];
    NSLog(@"\t%@\t\t - - - Location Info-Object",self);
    return self;
}

- (NSArray*)createUnits {
    // Used on graphView Axis
    NSString *LatLong = @"°";
    NSString *Altitude = @"m";
    NSString *Accuracy = @"";
    NSString *Speed = @"m/s";
    NSString *Course = @"°";
    
    return [[NSArray alloc] initWithObjects:
            LatLong,
            LatLong,
            Altitude,
            Accuracy,
            Accuracy,
            Speed,
            Course,
            nil];
}

- (NSArray*)createDescriptions {
    // Used in CSV Header
    return [[NSArray alloc] initWithObjects:
            @"Latitude",
            @"Longitude",
            @"Altitude",
            @"VerticalAccuracy",
            @"HorizontalAccuracy",
            @"Speed",
            @"Course",
            nil];
}

- (NSArray*)createLabels {
    // Used on graphView Axis
    return [[NSArray alloc] initWithObjects:
            @"lat",
            @"long",
            @"alt",
            @"accV",
            @"accH",
            @"Vfz",
            @"course",
            nil];
}

- (int)dimensionCount {
    return 7;
}

- (NSString*)sensorKey {
    return @"Location";
}

- (NSString*)dimensionKey:(NSNumber *)id {
    return [self descriptionOfDimension:id];
}

- (NSString*)descriptionOfSensor {
    return @"GPS";
}

@end
