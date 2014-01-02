//
//  JCSensorManager.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 25.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCSensorManager.h"
#import "JCAppDelegate.h"
#import "SERVICES.h"

@implementation JCSensorManager
@synthesize sensorManagerDelegate = _sensorManagerDelegate;
@synthesize sensorData = _sensorData;

#pragma mark - Singleton Methods

+ (id)sharedSensorManager {
    static JCSensorManager *sharedSensorManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSensorManager = [[self alloc] init];
    });
    return sharedSensorManager;
}

-(id)init {
    // init self
    self = [super init];
    NSLog(@"\t%@\t - Initialize:",self);
    
    
    // configure specific SensorManagers
    [self configureCoreLocationManager];
    [self configureMotionManager];

    // configure Operation Queues
    [self configureOperationQueues];
    [self configureCentralManager];
 
    // initialize SensorData
    _sensorData = [[JCSensorData alloc] init];

    NSLog(@"\t");
    // default updateInterval
    [self changeSensorUpdateInterval:0.07]; //100 Hz

    return self;
}

- (void)dealloc {
    NSLog(@"Sensor Manager released");
}

#pragma mark - Init SensorData
- (void)initSensorData {
    // init SensorData including recent values and sensorinformation (meta data)
    _sensorData = [[JCSensorData alloc] init];
}



#pragma mark - Configure Sensors

- (void)configureCoreLocationManager {
    // init LocationManager
    NSLog(@"\t%@\t - - LocationManager",self);
    
    _locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
}

- (void)configureMotionManager {
    // init MotionManager
    NSLog(@"\t%@\t - - MotionManager",self);
    
    _motionManager = [[CMMotionManager alloc] init];
    [self configureSensorUpdateInterval];
}

- (void)configureCentralManager {
    // init CentralManager
    NSLog(@"\t%@\t - - CentralManager",self);
    dispatch_queue_t centralQueue = dispatch_queue_create("com.yo.mycentral", DISPATCH_QUEUE_SERIAL);// or however you want to create your dispatch_queue_t
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
}


#pragma mark - Configure OperationQueues

- (void)configureOperationQueues {
    // init DeviceMotionQueue
    NSLog(@"\t%@\t - - Device Operation-Queue",self);
    _deviceMotionQueue = [[NSOperationQueue alloc] init];
    [_deviceMotionQueue setMaxConcurrentOperationCount:1];

    // init AccelerometerQueue
    NSLog(@"\t%@\t - - Accelerometer Operation-Queue",self);
    _accelerometerQueue = [[NSOperationQueue alloc] init];
    [_accelerometerQueue setMaxConcurrentOperationCount:1];

    // init GyroQueue
    NSLog(@"\t%@\t - - Gyroscope Operation-Queue",self);
    _gyroQueue = [[NSOperationQueue alloc] init];
    [_gyroQueue setMaxConcurrentOperationCount:1];
    
    // init general SensorUpdateQueue
    NSLog(@"\t%@\t - - SensorUpdate Operation-Queue",self);
    _sensorUpdateQueue = [[NSOperationQueue alloc] init];
    [_sensorUpdateQueue setMaxConcurrentOperationCount:1];
    
    // init bluetooth scanning queue
    NSLog(@"\t%@\t - - Scanning Queue",self);
    _bluetoothQueue = [[NSOperationQueue alloc] init];
}



#pragma mark - Start Sensor Updates

- (bool)startUpdatesForSensor:(SensorIDs)sensorID {
    bool success = false;
    NSString * log;
    switch (sensorID) {
        case SENSOR_Accelerometer:
            if (_motionManager.accelerometerActive) {
                log = [[NSString alloc] initWithFormat:@"Error:\t%@ - Accelerometer is already updating",self];
            } else {
                [self startAccelerometerUpdates];
                success = true;
            }
            break;
        case SENSOR_DeviceMotion:
            if (_motionManager.deviceMotionActive) {
                log = [[NSString alloc] initWithFormat:@"Error:\t%@ - DeviceMotion is already updating",self];
            } else {
                [self startDeviceMotionUpdates];
                success = true;
            }
            break;
            
        case SENSOR_Gyroscope:
            if (_motionManager.gyroActive) {
                log = [[NSString alloc] initWithFormat:@"Error:\t%@ - Gyroscope is already updating",self];
            } else {
                [self startGyroUpdates];
                success = true;
            }
            break;
            
        case SENSOR_Location:
            [self startLocationUpdates];
            success = true;
            break;
            
        default:
        {
            log = [[NSString alloc] initWithFormat:@"Error:\t%@ - SensorID(%d) out of range while trying to Start SensorUpdates",self, sensorID];
            break;
        }
    }
    if (!success) {
        NSLog(@"%@",log);
    }
    return success;
}

