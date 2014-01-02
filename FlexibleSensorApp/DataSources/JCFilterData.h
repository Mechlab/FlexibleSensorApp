//
//  JCFilterData.h
//  SensorToCoreDataTest
//
//  Created by Johannes Camin on 25.09.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCFilterData : NSObject

typedef NS_ENUM(NSInteger, FilterIDs) {
    FILTER_MaxMin,
    FILTER_Average,
};

@end
