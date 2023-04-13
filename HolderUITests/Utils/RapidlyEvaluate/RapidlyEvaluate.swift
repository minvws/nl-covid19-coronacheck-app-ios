/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoreFoundation

/// Adds an observer to the RunLoop with a callback to match a condition before each loop.
/// This allows for very rapid evaluation of a test condition without excessive waiting.
/// Downside: high CPU usage.
func rapidlyEvaluate(timeout: CFTimeInterval = 5, _ evaluateCondition: @escaping () -> Bool) -> Bool {
	
	var fulfilled = false
	
	// Create observer which will be evaluated on each runloop before runloop waits for next message:
	let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, true, 0) { _, _ in
		guard !fulfilled else { fatalError("RunLoop should be stopped after condition is fulfilled.") }
		
		fulfilled = evaluateCondition()
		
		if fulfilled {
			CFRunLoopStop(CFRunLoopGetCurrent())
		} else {
			// Condition not fulfilled: prevent RunLoop from waiting and continue looping.
			// NB: This step could be parameterised if situation found where normal runloop behaviour
			// is enough. That would lower the CPU usage. However, for now polling (i.e. not letting runloop wait) is most reliable.
			CFRunLoopWakeUp(CFRunLoopGetCurrent())
		}
	}
	
	CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, CFRunLoopMode.defaultMode)
	
	CFRunLoopRunInMode(CFRunLoopMode.defaultMode, timeout, false)
	
	CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, CFRunLoopMode.defaultMode)
	return fulfilled
}
