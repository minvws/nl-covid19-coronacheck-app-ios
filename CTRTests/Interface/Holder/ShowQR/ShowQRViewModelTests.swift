/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import UIKit
import XCTest
@testable import CTR
import Nimble

class ShowQRViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ShowQRViewModel!

	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var cryptoManagerSpy: CryptoManagerSpy!
	var dataStoreManager: DataStoreManaging!
	var screenCaptureDetector: ScreenCaptureDetectorSpy!
	var userSettingsSpy: UserSettingsSpy!
	var remoteConfigManagingSpy: RemoteConfigManagingSpy!

	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory)
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		screenCaptureDetector = ScreenCaptureDetectorSpy()
		userSettingsSpy = UserSettingsSpy()
		remoteConfigManagingSpy = RemoteConfigManagingSpy(networkManager: NetworkSpy())
	}

	// MARK: - Tests

	/// Test all the default content
	func test_content_withDomesticGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.sut.visibilityState) == .loading
		expect(self.sut.title) == L.holderShowqrDomesticTitle()
		expect(self.sut.infoButtonAccessibility) == L.holderShowqrDomesticAboutTitle()
	}

	/// Test all the default content
	func test_content_withEuGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.sut.visibilityState) == .loading
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.infoButtonAccessibility) == L.holderShowqrEuAboutTitle()
	}

	func test_constants() {
		expect(ShowQRViewModel.domesticCorrectionLevel) == "M"
		expect(ShowQRViewModel.internationalCorrectionLevel) == "Q"
		expect(ShowQRViewModel.screenshotWarningMessageDuration) == 180
	}

	func test_validity_withDomesticGreenCard_withoutCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == true
	}

	func test_validity_withEuGreenCard_withoutCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == true
	}

	func test_validity_withDomesticGreenCard_withValidCredential() throws {
		remoteConfigManagingSpy.stubbedGetConfigurationResult = .default
		
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.cryptoManagerSpy.invokedGenerateQRmessage).toEventually(beTrue())
		expect(self.sut.visibilityState).toEventually(beVisible())
		expect(self.sut.validityTimer).toEventuallyNot(beNil())
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == false
	}

	func test_validity_withEuGreenCard_withValidCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.cryptoManagerSpy.invokedGenerateQRmessage).toEventually(beFalse())
		expect(self.sut.visibilityState).toEventually(beVisible())
		expect(self.sut.validityTimer).toEventuallyNot(beNil())
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == false
	}

	/// Test taking a screenshot
	func testScreenshot() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// When
		screenCaptureDetector.invokedScreenshotWasTakenCallback?()

		// Then
		expect(self.sut.visibilityState).to(beScreenshotBlocking())
	}

	func testTakingAScreenshotPersistsDate() throws {

		// Given
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			remoteConfigManager: remoteConfigManagingSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy,
			now: { now }
		)

		// When
		screenCaptureDetector.invokedScreenshotWasTakenCallback?()

		// Then
		expect(self.userSettingsSpy.invokedLastScreenshotTime).toEventually(equal(now))
	}

	func testHavingAPriorUnexpiredScreenshotStartsScreenshotBlocker() throws {

		// Given
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()
		userSettingsSpy.stubbedLastScreenshotTime = now.addingTimeInterval(-10)

		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			remoteConfigManager: remoteConfigManagingSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy,
			now: { now }
		)

		// Then
		expect(self.sut.visibilityState).toEventually(beScreenshotBlocking(test: { message, voiceoverMessage in
			expect(message) == "Je QR-code komt terug in 2:50"
			expect(voiceoverMessage) == "Je QR-code komt terug in 2 minuten en 50 seconden"
		}))
	}

	func testHideForCapture() throws {
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.sut.visibilityState).toEventually(beVisible())

		screenCaptureDetector.invokedScreenCaptureDidChangeCallback?(true)
		expect(self.sut.visibilityState) == .hiddenForScreenCapture

		// And disable again:
		screenCaptureDetector.invokedScreenCaptureDidChangeCallback?(false)
		expect(self.sut.visibilityState).toEventually(beVisible())
	}

	func test_moreInformation_noValidCredential() throws {
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPage) == false
	}

	func test_moreInformation_domesticGreenCard_validCredential() throws {
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)
		cryptoManagerSpy.stubbedReadDomesticCredentialsResult = DomesticCredentialAttributes(
			birthDay: "30",
			birthMonth: "5",
			firstNameInitial: "R",
			lastNameInitial: "P",
			credentialVersion: "2",
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
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPageParameters?.body).to(contain("R P 30"))
	}

	func test_moreInformation_domesticGreenCard_validCredential_unreadableData() throws {
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)
		cryptoManagerSpy.stubbedReadDomesticCredentialsResult = nil

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPage) == false
	}

	func test_moreInformation_euGreenCard_validCredential() throws {
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: nil,
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)
		cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes(
			credentialVersion: 1,
			digitalCovidCertificate: EuCredentialAttributes.DigitalCovidCertificate(
				dateOfBirth: "2021-06-01",
				name: EuCredentialAttributes.Name(
					familyName: "Corona",
					standardisedFamilyName: "CORONA",
					givenName: "Check",
					standardisedGivenName: "CHECK"
				),
				schemaVersion: "1.0.0",
				vaccinations: [
					EuCredentialAttributes.Vaccination(
						certificateIdentifier: "test",
						country: "NLS",
						diseaseAgentTargeted: "test",
						doseNumber: 2,
						dateOfVaccination: "2021-06-01",
						issuer: "Test",
						marketingAuthorizationHolder: "Test",
						medicalProduct: "Test",
						totalDose: 2,
						vaccineOrProphylaxis: "test"
					)
				]
			),
			expirationTime: Date().timeIntervalSince1970,
			issuedAt: Date().timeIntervalSince1970 + 3600,
			issuer: "NL"
		)
		let expectedDetails: [DCCQRDetails] = [
			DCCQRDetails(field: DCCQRDetailsVaccination.name, value: "Corona, Check"),
			DCCQRDetails(field: DCCQRDetailsVaccination.dateOfBirth, value: "01-06-2021"),
			DCCQRDetails(field: DCCQRDetailsVaccination.pathogen, value: L.holderShowqrEuAboutVaccinationPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineBrand, value: "Test"),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineType, value: "test"),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineManufacturer, value: "Test"),
			DCCQRDetails(field: DCCQRDetailsVaccination.dosage, value: "2 / 2"),
			DCCQRDetails(field: DCCQRDetailsVaccination.date, value: "01-06-2021"),
			DCCQRDetails(field: DCCQRDetailsVaccination.country, value: "NLS"),
			DCCQRDetails(field: DCCQRDetailsVaccination.issuer, value: "Test"),
			DCCQRDetails(field: DCCQRDetailsVaccination.uniqueIdentifer, value: "test")
		]

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetails) == true
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetailsParameters?.title) == L.holderShowqrEuAboutTitle()
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetailsParameters?.description) == L.holderShowqrEuAboutVaccinationDescription()
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetailsParameters?.details) == expectedDetails
		expect(self.holderCoordinatorDelegateSpy.invokedPresentDCCQRDetailsParameters?.dateInformation) == L.holderShowqrEuAboutVaccinationDateinformation()
	}

	func test_canShowThirdPartyAppButton() throws {

		// Arrange
		let greenCard = try XCTUnwrap(
			GreenCardModel.createTestGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		sut = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCard: greenCard,
			thirdPartyTicketAppName: "RollerDiscoParties",
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// Act
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToLaunchThirdPartyTicketApp) == false
		sut.didTapThirdPartyAppButton()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToLaunchThirdPartyTicketApp) == true
	}
}

