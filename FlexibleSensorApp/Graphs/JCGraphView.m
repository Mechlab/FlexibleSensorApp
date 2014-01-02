//
//  JCGraphView.m
//  FlexiblesSensorApp
//
//  Created by Johannes Camin on 12.06.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCGraphView.h"



@implementation JCGraphView
#pragma mark - Properties
@synthesize border;
@synthesize xRange = _xRange;
@synthesize yRange = _yRange;
@synthesize origin;
@synthesize panDistance;
@synthesize singleValue;
@synthesize arrowSize;
@synthesize xGridScale = _xGridScale;
@synthesize xSubGridScale;
@synthesize yGridScale = _yGridScale;
@synthesize ySubGridScale;
@synthesize zoom = _zoom;
@synthesize xLabel;
@synthesize yLabel;
//@synthesize firstQ;

@synthesize filteredValues;
@synthesize minMaxVisible;

@synthesize MaxMinValueCount;
@synthesize maxValues;
@synthesize minValues;
@synthesize MaxMinHighBoundary;
@synthesize MaxMinLowBoundary;

@synthesize xAverage;
@synthesize yAverage;



#pragma mark - Initializer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initialize {
    [self setBorder:2];
    
    [self setGraphViewOrientation:GRAPHVIEW_ORIENTATION_CENTER];
    [self normalizeOrigin];
    [self setClipsToBounds:true];
    
    // Urpsprung zentrieren (um alle 4 Quadranten zu sehen)
    [self centerOrigin];
    // Wertebereich in x von -2.0 bis 2.0
    [self setXRange:4];
    // Wertebereich in y von -2.0 bis 2.0
    [self setYRange:4];
    
    // dunkles Gitter mit Abstand 1.0
    [self setGrid:true];
    [self setXGridScale:1];
    [self setYGridScale:1];
    // helles Gitter mit Abstand 0.2
    [self setXSubGridScale:5];
    [self setYSubGridScale:5];
    [self setSubGrid:true];
    
    // Achsenbeschriftung
    xLabel = [[UILabel alloc]initWithFrame:CGRectMake([self frame].size.width -border-25, [self trueOrigin].y , 25, 18)];
    [xLabel setAdjustsFontSizeToFitWidth:true];
    UIColor *bg = [[UIColor alloc] initWithWhite:1 alpha:0];
    [xLabel setBackgroundColor:bg];
    [xLabel setText:@"x"];
    [self addSubview:xLabel];

    yLabel = [[UILabel alloc]initWithFrame:CGRectMake([self trueOrigin].x - 30, 0 , 25, 18)];
    [yLabel setAdjustsFontSizeToFitWidth:true];
    [yLabel setBackgroundColor:bg];
    [yLabel setText:@"y"];
    
    [self addSubview:xLabel];
    [self addSubview:yLabel];

    // Achsenunterteilung
    [self setMarks:true];
    [self setSubMarks:true];
    // Pfeile an Achsen
    [self setArrowSize:3];
    
    // Position des Startdatums im Ursprung
    [self setSingleValue:CGPointMake(0,0)];
    
    // durch Gesten skalierbar
    [self setScaleable:true];
    // durch Gesten verschiebbar
    [self setPanable:true];
    
    // Zoom standardmäßig auf 1.0 setzen
    [self setZoom:1.0];
    [self setZoomNormalizer:1.0];
    
    // Min und Max Liste initialisieren
    minValues = [[NSMutableArray alloc] init];
    maxValues = [[NSMutableArray alloc] init];
    
    
    // Optionen
    [self setFilteredValues:false];
    [self setMinMaxVisible:false];
    
    [self loadStoredUserSettings];
    
    
    // define colors
    // orange
    [self setOrange:[[UIColor alloc]initWithRed:255/255 green:103/255.0 blue:0/255.0 alpha:1.0]];
    // light-green
    [self setLightGreen:[[UIColor alloc]initWithRed:202/255.0 green:242/255.0 blue:120/255.0 alpha:1.0]];
    // green
    [self setGreen:[[UIColor alloc]initWithRed:148/255.0 green:198/255.0 blue:0.0 alpha:1.0]];
    // dark-green
    [self setDarkGreen:[[UIColor alloc]initWithRed:62/255.0 green:61/255.0 blue:45/255.0 alpha:1.0]];
    // dark-gray
    [self setDarkGray:[[UIColor alloc]initWithRed:113/255.0 green:104/255.0 blue:90/255.0 alpha:1.0]];
    // dark-yellow
    [self setDarkYellow:[[UIColor alloc] initWithRed:230/255.0 green:158/255.0 blue:3/255.0 alpha:1.0]];
    // light-yellow
    [self setLightYellow:[[UIColor alloc]initWithRed:241/255.0 green:245/255.0 blue:168/255.0 alpha:1.0]];
    // mechlab-orange
    [self setMechlabOrange:[[UIColor alloc]initWithRed:241/255.0 green:124/255.0 blue:0.0 alpha:1.0]];
}

