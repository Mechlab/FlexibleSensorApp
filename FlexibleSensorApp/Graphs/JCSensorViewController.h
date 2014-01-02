//
//  JCSensorViewController.h
//  FlexiblesSensorApp
//
//  Created by Johannes Camin on 03.06.13.
//  Copyright (c) 2013 Johannes Camin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCSensorManager.h"
#import "JCFilterManager.h"
#import "JCGraphView.h"
#import "JCOptionTableViewViewController.h"

@protocol JCSensorViewDelegate <NSObject>
@required
- (IBAction)startButtonPressed:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)toggleOption:(NSUInteger)optionID From:(id)sender;
- (IBAction)toggleLoggingOptionForSensor:(SensorIDs)sensorID Dimension:(NSUInteger)dimensionID From:(id)sender;
@optional
- (IBAction)toggleLoggingOptionForCompleteSensor:(SensorIDs)sensorID From:(id)sender;
- (IBAction)toggleLoggingOptionForAllSensors:(id)sender;
@end

@interface JCSensorViewController : UIViewController{
}

@property IBOutlet JCGraphView* graphViewTopLeft;
@property IBOutlet JCGraphView* graphViewTopRight;
@property IBOutlet JCGraphView* graphViewBottomLeft;
@property IBOutlet JCGraphView* graphViewBottomRight;
@property IBOutlet UIView* frameForExpandedGraphView;
@property IBOutlet JCOptionTableViewViewController* optionViewController;
@property IBOutlet UITableView *optionView;

@property (nonatomic, assign)BOOL isUpdatetingView;
@property CGPoint panOffset;
@property CGFloat zoom;

- (JCSensorData *)sensorData;
- (NSString*)description;

// initGraphViews
@property NSMutableArray *graphViews;
@property NSMutableArray *graphViewRects;
- (void)initGraphViews;

// resize-animations
- (void)expandGraphView:(JCGraphView*)graphView;
- (void)resizeAllGraphViews;
@property bool expandedGraphView;

// Gestures and Actions
- (IBAction)stop;
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer;
- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)recognizer;
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer;
- (IBAction)resetView:(id)sender;

- (IBAction)style;
- (void)updateGraphs;
- (void)updateView;
- (void)draw;

// Buttons and Styles
@property IBOutlet UIButton *playButton;
@property IBOutlet UIButton *stopButton;
@property IBOutlet UIButton *styleButton;
@property IBOutlet UIButton *heartButton;
- (void)togglePlayButtonWithLogginConstraint:(bool)isLoggin;
- (void)setHeartButtonActive:(bool)isActive;

// Colors
@property (strong) UIColor *lightGreen;
@property (strong) UIColor *orange;
@property (strong) UIColor *middleGreen;
@property (strong) UIColor *darkGrey;
@property (strong) UIColor *darkGreen;
@property (strong) UIColor *mechlabOrange;
- (void)initColors;

// Optionkeys und UserInterface
- (void)initOptionView;
@property NSMutableArray *optionKeys;
@property bool showFilteredValues;
@property bool minMaxVisible;
- (void)showDiagrammOptionsUI;
- (void)filteredValueOptionChanged;
- (void)minMaxOptionChanged;

// Timer und Timer-Funktionen für zyklische Filterberechnungen
@property bool cyclicFilter;
@property double filterTimeInterval;
@property (weak) NSTimer *repeatingTimer;
- (IBAction)startRepeatingTimer:sender;
- (IBAction)stopRepeatingTimer:sender;
- (NSDictionary *)userInfo;

- (void)berechnung;

@end
