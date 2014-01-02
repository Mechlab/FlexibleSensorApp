//
//  JCLogger.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 25.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCLogger.h"

#import <ImageIO/ImageIO.h>

@interface JCLogger ()
@property(readwrite,strong) NSString * path;
@end

@implementation JCLogger

@synthesize path = _path;
@synthesize logItems = _logItems;
@synthesize availableSensors = _availableSensors;
@synthesize sensorManager = _sensorManager;
@synthesize dataLine = _dataLine;

+ loggerForDocumentName:(NSString*)name {
    NSLog(@"\t%@",self);

	return [[JCLogger alloc] initWithPath:[JCLogger createLoggingSessionPathFromName:name]];
}

- initWithPath:(NSString*)path {
	self = [super init];
	NSLog(@"\t%@\t - initWithPath:%@",self,path);
	if (self) {
        // Session Variablen
		self.startDate = [NSDate date];
		[self setPath:path];
                
		// Datenquelle bestimmen
        _sensorManager = [JCSensorManager sharedSensorManager];
        
//        [self initLogItems];
        [self initAvailabilityArray];
	}
    NSLog(@"\t%@",self);
    sessionCount = 1;

	return self;
}

- (void)resetDocumentName:(NSString *)name {
    [self setPath:[JCLogger createLoggingSessionPathFromName:name]];
}

- (void)setNewDocumentName:(NSString*)name {
    [self setPath:[JCLogger createLoggingSessionPathFromName:name]];
}

- (NSTimeInterval) timestamp
{
	return [[NSDate date] timeIntervalSinceDate:self.startDate];
}

- (void)openCSV {
    // Datei öffnen
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * logPath = [_path stringByAppendingPathComponent:[NSString stringWithFormat:@"log%d.csv",sessionCount]];
    
    
    [self resetBuffer];
    
    if (![fileManager fileExistsAtPath:logPath]) {
        [fileManager createFileAtPath:logPath contents:nil attributes:nil];
    }
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
    [_fileHandle seekToEndOfFile];
    NSLog(@"Opening log file: %@", logPath);

    // Timer und Eventzähler reseten
    _syncTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(synchronizeCSV:) userInfo:nil repeats:YES];
    _eventCounter = 0;
    
    // Headerzeile loggen
    NSString *header = [self createCSVHeaderLine];
    [self logWithFormat:@"time, timestamp%@\n",header];
    NSLog(@"LoggingSession gestartet");
    [self setIsLoggingSensors:TRUE];
    // NSLog(@"%@",header);
}

- (void)closeCSV {
	NSLog(@"Closing log file: %@", _path);
    [self setIsLoggingSensors:FALSE];

    _eventCounter = 0;

	if (_syncTimer) {
		[_syncTimer invalidate];
		_syncTimer = nil;
	}
	
	if (_fileHandle) {
		[_fileHandle closeFile];
		_fileHandle = nil;
	}
    sessionCount++;
}

- (void)resetBuffer{
    
    _buffer = nil;
    _buffer = [[NSMutableArray alloc] init];
    for (int sensor = 0; sensor< [[_sensorManager sensorData] sensorCount]; sensor++) {
        
        // für jeden Sensor ein Array mit Buffer Strings anlegen.
        [_buffer addObject:[[NSMutableArray alloc] init]];
        
        // jede Dimension zunächst mit "-" füllen
        for (int j = 0; j< [[_sensorManager sensorData] dimensionCountForSensor:sensor]; j++) {
            [[_buffer objectAtIndex:sensor] addObject: [[NSString alloc] initWithFormat:@"-"]];
        }
    }
}

- (void)dealloc
{
	[self closeCSV];
}

- (id)init {
    self = [super init];
    return self;
}

- (void) synchronizeCSV: (id)sender {
    if ([self isLoggingSensors]) {
        NSLog(@"\t%@\t - Sync log file: %@",self, _path);
        [_fileHandle synchronizeFile];
    }
}

