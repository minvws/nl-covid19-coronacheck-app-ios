/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class NavigationControllerSpy: UINavigationController {
	
	var pushViewControllerCallCount = 0
	var invokedPopToRootViewController = false
	var invokedPopViewController = false
	var invokedPopToViewController = false
	var invokedPresent = false
	
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		
		pushViewControllerCallCount += 1
		super.pushViewController(viewController, animated: animated)
	}
	
	override func popToRootViewController(animated: Bool) -> [UIViewController]? {
		invokedPopToRootViewController = true
		return super.popToRootViewController(animated: animated)
	}
	
	override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
		invokedPopToViewController = true
		return super.popToViewController(viewController, animated: animated)
	}
	
	override func popViewController(animated: Bool) -> UIViewController? {
		
		invokedPopViewController = true
		return super.popViewController(animated: animated)
	}
	
	override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {

		invokedPresent = true
		super.present(viewControllerToPresent, animated: flag, completion: completion)
	}
}
