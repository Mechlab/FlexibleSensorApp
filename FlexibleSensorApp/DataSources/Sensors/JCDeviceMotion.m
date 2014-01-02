//
//  JCDeviceMotion.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCDeviceMotion.h"

@implementation JCDeviceMotion

- (id)init {
    // init
    self = [super init];
    NSLog(@"\t%@\t - - - DeviceMotion Info-Object",self);
    return self;
}

- (NSArray*)createUnits {
    NSString *Attitude = @"rad";
    NSString *RotationRate = @"rad/s";
    NSString *Gravity = @"g";
    NSString *UserAcceleration = @"g";
    NSString *MagneticField = @"mT";
    NSString *Accuracy = @"";
    
    return [[NSArray alloc] initWithObjects:
            Attitude, Attitude, Attitude,
            RotationRate, RotationRate, RotationRate,
            Gravity, Gravity, Gravity,
            UserAcceleration, UserAcceleration, UserAcceleration,
            MagneticField, MagneticField, MagneticField,
            Accuracy,
            nil];
}

- (NSArray*)createDescriptions {
    return [[NSArray alloc] initWithObjects:
            @"AttitudeX", @"AttitudeY", @"AttitudeZ",
            @"CMRotationRateX", @"CMRotationRateY", @"CMRotationRateZ",
            @"GravityX",@"GravityY",@"GravityZ",
            @"UserAccelX", @"UserAccelY", @"UserAccelZ",
            @"MagneticFieldX", @"MagneticFieldY", @"MagneticFieldZ",
            @"MagneticFieldAccuracy",
            nil];
}

- (NSArray*)createLabels {
    return [[NSArray alloc] initWithObjects:
            @"atX", @"atY", @"atZ",
            @"drsX", @"drsY", @"drsZ",
            @"gravX",@"gravY",@"gravZ",
            @"aX", @"aY", @"aZ",
            @"magX", @"magY", @"magZ",
            @"MagAccuracy",
            nil];
}

- (int)dimensionCount {
    return 16;
}

- (NSString*)sensorKey {
    return @"DeviceMotion";
}

- (NSString*)dimensionKey:(NSNumber *)id {
    return [self descriptionOfDimension:id];
}

- (NSString*)descriptionOfSensor {
    return @"DeviceMotion";
}


@end
