/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class AboutViewModelTests: XCTestCase {

	var sut: AboutViewModel!
	private var coordinatorSpy: OpenUrlProtocolSpy!

	override func setUp() {
		super.setUp()

		coordinatorSpy = OpenUrlProtocolSpy()
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.holder
		)
	}

	// MARK: Tests

	func test_initializationWithHolder() {

		// Given

		// When
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		)

		// Then
		expect(self.sut.title) == .holderAboutTitle
		expect(self.sut.message) == .holderAboutText
		expect(self.sut.listHeader) == .holderAboutReadMore
		expect(self.sut.version.contains("testInitHolder")) == true
	}

	func test_initializationWithVerifier() {

		// Given

		// When
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		)

		// Then
		expect(self.sut.title) == .verifierAboutTitle
		expect(self.sut.message) == .verifierAboutText
		expect(self.sut.listHeader) == .verifierAboutReadMore
		expect(self.sut.version.contains("testInitVerifier")) == false // verifier version not in target language file.
	}
}
