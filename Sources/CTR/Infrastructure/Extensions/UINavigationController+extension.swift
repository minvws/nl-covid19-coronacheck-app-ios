/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

// Extend push/pop with completion blocks:

extension UINavigationController {
	func pushViewController( _ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
		pushViewController(viewController, animated: animated)

		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}

	func popViewController( animated: Bool, completion: @escaping () -> Void) {

		popViewController(animated: animated)

		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}

	func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {

		popToViewController(viewController, animated: animated)

		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}

	func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
		popToRootViewController(animated: animated)

		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}
	
	func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: @escaping () -> Void) {
		
		setViewControllers(viewControllers, animated: animated)
		
		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}
	
	/// Pushes view controller if no stack is present. Or replaces top view controller when a stack is present.
	/// This prevents an endless stack and increasing memory pressure while preserving native push animation.
	/// - Parameters:
	///   - viewController: The view controller to push onto the stack or replace to.
	///   - animated: Specify true to animate the transition or false if you do not want the transition to be animated.
	func pushOrReplaceTopViewController(with viewController: UIViewController, animated: Bool) {
		if viewControllers.count <= 1 {
			pushViewController(viewController, animated: animated)
		} else {
			var updatedViewControllers = viewControllers
			updatedViewControllers[updatedViewControllers.count - 1] = viewController
			setViewControllers(updatedViewControllers, animated: animated)
		}
	}
	
	/// Pushes view controller with fade animation instead of push animation.
	/// - Parameters:
	///   - viewController: The view controller to push onto the stack.
	///   - animationDuration: The animation duration.
	func pushWithFadeAnimation(with viewController: UIViewController, animationDuration: CFTimeInterval) {
		let transition = CATransition()
		transition.duration = animationDuration
		transition.type = .fade
		view.layer.add(transition, forKey: nil)
		pushViewController(viewController, animated: false)
	}
}
