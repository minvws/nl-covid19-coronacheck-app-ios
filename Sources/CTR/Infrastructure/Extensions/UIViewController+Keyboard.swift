//
//  UIViewController+Keyboard.swift
//  Alarm112
//
//  Created by Rool Paap on 03/09/2018.
//  Copyright © 2020 Landelijke Meldkamer Samenwerking. All rights reserved.
//

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
	
	/// Unsubscribe to keyboard events
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
