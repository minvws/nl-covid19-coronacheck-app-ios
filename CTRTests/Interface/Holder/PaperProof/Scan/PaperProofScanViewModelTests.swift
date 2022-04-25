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
	
	private var sut: PaperProofScanViewModel!
	private var environmentSpies: EnvironmentSpies!
	private var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	private var dccScannerSpy: DCCScannerSpy!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		dccScannerSpy = DCCScannerSpy()
		sut = PaperProofScanViewModel(coordinator: coordinatorDelegateSpy, scanner: dccScannerSpy)
	}
	
	func test_initialState() {

		// Given
		
		// When
		
		// Then
		expect(self.sut.title) == L.holder_scanner_title()
		expect(self.sut.message) == L.holder_scanner_message()
		expect(self.sut.torchLabels) == [L.holderTokenscanTorchEnable(), L.holderTokenscanTorchDisable()]
		
		PaperProofScanViewController(viewModel: sut).assertImage(containedInNavigationController: true)
	}

	func test_parseQRMessage_whenQRisCTB_shouldShowErrorState() {

		// Given
		dccScannerSpy.stubbedScanResult = .ctb
		
		// When
		sut.parseQRMessage("test")
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError) == true
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.title) == L.holder_scanner_error_title_ctb()
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.body) == L.holder_scanner_error_message_ctb()
	}

	func test_parseQRMessage_whenQRIsUnknown_shouldShowErrorState() {

		// Given
		dccScannerSpy.stubbedScanResult = .unknown
		
		// When
		sut.parseQRMessage("test")
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError) == true
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.title) == L.holder_scanner_error_title_unknown()
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.body) == L.holder_scanner_error_message_unknown()
	}

	func test_parseQRMessage_whenQRIsDutchDCC_shouldInvokeCoordinator() {
		
		// Given
		let code = "test"
		dccScannerSpy.stubbedScanResult = .dutchDCC(dcc: code )
		
		// When
		sut.parseQRMessage(code)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserDidScanDCC) == true
		expect(self.coordinatorDelegateSpy.invokedUserDidScanDCCParameters?.message) == code
		expect(self.coordinatorDelegateSpy.invokedUserWishesToEnterToken) == true
	}
	
	func test_parseQRMessage_whenQRIsForeignDCC_shouldInvokeCoordinator() {
		
		// Given
		let code = "test"
		dccScannerSpy.stubbedScanResult = .foreignDCC(dcc: code )
		environmentSpies.couplingManagerSpy.stubbedConvertResult = EventFlow.EventResultWrapper(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			identity: nil,
			status: .complete,
			result: nil
		)
		
		// When
		sut.parseQRMessage(code)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserDidScanDCC) == true
		expect(self.coordinatorDelegateSpy.invokedUserDidScanDCCParameters?.message) == code
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == true
	}
	
	func test_parseQRMessage_whenQRIsForeignDCC_conversionFailed_shouldShowError() {
		
		// Given
		let code = "test"
		dccScannerSpy.stubbedScanResult = .foreignDCC(dcc: code )
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil
		
		// When
		sut.parseQRMessage(code)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserDidScanDCC) == true
		expect(self.coordinatorDelegateSpy.invokedDisplayError) == true
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.title) == L.holderErrorstateTitle()
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.body) == L.holderErrorstateClientMessage("i 520 000 052")
	}
}

class DCCScannerSpy: DCCScannerProtocol {

	var invokedScan = false
	var invokedScanCount = 0
	var invokedScanParameters: (code: String, Void)?
	var invokedScanParametersList = [(code: String, Void)]()
	var stubbedScanResult: DCCScanResult!

	func scan(_ code: String) -> DCCScanResult {
		invokedScan = true
		invokedScanCount += 1
		invokedScanParameters = (code, ())
		invokedScanParametersList.append((code, ()))
		return stubbedScanResult
	}
}
