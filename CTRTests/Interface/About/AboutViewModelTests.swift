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
		expect(self.sut.menu).to(haveCount(1), description: "There should be 1 element")
		expect(self.sut.menu.first?.identifier) == .privacyStatement
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
		expect(self.sut.menu).to(haveCount(1), description: "There should be 1 element")
		expect(self.sut.menu.first?.identifier) == .terms
		expect(self.sut.version.contains("testInitVerifier")) == false // verifier version not in target language file.
	}

	func test_menuOptionSelected_privacy() {

		// Given

		// When
		sut.menuOptionSelected(.privacyStatement)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == String.holderUrlPrivacy
	}

	func test_menuOptionSelected_terms() {

		// Given

		// When
		sut.menuOptionSelected(.terms)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == String.verifierUrlPrivacy
	}

	func test_menuOptionSelected_accessibility() {

		// Given

		// When
		sut.menuOptionSelected(.accessibility)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == false
	}
}
