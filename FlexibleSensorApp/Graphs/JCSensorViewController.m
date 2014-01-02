//
//  JCSensorViewController.m
//  FlexiblesSensorApp
//
//  Created by Johannes Camin on 03.06.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import "JCSensorViewController.h"
#import "JCAppDelegate.h"
#import "IonIcons.h"


@interface JCSensorViewController ()

@end

@implementation JCSensorViewController
@synthesize playButton = _playButton;


@synthesize lightGreen = _lightGreen;
@synthesize middleGreen = _middleGreen;
@synthesize darkGreen = _darkGreen;
@synthesize orange = _orange;
@synthesize darkGrey = _darkGrey;

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view setNeedsDisplay];
        // Custom initialization
        
        // LOAD USERDEFAULT VALUES
        [self setFilterTimeInterval:0.02];
        [self initOptionView];
        
    }
    return self;
}

- (id)init {
    [self initColors];

    NSString *nibName;
    // if iPhone/iPod Touch
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // if iPhone 5 or new iPod Touch
        if ([UIScreen mainScreen].bounds.size.height == 568) {
            nibName = @"SensorViewControlleriPhone4.5";
        }
        // regular iPhone
        else {
            nibName = @"SensorViewControlleriPhone3.5";
        }
    }
    // if iPad
    else {
        nibName = @"SensorViewControlleriPad";
    }
    self = [self initWithNibName:nibName bundle:nil];
    [self initButtons];

    return self;
}

- (void)initOptionView {
    // init Options in Table
    _optionViewController = [[JCOptionTableViewViewController alloc] init];
    NSMutableArray* desc = [[NSMutableArray alloc] init];
    for (int i=0; i<[[self sensorData] sensorCount]; i++) {
        [desc addObject:[[self sensorData] descriptionFromSensor:i]];
    }
    [_optionViewController initLoggingOptionsWithSensors:(NSMutableArray*)desc];
    [[self optionView] setDataSource:[self optionViewController]];
    [[self optionView] setDelegate:[self optionViewController]];
    [[self optionViewController] setView:[self optionView]];
    [[self optionView] setHidden:TRUE];
}

- (void)initGraphViews {
    

    // KONFIGURATION DES DIAGRAMMS
    // init Graph View
    [_graphViewTopLeft initialize];
    [_graphViewTopRight initialize];
    [_graphViewBottomLeft initialize];
    [_graphViewBottomRight initialize];
    
    _graphViews = [[NSMutableArray alloc] initWithObjects:_graphViewTopLeft,_graphViewTopRight,_graphViewBottomLeft, _graphViewBottomRight, nil];
    
    for (JCGraphView* g in _graphViews) {
         // Urpsprung zentrieren (um alle 4 Quadranten zu sehen)
        
         // Wertebereich in x von -1.0 bis 1.0
        [g setXRange:1.8];
         // Wertebereich in y von -1.0 bis 1.0
        [g setYRange:1.8];
    
         // x-Achsenbeschriftung
        NSString *label = [[self sensorData] labelFromSensor:[g xAxisSensorID]  dimension:[g xAxisSensorDimensionID]];
        NSString *unit = [[self sensorData] unitFromSensor:[g xAxisSensorID]  dimension:[g xAxisSensorDimensionID]];
        [[g xLabel] setText:[NSString stringWithFormat:@"%@ /%@",label,unit]];
         // x-Achsenbeschriftung
        label = [[self sensorData] labelFromSensor:[g yAxisSensorID]  dimension:[g yAxisSensorDimensionID]];
        unit = [[self sensorData] unitFromSensor:[g yAxisSensorID]  dimension:[g yAxisSensorDimensionID]];
        [[g yLabel] setText:[NSString stringWithFormat:@"%@ /%@",label,unit]];

        // 200 Abtastwerte zwischen -1.0 und 1.0s
        [g setMaxMinValueCount:50];
        [g initMaxMinWithLowBoundary:-1.0 HighBoundary:1.0];

        // Mittelwert Filter
        [g setXAverage:20];
        [g setYAverage:20];
        
    }
    // initiations for resizing
    _expandedGraphView = FALSE;
    _graphViewRects = [[NSMutableArray alloc] init];

}

