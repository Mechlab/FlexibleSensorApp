//
//  JCGraphView.h
//  FlexiblesSensorApp
//
//  Created by Johannes Camin on 12.06.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCSensorManager.h"
#import "JCFilterManager.h"

@interface JCGraphView : UIView {
    enum originPreset {centered, xCentered, yCentered, first, second, third, fourth};
    IBOutlet id filteredValueSwitch;
    IBOutlet id minMaxSwitch;
}

typedef NS_ENUM(NSInteger, GRAPHVIEW_ORIENTATION) {
    GRAPHVIEW_ORIENTATION_CENTER,
    GRAPHVIEW_ORIENTATION_Q_1,
    GRAPHVIEW_ORIENTATION_Q_2,
    GRAPHVIEW_ORIENTATION_Q_3,
    GRAPHVIEW_ORIENTATION_Q_4,
    GRAPHVIEW_ORIENTATION_Q_1_AND_2,
    GRAPHVIEW_ORIENTATION_Q_2_AND_3,
    GRAPHVIEW_ORIENTATION_Q_3_AND_4,
    GRAPHVIEW_ORIENTATION_Q_1_AND_4,
};

- (JCSensorData*)sensorData;
- (void)centerOrigin;
- (void)centerX;
- (void)centerY;
- (void)firstQuadrant;
- (CGPoint)trueOrigin;
- (void)resetPan;
- (void)resetPinch;
- (void)moveTrueOriginTo:(CGPoint)point;
- (void)scaleAtOrigin:(CGFloat)scale;
- (void)drawXAxis;
- (void)drawYAxis;
- (void)drawGridInGray:(float)gray;
- (void)drawSubGridInGray:(float)gray;
- (void)drawValueX:(float)x ValueY:(float)y Color:(UIColor*)c Size:(float)size;
- (void)drawValueX:(float)x ValueY:(float)y;
- (void)initialize;
- (void)initMaxMinWithLowBoundary: (float)low HighBoundary:(float)high;
- (void)drawMaxMinValueX:(float)x ValueY:(float)y;
- (void)resetMaxMinValues;
- (void)loadStoredUserSettings;

// Common UI-Settings
@property float border;

// DATA-Input
//sensors
@property int xAxisSensorID;
@property int xAxisSensorDimensionID;
@property int yAxisSensorID;
@property int yAxisSensorDimensionID;
//filter
@property int xAxisFilterID;
@property int xAxisFilterDimensionID;
@property int yAxisFilterID;
@property int yAxisFilterDimensionID;

- (void)setXAxisSensorInput:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID;
- (void)setYAxisSensorInput:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID;

- (void)setXAxisFilterInput:(FilterIDs)sensorID dimension:(NSUInteger)dimensionID;
- (void)setYAxisFilterInput:(FilterIDs)sensorID dimension:(NSUInteger)dimensionID;

// Colors
@property UIColor *orange;
@property UIColor *lightGreen;
@property UIColor *green;
@property UIColor *darkGreen;
@property UIColor *darkGray;
@property UIColor *darkYellow;
@property UIColor *lightYellow;
@property UIColor *mechlabOrange;

// Origin of the graph (not the graph View!)
@property CGPoint origin;
@property CGPoint normalizedOrigin;

// Single Value Points
@property CGPoint singleValue;
@property bool filteredValues;

// Scales on the axes
@property bool xScalaVisible;
@property bool yScalaVisible;
@property float xRange;
@property float xGridScale;
@property float xSubGridScale;
@property float yRange;
@property float yGridScale;
@property float ySubGridScale;

// Graph View Orientation
@property NSUInteger graphViewOrientation;
@property int xAverage;
@property int yAverage;

// Grid Flags
@property bool grid;
@property bool subGrid;
@property bool marks;
@property bool subMarks;

// Gesture Flags
@property bool panable;
@property bool scaleable;
@property float arrowSize;
@property float zoom;
@property float zoomNormalizer;

- (IBAction)resetView:(id)sender;

// resetView Informations
@property CGPoint panDistance;
@property CGFloat zoomOffset;
@property CGPoint panOffset;

// Max Min - Points to draw
@property NSMutableArray *maxValues;
@property NSMutableArray *minValues;
@property int MaxMinValueCount;
@property float MaxMinLowBoundary;
@property float MaxMinHighBoundary;
@property bool minMaxVisible;

// Labels
@property UILabel *xLabel;
@property UILabel *yLabel;
@end
