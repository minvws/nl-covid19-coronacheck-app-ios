//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class VerifierScanViewModelTests: XCTestCase {

    /// Subject under test
    var sut: VerifierScanViewModel?

    /// The coordinator spy
    var verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()

    override func setUp() {

        super.setUp()
        verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()

        sut = VerifierScanViewModel(
            coordinator: verifyCoordinatorDelegateSpy,
            cryptoManager: CryptoManagerSpy()
        )
    }

    // MARK: - Tests

    /// Test the dismiss method
    func testDismiss() {

        // Given

        // When
        sut?.dismiss()

        // Then
        XCTAssertTrue(verifyCoordinatorDelegateSpy.invokedNavigateToVerifierWelcome)
    }
}
