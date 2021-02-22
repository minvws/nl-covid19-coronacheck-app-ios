/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ViewControllerSpy: UIViewController {

	var presentCalled = false
	var dismissCalled = false

	override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {

		presentCalled = true
		super.present(viewControllerToPresent, animated: flag, completion: completion)
	}

	override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		dismissCalled = true
		super.dismiss(animated: flag, completion: completion)
	}
}
