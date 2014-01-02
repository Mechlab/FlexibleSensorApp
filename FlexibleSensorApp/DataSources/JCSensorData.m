//
//  JCSensorData.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCSensorData.h"

@implementation JCSensorData

@synthesize deviceMotion = _deviceMotionData;
@synthesize accelerometer = _accelerometerData;
@synthesize gyroscope = _gyroscopeData;
@synthesize location = _locationData;
@synthesize heartRate = _heartRateData;


#pragma mark - initializer
- (id)init {
    self = [super init];
    // create Sensors
    if (self) {
        // init SensorInfos
        [self initSensors];
        [self initSensorInfo];
    }
    // init data
    return self;
}

- (void)initSensors {
    // init SensorData
    NSLog(@"\t%@\t\t - - SensorData",self);
    _deviceMotionData = [[NSMutableArray alloc] initWithObjects:[[CMDeviceMotion alloc]init], nil];
    _accelerometerData = [[NSMutableArray alloc] initWithObjects:[[CMAccelerometerData alloc] init], nil];
    _gyroscopeData = [[NSMutableArray alloc] initWithObjects:[[CMGyroData alloc] init], nil];
    _locationData = [[NSMutableArray alloc] initWithObjects:[[CLLocation alloc] init], nil];
    _heartRateData = [[NSMutableArray alloc] initWithObjects:[[NSData alloc] init], nil];
    
    // add SensorData to sensors
    _sensors = [[NSMutableArray alloc] initWithObjects:_deviceMotionData, _accelerometerData, _gyroscopeData, _locationData, _heartRateData, nil];
}

- (void)initSensorInfo {
    // init SensorInfoObjects
    NSLog(@"\t%@\t\t - - SensorInfoObjects:",self);
    
    _deviceMotionInfo = [[JCDeviceMotion alloc] init];
    _accelerometerInfo = [[JCAccelerometer alloc] init];
    _gyroscopeInfo = [[JCGyroscope alloc] init];
    _locationInfo = [[JCLocation alloc] init];
    _heartRateInfo = [[JCHeartRateDevice alloc] init];
    
    // add SensorInfoObjects to sensorInfoObjects array
    _sensorInfoObjects = [[NSMutableArray alloc] initWithObjects:_deviceMotionInfo, _accelerometerInfo, _gyroscopeInfo, _locationInfo, _heartRateInfo, nil];
}

- (void)initIsReadingSensor {
    //init with 0 for not reading any sensors
    for(int i = 0; i <= [_sensors count]; i++) {
        [_isReadingSensor addObject:[[NSNumber alloc] initWithBool:FALSE]];
    }
}

#pragma mark - sensor data getter
- (NSString*)unitFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID {
    if(sensorID>=[_sensors count])
    {
        NSLog(@"Error:\t%@\t - SensorID(%d) out of Range:(0 - %d)",self,sensorID,[_sensors count]);
        return @"";
    }
    NSNumber* dimID = [[NSNumber alloc] initWithUnsignedInt:dimensionID];
    return [[_sensorInfoObjects objectAtIndex:sensorID] performSelector:@selector(unitOfDimension:) withObject:dimID];
}

- (NSString*)labelFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID {
    if(sensorID>=[_sensors count])
    {
        NSLog(@"Error:\t%@\t - SensorID(%d) out of Range:(0 - %d)",self,sensorID,[_sensors count]);
        return @"";
    }
    NSNumber* dimID = [[NSNumber alloc] initWithUnsignedInt:dimensionID];
    return [[_sensorInfoObjects objectAtIndex:sensorID] performSelector:@selector(labelOfDimension:) withObject:dimID];
}

- (NSString*)descriptionFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID {
    //NSLog(@"\t%@\t - - Get Description from Sensor:%d, Dimension: %d",self, sensorID, dimensionID);
    if(sensorID>=[_sensors count])
    {
        NSLog(@"Error:\t%@\t - SensorID(%d) out of Range:(0 - %d)",self,sensorID,[_sensors count]);
        return @"";
    }
    NSNumber* dimID = [[NSNumber alloc] initWithUnsignedInt:dimensionID];
    
    return [[_sensorInfoObjects objectAtIndex:sensorID] performSelector:@selector(descriptionOfDimension:) withObject:dimID];
}

- (NSString*)descriptionFromSensor:(SensorIDs)sensorID {
    //NSLog(@"\t%@\t - - Get Description from Sensor:%d, Dimension: %d",self, sensorID, dimensionID);
    if(sensorID>=[_sensors count])
    {
        NSLog(@"Error:\t%@\t - SensorID(%d) out of Range:(0 - %d)",self,sensorID,[_sensors count]);
        return @"";
    }
    
    return [[_sensorInfoObjects objectAtIndex:sensorID] performSelector:@selector(descriptionOfSensor)];
}

