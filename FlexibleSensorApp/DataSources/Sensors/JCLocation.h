//
//  JCLocation.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCSensor.h"


typedef NS_ENUM(NSInteger, LocationIDs) {
    DIMENSION_Location_Latitude,
    DIMENSION_Location_Longitude,
    DIMENSION_Location_Altitude,
    DIMENSION_Location_VerticalAccuracy,
    DIMENSION_Location_HorizontalAccuracy,
    DIMENSION_Location_Speed,
    DIMENSION_Location_Course,
};

@interface JCLocation : JCSensor

@end
