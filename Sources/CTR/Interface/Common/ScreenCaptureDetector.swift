/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ScreenCaptureDetectorProtocol: AnyObject {
	var screenIsBeingCaptured: Bool { get }

	var screenshotWasTakenCallback: (() -> Void)? { get set }
	var screenCaptureDidChangeCallback: ((Bool) -> Void)? { get set }
}

final class ScreenCaptureDetector: ScreenCaptureDetectorProtocol {

	private var notificationCenter: NotificationCenterProtocol = NotificationCenter.default

	private(set) var screenIsBeingCaptured: Bool = false

	var screenshotWasTakenCallback: (() -> Void)?
	var screenCaptureDidChangeCallback: ((Bool) -> Void)? {
		didSet {
			updateScreenCaptureDidChangeCallback()
		}
	}

	/// Initializer
	init() {
		screenIsBeingCaptured = isCaptured
		addObservers()
	}

	deinit {
		notificationCenter.removeObserver(self)
	}

	// MARK: - capturedDidChangeNotification

	/// Add  observers to prevent screen capture
	func addObservers() {

		notificationCenter.addObserver(
			self,
			selector: #selector(updateScreenCaptureDidChangeCallback),
			name: UIScreen.capturedDidChangeNotification,
			object: nil
		)

		notificationCenter.addObserver(
			self,
			selector: #selector(updateScreenCaptureDidChangeCallback),
			name: UIApplication.willEnterForegroundNotification,
			object: nil
		)
		
		notificationCenter.addObserver(
			self,
			selector: #selector(updateScreenCaptureDidChangeCallback),
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
	@objc internal func updateScreenCaptureDidChangeCallback() {
		screenIsBeingCaptured = isCaptured
		screenCaptureDidChangeCallback?(isCaptured)
	}

	/// handle a screen shot taken
	@objc internal func handleScreenShot() {
		screenshotWasTakenCallback?()
	}
}

private extension ScreenCaptureDetector {
	
	var isCaptured: Bool {
		
		guard Configuration().getEnvironment() == "production" else {
			// Screen Capture is allowed in non production.
			return false
		}
		
		return UIScreen.main.isCaptured
	}
}
