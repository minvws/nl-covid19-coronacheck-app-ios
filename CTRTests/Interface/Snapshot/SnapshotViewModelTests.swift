/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class SnapshotViewModelTests: XCTestCase {

	var sut: SnapshotViewModel?

	var versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0", build: "test")

	override func setUp() {
		super.setUp()

		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0", build: "test")

		sut = SnapshotViewModel(
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)
	}

	// MARK: Tests

	/// Test the initializer for the holder
	func testInitHolder() throws {

		// Given

		// When
		sut = SnapshotViewModel(
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder
		)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertEqual(strongSut.title, L.holderLaunchTitle(), "Title should match")
		XCTAssertEqual(strongSut.appIcon, I.launch.holderAppIcon(), "Icon should match")
		XCTAssertTrue(strongSut.version.contains("1.0.0"))
		XCTAssertTrue(strongSut.version.contains("test"))
	}

	/// Test the initializer for the verifier
	func testInitVerifier() throws {

		// Given

		// When
		sut = SnapshotViewModel(
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.verifier
		)

		// Then
		let strongSut = try XCTUnwrap(sut)
		XCTAssertEqual(strongSut.title, L.verifierLaunchTitle(), "Title should match")
		XCTAssertEqual(strongSut.appIcon, I.launch.verifierAppIcon(), "Icon should match")
	}
}