#pragma mark - UIView
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void) viewDidDisappear:(BOOL)animated {
    [self stopRepeatingTimer:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter
- (NSString *)description {
    return [NSString stringWithFormat:@"Default Diagramm"];
}

- (JCSensorData *)sensorData {
    return [[JCSensorManager sharedSensorManager] sensorData];
}


#pragma mark - Actions

- (IBAction)play {
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(playButtonPressed:)]) {
        [appDelegate playButtonPressed:self];
        [self startRepeatingTimer:self];
    }
}

- (IBAction)stop {
    [self stopRepeatingTimer:self];

    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(stopButtonPressed:)]) {
        [appDelegate stopButtonPressed:self];
    }
    for (JCGraphView* g in _graphViews) {
        [g resetView:self];
    }
    
}

- (IBAction)style
{
    // Change the style of the graphView
    // (e.g. with our without colors)
    if ([_optionView isHidden]) {
        [_optionView setHidden:FALSE];
    }
    else [_optionView setHidden:TRUE];
}

- (IBAction)session {
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(sessionButtonPressed:)]) {
        [appDelegate sessionButtonPressed:self];
    }
}

- (IBAction)resetView:(id)sender {
}

#pragma mark - GraphView

- (void)updateView {
    [self updateGraphs];
}

- (void)updateGraphs {
    NSLog(@"UpdateView in SensorView");
    if([self sensorData] != nil) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self draw];
        });
    } else {
        NSLog(@"CANT GET THE SENSOR MODELL \n\n\n");
    }
}


- (void)draw {
    [[self graphViewTopLeft] setNeedsDisplay];
    [[self graphViewTopRight] setNeedsDisplay];
    [[self graphViewBottomLeft] setNeedsDisplay];
    [[self graphViewBottomRight] setNeedsDisplay];

    // x und y vertauscht, weil LandscapeFormat
/*    float xAxis = [self sensorData].accelerometerData.acceleration.x *-1;
    float yAxis = [self sensorData].accelerometerData.acceleration.y;
*/

    /*
    [_ax_wert setText:[NSString stringWithFormat:@"Ay: %2.2f /g", yAxis]];
    [_ay_wert setText:[NSString stringWithFormat:@"Ax: %2.2f /g", xAxis]];
     */
}


- (NSDictionary *)userInfo {
    return @{ @"StartDate" : [NSDate date] };
}

- (IBAction)startRepeatingTimer:sender {
    
    // Cancel a preexisting timer.
    [self.repeatingTimer invalidate];
    
    if ([self cyclicFilter]) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[self filterTimeInterval]
                                                      target:self selector:@selector(berechnung)
                                                    userInfo:[self userInfo] repeats:YES];
        self.repeatingTimer = timer;
    }
}

- (IBAction)stopRepeatingTimer:sender {
    [self.repeatingTimer invalidate];
    self.repeatingTimer = nil;
}

- (void)berechnung {
    NSLog(@"zyklische Berechnung");
}

- (void)showDiagrammOptionsUI {
    /*
    NSLog(@"Diagramm Optionen");
    
    // Optionen View Controller anlegen
    JCGraphOptionsViewController *optView;
    
    // iPhone oder iPad Interface laden
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        optView = [[JCGraphOptionsViewController alloc] initWithNibName:@"JCGraphOptions_iPhone" bundle:nil]; // Zuweisung zur xib-Datei
    } else {
        optView = [[JCGraphOptionsViewController alloc] initWithNibName:@"JCGraphOptions_iPad" bundle:nil];
    }
    
    // Observer anmelden, um Änderungen behandeln zu können
    //[optView addObserver:self forKeyPath:@"minMaxVisibiltySwitch" options:NSKeyValueObservingOptionNew context:NULL];
    [optView setDad:self];
    if ([graphView filteredValues]) {
        [[optView filterdValueSwitch] setOn:true];
    }
    else
        [[optView filterdValueSwitch] setOn:false];
    
    
    // UserInterface-Elemente erstellen
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:optView action:@selector(saveSettings)];
    optView.navigationItem.rightBarButtonItem = saveButton;
    optView.title = @"Optionen";
    
    // Optionen anzeigen
    [self.navigationController pushViewController:optView animated:YES];
     */
}


