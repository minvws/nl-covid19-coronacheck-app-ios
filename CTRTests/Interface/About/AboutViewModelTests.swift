/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class AboutViewModelTests: XCTestCase {

	var sut: AboutViewModel?

	override func setUp() {
		super.setUp()

		sut = AboutViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.holder
		)
	}

	// MARK: Tests

	/// Test the initializer for the holder
	func testInitHolder() {

		// Given

		// When
		sut = AboutViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		)

		// Then
		guard let strongSut = sut else {

			XCTFail("Can not unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.title, .holderAboutTitle, "Title should match")
		XCTAssertEqual(strongSut.message, .holderAboutText, "Message should match")
		XCTAssertTrue(strongSut.version.contains("testInitHolder"), "Version should match")
	}

	/// Test the initializer for the verifier
	func testInitVerifier() {

		// Given

		// When
		sut = AboutViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		)

		// Then
		guard let strongSut = sut else {

			XCTFail("Can not unwrap sut")
			return
		}
		XCTAssertEqual(strongSut.title, .verifierAboutTitle, "Title should match")
		XCTAssertEqual(strongSut.message, .verifierAboutText, "Message should match")
		XCTAssertFalse(strongSut.version.contains("testInitVerifier"), "Version should match") // verifier version not in target
	}
}