-(void) loadStoredUserSettings {
    
}

- (void)initMaxMinWithLowBoundary:(float)low HighBoundary:(float)high {
    [self setMaxMinHighBoundary:high];
    [self setMaxMinLowBoundary:low];
    for (int i = 0; i<[self MaxMinValueCount]; i++) {
        [maxValues addObject:[ NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)]];
        [minValues addObject:[ NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)]];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

#pragma mark - DRAW FUNCTIONs
- (void)drawRect:(CGRect)rect
{
    // Koordinaten-System
    // KoordinatenSystem
    if ([self grid]) {
        [self drawSubGridInGray:0.95];
        if ([self subGrid]) {
            [self drawGridInGray:0.8];
        }
    }
    [self drawXAxis];
    [self drawYAxis];
    
    // Draw Values from Data Input
    [self drawValuesFromSensorDataInput];
    
    // Draw MaxMin Samples
    [self drawMaxMinFromSensorDataInput];

}

- (void)drawValuesFromSensorDataInput {
    float xAxis = [[self sensorData] valueFromSensor:_xAxisSensorID dimension:_xAxisSensorDimensionID sender:self];
    float yAxis = [[self sensorData] valueFromSensor:_yAxisSensorID dimension:_yAxisSensorDimensionID sender:self];

    [self drawValueX:xAxis ValueY:yAxis Color:_orange Size:2.0];
}
     
- (void) drawMaxMinFromSensorDataInput {
    float xAxis = [[self sensorData] valueFromSensor:_xAxisSensorID dimension:_xAxisSensorDimensionID sender:self];
    float yAxis = [[self sensorData] valueFromSensor:_yAxisSensorID dimension:_yAxisSensorDimensionID sender:self];
    
    [self drawMaxMinValueX:xAxis ValueY:yAxis];
}


#pragma mark - DataInput

- (void)setXAxisSensorInput:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID {
    _xAxisSensorDimensionID = dimensionID;
    _xAxisSensorID = sensorID;
}

- (void)setYAxisSensorInput:(SensorIDs)sensorID dimension:(NSUInteger)dimensionID {
    _yAxisSensorDimensionID = dimensionID;
    _yAxisSensorID = sensorID;
}

- (void)setXAxisFilterInput:(FilterIDs)filterID dimension:(NSUInteger)dimensionID {
    _xAxisFilterDimensionID = dimensionID;
    _xAxisFilterID = filterID;
}

- (void)setYAxisFilterInput:(FilterIDs)filterID dimension:(NSUInteger)dimensionID {
    _yAxisFilterDimensionID = dimensionID;
    _yAxisFilterID = filterID;
}

#pragma mark - Center the Origin

- (void)normalizeOrigin {
    
}

- (void)centerOrigin {
    NSLog(@"center X and Y");
    panDistance.x = 0;
    panDistance.y = 0;
    [self setOrigin:CGPointMake([self frame].size.width/2-border, [self frame].size.height/2-1)];
    [self setGraphViewOrientation:GRAPHVIEW_ORIENTATION_CENTER];
}

