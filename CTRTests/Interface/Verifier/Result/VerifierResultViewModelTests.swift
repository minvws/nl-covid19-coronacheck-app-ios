/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Rswift

class VerifierResultViewModelTests: XCTestCase {
	
	/// Subject under test
	var sut: VerifierResultViewModel!
	
	/// The coordinator spy
	var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	
	/// Date parser
	private lazy var parseDateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()
	
	override func setUp() {
		
		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		
		sut = VerifierResultViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			cryptoResults: CryptoResult(
				attributes: CryptoAttributes(
					birthDay: nil,
					birthMonth: nil,
					credentialVersion: nil,
					domesticDcc: "0",
					firstNameInitial: nil,
					lastNameInitial: nil,
					specimen: "0"
				),
				errorMessage: nil
			)
		)
	}
	
	// MARK: - Tests
	
	func test_checkAttributes_shouldDisplayDemo() {
		
		// Given
		sut.cryptoResults = CryptoResult(
			attributes:
				CryptoAttributes(
					birthDay: nil,
					birthMonth: nil,
					credentialVersion: nil,
					domesticDcc: "0",
					firstNameInitial: nil,
					lastNameInitial: nil,
					specimen: "1"
				),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .demo
		expect(self.sut.title) == L.verifierResultDemoTitle()
		expect(self.sut.message).to(beNil(), description: "Message should be nil")
	}
	
	func test_checkAttributes_whenNoAttributesAreSet_shouldDisplayDeniedInvalidQR() {
		
		// Given
		sut.cryptoResults = CryptoResult(
			attributes: nil,
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .denied
		expect(self.sut.title) == L.verifierResultDeniedTitle()
		expect(self.sut.message) == L.verifierResultDeniedMessage()
	}
	
	func test_checkAttributes_shouldDisplayDeniedDomesticDcc() {
		
		// Given
		sut.cryptoResults = CryptoResult(
			attributes: CryptoAttributes(
				birthDay: nil,
				birthMonth: nil,
				credentialVersion: nil,
				domesticDcc: "1",
				firstNameInitial: nil,
				lastNameInitial: nil,
				specimen: "0"
			),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .denied
		expect(self.sut.title) == L.verifierResultDeniedRegionTitle()
		expect(self.sut.message) == L.verifierResultDeniedRegionMessage()
	}
	
	func test_checkAttributes_whenSpecimenIsSet_shouldDisplayDeniedDomesticDcc() {
		
		// Given
		sut.cryptoResults = CryptoResult(
			attributes: CryptoAttributes(
				birthDay: nil,
				birthMonth: nil,
				credentialVersion: nil,
				domesticDcc: "1",
				firstNameInitial: nil,
				lastNameInitial: nil,
				specimen: "1"
			),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .denied
		expect(self.sut.title) == L.verifierResultDeniedRegionTitle()
		expect(self.sut.message) == L.verifierResultDeniedRegionMessage()
	}
	
	func test_checkAttributes_shouldDisplayVerified() {
		
		// Given
		sut.cryptoResults = CryptoResult(
			attributes:
				CryptoAttributes(
					birthDay: nil,
					birthMonth: nil,
					credentialVersion: nil,
					domesticDcc: "0",
					firstNameInitial: nil,
					lastNameInitial: nil,
					specimen: "0"
				),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .verified
		expect(self.sut.title) == L.verifierResultAccessTitle()
		expect(self.sut.message).to(beNil(), description: "Message should be nil")
	}

	func test_holderIdentity_allNil() {

		// Given
		let attributes = CryptoAttributes(
			birthDay: nil,
			birthMonth: nil,
			credentialVersion: nil,
			domesticDcc: "0",
			firstNameInitial: nil,
			lastNameInitial: nil,
			specimen: "0"
		)

		// When
		sut.setHolderIdentity(attributes)

		// Then
		expect(self.sut.firstName) == "-"
		expect(self.sut.lastName) == "-"
		expect(self.sut.dayOfBirth) == "-"
		expect(self.sut.monthOfBirth) == "-"
	}

	func test_holderIdentity_allEmpty() {

		// Given
		let attributes = CryptoAttributes(
			birthDay: "",
			birthMonth: "",
			credentialVersion: "",
			domesticDcc: "0",
			firstNameInitial: "",
			lastNameInitial: "",
			specimen: "0"
		)

		// When
		sut.setHolderIdentity(attributes)

		// Then
		expect(self.sut.firstName) == "-"
		expect(self.sut.lastName) == "-"
		expect(self.sut.dayOfBirth) == "-"
		expect(self.sut.monthOfBirth) == "-"
	}

	func test_holderIdentity_allNotEmpty() {

		// Given
		let attributes = CryptoAttributes(
			birthDay: "5",
			birthMonth: "5",
			credentialVersion: nil,
			domesticDcc: "0",
			firstNameInitial: "R",
			lastNameInitial: "P",
			specimen: "0"
		)

		// When
		sut.setHolderIdentity(attributes)

		// Then
		expect(self.sut.firstName) == "R"
		expect(self.sut.lastName) == "P"
		expect(self.sut.dayOfBirth) == "5"
		expect(self.sut.monthOfBirth) == "MEI (05)"
	}

	func test_holderIdentity_dateOfBirthUnknown() {

		// Given
		let attributes = CryptoAttributes(
			birthDay: "X",
			birthMonth: "X",
			credentialVersion: "",
			domesticDcc: "0",
			firstNameInitial: "",
			lastNameInitial: "",
			specimen: "0"
		)

		// When
		sut.setHolderIdentity(attributes)

		// Then
		expect(self.sut.firstName) == "-"
		expect(self.sut.lastName) == "-"
		expect(self.sut.dayOfBirth) == "X"
		expect(self.sut.monthOfBirth) == "X"
	}

	func testDismiss() {
		
		// Given
		
		// When
		sut.dismiss()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func testScanAgain() {
		
		// Given
		
		// When
		sut.scanAgain()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToScan) == true
	}
	
	func testLinkTappedDenied() {
		
		// Given
		sut.allowAccess = .denied
		
		// When
		sut.linkTapped()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDisplayContent) == true
	}
	
	func testLinkTappedAllowed() {
		
		// Given
		sut.allowAccess = .verified
		
		// When
		sut.linkTapped()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDisplayContent) == true
	}
}
