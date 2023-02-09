/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

// Extend push/pop with completion blocks:

extension UINavigationController {
	
	public func pushViewController( _ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
		pushViewController(viewController, animated: animated)

		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}

	public func popViewController( animated: Bool, completion: @escaping () -> Void) {

		popViewController(animated: animated)

		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}

	public func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {

		popToViewController(viewController, animated: animated)

		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}

	public func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
		popToRootViewController(animated: animated)

		guard animated, let coordinator = transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}
	
	public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: @escaping () -> Void) {
		
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
	public func pushOrReplaceTopViewController(with viewController: UIViewController, animated: Bool) {
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
	public func pushWithFadeAnimation(with viewController: UIViewController, animationDuration: CFTimeInterval) {
		let transition = CATransition()
		transition.duration = animationDuration
		transition.type = .fade
		view.layer.add(transition, forKey: nil)
		pushViewController(viewController, animated: false)
	}
	
	public func popbackTo(instanceOf viewControllerType: UIViewController.Type, animated: Bool, completion: @escaping () -> Void) {

		guard let popbackVC = viewControllers.first(where: { $0.isKind(of: viewControllerType) })
		else {
			completion()
			return
		}
		
		popToViewController(popbackVC, animated: animated, completion: completion)
	}
	
	/// `oneOfInstanceOf` is in descending priority order
	public func popbackTo(oneOfInstanceOf viewControllerTypes: [UIViewController.Type], animated: Bool, completion: @escaping () -> Void) {

		let viewControllersMatchingTypes = viewControllerTypes.compactMap { viewControllerType in
			self.viewControllers.last(where: { $0.isKind(of: viewControllerType) })
		}
		
		guard let popbackVC = viewControllersMatchingTypes.first else {
			completion()
			return
		}
		
		popToViewController(popbackVC, animated: animated, completion: completion)
	}
}
