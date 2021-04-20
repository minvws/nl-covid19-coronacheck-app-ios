//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import SnapshotTesting
import XCTest

@testable import CTR

class TokenEntryViewControllerTests: XCTestCase {

    var sut: TokenEntryViewController!
    var viewModelSpy: TokenEntryViewModelSpy!

    override func setUp() {
        super.setUp()

        viewModelSpy = TokenEntryViewModelSpy(
            coordinator: HolderCoordinatorDelegateSpy(),
            proofManager: ProofManagingSpy(),
            requestToken: nil,
            tokenValidator: TokenValidatorSpy()
        )
        sut = TokenEntryViewController(viewModel: viewModelSpy)
    }

    func test_initialState_withoutRequestToken() {
        sut.assertImage()
    }
}

