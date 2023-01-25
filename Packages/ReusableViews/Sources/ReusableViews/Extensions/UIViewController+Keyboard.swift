/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIViewController {
	
	/// Subscribe to keyboard events
	///
	/// - Parameters:
	///   - keyboardWillShow: method called when the keyboard will show
	///   - keyboardWillHide: method called when the keyboard will hide
	func subscribeToKeyboardEvents(_ keyboardWillShow: Selector, keyboardWillHide: Selector) {
		
		// Listen to Keyboard events.
		NotificationCenter.default.addObserver(
			self,
			selector: keyboardWillShow,
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: keyboardWillHide,
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}

	func unSubscribeToKeyboardEvents() {
		
		// Remove Keyboard listeners
		NotificationCenter.default.removeObserver(
			self,
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		NotificationCenter.default.removeObserver(
			self,
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}
}
