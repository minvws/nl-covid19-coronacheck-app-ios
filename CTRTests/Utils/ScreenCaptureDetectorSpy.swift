/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class ScreenCaptureDetectorSpy: ScreenCaptureDetectorProtocol {

	var invokedScreenshotWasTakenCallbackSetter = false
	var invokedScreenshotWasTakenCallbackSetterCount = 0
	var invokedScreenshotWasTakenCallback: (() -> Void)?
	var invokedScreenshotWasTakenCallbackList = [(() -> Void)?]()
	var invokedScreenshotWasTakenCallbackGetter = false
	var invokedScreenshotWasTakenCallbackGetterCount = 0
	var stubbedScreenshotWasTakenCallback: (() -> Void)!

	var screenshotWasTakenCallback: (() -> Void)? {
		set {
			invokedScreenshotWasTakenCallbackSetter = true
			invokedScreenshotWasTakenCallbackSetterCount += 1
			invokedScreenshotWasTakenCallback = newValue
			invokedScreenshotWasTakenCallbackList.append(newValue)
		}
		get {
			invokedScreenshotWasTakenCallbackGetter = true
			invokedScreenshotWasTakenCallbackGetterCount += 1
			return stubbedScreenshotWasTakenCallback
		}
	}

	var invokedScreenCaptureDidChangeCallbackSetter = false
	var invokedScreenCaptureDidChangeCallbackSetterCount = 0
	var invokedScreenCaptureDidChangeCallback: ((Bool) -> Void)?
	var invokedScreenCaptureDidChangeCallbackList = [((Bool) -> Void)?]()
	var invokedScreenCaptureDidChangeCallbackGetter = false
	var invokedScreenCaptureDidChangeCallbackGetterCount = 0
	var stubbedScreenCaptureDidChangeCallback: ((Bool) -> Void)!

	var screenCaptureDidChangeCallback: ((Bool) -> Void)? {
		set {
			invokedScreenCaptureDidChangeCallbackSetter = true
			invokedScreenCaptureDidChangeCallbackSetterCount += 1
			invokedScreenCaptureDidChangeCallback = newValue
			invokedScreenCaptureDidChangeCallbackList.append(newValue)
		}
		get {
			invokedScreenCaptureDidChangeCallbackGetter = true
			invokedScreenCaptureDidChangeCallbackGetterCount += 1
			return stubbedScreenCaptureDidChangeCallback
		}
	}
}