- (double)valueFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID sender:(id)sender{
    double ret;
    switch (sensorID) {
        case SENSOR_Accelerometer:
            [_accelerometerInfo addReader];
            ret = [self getAcceleroemterValue:dimensionID];
            [_accelerometerInfo removeReader];
            break;
        case SENSOR_DeviceMotion:
            [_deviceMotionInfo addReader];
            ret = [self getDeviceMotionValue:dimensionID];
            [_deviceMotionInfo removeReader];
            break;
        case SENSOR_Gyroscope:
            [_gyroscopeInfo addReader];
            ret = [self getGyroscopeValue:dimensionID];
            [_gyroscopeInfo removeReader];
            break;
        case SENSOR_Location:
            [_locationInfo addReader];
            ret = [self getLocationValue:dimensionID];
            [_locationInfo removeReader];
            break;
        case SENSOR_HeartRate:
            [_heartRateInfo addReader];
            ret = [self getHeartRateValue:dimensionID];
            [_heartRateInfo removeReader];
        default:
            break;
    }
    return ret;
}

- (NSString*)valueAsStringFromSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID sender:(id)sender{
    double ret = [self valueFromSensor:sensorID dimension:dimensionID sender:sender];
    return [NSString stringWithFormat:@"%f",ret];
}


#pragma mark - meta data getter

-(int)dimensionCountForSensor:(SensorIDs)sensorID {
    return [_sensorInfoObjects[sensorID] dimensionCount];
}

- (int)sensorCount {
    //NSLog(@"SensorCount: %d",[_sensors count]);
    return [_sensors count];
}

- (NSString*)keyForSensor:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID {
    // unique key consisting of sensorKey and DimensionKey
    NSString* ret = @"";
    NSNumber* dimID = [[NSNumber alloc] initWithUnsignedInt:dimensionID];
    
    [ret stringByAppendingString: [[_sensorInfoObjects objectAtIndex:sensorID]sensorKey]];
    [ret stringByAppendingString: [[_sensorInfoObjects objectAtIndex:sensorID]dimensionKey:dimID]];
    
    return ret;
}

- (NSString*)keyForSensor:(SensorIDs)sensorID {
    // unique sensorKey
    return [[_sensorInfoObjects objectAtIndex:sensorID]sensorKey];
}


#pragma mark - internal getter
- (double)getAcceleroemterValue:(NSUInteger)dimensionID {
    double data = -1;
    //NSLog(@"\t%@\t get %@",self,[self descriptionFromSensor:SENSOR_DeviceMotion dimension:dimensionID]);

    // Wenn bereits Samples vom Sensor empfangen wurden
    if ([[_sensorInfoObjects objectAtIndex:SENSOR_Accelerometer] firstDataArrived]) {
        CMAccelerometerData *ac = [[_sensors objectAtIndex:SENSOR_Accelerometer]lastObject];
        switch (dimensionID) {
            case DIMENSION_Accelerometer_AccelerationX:
                data = ac.acceleration.x;
                break;
            case DIMENSION_Accelerometer_AccelerationY:
                data = ac.acceleration.y;
                break;
            case DIMENSION_Accelerometer_AccelerationZ:
                data = ac.acceleration.z;
                break;
            default:
                NSLog(@"out of range");
                data = 0;
                break;
        }
    }
    return data;
}

- (double)getGyroscopeValue:(NSUInteger)dimensionID {
    double data = -1;
    //NSLog(@"\t%@\t get %@",self,[self descriptionFromSensor:SENSOR_DeviceMotion dimension:dimensionID]);

    // Wenn bereits Samples vom Sensor empfangen wurden
    if ([[_sensorInfoObjects objectAtIndex:SENSOR_Gyroscope] firstDataArrived]) {
        CMGyroData *gy = [[_sensors objectAtIndex:SENSOR_Gyroscope]lastObject];
        switch (dimensionID) {
            case DIMENSION_Gyroscope_GyroRotationRateX:
                data = gy.rotationRate.x;
                break;
            case DIMENSION_Gyroscope_GyroRotationRateY:
                data = gy.rotationRate.y;
                break;
            case DIMENSION_Gyroscope_GyroRotationRateZ:
                data = gy.rotationRate.z;
                break;
                
            default:
                NSLog(@"out of range");
                data = 0;
                break;
        }
    }
    return data;
}