- (void)logWithFormat:(NSString *)messageFormat, ... {
	va_list args;
	va_start(args, messageFormat);
	
	_logCounter++;
	
	NSString * message = [[NSString alloc] initWithFormat:messageFormat arguments:args];
	NSString * newline = @"\n";
	NSString * logMessage = [NSString stringWithFormat:@"%@ %@",message,newline];

    // Zeile in die Datei schreiben
	[_fileHandle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
}



#pragma mark - Start Stop

- (void)startSensorLogging {
    if ([self isLoggingSensors] == FALSE) {
        // start SensorLoggin
        NSLog(@"\t%@\t - Starting Logging Session",self);
        [self openCSV];
        [self setIsLoggingSensors:TRUE];
    }
    else {
        NSLog(@"\t%@\t - Already in Action!",self);
    }
}

- (void)stopSensorLogging {
    if ([self isLoggingSensors]) {
        NSLog(@"\t%@\t - Stopping Logging Session",self);
        [self synchronizeCSV:self];
        [self closeCSV];
    }
    else {
        NSLog(@"\t%@\t - Already Stoppped!",self);
    }
}

- (void)startImageLogging {
    if ([self isLoggingImages] == FALSE) {
        // start SensorLoggin
        NSLog(@"\t%@\t - Starting Logging Session",self);
        [self setIsLoggingImages:TRUE];
    }
    else {
        NSLog(@"\t%@\t - Already in Action!",self);
    }
}

- (void)stopImageLogging {
    if ([self isLoggingImages]) {
        NSLog(@"\t%@\t - Stopping Logging Session",self);
        [self synchronizeCSV:self];
        [self setIsLoggingImages:FALSE];
    }
    else {
        NSLog(@"\t%@\t - Already Stoppped!",self);
    }
}

#pragma mark - Image Logger
- (void)logImage:(CGImageRef)image withFormat:(NSString *)format, ... {
    if ([self isLoggingImages]) {
        va_list args;
        va_start(args, format);
    
        NSString * imageName = [[NSString alloc] initWithFormat:format arguments:args];
        NSString * path = [_path stringByAppendingPathComponent:[imageName stringByAppendingString:@".png"]];
    
        [self saveImage:image toPath:path];
    }
}

-(void)saveImage:(CGImageRef)imageRef toPath:(NSString *)path {
    NSURL *outURL = [[NSURL alloc] initFileURLWithPath:path];
	
	// Save the image to a png file:
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)outURL, (CFStringRef)@"public.png" , 1, NULL);
    CGImageDestinationAddImage(destination, imageRef, NULL);
    CGImageDestinationFinalize(destination);
	
}

# pragma mark - Session Controller
- (void)startNewSession {
    // init
    NSLog(@"Starting new Session");
    [self initWithPath:[JCLogger createLoggingSessionPathFromName:@"Loggin Session"]];
}

- (void)stopSession {
}

# pragma mark - CSV Logger
- (void)logNewLineWithUpdateFromSensor:(SensorIDs)sensorID {
    // Wenn Logger aktiv
    if ([self isLoggingSensors]){
        JCSensorData *data = [_sensorManager sensorData];
        
        bool logData= false;
        for (int i = 0; i<[data dimensionCountForSensor:sensorID]; i++) {
            if ([[[_logItems objectAtIndex:sensorID] objectAtIndex:i] boolValue]) {
                logData = true;}
        }
        if (logData) {

        
        
       // NSLog(@"Log %@ updates",[data keyForSensor:sensorID]);
    // If received data from sensor the first time, call it available
    
    [_availableSensors replaceObjectAtIndex:sensorID withObject:[NSNumber numberWithBool:TRUE]];
    // Daten loggen
        NSString *dataString = [self createCSVDataLineForSensor:sensorID];
        [self logWithFormat:@"%@,%d%@",[[NSDate date] description],_eventCounter,dataString];
        //NSLog(@"%@",data);
        
        _eventCounter = _eventCounter+1;
        }
    }
}

- (NSString *)createCSVHeaderLine {
    //NSLog(@"\t%@\t\t - Creating CSV HeaderLine",self);
    NSString *ret = [[NSString alloc] init];
    JCSensorData *data = [_sensorManager sensorData];
    
    int sCount = [data sensorCount];
    lineCounter = 0;
    
    // für jeden Sensor in den zu loggenden Items
    for (int sensor = 0; sensor < sCount; sensor++)
    {
        // Für jede Dimension des zu loggenden Sensors
        int dCount = [data dimensionCountForSensor:sensor];
        for (int dimension = 0; dimension< dCount; dimension++) {
            // Wenn geloggt werden soll, dann Beschreibung aus Datenmodell in Kopfzeile einfügen
            if ([[[_logItems objectAtIndex:sensor] objectAtIndex:dimension] boolValue]) {
                NSString *descr = [data descriptionFromSensor:sensor dimension:dimension];
                ret = [ret stringByAppendingFormat:@",%@",descr];
            }
        }
    }
    
    //NSLog(@"%@",ret);
    return ret;
}

