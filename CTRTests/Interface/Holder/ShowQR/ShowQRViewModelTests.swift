/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

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

	override func setUp() {

		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory)
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		screenCaptureDetector = ScreenCaptureDetectorSpy()
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
		)

		// Then
		expect(self.sut.showValidQR) == false
		expect(self.sut.hideForCapture) == false
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
		)

		// Then
		expect(self.sut.showValidQR) == false
		expect(self.sut.hideForCapture) == false
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.infoButtonAccessibility) == L.holderShowqrEuAboutTitle()
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateBackToStart) == true
	}

	func test_validity_withDomesticGreenCard_withValidCredential() throws {

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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
		)
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.cryptoManagerSpy.invokedGenerateQRmessage).toEventually(beTrue())
		expect(self.sut.showValidQR).toEventually(beTrue())
		expect(self.sut.qrImage).toEventuallyNot(beNil())
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.cryptoManagerSpy.invokedGenerateQRmessage).toEventually(beFalse())
		expect(self.sut.showValidQR).toEventually(beTrue())
		expect(self.sut.qrImage).toEventuallyNot(beNil())
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
		)

		var screenshotWasTaken = false
		sut.screenshotWasTakenHandler = {
			screenshotWasTaken = true
		}

		// When
		screenCaptureDetector.invokedScreenshotWasTakenCallback?()

		// Then
		expect(screenshotWasTaken) == true
	}

	func testHideForCapture() throws {
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
		)
		expect(self.sut.hideForCapture) == false

		// When
		screenCaptureDetector.invokedScreenCaptureDidChangeCallback?(true)

		// Then
		expect(self.sut.hideForCapture) == true

		// And disable again:
		screenCaptureDetector.invokedScreenCaptureDidChangeCallback?(false)
		expect(self.sut.hideForCapture) == false
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
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
			cryptoManager: cryptoManagerSpy,
			screenCaptureDetector: screenCaptureDetector
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

		// When
		sut?.showMoreInformation()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPage) == true
		expect(self.holderCoordinatorDelegateSpy.invokedPresentInformationPageParameters?.title) == L.holderShowqrEuAboutTitle()
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
