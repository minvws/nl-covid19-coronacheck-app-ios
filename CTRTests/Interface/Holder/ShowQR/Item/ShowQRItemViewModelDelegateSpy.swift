/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ShowQRItemViewModelDelegateSpy: ShowQRItemViewModelDelegate {

	var invokedItemIsNotValid = false
	var invokedItemIsNotValidCount = 0

	func itemIsNotValid() {
		invokedItemIsNotValid = true
		invokedItemIsNotValidCount += 1
	}
}
