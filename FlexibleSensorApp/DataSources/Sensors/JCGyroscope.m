//
//  JCGyroscope.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCGyroscope.h"

@implementation JCGyroscope

- (id)init {
    // init Gyroscope Info
    self = [super init];
    NSLog(@"\t%@\t\t - - - Gyroscope Info-Object",self);
    return self;
}

- (NSArray*)createUnits {
    NSString *RotationRate = @"°/s";

    return [[NSArray alloc] initWithObjects:
            RotationRate, RotationRate, RotationRate,
            nil];
}

- (NSArray*)createDescriptions {
    return [[NSArray alloc] initWithObjects:
            @"RotationRateX", @"RotationRateY", @"RotationRateZ",
            nil];
}

- (NSArray*)createLabels {
    return [[NSArray alloc] initWithObjects:
            @"drsX",@"drsY",@"drsZ", nil];
}

- (int)dimensionCount {
    return 3;
}

- (NSString*)sensorKey {
    return @"Gyroscope";
}

- (NSString*)getDimensionKey:(NSNumber *)id {
    return [self descriptionOfDimension:id];
}

- (NSString*)descriptionOfSensor {
    return @"Drehrate";
}

@end