- (NSString *)createCSVDataLineForSensor:(SensorIDs)sensorID {
    _dataLine = @"";
    lineCounter ++;
    //int lineCounterB = lineCounter;
    //NSLog(@"-> %d",lineCounter);

    JCSensorData *data = [_sensorManager sensorData];
    
    int sCount = [data sensorCount];
    
    // alle Dimensionen des neuen Sensorwerts in Buffer speichern
    for (int dimension = 0; dimension < [data dimensionCountForSensor:sensorID]; dimension++) {
       // NSLog(@" %@ l:%d, d:%d",[data keyForSensor:sensorID],lineCounterB,dimension);
        NSString *val =[data valueAsStringFromSensor:sensorID dimension:dimension sender:self];
        [[_buffer objectAtIndex:sensorID] replaceObjectAtIndex:dimension withObject:val];
    }
    
    
    // für jeden Sensor in den zu loggenden Items
    for (int sensor = 0; sensor < sCount; sensor++)
    {
        // Für jede Dimension des zu loggenden Sensors
        int dCount = [data dimensionCountForSensor:sensor];
        for (int dimension = 0; dimension< dCount; dimension++) {
            // Wenn geloggt werden soll
            if ([[[_logItems objectAtIndex:sensor] objectAtIndex:dimension] boolValue]) {
                // aktuellen Buffer schreiben
                NSString *val = [[_buffer objectAtIndex:sensor] objectAtIndex:dimension];
                _dataLine = [_dataLine stringByAppendingFormat:@",%@",val];
            }
        }
    }
    
    //NSLog(@"%@",ret);
    //NSLog(@"<- %d",lineCounterB);
    return _dataLine;
}

#pragma mark - de/activate Log For Sensors

- (void)activateLogForSensor:(NSUInteger)sensorID dimension:(NSUInteger)dimensionID {
    //
    [_logItems[sensorID] replaceObjectAtIndex:dimensionID withObject:[NSNumber numberWithBool:TRUE]];
}

- (void)activateLogForCompleteSensor:(NSUInteger)sensorID {
    int dimensionCount = [_sensorManager.sensorData dimensionCountForSensor:sensorID];
    for (int i = 0; i < dimensionCount; i++) {
        [self activateLogForSensor:sensorID dimension:i];
    }
}

- (void)activateLogForAllSensors{
    int sensorCount = [_sensorManager.sensorData sensorCount];
    for (int i = 0; i < sensorCount; i++) {
        [self activateLogForCompleteSensor:i];
    }
}


- (void)deactivateLogForSensor:(NSUInteger)sensorID dimension:(NSUInteger)dimensionID {
    [_logItems[sensorID] replaceObjectAtIndex:dimensionID withObject:[NSNumber numberWithBool:FALSE]];
}

- (void)deactivateLogForCompleteSensor:(NSUInteger)sensorID {
    int dimensionCount = [_sensorManager.sensorData dimensionCountForSensor:sensorID];
    for (int i = 0; i < dimensionCount; i++) {
        [self deactivateLogForSensor:sensorID dimension:i];
    }
}

- (void)deactivateLogForAllSensors{
    int sensorCount = [_sensorManager.sensorData sensorCount];
    for (int i = 0; i < sensorCount; i++) {
        [self deactivateLogForCompleteSensor:i];
    }
}

- (void)initLogItems {
    // how many sensors does the sensorManager hold?
    int sensorCount = [_sensorManager.sensorData sensorCount];
    _logItems = [[NSMutableArray alloc] init];
    
    // all dimensions in all sensors -
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    // for each sensor
    for (int i = 0; i < sensorCount; i++) {
        // create an array with all dimensions the actual sensor records
        NSMutableArray *dimensions = [[NSMutableArray alloc] init];
        int dimensionCount = [_sensorManager.sensorData dimensionCountForSensor:i];
        for (int j = 0; j < dimensionCount; j++) {
            NSString* uniqueKey = [_sensorManager.sensorData keyForSensor:i dimension:j];
            //NSLog(@"Init LogItem: %d dimension: %d",i,j);
            // initialize with saved userDefault Value or TRUE
            if ([settings objectForKey:uniqueKey] != nil) {
                [dimensions addObject:[NSNumber numberWithBool:[settings boolForKey:uniqueKey]]];
            } else {
                [dimensions addObject:[NSNumber numberWithBool:TRUE]];
            }
        }
        // add dimensions to logItems
        [_logItems addObject:dimensions];
    }
}

- (void)initAvailabilityArray {
    int sensorCount = [_sensorManager.sensorData sensorCount];
    _availableSensors = [[NSMutableArray alloc] init];
    for (int i = 0; i < sensorCount; i++) {
        [_availableSensors addObject:[NSNumber numberWithBool:false]];
    }
}

+ (NSString*)createLoggingSessionPathFromName:(NSString*)name {
    NSError * error = nil;
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSDateFormatter * format = [NSDateFormatter new];
	[format setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
	
	NSString * top = [NSString stringWithFormat:@"%@-%@", name, [format stringFromDate:[NSDate date]]];
	NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:top];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
    
	[fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
	
	if (error) {
		NSLog(@"Error creating directory at path %@: %@", directory, error);
		return nil;
	}
    return directory;
}


@end

