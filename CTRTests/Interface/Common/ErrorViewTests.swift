/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import SnapshotTesting
@testable import CTR

class ErrorViewTests: XCTestCase {

    var sut: ErrorView!

    override func setUp() {
        super.setUp()

		sut = ErrorView()
        sut.frame = CGRect(x: 0, y: 0, width: 390, height: 100)
		sut.backgroundColor = C.white()
    }

	func test_singleLine() {

		// Given
		sut.error = L.holderTokenentryRegularflowErrorInvalidCode()

		// Then
		assertSnapshot(matching: sut, as: .image)
	}

	func test_multiLine() {

		// Given
		sut.error = L.holderTokenentryRegularflowErrorUnknownprovider()

		// Then
		assertSnapshot(matching: sut, as: .image)
	}
}
