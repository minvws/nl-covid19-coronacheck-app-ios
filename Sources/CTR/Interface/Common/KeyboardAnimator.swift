/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct KeyboardAnimator {
	
	static func keyBoardWillShow(notification: Notification, onCompletion: ((CGFloat) -> Void)?) {
		
		let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
		let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
		let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
		
		// Create a property animator to manage the animation
		let animator = UIViewPropertyAnimator(
			duration: animationDuration,
			curve: UIView.AnimationCurve(rawValue: animationCurve) ?? .linear
		) {
			let buttonOffset: CGFloat = UIDevice.current.hasNotch ? 20 : -10
			onCompletion?(-keyboardHeight + buttonOffset)
		}
		
		// Start the animation
		animator.startAnimation()
	}
	
	static func keyBoardWillHide(notification: Notification, onCompletion: ((CGFloat) -> Void)?) {
		
		let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
		let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
		
		// Create a property animator to manage the animation
		let animator = UIViewPropertyAnimator(
			duration: animationDuration,
			curve: UIView.AnimationCurve(rawValue: animationCurve) ?? .linear
		) {
			onCompletion?(-20)
		}
		
		// Start the animation
		animator.startAnimation()
	}
}
