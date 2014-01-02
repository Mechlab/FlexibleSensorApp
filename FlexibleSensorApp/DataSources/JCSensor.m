//
//  JCSensor.m
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 27.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCSensor.h"

@implementation JCSensor
@synthesize readers = _readers;
@synthesize firstDataArrived = _firstDataArrived;

- (id)init {
    self = [super init];
    // create UnitArray
    _units = [self createUnits];
    // create DescriptionArray
    _descriptions = [self createDescriptions];
    // create LabelArray
    _labels = [self createLabels];
    _readers = 0;
    _adds = 0;
    _removes = 0;
    _firstDataArrived = false;
    return self;
}

- (NSString*)descriptionOfDimension:(NSNumber *)id {
    NSUInteger d = [id unsignedIntegerValue];

    if (d>=[_descriptions count])
    {
        NSLog(@"Error:\t%@ - DimensionID(%d) out of Range(0 - %d) while getting Description",self,d,[_descriptions count]);
        return @"";
    }
//    NSLog(@"\t%@\t - - Get Description of Dimension %d: %@",self,d,[_descriptions objectAtIndex:d]);
    return [_descriptions objectAtIndex:d];
}

- (NSString*)descriptionOfSensor {
    return  @"foo";
}

- (NSString*)unitOfDimension:(NSNumber*)id {
    NSUInteger d = [id unsignedIntegerValue];
    if (d>=[_units count])
    {
        NSLog(@"Error:\t%@ - DimensionID(%d) out of Range:(0 - %d) while getting Unit",self,d,[_units count]);
        return @"";
    }
    //NSLog(@"\t%@\t - - Get Unit of Dimension %d: %@",self,d,[_descriptions objectAtIndex:d]);
    return [_units objectAtIndex:d];
}

- (NSString*)labelOfDimension:(NSNumber *)id {
    NSUInteger d = [id unsignedIntegerValue];
    if (d>=[_labels count])
    {
        NSLog(@"Error:\t%@ - DimensionID(%d) out of Range:(0 - %d) while getting Label",self,d,[_labels count]);
        return @"";
    }
    //NSLog(@"\t%@\t - - Get Unit of Dimension %d: %@",self,d,[_descriptions objectAtIndex:d]);
    return [_labels objectAtIndex:d];
}

- (NSArray*)createUnits {
    NSString *foo = @"foo";
    return [[NSArray alloc] initWithObjects:foo, nil];
}

- (NSArray*)createDescriptions {
    NSString *foo = @"foo";
    return [[NSArray alloc] initWithObjects:foo, nil];
}

- (NSArray*)createLabels {
    NSString *foo = @"foo";
    return [[NSArray alloc] initWithObjects:foo, nil];
}

- (int)dimensionCount {
    return 0;
}

- (NSString*)sensorKey {
    return @"defaultSensor";
}

- (NSString*)dimensionKey:(NSNumber *)id {
    return @"defaultDimensionKey";
}

- (int)addReader {
    //NSLog(@"\t%@\t Adding Reader",self);
    _readers ++;
    _adds ++;
    return _readers;
}

- (int)removeReader {
    _removes ++;
    if (_readers > 0) {
        //NSLog(@"\t%@\t Removing Reader",self);
        _readers --;
    }
    else {
        NSLog(@"\t%@\t Can not remove reader (%d,%d)",self,_adds,_removes);
    }
    //NSLog(@"\t%@ \tReaders:%d",self,_readers);
    return _readers;
}
@end
