//
//  JCSensorManager.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 25.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>
#import "JCSensorData.h"
#import <CoreBluetooth/CoreBluetooth.h>


@protocol JCSensorManagerDelegate <NSObject>
@required
- (void)handleRecentData:(id)sender FromSensor:(SensorIDs)sensorID;
@end


@interface JCSensorManager : NSObject <CLLocationManagerDelegate, CBCentralManagerDelegate> {
    
    id <JCSensorManagerDelegate> _sensorManagerDelegate;
    
    CMMotionManager *_motionManager;
    NSOperationQueue *_deviceMotionQueue;
    NSOperationQueue *_accelerometerQueue;
    NSOperationQueue *_gyroQueue;
    NSOperationQueue *_sensorUpdateQueue;
    NSOperationQueue *_bluetoothQueue;
    CLLocationManager *_locationManager;
    CBCentralManager *_centralManager;
    CBPeripheral *_discoveredPeripheral;
    JCSensorData *_sensorData;
    float _sensorUpdateInterval;
}

- (void)setSensorManagerDelegate:(id)delegate;

- (void)changeSensorUpdateInterval:(float)newUpdateInterval;
- (bool)startUpdatesForSensor:(SensorIDs)sensorID;
- (void)startUpdatesForAllSensors;
- (bool)stopUpdatesForSensor:(SensorIDs)sensorID;
- (void)stopAllSensorUpdates;

// app wide sensorData
@property (strong, nonatomic)JCSensorData *sensorData;

// Delegate that handles sensor updates
@property (retain, nonatomic) id sensorManagerDelegate;
+ (id)sharedSensorManager;


    // Bluetooth
// Delegate methods for Central Manager
- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
// Delegate methofs for Peripheral
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
@end
