/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import XCTest
@testable import CTR

class ShowQRItemViewModelDelegateSpy: ShowQRItemViewModelDelegate {

	var invokedItemIsNotValid = false
	var invokedItemIsNotValidCount = 0

	func itemIsNotValid() {
		invokedItemIsNotValid = true
		invokedItemIsNotValidCount += 1
	}

	var invokedShowInfoExpiredQR = false
	var invokedShowInfoExpiredQRCount = 0
	var invokedShowInfoExpiredQRParameters: (type: OriginType, Void)?
	var invokedShowInfoExpiredQRParametersList = [(type: OriginType, Void)]()

	func showInfoExpiredQR(type: OriginType) {
		invokedShowInfoExpiredQR = true
		invokedShowInfoExpiredQRCount += 1
		invokedShowInfoExpiredQRParameters = (type, ())
		invokedShowInfoExpiredQRParametersList.append((type, ()))
	}

	var invokedShowInfoHiddenQR = false
	var invokedShowInfoHiddenQRCount = 0

	func showInfoHiddenQR() {
		invokedShowInfoHiddenQR = true
		invokedShowInfoHiddenQRCount += 1
	}
}
