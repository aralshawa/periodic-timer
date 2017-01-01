//
//  PeriodicTimerMonitor.m
//  PeriodicTimer
//
//  Created by Abdul Al-Shawa on 2016-08-20.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import "PeriodicTimerMonitor.h"

@interface PeriodicTimerMonitor ()

@property (nonatomic, readwrite) id<PeriodicTimerDelegate> delegate;
@property (nonatomic, readwrite) double timerQuantum;
@property (nonatomic, readwrite) BOOL inProgress;

@end

@implementation PeriodicTimerMonitor {
	NSTimer *_tickTimer;
	NSTimeInterval _targetPeriod;
	NSTimeInterval _currTime;
}

- (instancetype)initWithTimeQuantum:(double)quantum delegate:(id<PeriodicTimerDelegate>)delegate
{
	if (self = [super init]) {
		_timerQuantum = quantum;
		_delegate = delegate; // Weakly ref the delegate
		_inProgress = NO;
	}

	return self;
}

#pragma mark - Properties

- (BOOL)inProgress
{
	return _tickTimer.valid;
}

- (double)targetPeriod
{
	return _targetPeriod;
}

- (double)currentTime
{
	return _currTime;
}

#pragma mark - Actions

- (void)toggleTimer
{
	if (_tickTimer.valid) {
		// Stop timer
		[_tickTimer invalidate];
	} else {
		// Start timer
		// NOTE: NSTimer provides no real time guarantees. Due to how run loops are managed, the effective resolution is 50-100 ms.
		// REFERENCE: https://developer.apple.com/reference/foundation/timer
		// TODO: Use GCD for timer creation.
		// REFERENCE: https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/GCDWorkQueues/GCDWorkQueues.html#//apple_ref/doc/uid/TP40008091-CH103-SW2
		_currTime = _targetPeriod;
		_tickTimer = [NSTimer scheduledTimerWithTimeInterval:self.timerQuantum target:self selector:@selector(onTimerTick:) userInfo:nil repeats:YES];
	}
}

- (void)configureWithValue:(double)period
{
	_targetPeriod = period;
}

- (void)onTimerTick:(id)sender
{
	// All timing is based off of the tickTimer to ensure consistency
	_currTime  -= self.timerQuantum;

	if (_currTime < 0) {
		// Period hit - - -
		[self.delegate onTimerPeriodForMonitor:self];

		// Reset
		_currTime = _targetPeriod;
	}

	[self.delegate onTimerTickForMonitor:self];
}

@end
