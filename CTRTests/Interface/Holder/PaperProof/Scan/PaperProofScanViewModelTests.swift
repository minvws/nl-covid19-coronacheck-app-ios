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
	private var environmentSpies: EnvironmentSpies!
	var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		sut = PaperProofScanViewModel(coordinator: coordinatorDelegateSpy)
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
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		sut.parseQRMessage(message)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateACertificate) == true
		expect(self.coordinatorDelegateSpy.invokedUserWishesToCreateACertificateParameters?.message) == message
	}
}
