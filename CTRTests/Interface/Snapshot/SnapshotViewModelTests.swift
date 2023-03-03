/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
@testable import Resources

class SnapshotViewModelTests: XCTestCase {

	var sut: SnapshotViewModel?

	// MARK: Tests

	/// Test the initializer for the holder
	func testInitHolder() throws {

		// Given

		// When
		sut = SnapshotViewModel(
			flavor: AppFlavor.holder
		)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertEqual(strongSut.appIcon, I.launch.holderAppIcon(), "Icon should match")
	}

	/// Test the initializer for the verifier
	func testInitVerifier() throws {

		// Given

		// When
		sut = SnapshotViewModel(
			flavor: AppFlavor.verifier
		)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertEqual(strongSut.appIcon, I.launch.verifierAppIcon(), "Icon should match")
	}
}
