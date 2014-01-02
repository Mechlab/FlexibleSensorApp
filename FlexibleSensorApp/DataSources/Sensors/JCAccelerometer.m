//
//  JCAccelerometer.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCAccelerometer.h"

@implementation JCAccelerometer

- (id)init {
    // init Accelerometer Info
    self = [super init];
    NSLog(@"\t%@\t - - - Accelerometer Info-Object",self);
    return self;
}

- (NSArray*)createUnits {
    NSString *Acceleration = @"g";
    
    return [[NSArray alloc] initWithObjects:Acceleration, Acceleration, Acceleration, nil];
}

- (NSArray*)createDescriptions {
    return [[NSArray alloc] initWithObjects:
            @"AccelerationX", @"AccelerationY", @"AccelerationZ",
            nil];
}

- (NSArray*)createLabels {
    return [[NSArray alloc] initWithObjects:
            @"aX",@"aY",@"aZ", nil];
}

- (int)dimensionCount {
    return 3;
}

- (NSString*)sensorKey {
    return @"Accelerometer";
}

- (NSString*)dimensionKey:(NSNumber *)id {
    return [self descriptionOfDimension:id];
}

- (NSString*)descriptionOfSensor {
    return @"Beschleunigung";
}

@end
