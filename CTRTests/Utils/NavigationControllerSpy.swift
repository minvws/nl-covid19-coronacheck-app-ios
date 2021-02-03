/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class NavigationControllerSpy: UINavigationController {
	
	var pushViewControllerCallCount = 0
	var popToRootViewControllerCalled = false
	var popViewControllerCalled = false
	var popToViewControllerCalled = false
	
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		
		pushViewControllerCallCount += 1
		super.pushViewController(viewController, animated: animated)
	}
	
	override func popToRootViewController(animated: Bool) -> [UIViewController]? {
		popToRootViewControllerCalled = true
		return super.popToRootViewController(animated: animated)
	}
	
	override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
		popToViewControllerCalled = true
		return super.popToViewController(viewController, animated: animated)
	}
	
	override func popViewController(animated: Bool) -> UIViewController? {
		
		popViewControllerCalled = true
		return super.popViewController(animated: animated)
	}
}
