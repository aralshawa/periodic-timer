Periodic Timer
============

A simple iOS and watchOS client that notifies the user upon a configured period completion via tones and haptics.

Objective
------------
Provide a mechanism for the user to configure a value of at most 60 seconds to fire periodically giving haptic and audio feedback. The originally intended use-case was to help the user [pace food consumption](http://www.precisionnutrition.com/all-about-slow-eating) by, say, taking a bite every 45 seconds.

A Note on Timer Precision
------------
For the sake of simplicity, [`NSTimer`](https://developer.apple.com/documentation/foundation/timer) is used to schedule the user configured intervals. This is not ideal as `NSTimer` provides no real-time guarantees. Due to how run loops are managed, the effective resolution is 50-100 ms (the timer will not fire until the next time it is checked in a subsequent run loop). Utilizing [GCD based timers](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/GCDWorkQueues/GCDWorkQueues.html#//apple_ref/doc/uid/TP40008091-CH103-SW2) may offer more precision; however, this would also encounter a similar limitation. Since the end goal is to update the screen to reflect the time, it is possible to bind into Core Animation's [`CADisplayLink`](https://developer.apple.com/documentation/quartzcore/cadisplaylink) run loop such that it is not updated faster than the screen (typically around 16-18 ms).

With all this said, one feature is to provide the user [audio](https://developer.apple.com/documentation/audiotoolbox) and [haptic](https://developer.apple.com/documentation/uikit/uifeedbackgenerator) feedback which provide even fewer system guarantees. These depend on the application's state, system load, and device battery gauge.