- (void)centerX {
    NSLog(@"center X");
    panDistance.y = 0;
    [self setOrigin:CGPointMake(border+28, [self frame].size.height/2-1)];
    [self setGraphViewOrientation:GRAPHVIEW_ORIENTATION_Q_1_AND_4];
}

- (void)centerY {
    NSLog(@"center Y");
    panDistance.x = 0;
    [self setOrigin:CGPointMake([self frame].size.width/2-border, [self frame].size.height-border-28)];
    [self setGraphViewOrientation:GRAPHVIEW_ORIENTATION_Q_1_AND_2];
}

- (void)firstQuadrant {
    NSLog(@"set Origin so only the first Quadrant is visible");
    panDistance.x = 0;
    panDistance.y = 0;
    [self setOrigin:CGPointMake(border+28, [self frame].size.height-border-28)];
    [self setGraphViewOrientation:GRAPHVIEW_ORIENTATION_Q_1];
}

- (void)secondQuadrant {
    NSLog(@"set Origin so only the second Quadrant is visible");
    panDistance.x = 0;
    panDistance.y = 0;
}

- (CGPoint) trueOrigin {
    // normalized Origin * actual View Size
//    CGPoint p = CGPointMake(_normalizedOrigin.x * self.frame.size.width, _normalizedOrigin.y * self.frame.size.height);
    // turn p into trueOrigin
    return CGPointMake(origin.x+border+panDistance.x, origin.y-border-+panDistance.y);
}



#pragma mark - Draw Axes

- (void)drawXAxis {
    CGFloat top = border;
    CGFloat bottom = [self frame].size.height-border;
    CGFloat left = border;
    CGFloat right = [self frame].size.width-border;
    CGFloat ypos = [self trueOrigin].y;
    
    // Wenn X-Achse innerhalb des Diagrammes
    if  (ypos >= top && ypos <= bottom) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextBeginPath (context);
        // Schwarze Farbe
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        // x-axis
        CGContextMoveToPoint(context, left, ypos);
        CGContextAddLineToPoint(context, right, ypos);
        // Arrow
        CGContextAddLineToPoint(context, right-[self arrowSize], ypos-[self arrowSize]+1);
        CGContextMoveToPoint(context, right, ypos);
        CGContextAddLineToPoint(context, right-[self arrowSize], ypos+[self arrowSize]-1);
        
        // zeichne!
        CGContextStrokePath(context);
        
        // Markierungen auf x-Achse
        if ([self marks]) {
            CGFloat xPadding;
            CGFloat size = [self arrowSize];
            if ([self subMarks]) {
                xPadding = ([self frame].size.width-2*border)/([self xGridScale]*[self xSubGridScale]);
                [self drawMarksAtY:ypos withPadding:xPadding withSize:size/2];
            }
            xPadding = ([self frame].size.width-2*border)/([self xGridScale]);
            [self drawMarksAtY:ypos withPadding:xPadding withSize:size];
        }
    }
    // Move Label
    xLabel.center = CGPointMake([self frame].size.width -border-25, ypos+11);
}

- (void)drawYAxis {
    CGFloat top = border;
    CGFloat bottom = [self frame].size.height-border;
    CGFloat left = border;
    CGFloat right = [self frame].size.width-border;
    CGFloat xpos = [self trueOrigin].x;
    
    // Wenn y-Achse innnerhalb des Diagrammes
    if (xpos >= left && xpos <= right) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        // Schwarze Farbe
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        CGContextBeginPath (context);
        // y-axis
        CGContextMoveToPoint(context, xpos, bottom);
        CGContextAddLineToPoint(context, xpos, top);
        // Arrow
        CGContextAddLineToPoint(context, xpos+[self arrowSize]-1, top+[self arrowSize]);
        CGContextMoveToPoint(context, xpos, border);
        CGContextAddLineToPoint(context, xpos-[self arrowSize]+1, top+[self arrowSize]);
        
        // zeichne!
        CGContextStrokePath(context);
        
        // Markierungen auf y-Achse
        if ([self marks]) {
            CGFloat yPadding;
            CGFloat size = [self arrowSize];

            if ([self subMarks]) {
                yPadding = ([self frame].size.height-2*border)/([self yGridScale]*[self ySubGridScale]);
                [self drawMarksAtX:xpos withPadding:yPadding withSize:size/2];
            }
            yPadding = ([self frame].size.height-2*border)/([self yGridScale]);
            [self drawMarksAtX:xpos withPadding:yPadding withSize:size];
        }
    }
    // Move Label
    yLabel.center = CGPointMake(xpos - 19, yLabel.center.y);
}

