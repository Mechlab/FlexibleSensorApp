//
//  JCGyroscope.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCSensor.h"



typedef NS_ENUM(NSInteger, GyroscopeIDs) {
    DIMENSION_Gyroscope_GyroRotationRateX,
    DIMENSION_Gyroscope_GyroRotationRateY,
    DIMENSION_Gyroscope_GyroRotationRateZ,
};
@interface JCGyroscope : JCSensor

@end