- (double)getDeviceMotionValue:(NSUInteger)dimensionID {
    double data = -1;
    //NSLog(@"\t%@\t get %@",self,[self descriptionFromSensor:SENSOR_DeviceMotion dimension:dimensionID]);
    
    // Wenn bereits Samples vom Sensor empfangen wurden
    if ([[_sensorInfoObjects objectAtIndex:SENSOR_DeviceMotion] firstDataArrived]) {
        CMDeviceMotion *dm = [[_sensors objectAtIndex:SENSOR_DeviceMotion]lastObject];
        switch (dimensionID) {
            case DIMENSION_DeviceMotion_AttitudePitch:
                data = dm.attitude.pitch;
                break;
            case DIMENSION_DeviceMotion_AttitudeRoll:
                data = dm.attitude.roll;
                break;
            case DIMENSION_DeviceMotion_AttitudeYaw:
                data = dm.attitude.yaw;
                break;
            case DIMENSION_DeviceMotion_GravityX:
                data = dm.gravity.x;
                break;
            case DIMENSION_DeviceMotion_GravityY:
                data = dm.gravity.y;
                break;
            case DIMENSION_DeviceMotion_GravityZ:
                data = dm.gravity.z;
                break;
            case DIMENSION_DeviceMotion_MagenticFieldAccuracy:
                data = dm.magneticField.accuracy;
                break;
            case DIMENSION_DeviceMotion_MagenticFieldX:
                data = dm.magneticField.field.x;
                break;
            case DIMENSION_DeviceMotion_MagenticFieldY:
                data = dm.magneticField.field.y;
                break;
            case DIMENSION_DeviceMotion_MagenticFieldZ:
                data = dm.magneticField.field.z;
                break;
            case DIMENSION_DeviceMotion_RotationRateX:
                data = dm.rotationRate.x;
                break;
            case DIMENSION_DeviceMotion_RotationRateY:
                data = dm.rotationRate.y;
                break;
            case DIMENSION_DeviceMotion_RotationRateZ:
                data = dm.rotationRate.z;
                break;
            case DIMENSION_DeviceMotion_UserAccelerationX:
                data = dm.userAcceleration.x;
                break;
            case DIMENSION_DeviceMotion_UserAccelerationY:
                data = dm.userAcceleration.y;
                break;
            case DIMENSION_DeviceMotion_UserAccelerationZ:
                data = dm.userAcceleration.z;
                break;
                
            default:
                NSLog(@"out of range");
                data = 0;
                break;
        }
    }
    return data;
}

- (double)getLocationValue:(NSUInteger)dimensionID {
    double data = -1;
    //NSLog(@"\t%@\t get %@",self,[self descriptionFromSensor:SENSOR_DeviceMotion dimension:dimensionID]);
    
    // Wenn bereits Samples vom Sensor empfangen wurden
    if ([[_sensorInfoObjects objectAtIndex:SENSOR_Location] firstDataArrived]) {
        CLLocation *loc = [[_sensors objectAtIndex:SENSOR_Location]lastObject];
        
        switch (dimensionID) {
            case DIMENSION_Location_Altitude:
                data = loc.altitude;
                break;
            case DIMENSION_Location_Course:
                data = loc.course;
                break;
            case DIMENSION_Location_HorizontalAccuracy:
                data = loc.horizontalAccuracy;
                break;
            case DIMENSION_Location_Latitude:
                data = loc.coordinate.latitude;
                break;
            case DIMENSION_Location_Longitude:
                data = loc.coordinate.longitude;
                break;
            case DIMENSION_Location_Speed:
                data = loc.speed;
                break;
            case DIMENSION_Location_VerticalAccuracy:
                data = loc.verticalAccuracy;
                break;
                
            default:
                NSLog(@"out of range");
                data = 0;
                break;
        }
    }
    return data;
}

- (double)getHeartRateValue:(NSUInteger)dimensionID {
    double data = -1;
    //NSLog(@"\t%@\t get %@",self,[self descriptionFromSensor:SENSOR_DeviceMotion dimension:dimensionID]);
    
    // Wenn bereits Samples vom Sensor empfangen wurden
    if ([[_sensorInfoObjects objectAtIndex:SENSOR_HeartRate] firstDataArrived]) {
        CBCharacteristic *heart = [[_sensors objectAtIndex:SENSOR_HeartRate]lastObject];
        
        switch (dimensionID) {
            case DIMENSION_HeartRate_Rate:
                {
                    // GET NSUINTER from Characteristic.value
                    const uint8_t *reportData = [heart.value bytes];
                    uint16_t bpm = 0;
                    
                    if ((reportData[0] & 0x01) == 0)
                    {
                        /* uint8 bpm */
                        bpm = reportData[1];
                    }
                    else
                    {
                        /* uint16 bpm */
                        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
                    }
                    
                    data = (double)bpm;
                    break;
                }
            default:
                NSLog(@"out of range");
                data = 0;
                break;
        }
    }
    return data;
}


- (void)addNewSampleData:(id)data fromSensor:(SensorIDs)sensorID  {
    
    // Wenn SensorID vorhanden
    if (sensorID <= [_sensors count] && sensorID>=0) {
        
        int bufferSize = [[_sensors objectAtIndex:sensorID] count];
        int readersCount = [[_sensorInfoObjects objectAtIndex:sensorID] readers];
        [[_sensorInfoObjects objectAtIndex:sensorID] setFirstDataArrived:true];
        //NSLog(@"adding sample %@, %d, %d",self,bufferSize,readersCount);
        // Wenn Buffergröße <= der Anzhal lesender Zugriffe, dann Daten hinten im Buffer hinzufügen
        if (bufferSize < readersCount) {
            //NSLog(@"Add sample %@",data);
            [[_sensors objectAtIndex:sensorID] addObject:data];
        } else {
        // ansonsten letztes Element im Buffer austauschen
            //NSLog(@"Replace sample at index %d with %@",bufferSize-1,data);
            [[_sensors objectAtIndex:sensorID] replaceObjectAtIndex:bufferSize-1 withObject:data];
        }
    } else {
        NSLog(@"\t%@\t Sensor-ID (%d) out of range (%d)",self,sensorID,[_sensors count]);
    }
}



@end