-(void)filteredValueOptionChanged {
    NSLog(@"Switch at SensorViewController");
    if ([_graphViewTopLeft filteredValues]==true) {
        NSLog(@"Filter aus");
        [_graphViewTopLeft setFilteredValues:false];
    }
    else {
        NSLog(@"Filter an");
        [_graphViewTopLeft setFilteredValues:true];
    }
}
-(void)minMaxOptionChanged {
    NSLog(@"Switch at SensorViewController");
    [_graphViewTopLeft setMinMaxVisible:false];
/*    if ([[graphView minMaxVisible] ]) {
        NSLog(@"MinMax aus");
        [graphView setMinMaxVisible:false];
    }
    else
    {
        NSLog(@"MinMax an");
        [graphView setMinMaxVisible:true];
    }
 */
}

- (void)resizeAllGraphViews {
    // animate each View
    [UIView beginAnimations:Nil context:Nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    NSUInteger viewIndex;
    
    for(JCGraphView *g in _graphViews) {
        viewIndex = [_graphViews indexOfObject:g];
        g.frame = [[_graphViewRects objectAtIndex:viewIndex] CGRectValue];
//        NSLog(@"%f,%f,%f,%f",g.frame.origin.x,g.frame.origin.y,g.frame.size.width,g.frame.size.height);

        [g setNeedsDisplay];
        // hide them after shrinking
            
    }
    [UIView commitAnimations];
    _expandedGraphView = FALSE;
}

- (void)expandGraphView:(JCGraphView*)graphView {
    // animate each View
    [UIView beginAnimations:Nil context:Nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    for(JCGraphView *g in _graphViews) {
        
//        NSLog(@"%f,%f,%f,%f",g.frame.origin.x,g.frame.origin.y,g.frame.size.width,g.frame.size.height);
        
        if (g == graphView) {
            // grow tapped View
            g.frame = _frameForExpandedGraphView.frame;
            [g setNeedsDisplay];
        }
        else {
            // shrink the others
            g.frame = CGRectMake(g.origin.y, g.origin.x, 0.0, 0.0);
            // hide them after shrinking
            
        }
    }
    
    [UIView commitAnimations];
    _expandedGraphView = TRUE;

}

#pragma mark - Gesture Recognizer

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    //NSLog(@"pinch inside GraphView");
    JCGraphView *view = recognizer.view;
    if ([view scaleable]) {
        CGFloat oldZoom = 1.0;
        if ([view zoomOffset]!= 0.0) {
            oldZoom = [view zoomOffset];
        }
        NSLog(@"Scale: %f",[recognizer scale]);
        [view setZoom:[recognizer scale]*oldZoom];
        [view setNeedsDisplay];
        
        if (([recognizer state] == UIGestureRecognizerStateEnded) || ([recognizer state] == UIGestureRecognizerStateCancelled)) {
            [view setZoomOffset:[recognizer scale]*oldZoom];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    //NSLog(@"pan inside GraphView");
    JCGraphView *view = recognizer.view;
    if ([view panable]) {
        CGPoint additionalOffset = CGPointMake([recognizer translationInView:view].x,[recognizer translationInView:view].y*-1);
        CGPoint newOrigin = CGPointMake([view panOffset].x + additionalOffset.x, [view panOffset].y + additionalOffset.y);
        [view moveTrueOriginTo:newOrigin];
        if (([recognizer state] == UIGestureRecognizerStateEnded) || ([recognizer state] == UIGestureRecognizerStateCancelled)) {
            [view setPanOffset:newOrigin];
        }
        [view setNeedsDisplay];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Double Tap recognized");
    JCGraphView *view = recognizer.view;

    if(_expandedGraphView) {
        [self resizeAllGraphViews];
    }
    else {
        NSUInteger viewIndex;

        for (JCGraphView* g in _graphViews) {
            // Save GraphView Rects for later animations
            NSValue *rectObj = [NSValue valueWithCGRect:g.frame];
            NSLog(@"%f,%f,%f,%f",[rectObj CGRectValue].origin.x,[rectObj CGRectValue].origin.y,[rectObj CGRectValue].size.width,[rectObj CGRectValue].size.height);
            if ([_graphViewRects count]<[_graphViews count]) {
                // ViewRects mit neuen Rects füllen
                [_graphViewRects addObject:rectObj];
            } else {
                // ansonsten alte austauschen
                viewIndex = [_graphViews indexOfObject:g];
                [_graphViewRects replaceObjectAtIndex:viewIndex withObject:rectObj];
            }
        }
        [self expandGraphView:view];
    }
}


#pragma mark - Buttons

- (void)initButtons {
    [self togglePlayButtonWithLogginConstraint:false];
    [self initStopButton];
    [self initStyleButton];
    [self initHeartButton];
}

- (void)togglePlayButtonWithLogginConstraint:(bool)isLoggin {
    UIImage *icon;
    
    // ORANGE PAUSE - ACTIVE
    if (isLoggin) {
        icon = [IonIcons imageWithIcon:icon_pause iconColor:_mechlabOrange
                              iconSize:35.0f
                             imageSize:CGSizeMake(35.0f, 35.0f)];
        [_stopButton setEnabled:true];
    }

    // ORANGE PLAY - NORMAL
    else {
        icon = [IonIcons imageWithIcon:icon_play
                             iconColor:_mechlabOrange
                              iconSize:35.0f
                             imageSize:CGSizeMake(35.0f, 35.0f)];
        
        [_stopButton setEnabled:FALSE];
    }
    [_playButton setBackgroundImage:icon forState:UIControlStateNormal];
}

- (void)initStopButton {
    

    // GRAY STOP - DISABLED
    UIImage *icon = [IonIcons imageWithIcon:icon_stop
                                  iconColor:_darkGrey
                                   iconSize:35.0f
                                  imageSize:CGSizeMake(35.0f, 35.0f)];
    
    [_stopButton setBackgroundImage:icon forState:UIControlStateDisabled];
    
    // ORANGE STOP - ENABLED
    icon = [IonIcons imageWithIcon:icon_stop iconColor:_mechlabOrange
                          iconSize:35.0f
                         imageSize:CGSizeMake(35.0f, 35.0f)];
    [_stopButton setBackgroundImage:icon forState:UIControlStateNormal];
    [_stopButton setEnabled:false];
}

- (void)initHeartButton {
    // GRAY HEART - DISABLED
    UIImage *icon = [IonIcons imageWithIcon:icon_ios7_heart_outline
                                  iconColor:_darkGrey
                                   iconSize:35.0f
                                  imageSize:CGSizeMake(35.0f, 35.0f)];
    
    [_heartButton setBackgroundImage:icon forState:UIControlStateDisabled];
    
    // ORANGE HEART - ENABLED
    icon = [IonIcons imageWithIcon:icon_ios7_heart iconColor:_middleGreen
                          iconSize:35.0f
                         imageSize:CGSizeMake(35.0f, 35.0f)];
    [_heartButton setBackgroundImage:icon forState:UIControlStateNormal];
    [_heartButton setEnabled:true];
}

- (void)setHeartButtonActive:(bool)isActive {
    [_heartButton setEnabled:isActive];
}

- (void)initStyleButton {
    
    // GRAY DIAGRAM
    UIImage *icon = [IonIcons imageWithIcon:icon_gear_a
                                  iconColor:_darkGrey
                                   iconSize:35.0f
                                  imageSize:CGSizeMake(35.0f, 35.0f)];
    [_styleButton setBackgroundImage:icon forState:UIControlStateNormal];
    [_styleButton setEnabled:true];
}

- (void)initColors {
    _orange = [[UIColor alloc] initWithRed:1.0 green:103.0/255 blue:0.0 alpha:1.0];
    _lightGreen = [UIColor colorWithRed:202.0/255 green:242.0/255 blue:120.0/255 alpha:1.0];
    _middleGreen = [UIColor colorWithRed:148.0/255 green:198.0/255 blue:0.0 alpha:1.0];
    _darkGreen = [UIColor colorWithRed:113.0/255 green:104.0/255 blue:90.0/255 alpha:1.0];
    _darkGrey = [UIColor colorWithRed:62.0/255 green:61.0/255 blue:41.0/255 alpha:1.0];
    [self setMechlabOrange:[[UIColor alloc]initWithRed:241/255.0 green:124/255.0 blue:0.0 alpha:1.0]];

}

@end
