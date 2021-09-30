/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import SnapshotTesting
@testable import CTR

class TokenEntryViewTests: XCTestCase {

    var sut: TokenEntryView!

    override func setUp() {
        super.setUp()

		sut = TokenEntryView()
        sut.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
    }

    func testAllVisible() {
        sut.title = "A nice title"
        sut.message = "Here is a message of reasonable length"
        sut.tokenEntryFieldPlaceholder = "tokenEntryFieldPlaceholder"
        sut.verificationEntryFieldPlaceholder = "tokenEntryFieldPlaceholder"
        sut.tokenEntryView.header = "sut.tokenEntryView.header"
        sut.verificationEntryView.header = "verificationEntryView.header"
        sut.text = "verificationInfo"
        sut.primaryTitle = "Primary title"
        sut.errorView.error = "An error occurred!"
        sut.errorView.isHidden = false
        sut.textLabel.isHidden = false
		sut.textLabel.text = "textLabel"
		sut.userNeedsATokenButton.isHidden = false
		sut.userNeedsATokenButton.title = "userNeedsATokenButton"
		sut.resendVerificationCodeButton.isHidden = false
		sut.resendVerificationCodeButton.title = "resendVerificationCodeButton"

		assertSnapshot(matching: sut, as: .image)
    }

	func testTokenEntryOnly() {
		sut.title = "A nice title"
		sut.message = "Here is a message of reasonable length"
		sut.tokenEntryFieldPlaceholder = "tokenEntryFieldPlaceholder"
		sut.tokenEntryView.header = "sut.tokenEntryView.header"
		sut.errorView.isHidden = true
		sut.userNeedsATokenButton.isHidden = false
		sut.userNeedsATokenButton.title = "userNeedsATokenButton"
		sut.resendVerificationCodeButton.isHidden = true
		sut.primaryButton.title = "Button 1"

		assertSnapshot(matching: sut, as: .image)
	}
}
