/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import XCTest
@testable import CTR
import Nimble

class DashboardViewModelTests: XCTestCase {

	/// Subject under test
	var sut: HolderDashboardViewModel!

	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	var cryptoManagerSpy: CryptoManagerSpy!

	var proofManagerSpy: ProofManagingSpy!

	var configSpy: ConfigurationGeneralSpy!

	override func setUp() {
		super.setUp()

		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		proofManagerSpy = ProofManagingSpy()
		configSpy = ConfigurationGeneralSpy()

		sut = HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)
	}

	// MARK: - Tests

	/// Test the appointment card tapped
	func testCardTappedAppointment() {

		// Given

		// When
		sut.cardTapped(.appointment)

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateToAppointment) == true
	}

	/// Test the create card tapped
	func testCardTappedCreate() {

		// Given

		// When
		sut.cardTapped(.create)

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateToAboutMakingAQR) == true
	}

	/// Test all the default content
	func testContent() {

		// Given

		// When
		sut = HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48
		)

		// Then
		expect(self.sut.title)
			.to(equal(.holderDashboardTitle), description: "Title should match")
		expect(self.sut.message)
			.to(equal(.holderDashboardIntro), description: "Message should match")
		expect(self.sut.qrCard)
			.to(beNil())
		expect(self.sut.expiredTitle)
			.to(equal(.holderDashboardQRExpired), description: "QR Expired title should match")
		expect(self.sut.appointmentCard)
			.toNot(beNil())
		expect(self.sut.createCard)
			.toNot(beNil())
		expect(self.sut.showExpiredQR) == false
		expect(self.sut.hideForCapture) == false
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() {

		// Given
		cryptoManagerSpy.crypoAttributes = nil

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.cryptoManagerSpy.readCredentialCalled) == true
		expect(self.cryptoManagerSpy.generateQRmessageCalled) == false
		expect(self.sut.qrCard)
			.to(beNil())
		expect(self.sut.showExpiredQR) == false
		expect(self.sut.createCard.title)
			.to(equal(.holderDashboardCreateTitle), description: "The title of the create card should match")
		expect(self.sut.createCard.actionTitle)
			.to(equal(.holderDashboardCreateAction), description: "The action title of the create card should match")
	}

	/// Test the validity of the credential with expired credential
	func testValidityCredentialExpired() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 3608
		cryptoManagerSpy.crypoAttributes = CryptoAttributes(
			birthDay: nil,
			birthMonth: nil,
			firstNameInitial: nil,
			lastNameInitial: nil,
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired",
			specimen: "0",
			paperProof: "0"
		)
		sut?.proofValidator = ProofValidator(maxValidity: 1)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.cryptoManagerSpy.readCredentialCalled) == true
		expect(self.cryptoManagerSpy.generateQRmessageCalled) == false
		expect(self.sut.validityTimer)
			.to(beNil())
		expect(self.sut.qrCard)
			.to(beNil())
		expect(self.sut.showExpiredQR) == true
		expect(self.sut.createCard.title)
			.to(equal(.holderDashboardCreateTitle), description: "The title of the create card should match")
		expect(self.sut.createCard.actionTitle)
			.to(equal(.holderDashboardCreateAction), description: "The action title of the create card should match")
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValid() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 20
		cryptoManagerSpy.crypoAttributes = CryptoAttributes(
			birthDay: nil,
			birthMonth: nil,
			firstNameInitial: nil,
			lastNameInitial: nil,
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired",
			specimen: "0",
			paperProof: "0"
		)
		let qrMessage = Data("testValidityCredentialValid".utf8)
		cryptoManagerSpy.qrMessage = qrMessage
		sut?.proofValidator = ProofValidator(maxValidity: 40)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.cryptoManagerSpy.readCredentialCalled) == true
		expect(self.sut.qrCard)
			.toNot(beNil())
		expect(self.sut.validityTimer)
			.toNot(beNil())
		expect(self.sut.showExpiredQR) == false
		expect(self.sut.createCard.title)
			.to(equal(.holderDashboardChangeTitle), description: "The title of the create card should match")
		expect(self.sut.createCard.actionTitle)
			.to(equal(.holderDashboardChangeAction), description: "The action title of the create card should match")

	}

	/// Test the navigat to enlarged QR scene
	func testNavigateToEnlargedQR() {

		// Given

		// When
		sut?.cardTapped(.qrcode)

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateToEnlargedQR) == true
	}

	func testCloseExpiredRQ() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 3608
		cryptoManagerSpy.crypoAttributes = CryptoAttributes(
			birthDay: nil,
			birthMonth: nil,
			firstNameInitial: nil,
			lastNameInitial: nil,
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired",
			specimen: "0",
			paperProof: "0"
		)
		sut?.proofValidator = ProofValidator(maxValidity: 1)
		sut?.checkQRValidity()

		// When
		sut?.closeExpiredRQ()

		// Then
		expect(self.cryptoManagerSpy.removeCredentialCalled) == true
		expect(self.cryptoManagerSpy.crypoAttributes)
			.to(beNil())
	}

	func test_qrcard_withValidAMTime() {

		// Given
		let holder = TestHolderIdentity(
			firstNameInitial: "R",
			lastNameInitial: "P",
			birthDay: "27",
			birthMonth: "5"
		)
		// Date and time (GMT): Wednesday, 28 April 2021 02:00:00
		let date = Date(timeIntervalSince1970: 1619575200)

		// When
		sut.showQRMessageIsValid(date, holder: holder)

		// Then
		expect(self.sut.qrCard?.identifier) == .qrcode
		expect(self.sut.qrCard?.title) == .holderDashboardQRTitle
		expect(self.sut.qrCard?.message) == .holderDashboardQRSubTitle
		expect(self.sut.qrCard?.holder) == "R P 27 MEI"
		expect(self.sut.qrCard?.actionTitle) == .holderDashboardQRAction
		expect(self.sut.qrCard?.image) == .myQR
		expect(self.sut.qrCard?.validUntil.contains("28")) == true
		expect(self.sut.qrCard?.validUntil.contains("april")) == true
		expect(self.sut.qrCard?.validUntil.contains("04:00")) == true
		expect(self.sut.qrCard?.validUntil.contains(String.am)) == false
		expect(self.sut.qrCard?.validUntilAccessibility.contains("28")) == true
		expect(self.sut.qrCard?.validUntilAccessibility.contains("april")) == true
		expect(self.sut.qrCard?.validUntilAccessibility.contains("04:00")) == false
		expect(self.sut.qrCard?.validUntilAccessibility.contains(String.am)) == true
	}

	func test_qrcard_withValidPMTime() {

		// Given
		let holder = TestHolderIdentity(
			firstNameInitial: "R",
			lastNameInitial: "P",
			birthDay: "27",
			birthMonth: "5"
		)
		// Date and time (GMT): Wednesday, 28 April 2021 14:00:00
		let date = Date(timeIntervalSince1970: 1619618400)

		// When
		sut.showQRMessageIsValid(date, holder: holder)

		// Then
		expect(self.sut.qrCard?.identifier) == .qrcode
		expect(self.sut.qrCard?.title) == .holderDashboardQRTitle
		expect(self.sut.qrCard?.message) == .holderDashboardQRSubTitle
		expect(self.sut.qrCard?.holder) == "R P 27 MEI"
		expect(self.sut.qrCard?.actionTitle) == .holderDashboardQRAction
		expect(self.sut.qrCard?.image) == .myQR
		expect(self.sut.qrCard?.validUntil.contains("28")) == true
		expect(self.sut.qrCard?.validUntil.contains("april")) == true
		expect(self.sut.qrCard?.validUntil.contains("16:00")) == true
		expect(self.sut.qrCard?.validUntil.contains(String.pm)) == false
		expect(self.sut.qrCard?.validUntilAccessibility.contains("28")) == true
		expect(self.sut.qrCard?.validUntilAccessibility.contains("april")) == true
		expect(self.sut.qrCard?.validUntilAccessibility.contains("16:00")) == false
		expect(self.sut.qrCard?.validUntilAccessibility.contains(String.pm)) == true
	}
}
