/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import XCTest
@testable import CTR
import Nimble

class ShowQRViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ShowQRViewModel!

	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var notificationCenterSpy: NotificationCenterSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		notificationCenterSpy = NotificationCenterSpy()
	}

	// MARK: - Tests

	/// Test all the default content
	func test_content_withDomesticGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: .policy3G,
			thirdPartyTicketAppName: nil
		)

		// Then
		expect(self.sut.title) == L.holderShowqrDomesticTitle()
		expect(self.sut.dosage).to(beNil())
		expect(self.sut.infoButtonAccessibility) == L.holder_showqr_domestic_accessibility_button_details()
		expect(self.sut.items).toEventually(haveCount(1))
	}

	func test_multiple_domesticGreenCards() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard, greenCard, greenCard],
			disclosurePolicy: .policy3G,
			thirdPartyTicketAppName: nil
		)

		// Then
		expect(self.sut.title) == L.holderShowqrDomesticTitle()
		expect(self.sut.dosage).to(beNil())
		expect(self.sut.infoButtonAccessibility) == L.holder_showqr_domestic_accessibility_button_details()
		expect(self.sut.items).toEventually(haveCount(3))
	}

	/// Test all the default content
	func test_content_withEuGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: nil,
			thirdPartyTicketAppName: nil
		)

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.dosage).to(beNil())
		expect(self.sut.infoButtonAccessibility) == L.holder_showqr_international_accessibility_button_details()
		expect(self.sut.items).toEventually(haveCount(1))
	}

	func test_content_withEuGreenCard_expiredForeignVaccination() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = .foreignExpiredFakeVaccination()

		// When
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: nil,
			thirdPartyTicketAppName: nil
		)

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.dosage) == "Dosis 1/2"
		expect(self.sut.relevancyInformation) == "Deze QR-code is niet meer geldig"
		expect(self.sut.infoButtonAccessibility) == L.holder_showqr_international_accessibility_button_details()
		expect(self.sut.items).toEventually(haveCount(1))
	}
	
	func test_delegate_itemIsNotValid() {

		// Given
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [],
			disclosurePolicy: .policy3G,
			thirdPartyTicketAppName: nil
		)

		// When
		sut.itemIsNotValid()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == true
	}

	func test_moreInformation_noValidCredential() throws {
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: .policy3G,
			thirdPartyTicketAppName: nil
		)

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPage) == false
	}

	func test_moreInformation_domesticGreenCard_validCredential_vaccination() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true,
				originType: .vaccination
			)
		)

		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: .policy3G,
			thirdPartyTicketAppName: nil
		)
		environmentSpies.cryptoManagerSpy.stubbedReadDomesticCredentialsResult = DomesticCredentialAttributes(
			birthDay: "30",
			birthMonth: "5",
			firstNameInitial: "R",
			lastNameInitial: "P",
			credentialVersion: "2",
			category: "3",
			specimen: "0",
			paperProof: "0",
			validFrom: "\(Date())",
			validForHours: "24"
		)

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPage) == true
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPageParameters?.title) == L.holderShowqrDomesticAboutTitle()
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPageParameters?.body) == L.holderShowqrDomesticAboutMessage("R P 30 MEI")
	}

	func test_moreInformation_domesticGreenCard_validCredential_disclosurePolicy1GEnabled() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true,
				originType: .test
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: .policy1G,
			thirdPartyTicketAppName: nil
		)
		environmentSpies.cryptoManagerSpy.stubbedReadDomesticCredentialsResult = DomesticCredentialAttributes(
			birthDay: "30",
			birthMonth: "5",
			firstNameInitial: "R",
			lastNameInitial: "P",
			credentialVersion: "2",
			category: "1",
			specimen: "0",
			paperProof: "0",
			validFrom: "\(Date())",
			validForHours: "24"
		)

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPage) == true
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPageParameters?.title) == L.holderShowqrDomesticAboutTitle()
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPageParameters?.body) == L.holder_qr_explanation_description_domestic_1G("R P 30 MEI")
	}

	func test_moreInformation_domesticGreenCard_validCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: .policy3G,
			thirdPartyTicketAppName: nil
		)
		environmentSpies.cryptoManagerSpy.stubbedReadDomesticCredentialsResult = DomesticCredentialAttributes(
			birthDay: "30",
			birthMonth: "5",
			firstNameInitial: "R",
			lastNameInitial: "P",
			credentialVersion: "2",
			category: "2",
			specimen: "0",
			paperProof: "0",
			validFrom: "\(Date())",
			validForHours: "24"
		)

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPage) == true
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPageParameters?.title) == L.holderShowqrDomesticAboutTitle()
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPageParameters?.body) == L.holderShowqrDomesticAboutMessage("R P 30 MEI")
	}

	func test_moreInformation_domesticGreenCard_validCredential_unreadableData() throws {
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: .policy3G,
			thirdPartyTicketAppName: nil
		)
		environmentSpies.cryptoManagerSpy.stubbedReadDomesticCredentialsResult = nil

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPage) == false
	}

	func test_moreInformation_euGreenCard_validCredential() throws {
		// Given
		environmentSpies.mappingManagerSpy.stubbedGetBilingualDisplayCountryResult = "Nederland / The Netherlands"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Test"
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: nil,
			thirdPartyTicketAppName: nil
		)
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 2, totalDose: 2))
		let expectedDetails: [DCCQRDetails] = [
			DCCQRDetails(field: DCCQRDetailsVaccination.name, value: "Corona, Check"),
			DCCQRDetails(field: DCCQRDetailsVaccination.dateOfBirth, value: "01-06-2021"),
			DCCQRDetails(field: DCCQRDetailsVaccination.pathogen, value: L.holderShowqrEuAboutVaccinationPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineBrand, value: "Test"),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineType, value: "test"),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineManufacturer, value: "Test"),
			DCCQRDetails(field: DCCQRDetailsVaccination.dosage, value: "2 / 2"),
			DCCQRDetails(field: DCCQRDetailsVaccination.date, value: "01-06-2021"),
			DCCQRDetails(field: DCCQRDetailsVaccination.country, value: "Nederland / The Netherlands"),
			DCCQRDetails(field: DCCQRDetailsVaccination.issuer, value: "Test"),
			DCCQRDetails(field: DCCQRDetailsVaccination.uniqueIdentifer, value: "test")
		]

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetails) == true
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetailsParameters?.title) == L.holderShowqrEuAboutVaccinationTitle("2", "2")
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetailsParameters?.description) == L.holderShowqrEuAboutVaccinationDescription()
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetailsParameters?.details) == expectedDetails
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetailsParameters?.dateInformation) == L.holderShowqrEuAboutVaccinationDateinformation()
	}

	func test_canShowThirdPartyAppButton() throws {

		// Arrange
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: .policy3G,
			thirdPartyTicketAppName: "RollerDiscoParties"
		)

		// Act
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToLaunchThirdPartyTicketApp) == false
		sut.didTapThirdPartyAppButton()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToLaunchThirdPartyTicketApp) == true
	}

	func test_minimisingApp_clears_thirdpartyappbutton() throws {
		// Arrange
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		notificationCenterSpy.stubbedAddObserverForNameResult = NSObject()
		notificationCenterSpy.stubbedAddObserverForNameBlockResult = (Notification(name: UIApplication.didEnterBackgroundNotification, object: nil, userInfo: nil), ())
		// Act
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			disclosurePolicy: .policy3G,
			thirdPartyTicketAppName: "RollerDiscoParties",
			notificationCenter: notificationCenterSpy
		)

		let (name, _, _, _) = notificationCenterSpy.invokedAddObserverForNameParameters!
		expect(name) == UIApplication.didEnterBackgroundNotification

		expect(self.sut.thirdPartyTicketAppButtonTitle).to(beNil())
	}
}