#pragma mark - Draw Grids
- (void)drawSubGridInGray:(float)subgray {
    
    int xsub = 1, ysub = 1;
    if([self subGrid]) {
        xsub = [self xSubGridScale];
        ysub = [self ySubGridScale];
    }
    CGFloat xPadding = ([self frame].size.width-2*border)/([self xGridScale]*xsub);
    CGFloat yPadding = ([self frame].size.height-2*border)/([self yGridScale]*ysub);
    
    //NSLog(@"SubGridPadding x: @d y: @d", xPadding, yPadding);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetRGBStrokeColor(context, subgray, subgray, subgray, 1);

    // -x-axis
    for (CGFloat i = [self trueOrigin].y; i < [self frame].size.height-border ; i += yPadding) {
        if (i > [self trueOrigin].y) {
                CGContextMoveToPoint(context, border, i);
                CGContextAddLineToPoint(context, [self frame].size.width-border, i);
        }
    }
    
    // +x-axis
    for (CGFloat i = [self trueOrigin].y; i > border ; i -= yPadding) {
        if (i < [self trueOrigin].y) {
                CGContextMoveToPoint(context, border, i);
                CGContextAddLineToPoint(context, [self frame].size.width-border, i);
        }
    }
    
    // +y-axis
    for (CGFloat i = [self trueOrigin].x; i < [self frame].size.width-border ; i += xPadding) {
        if (i > [self trueOrigin].x) {
                CGContextMoveToPoint(context, i, border);
                CGContextAddLineToPoint(context, i, [self frame].size.height-border);
        }
    }
    
    // -y-axis
    for (CGFloat i = [self trueOrigin].x; i > border ; i -= xPadding) {
        if (i < [self trueOrigin].x) {
                CGContextMoveToPoint(context, i, border);
                CGContextAddLineToPoint(context, i, [self frame].size.height-border);
        }
    }
    CGContextStrokePath(context);

}

- (void)drawGridInGray:(float)gray {
    
    // Gitterabstände
    CGFloat xPadding = ([self frame].size.width-2*border)/([self xGridScale]);
    CGFloat yPadding = ([self frame].size.height-2*border)/([self yGridScale]);
    
    //NSLog(@"GridPadding x: %d y: %d", xPadding, yPadding);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetRGBStrokeColor(context, gray, gray, gray , 1);

    // -x-axis
    for (CGFloat i = [self trueOrigin].y; i < [self frame].size.height-border ; i += yPadding) {
        
        if (i > [self trueOrigin].y) {
            CGContextMoveToPoint(context, border, i);
            CGContextAddLineToPoint(context, [self frame].size.width-border, i);
        }
    }

    // +x-axis
    for (CGFloat i = [self trueOrigin].y; i > border ; i -= yPadding) {
        if (i < [self trueOrigin].y) {
            CGContextMoveToPoint(context, border, i);
            CGContextAddLineToPoint(context, [self frame].size.width-border, i);
        }
    }
    
    // +y-axis
    for (CGFloat i = [self trueOrigin].x; i < [self frame].size.width-border ; i += xPadding) {
        if (i > [self trueOrigin].x) {
            CGContextMoveToPoint(context, i, border);
            CGContextAddLineToPoint(context, i, [self frame].size.height-border);
        }
    }

    // -y-axis
    for (CGFloat i = [self trueOrigin].x; i > border ; i -= xPadding) {
        if (i < [self trueOrigin].x) {
            CGContextMoveToPoint(context, i, border);
            CGContextAddLineToPoint(context, i, [self frame].size.height-border);
        }
    }
    
    CGContextStrokePath(context);
}