extension GreenCardModel {

	static func createTestGreenCard(dataStoreManager: DataStoreManaging, type: GreenCardType, withValidCredential: Bool) -> GreenCard? {

		var result: GreenCard?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				result = GreenCardModel.create(
					type: type,
					wallet: wallet,
					managedContext: context
				)
				if withValidCredential, let greenCard = result {
					let now = Date().timeIntervalSince1970 - 200
					let expiration = now + 3600
					CredentialModel.create(
						data: Data(),
						validFrom: Date(timeIntervalSince1970: now),
						expirationTime: Date(timeIntervalSince1970: expiration),
						greenCard: greenCard,
						managedContext: context
					)
				}
			}
		}
		return result
	}
}

private func beVisible(test: @escaping (UIImage) -> Void = { _ in }) -> Predicate<ShowQRImageView.VisibilityState> {
	return Predicate.define("be .expiredQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .visible(qrImage: image) = actual {
			test(image)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
private func beScreenshotBlocking(test: @escaping (String, String) -> Void = { _, _ in }) -> Predicate<ShowQRImageView.VisibilityState> {
	return Predicate.define("be .expiredQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .screenshotBlocking(timeRemainingText, voiceoverTimeRemainingText) = actual {
			test(timeRemainingText, voiceoverTimeRemainingText)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
