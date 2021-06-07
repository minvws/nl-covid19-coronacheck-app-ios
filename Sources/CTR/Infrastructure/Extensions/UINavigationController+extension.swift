//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
}
