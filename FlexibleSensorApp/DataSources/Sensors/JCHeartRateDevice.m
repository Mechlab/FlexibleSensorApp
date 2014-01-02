//
//  JCHeartRateDevice.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 02.12.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCHeartRateDevice.h"

@implementation JCHeartRateDevice

- (id)init {
    // init HeartRate Info
    self = [super init];
    NSLog(@"\t%@\t\t - - - HeartRate Info-Object",self);
    return self;
}

- (NSArray*)createUnits {
    // Used on graphView Axis
    NSString *bpm = @"bpm";

    return [[NSArray alloc] initWithObjects:
            bpm,
            nil];
}

- (NSArray*)createDescriptions {
    // Used in CSV Header
    return [[NSArray alloc] initWithObjects:
            @"HeartRate",
            nil];
}

- (NSArray*)createLabels {
    // Used on graphView Axis
    return [[NSArray alloc] initWithObjects:
            @"lat",
            nil];
}

- (int)dimensionCount {
    return 1;
}

- (NSString*)sensorKey {
    return @"HeartRateDevice";
}

- (NSString*)dimensionKey:(NSNumber *)id {
    return [self descriptionOfDimension:id];
}

- (NSString*)descriptionOfSensor {
    return @"HeartRate";
}
@end
