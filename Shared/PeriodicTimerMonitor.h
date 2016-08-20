//
//  PeriodicTimerMonitor.h
//  PeriodicTimer
//
//  Created by Abdul Al-Shawa on 2016-08-20.
//  Copyright © 2016 Abdul Al-Shawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PeriodicTimerDelegate;


@interface PeriodicTimerMonitor : NSObject

// TODO: Add support for multiple delegates (?)
// TODO: Add support for C-block style callbacks (?)

@property (nonatomic, readonly) id<PeriodicTimerDelegate> delegate;
@property (nonatomic, readonly) double timerQuantum;
@property (nonatomic, readonly) BOOL inProgress;
@property (nonatomic, readonly) double targetPeriod;
@property (nonatomic, readonly) double currentTime;

- (instancetype)initWithTimeQuantum:(double)quantum delegate:(id<PeriodicTimerDelegate>)delegate;

- (void)toggleTimer;
- (void)configureWithValue:(double)period;

@end


@protocol PeriodicTimerDelegate <NSObject>

- (void)onTimerTickForMonitor:(PeriodicTimerMonitor *)sender;
- (void)onTimerPeriodForMonitor:(PeriodicTimerMonitor *)sender;

@end
