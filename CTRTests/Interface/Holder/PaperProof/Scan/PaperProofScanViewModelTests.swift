/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR

final class PaperProofScanViewModelTests: XCTestCase {
	
	var sut: PaperProofScanViewModel!
	var coordinatorDelegateSpy: PaperCertificateCoordinatorDelegateSpy!
	var cryptoManagerSpy: CryptoManagerSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = PaperCertificateCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		Services.use(cryptoManagerSpy)
		sut = PaperProofScanViewModel(coordinator: coordinatorDelegateSpy)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}
	
	func test_initialState() {
		expect(self.sut.title) == L.holderScannerTitle()
		expect(self.sut.message) == L.holderScannerMessage()
		expect(self.sut.torchLabels) == [L.holderTokenscanTorchEnable(), L.holderTokenscanTorchDisable()]
		
		PaperProofScanViewController(viewModel: sut).assertImage()
	}
	
	func test_parseQRMessage_whenDomesticQRIsUppercased_shouldInvokeAlert() {
		// Given
		let message = "NL:MOCK:MESSAGE"
		
		// When
		sut.parseQRMessage(message)
		
		// Then
		expect(self.sut.alert?.title) == L.holderScannerAlertDccTitle()
		expect(self.sut.alert?.subTitle) == L.holderScannerAlertDccMessage()
		expect(self.sut.alert?.okTitle) == L.generalOk()
	}
	
	func test_parseQRMessage_whenDomesticQRIsLowercased_shouldInvokeAlert() {
		// Given
		let message = "nl:mock:message"
		
		// When
		sut.parseQRMessage(message)
		
		// Then
		expect(self.sut.alert?.title) == L.holderScannerAlertDccTitle()
		expect(self.sut.alert?.subTitle) == L.holderScannerAlertDccMessage()
		expect(self.sut.alert?.okTitle) == L.generalOk()
	}
	
	func test_parseQRMessage_whenQRIsUnknown_shouldInvokeAlert() {
		// Given
		let message = "ml:!@#$%"
		
		// When
		sut.parseQRMessage(message)
		
		// Then
		expect(self.sut.alert?.title) == L.holderScannerAlertUnknownTitle()
		expect(self.sut.alert?.subTitle) == L.holderScannerAlertUnknownMessage()
		expect(self.sut.alert?.okTitle) == L.generalOk()
	}
	
	func test_parseQRMessage_whenQRIsDCC_shouldInvokeCoordinator() {
		// Given
		let message = "HC1:MOCK:MESSAGE"
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
		sut.parseQRMessage(message)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateACertificate) == true
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateACertificateParameters?.message) == message
	}
}
