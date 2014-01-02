//
//  JCSensorData.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "JCDeviceMotion.h"
#import "JCAccelerometer.h"
#import "JCGyroscope.h"
#import "JCLocation.h"
#import "JCHeartRateDevice.h"

@interface JCSensorData : NSObject{
    JCDeviceMotion *_deviceMotionInfo;
    JCAccelerometer *_accelerometerInfo;
    JCGyroscope *_gyroscopeInfo;
    JCLocation *_locationInfo;
    JCHeartRateDevice *_heartRateInfo;
    
    NSMutableArray *_deviceMotionData;
    NSMutableArray *_accelerometerData;
    NSMutableArray *_gyroscopeData;
    NSMutableArray *_locationData;
    NSMutableArray *_heartRateData;
    
    NSMutableArray *_sensors;
    NSMutableArray *_sensorInfoObjects;
    NSMutableArray *_isReadingSensor;
}

typedef NS_ENUM(NSInteger, SensorIDs) {
    SENSOR_DeviceMotion,
    SENSOR_Accelerometer,
    SENSOR_Gyroscope,
    SENSOR_Location,
    SENSOR_HeartRate,
};

// get methods for descriptions, units and values of sensor-dimensions
- (NSString*)unitFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID;
- (NSString*)descriptionFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID;
- (NSString*)descriptionFromSensor:(SensorIDs)sensorID;
- (NSString*)labelFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID;
- (double)valueFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID sender:(id)sender;
- (NSString*)valueAsStringFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID sender:(id)sender;


// method to savely add new samples
- (void)addNewSampleData:(id)data fromSensor:(SensorIDs)sensorID;

// Unique Keys
- (NSString*)keyForSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID;
- (NSString*)keyForSensor:(SensorIDs)sensorID;

// number of sensors and number of their dimensions
- (int)dimensionCountForSensor:(SensorIDs)sensorID;
- (int)sensorCount;


// data buffer arrays
@property (strong, nonatomic) NSMutableArray *deviceMotion;
@property (strong, nonatomic) NSMutableArray *accelerometer;
@property (strong, nonatomic) NSMutableArray *gyroscope;
@property (strong, nonatomic) NSMutableArray *location;
@property (strong, nonatomic) NSMutableArray *heartRate;



@end
