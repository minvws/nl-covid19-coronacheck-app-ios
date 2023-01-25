/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

extension UIWindow {
	
	/// Replace UIWindow root view controller with fade animation.
	/// - Parameters:
	///   - viewController: The view controller to be shown
	///   - animated: Display fade animation
	///   - completion: A completion handler to be executed when the animation sequence ends
	func replaceRootViewController(with viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
		
		guard animated else {
			rootViewController = viewController
			completion?()
			return
		}
		
		UIView.transition(with: self, duration: 0.22, options: .transitionCrossDissolve) {
			let areAnimationsEnabled = UIView.areAnimationsEnabled
			UIView.setAnimationsEnabled(false)
			self.rootViewController = viewController
			UIView.setAnimationsEnabled(areAnimationsEnabled)
		} completion: { _ in
			completion?()
		}
	}
}
