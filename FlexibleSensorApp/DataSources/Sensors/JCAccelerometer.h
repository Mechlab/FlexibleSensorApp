//
//  JCAccelerometer.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCSensor.h"


typedef NS_ENUM(NSInteger, AccelerometerIDs) {
    DIMENSION_Accelerometer_AccelerationX,
    DIMENSION_Accelerometer_AccelerationY,
    DIMENSION_Accelerometer_AccelerationZ,
};

@interface JCAccelerometer : JCSensor
@end
