//
//  InterfaceController.m
//  PeriodicTimer
//
//  Created by Abdul Al-Shawa on 2016-08-20.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "InterfaceController.h"
#import "PeriodicTimerMonitor.h"

#define MAX_TIMER_VALUE 60.0
#define TIMER_QUANTUM 1.0

static NSString * const TIMER_TOGGLE_BTN_ENABLED_LABEL = @"Start";
static NSString * const TIMER_TOGGLE_BTN_DISABLED_LABEL = @"Stop";

@interface InterfaceController () <PeriodicTimerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *timerLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *timerToggleButton;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *interfacePicker;

@end

@implementation InterfaceController {
	PeriodicTimerMonitor *_monitor;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    _monitor = [[PeriodicTimerMonitor alloc] initWithTimeQuantum:TIMER_QUANTUM delegate:self];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
	
	// Interface Picker stub so that we can monitor the digital crown in watchOS 2
	NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:MAX_TIMER_VALUE];
	for(int ctr = 0; ctr <= MAX_TIMER_VALUE; ctr++) {
		WKPickerItem *item = [[WKPickerItem alloc] init];
		NSString *title = [NSString stringWithFormat:@"%d", ctr];
		item.title = title;
		[items addObject:item];
	}
	[self.interfacePicker setItems:items];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - UI Actions

- (IBAction)pickerValueDidChange:(NSInteger)value
{
	if (!_monitor.inProgress) {
		[_monitor configureWithValue:value];
		self.timerLabel.text = [NSString stringWithFormat:@"%02zd", (NSUInteger)value];
	}
}

- (IBAction)onTimerToggle
{
	if (_monitor.inProgress) {
		// Stop timer
		[_monitor toggleTimer];
		[self pickerValueDidChange:_monitor.targetPeriod];
		
		self.timerLabel.textColor = [UIColor colorWithRed:0.35 green:0.60 blue:0.95 alpha:1.00];
		
		[self.timerToggleButton setTitle:TIMER_TOGGLE_BTN_ENABLED_LABEL];
	} else {
		// Start timer
		self.timerLabel.textColor = [UIColor colorWithRed:0.98 green:0.21 blue:0.39 alpha:1.00];
		
		[self.timerToggleButton setTitle:TIMER_TOGGLE_BTN_DISABLED_LABEL];
		
		[_monitor toggleTimer];
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
	// Asynchronously play period sound
	[[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeSuccess];
}

@end



