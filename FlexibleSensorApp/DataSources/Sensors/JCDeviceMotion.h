//
//  JCDeviceMotion.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCSensor.h"

typedef NS_ENUM(NSInteger, DeviceMotionDimensionIDs) {
    DIMENSION_DeviceMotion_AttitudeRoll,
    DIMENSION_DeviceMotion_AttitudePitch,
    DIMENSION_DeviceMotion_AttitudeYaw,
    DIMENSION_DeviceMotion_RotationRateX,
    DIMENSION_DeviceMotion_RotationRateY,
    DIMENSION_DeviceMotion_RotationRateZ,
    DIMENSION_DeviceMotion_GravityX,
    DIMENSION_DeviceMotion_GravityY,
    DIMENSION_DeviceMotion_GravityZ,
    DIMENSION_DeviceMotion_UserAccelerationX,
    DIMENSION_DeviceMotion_UserAccelerationY,
    DIMENSION_DeviceMotion_UserAccelerationZ,
    DIMENSION_DeviceMotion_MagenticFieldX,
    DIMENSION_DeviceMotion_MagenticFieldY,
    DIMENSION_DeviceMotion_MagenticFieldZ,
    DIMENSION_DeviceMotion_MagenticFieldAccuracy,
};

@interface JCDeviceMotion : JCSensor

@end