- (void)startUpdatesForAllSensors {
    // start Updates For all Sensors that are available over enums
    NSLog(@"\t%@\tStart Updates for all Sensors",self);
    [self startUpdatesForSensor:SENSOR_Accelerometer];
    [self startUpdatesForSensor:SENSOR_DeviceMotion];
    [self startUpdatesForSensor:SENSOR_Gyroscope];
    [self startUpdatesForSensor:SENSOR_Location];
}

- (void)startGyroUpdates {
    //start Gyro
    NSLog(@"\t%@\t - Starting Gyro Updates",self);
    
    CMGyroHandler gyroHandler = ^(CMGyroData *gyroData, NSError *error) {
        if (error) {
            NSLog(@"\t%@\t - Fehler beim lesen der Gyro Daten",self);
        }
        else {
            NSLog(@"\t%@\t - New Gyro Update",self);
            [_sensorData addNewSampleData:gyroData fromSensor:SENSOR_Gyroscope];
            
            [_sensorManagerDelegate handleRecentData:self FromSensor:SENSOR_Gyroscope];
        }
    };
    [_motionManager startGyroUpdatesToQueue:_sensorUpdateQueue withHandler:gyroHandler];
}

- (void)startAccelerometerUpdates {
    //start Accelerometer
    NSLog(@"\t%@\t - Starting Accelerometer Updates",self);
    
    CMAccelerometerHandler accelHandler = ^(CMAccelerometerData *accelerometerData, NSError *error) {
        if (error) {
            NSLog(@"\t%@\t - Fehler beim lesen der Accelerometer Daten",self);
        }
        else {
            NSLog(@"\t%@\t - New Accelerometer Update",self);
            [_sensorData addNewSampleData:accelerometerData fromSensor:SENSOR_Accelerometer];
            [_sensorManagerDelegate handleRecentData:self FromSensor:SENSOR_Accelerometer];
        }
    };
    [_motionManager startAccelerometerUpdatesToQueue:_sensorUpdateQueue withHandler:accelHandler];
}

- (void)startDeviceMotionUpdates {
    //start DeviceMotion
    NSLog(@"\t%@\t - Starting DeviceMotion Updates",self);
    
    CMDeviceMotionHandler motionHandler = ^(CMDeviceMotion *motion, NSError *error) {
        if (error) { NSLog(@"\t%@\t - Fehler beim lesen der Device Motion Daten",self);}
        else {
            NSLog(@"\t%@\t - New DeviceMotion Update",self);
            [_sensorData addNewSampleData:motion fromSensor:SENSOR_DeviceMotion];
            [_sensorManagerDelegate handleRecentData:self FromSensor:SENSOR_DeviceMotion];
        }
    };
    [_motionManager startDeviceMotionUpdatesToQueue:_sensorUpdateQueue withHandler:motionHandler];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"\t\t%@\t - New LocationUpdate",self);
    [_sensorData addNewSampleData:newLocation fromSensor:SENSOR_Location];
    [_sensorManagerDelegate handleRecentData:self FromSensor:SENSOR_Location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"\t%@\t - %@",self,[error description]);
}

- (void)startLocationUpdates {
    // start Location and Heading Updates
//    NSLog(@"\t%@\t - Starting Location and Heading Updates",self);
    
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}


#pragma mark - Stop Sensor Updates

- (bool)stopUpdatesForSensor:(SensorIDs)sensorID {
    bool success = false;
    NSString * log;
    switch (sensorID) {
        case SENSOR_Accelerometer:
            if (_motionManager.accelerometerActive) {
                log = [[NSString alloc] initWithFormat:@"Error:\t%@ - Accelerometer is still not updating",self];
            } else {
                [self stopAccelerometerUpdates];
                success = true;
            }
            break;
        case SENSOR_DeviceMotion:
            if (_motionManager.deviceMotionActive) {
                log = [[NSString alloc] initWithFormat:@"Error:\t%@ - DeviceMotion is still not updating",self];
            } else {
                [self stopDeviceMotionUpdates];
                success = true;
            }
            break;
            
        case SENSOR_Gyroscope:
            if (_motionManager.deviceMotionActive) {
                log = [[NSString alloc] initWithFormat:@"Error:\t%@ - Gyroscope is still not updating",self];
            } else {
                [self stopGyroscopeUpdates];
                success = true;
            }
            break;
            
        case SENSOR_Location:
            if (_motionManager.deviceMotionActive) {
                log = [[NSString alloc] initWithFormat:@"Error:\t%@ - Location is still not updating",self];
            } else {
                [self stopLocationUpdates];
                success = true;
            }
            break;
            
        default:
        {
            log = [[NSString alloc] initWithFormat:@"Error:\t%@ - SensorID(%d) out of range while trying to Start SensorUpdates",self, sensorID];
            break;
        }
    }
    if (!success) {
        NSLog(@"%@",log);
    }
    return success;
}

