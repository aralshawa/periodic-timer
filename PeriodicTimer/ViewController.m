//
//  ViewController.m
//  PeriodicTimer
//
//  Created by Abdul Al-Shawa on 2016-08-20.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "ViewController.h"

#define MAX_TIMER_VALUE 60.0
#define MIN_TIMER_VALUE 0.0
#define TIMER_QUANTUM 1.0

static NSString * const TIMER_TOGGLE_BTN_ENABLED_LABEL = @"Start";
static NSString * const TIMER_TOGGLE_BTN_DISABLED_LABEL = @"Stop";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIStepper *timeStepper;
@property (weak, nonatomic) IBOutlet UIButton *timerToggleButton;
@property (weak, nonatomic) IBOutlet UISwitch *perSecTickSwitch;

@end

@implementation ViewController {
//	NSTimer *_periodicTimer;
	NSTimer *_tickTimer;
	NSTimeInterval _targetPeriod;
	NSTimeInterval _currTime;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

#pragma mark - UI Actions
- (void)onTimerTick:(id)sender
{
	// All timing is based off of the tickTimer to ensure consistency
	_currTime  -= TIMER_QUANTUM;
	
	if (_currTime < 0) {
		// Period hit - - -
		// TODO: Play period sound
		
		// Reset
		_currTime = _targetPeriod;
	} else {
		// TODO: Play tick sound
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		// Update the timer label
		self.timerLabel.text = [NSString stringWithFormat:@"%02zd", (NSUInteger)_currTime];
	});
}

- (IBAction)onTimerToggle:(id)sender
{
	if (_tickTimer.valid) {
		// Stop timer
		[_tickTimer invalidate];
		[self onConfigureTime:nil];

		self.timeStepper.enabled = YES;
		self.timeStepper.alpha = 1.f;
		
		[self.timerToggleButton setTitle:TIMER_TOGGLE_BTN_ENABLED_LABEL forState:UIControlStateNormal];
	} else {
		// Start timer
		self.timeStepper.enabled = NO;
		self.timeStepper.alpha = 0.5f;
		
		[self.timerToggleButton setTitle:TIMER_TOGGLE_BTN_DISABLED_LABEL forState:UIControlStateNormal];
		
		_tickTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_QUANTUM target:self selector:@selector(onTimerTick:) userInfo:nil repeats:YES];
	}
}

- (IBAction)onConfigureTime:(id)sender
{
	double stepperVal = self.timeStepper.value;
	if (stepperVal <= MAX_TIMER_VALUE && stepperVal >= MIN_TIMER_VALUE) {
		_targetPeriod = stepperVal;
		self.timerLabel.text = [NSString stringWithFormat:@"%02zd", (NSUInteger)_targetPeriod];
	}
}

@end
