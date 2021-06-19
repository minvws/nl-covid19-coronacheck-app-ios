/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PreventableScreenCapture {

	private var notificationCenter: NotificationCenterProtocol = NotificationCenter.default

	@Bindable var hideForCapture: Bool = false
	@Bindable var screenshotWasTaken: Bool = false

	/// Initializer
	init() {

		addObservers()
		preventScreenCapture()
	}

	deinit {

		notificationCenter.removeObserver(self)
	}

	// MARK: - capturedDidChangeNotification

	/// Add  observers to prevent screen capture
	func addObservers() {

		notificationCenter.addObserver(
			self,
			selector: #selector(preventScreenCapture),
			name: UIScreen.capturedDidChangeNotification,
			object: nil
		)

		notificationCenter.addObserver(
			self,
			selector: #selector(preventScreenCapture),
			name: UIApplication.willEnterForegroundNotification,
			object: nil
		)
		
		notificationCenter.addObserver(
			self,
			selector: #selector(preventScreenCapture),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)

		notificationCenter.addObserver(
			self,
			selector: #selector(handleScreenShot),
			name: UIApplication.userDidTakeScreenshotNotification,
			object: nil
		)
	}

	/// Prevent screen capture
	@objc internal func preventScreenCapture() {
		
		if UIScreen.main.isCaptured {
			hideForCapture = true
		} else {
			hideForCapture = false
		}
	}

	/// handle a screen shot taken
	@objc internal func handleScreenShot() {

		screenshotWasTaken = true
	}
}
