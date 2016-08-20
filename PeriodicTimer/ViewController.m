//
//  ViewController.m
//  PeriodicTimer
//
//  Created by Abdul Al-Shawa on 2016-08-20.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "PeriodicTimerMonitor.h"

#define MAX_TIMER_VALUE 60.0
#define MIN_TIMER_VALUE 0.0
#define TIMER_QUANTUM 1.0

static NSString * const TIMER_TOGGLE_BTN_ENABLED_LABEL = @"Start";
static NSString * const TIMER_TOGGLE_BTN_DISABLED_LABEL = @"Stop";

@interface ViewController () <PeriodicTimerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIStepper *timeStepper;
@property (weak, nonatomic) IBOutlet UIButton *timerToggleButton;
@property (weak, nonatomic) IBOutlet UISwitch *perSecTickSwitch;

@end

@implementation ViewController {
	PeriodicTimerMonitor *_monitor;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.timeStepper.minimumValue = MIN_TIMER_VALUE;
	self.timeStepper.maximumValue = MAX_TIMER_VALUE;
	
	_monitor = [[PeriodicTimerMonitor alloc] initWithTimeQuantum:TIMER_QUANTUM delegate:self];
}

#pragma mark - UI Actions
- (IBAction)onTimerToggle:(id)sender
{
	if (_monitor.inProgress) {
		// Stop timer
		[_monitor toggleTimer];
		[self onConfigureTime:nil];

		self.timeStepper.enabled = YES;
		self.timeStepper.alpha = 1.f;
		self.timerLabel.textColor = [UIColor colorWithRed:0.35 green:0.60 blue:0.95 alpha:1.00];
		
		[self.timerToggleButton setTitle:TIMER_TOGGLE_BTN_ENABLED_LABEL forState:UIControlStateNormal];
	} else {
		// Start timer
		self.timeStepper.enabled = NO;
		self.timeStepper.alpha = 0.5f;
		self.timerLabel.textColor = [UIColor colorWithRed:0.98 green:0.21 blue:0.39 alpha:1.00];
		
		[self.timerToggleButton setTitle:TIMER_TOGGLE_BTN_DISABLED_LABEL forState:UIControlStateNormal];
		
		[_monitor toggleTimer];
	}
}

- (IBAction)onConfigureTime:(id)sender
{
	double stepperVal = self.timeStepper.value;
	if (stepperVal <= MAX_TIMER_VALUE && stepperVal >= MIN_TIMER_VALUE) {
		[_monitor configureWithValue:stepperVal];
		self.timerLabel.text = [NSString stringWithFormat:@"%02zd", (NSUInteger)_monitor.targetPeriod];
	}
}

#pragma mark - <PeriodicTimerDelegate>

- (void)onTimerTickForMonitor:(PeriodicTimerMonitor *)sender
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Update the timer label
		self.timerLabel.text = [NSString stringWithFormat:@"%02zd", (NSUInteger)_monitor.currentTime];
	});
}

- (void)onTimerPeriodForMonitor:(PeriodicTimerMonitor *)sender
{
	// Period hit - - -
	// Asynchronously play period sound if enabled
	if (self.perSecTickSwitch.on) {
		NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/calendar_alert_chord.caf"];
		SystemSoundID soundID;
		AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL, &soundID);
		AudioServicesPlaySystemSoundWithCompletion(soundID, NULL);
		AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, NULL);
	}
}

@end