- (void)stopAllSensorUpdates {
    [self stopAccelerometerUpdates];
    [self stopDeviceMotionUpdates];
    [self stopGyroscopeUpdates];
    [self stopLocationUpdates];
//    [self stopHeartRateUpdates];
}

- (void)stopDeviceMotionUpdates {
    NSLog(@"\t%@\t - Stopping DeviceMotion Updates",self);
    [_motionManager stopDeviceMotionUpdates];
}

- (void)stopAccelerometerUpdates {
    NSLog(@"\t%@\t - Stopping Accelerometer Updates",self);
    [_motionManager stopAccelerometerUpdates];
}

- (void)stopGyroscopeUpdates {
    NSLog(@"\t%@\t - Stopping Gyroscope Updates",self);
    [_motionManager stopGyroUpdates];
}

- (void)stopLocationUpdates {
    NSLog(@"\t%@\t - Stopping Location and Heading Updates",self);
    [_locationManager stopUpdatingHeading];
    [_locationManager stopUpdatingLocation];
}

- (void)stopHeartRateUpdates {
    NSLog(@"\t%@\t - Stopping HeartRate Updates",self);
}


#pragma mark - Changing UpdateInterval

- (void)changeSensorUpdateInterval:(float)newUpdateInterval {
    
    // set _sensorUpdateInterval
    NSLog(@"\t%@\t - Set UpdateInterval %f in:",self,newUpdateInterval);
    _sensorUpdateInterval = newUpdateInterval;
    
    //configure all relevant SensorManagers with new UpdateInterval
    [self configureSensorUpdateInterval];
}

- (void)configureSensorUpdateInterval {
    NSLog(@"\t%@\t - - DeviceMotion",self);
    _motionManager.deviceMotionUpdateInterval = _sensorUpdateInterval;
    NSLog(@"\t%@\t - - Accelerometer",self);
    _motionManager.accelerometerUpdateInterval = _sensorUpdateInterval;
    NSLog(@"\t%@\t - - Gyroscope",self);
    _motionManager.gyroUpdateInterval = _sensorUpdateInterval;
}

#pragma mark - Bluetooth CentralManager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Scan for devices
        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        NSLog(@"Scanning started");
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
    [self cleanup];
}

- (void)cleanup {
    // See if we are subscribed to a characteristic on the peripheral
    if (_discoveredPeripheral.services != nil) {
        for (CBService *service in _discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            [_discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    [_centralManager cancelPeripheralConnection:_discoveredPeripheral];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected");
    [_centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // daten in SensorData schreiben
//    [_data setLength:0];

    // wenn auch peripherie sein kann
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];

}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    _discoveredPeripheral = nil;
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    if (_discoveredPeripheral != peripheral) {
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        _discoveredPeripheral = peripheral;
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [_centralManager connectPeripheral:peripheral options:nil];
    }
}

#pragma mark - Bluetooth Peripheral

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"Discovered service");
    if (error) {
        [self cleanup];
        return;
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
    // Discover other characteristics
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"Discovered characteristic");
    if (error) {
        [self cleanup];
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSLog(@"Update"); 
    // Notifiy AppDelegate for View Upates
    JCAppDelegate *app= [[UIApplication sharedApplication] delegate];
    if (error) {
        NSLog(@"Error");
        return;
        [app updateHeartRateIcon:false];
    }
    [app updateHeartRateIcon:true];
    
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        //[_textview setText:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        [_centralManager cancelPeripheralConnection:peripheral];
    }
    // Daten in SensorData schreiben
    NSLog(@"\t%@\t - New HeartRate Update!",self);
    [_sensorData addNewSampleData:characteristic fromSensor:SENSOR_HeartRate];
    [_sensorManagerDelegate handleRecentData:self FromSensor:SENSOR_HeartRate];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    } else {
        // Notification has stopped
        [_centralManager cancelPeripheralConnection:peripheral];
    }
}


@end
