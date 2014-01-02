//
//  JCHeartRateDevice.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 02.12.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCSensor.h"

typedef NS_ENUM(NSInteger, HeartRateIDs) {
    DIMENSION_HeartRate_Rate,
};

@interface JCHeartRateDevice : JCSensor

@end