#pragma mark - Draw Marks at the Axes

- (void)drawMarksAtX:(CGFloat)xpos withPadding:(CGFloat)yPadding withSize:(CGFloat)size {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    // marks on -y-axis
    for (CGFloat i = [self trueOrigin].y; i <= [self frame].size.height-border ; i += yPadding) {
            
        if (i > [self trueOrigin].y) {
            CGContextMoveToPoint(context, xpos-size, i);
            CGContextAddLineToPoint(context, xpos+size, i);
        }
    }
        
    // marks on +y-axis
    for (CGFloat i = [self trueOrigin].y; i > border ; i -= yPadding) {
        if (i < [self trueOrigin].y) {
            CGContextMoveToPoint(context, xpos-size, i);
            CGContextAddLineToPoint(context, xpos+size, i);
        }
    }
    CGContextStrokePath(context);//draw

}

- (void)drawMarksAtY:(CGFloat)ypos withPadding:(CGFloat)xPadding withSize:(CGFloat)size{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
                 
    // marks on +x-axis
    for (CGFloat i = [self trueOrigin].x; i < [self frame].size.width-border ; i += xPadding) {
        if (i > [self trueOrigin].x) {
            CGContextMoveToPoint(context, i, ypos+size);
            CGContextAddLineToPoint(context, i, ypos-size);
        }
    }
                 
    // marks on -x-axis
    for (CGFloat i = [self trueOrigin].x; i > border ; i -= xPadding) {
        if (i < [self trueOrigin].x) {
            CGContextMoveToPoint(context, i, ypos+size);
            CGContextAddLineToPoint(context, i, ypos-size);
        }
    }
    CGContextStrokePath(context);//draw
}

#pragma mark - Draw Values

