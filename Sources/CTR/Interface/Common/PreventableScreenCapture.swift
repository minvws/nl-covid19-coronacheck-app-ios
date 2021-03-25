/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PreventableScreenCapture {

	/// Hide for screen capture
	@Bindable var hideForCapture: Bool = false

	/// Initializer
	init() {

		addObservers()
		preventScreenCapture()
	}

	deinit {

		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - capturedDidChangeNotification

	/// Add  observesr to prevent screen capture
	func addObservers() {

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(preventScreenCapture),
			name: UIScreen.capturedDidChangeNotification,
			object: nil
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(preventScreenCapture),
			name: UIApplication.willEnterForegroundNotification,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(preventScreenCapture),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)
	}

	/// Prevent screen capture
	@objc func preventScreenCapture() {
		
		if UIScreen.main.isCaptured {
			hideForCapture = true
		} else {
			hideForCapture = false
		}
	}
}
