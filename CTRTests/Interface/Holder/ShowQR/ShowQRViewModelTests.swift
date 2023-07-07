/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

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
			thirdPartyTicketAppName: nil
		)

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.dosage) == nil
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
			thirdPartyTicketAppName: nil
		)

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.dosage) == "Dosis 1/2"
		expect(self.sut.infoButtonAccessibility) == L.holder_showqr_international_accessibility_button_details()
		expect(self.sut.items).toEventually(haveCount(1))
	}
	
	func test_delegate_itemIsNotValid() {

		// Given
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [],
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
			thirdPartyTicketAppName: nil
		)

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
			DCCQRDetails(field: DCCQRDetailsVaccination.daysElapsed, value: "44 dagen"),
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
				type: .eu,
				withValidCredential: true
			)
		)
		notificationCenterSpy.stubbedAddObserverForNameResult = NSObject()
		notificationCenterSpy.stubbedAddObserverForNameBlockResult = (Notification(name: UIApplication.didEnterBackgroundNotification, object: nil, userInfo: nil), ())
		// Act
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			thirdPartyTicketAppName: "RollerDiscoParties",
			notificationCenter: notificationCenterSpy
		)

		let (name, _, _, _) = notificationCenterSpy.invokedAddObserverForNameParameters!
		expect(name) == UIApplication.didEnterBackgroundNotification

		expect(self.sut.thirdPartyTicketAppButtonTitle) == nil
	}

	func test_selectedanimation_internationalsummer() throws {
		
		// Arrange
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 3, day: 21).date! }
		
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		// Act
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			thirdPartyTicketAppName: nil
		)
		
		expect(self.sut.animationStyle) == .international(isWithinWinterPeriod: false)
	}
	
	func test_selectedanimation_internationalwinter() throws {
		
		// Arrange
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 12, day: 21).date! }
		
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		// Act
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			thirdPartyTicketAppName: nil
		)
		
		expect(self.sut.animationStyle) == .international(isWithinWinterPeriod: true)
	}
}
