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

	private var sut: AboutViewModel!
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
		expect(self.sut.title) == L.holderAboutTitle()
		expect(self.sut.message) == L.holderAboutText()
		expect(self.sut.listHeader) == L.holderAboutReadmore()
		expect(self.sut.menu).to(haveCount(3))
		expect(self.sut.menu.first?.identifier) == .privacyStatement
		expect(self.sut.menu[1].identifier) == AboutMenuIdentifier.accessibility
		expect(self.sut.menu.last?.identifier) == .colophon
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
		expect(self.sut.title) == L.verifierAboutTitle()
		expect(self.sut.message) == L.verifierAboutText()
		expect(self.sut.listHeader) == L.verifierAboutReadmore()
		expect(self.sut.menu).to(haveCount(3))
		expect(self.sut.menu.first?.identifier) == .terms
		expect(self.sut.menu[1].identifier) == AboutMenuIdentifier.accessibility
		expect(self.sut.menu.last?.identifier) == .colophon
		expect(self.sut.version.contains("testInitVerifier")) == true
	}

	func test_menuOptionSelected_privacy() {

		// Given

		// When
		sut.menuOptionSelected(.privacyStatement)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holderUrlPrivacy()
	}

	func test_menuOptionSelected_terms() {

		// Given

		// When
		sut.menuOptionSelected(.terms)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.verifierUrlPrivacy()
	}

	func test_menuOptionSelected_accessibility_forHolder() {

		// Given
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitHolder"),
			flavor: AppFlavor.holder
		)
		// When
		sut.menuOptionSelected(.accessibility)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.holderUrlAccessibility()
	}

	func test_menuOptionSelected_accessibility_forVerifier() {

		// Given
		sut = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "testInitVerifier"),
			flavor: AppFlavor.verifier
		)

		// When
		sut.menuOptionSelected(.accessibility)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.url.absoluteString) == L.verifierUrlAccessibility()
	}
}