- (void)drawValueX:(float)x ValueY:(float)y Color:(UIColor *)c Size:(float)size {    // Single Value
    //NSLog(@"Draw Value");
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = ((2*(float)M_PI) + startAngle);
    double translatedX = [self trueOrigin].x + ([self frame].size.width-2*[self border])/[self xRange]*x;
    double translatedY = [self trueOrigin].y - ([self frame].size.height-2*[self border])/[self yRange]*y;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Style
    CGContextSetLineWidth(context,size);//set the line width
    CGFloat red, green, blue, alpha;
    [c getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor(context, red, green, blue, alpha);
    CGContextAddArc(context, translatedX, translatedY, size/2, startAngle, endAngle, 1);
    CGContextStrokePath(context);//draw
    CGContextSetLineWidth(context,1);//set the line width
}

- (void)drawValueX:(float)x ValueY:(float)y {
    [self drawValueX:x ValueY:y Color:[self orange] Size:3];
}

- (void)drawMaxMinValueX:(float)x ValueY:(float)y {
    // update and draw List
    for (int i = 0; i<MaxMinValueCount; i++) {
        // aktueller Bereich = Länge/Anzahl Bereiche
        float areaWidth = ((MaxMinHighBoundary-MaxMinLowBoundary)/MaxMinValueCount);
        float area = MaxMinLowBoundary + areaWidth*i;
        CGPoint max = [[maxValues objectAtIndex:i] CGPointValue];
        CGPoint min = [[minValues objectAtIndex:i] CGPointValue];

        // Wenn aktuelles X im Bereich
        if (x>area && x< area+areaWidth) {
            
            // Wenn aktuelles Y größer als Maximum im Bereich -> updaten
            if (y>max.y) {
                [maxValues replaceObjectAtIndex:i withObject:[ NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
        
            // Wenn aktuelles Y kleiner als Minimum im Bereich -> updaten
            if (y<min.y) {
                [minValues replaceObjectAtIndex:i withObject:[ NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
        }
        
        // draw all max and min
        [self drawValueX:max.x ValueY:max.y Color:[self darkGray] Size:1];
        [self drawValueX:min.x ValueY:min.y Color:[self darkGray] Size:1];
    }
}

- (void)drawMaxArea {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 230.0/255, 158.0/255, 3.0/255, 1.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, [[maxValues objectAtIndex:0] CGPointValue].x, [[maxValues objectAtIndex:0] CGPointValue].x);
    NSLog(@"DRAW");
    // draw max
    for (int i = 1 ; i<MaxMinValueCount; i++) {
        NSLog(@"on the way to max");
        // aktueller Bereich = Länge/Anzahl Bereiche
        CGPoint max = [[maxValues objectAtIndex:i] CGPointValue];
        // draw all max and min
        CGContextAddLineToPoint(context, max.x, max.y);
    }
    CGContextSetFillColorWithColor(context, _lightYellow.CGColor);
    CGContextStrokePath(context);
        
}


#pragma mark - Reset Graph
- (void)resetMaxMinValues {
    [maxValues removeAllObjects];
    [minValues removeAllObjects];
    for (int i = 0; i<[self MaxMinValueCount]; i++) {
        [maxValues addObject:[ NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)]];
        [minValues addObject:[ NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)]];
    }
}

- (void)resetPinch {
    NSLog(@"reset Zoom:%f ",[self zoomNormalizer]);
    
    [self setZoomNormalizer:[self zoom]*[self zoomNormalizer]];
    [self setZoom:_zoomNormalizer];
}


- (void)resetPan {
    switch (_graphViewOrientation) {
        case GRAPHVIEW_ORIENTATION_Q_1:
            [self firstQuadrant];
            break;
        case GRAPHVIEW_ORIENTATION_CENTER:
            [self centerOrigin];
            break;
        case GRAPHVIEW_ORIENTATION_Q_1_AND_2:
            [self centerY];
            break;
        case GRAPHVIEW_ORIENTATION_Q_1_AND_4:
            [self centerX];
            break;
        default:
            [self centerOrigin];
            break;
    }
}

- (void)resetView:(id)sender {
    [self resetMaxMinValues];
    [self resetPan];
    [self resetPinch];
}

#pragma mark - Internal Methods
- (JCSensorData*)sensorData {
    return [[JCSensorManager sharedSensorManager] sensorData];
}

- (void)moveTrueOriginTo:(CGPoint)point {
    panDistance = point;
}

- (void)scaleAtOrigin:(CGFloat)scale {
    // Zoom-Faktor skalieren
    if ([self zoomNormalizer] != 0) {
        [self setZoom:scale/[self zoomNormalizer]];
        NSLog(@"Zoom: %f",[self zoom]);
    }
}

- (void)scaleAtCenterOfView:(CGFloat)scale {
    NSLog(@"Noch zu implementieren!");
}

- (void)setXRange:(float)xRange {
    _xRange = xRange;
}

- (float)xRange {
    if (_zoom != 0) {
//        NSLog(@"Zoom:%f",zoom);
        return _xRange / _zoom;
    }
    return _xRange;
}

- (void)setYRange:(float)yRange {
    _yRange = yRange;
}

- (float)yRange {
    if (_zoom != 0) {
        return _yRange / _zoom;
    }
    else return _yRange;
}


- (void)setXGridScale:(float)xGridScale {
    _xGridScale = xGridScale;
}

- (float)xGridScale {
    float ret;
    if (_zoom != 0) {
        ret =_xRange / _xGridScale / _zoom;
    }
    else {
        ret = _xRange / _xGridScale;
    }
    return ret;
}

- (void)setYGridScale:(float)yGridScale {
    _yGridScale = yGridScale;
}

- (float)yGridScale {
    float ret;
    if (_zoom != 0) {
        ret= _yRange/_yGridScale / _zoom;
    }
    else {
        ret= _yRange / _yGridScale;
    }
    return  ret;
}

- (void)setZoom:(float)z {
    if (_zoomNormalizer != 0) {
        _zoom = z / _zoomNormalizer;
    }
}

- (float)zoom {
    return  _zoom;
}





@end
