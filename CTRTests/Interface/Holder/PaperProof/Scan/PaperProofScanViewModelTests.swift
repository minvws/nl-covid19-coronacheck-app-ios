/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR
@testable import Transport
@testable import Shared
import TestingShared

final class PaperProofScanViewModelTests: XCTestCase {
	
	private var sut: PaperProofScanViewModel!
	private var environmentSpies: EnvironmentSpies!
	private var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	private var paperProofIdentifierSpy: PaperProofIdentifierSpy!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		paperProofIdentifierSpy = PaperProofIdentifierSpy()
		sut = PaperProofScanViewModel(coordinator: coordinatorDelegateSpy, scanner: paperProofIdentifierSpy)
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
		paperProofIdentifierSpy.stubbedIdentifyResult = .hasDomesticPrefix
		
		// When
		sut.parseQRMessage("test")
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError) == true
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.title) == L.holder_scanner_error_title_ctb()
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.body) == L.holder_scanner_error_message_ctb()
	}

	func test_parseQRMessage_whenQRIsUnknown_shouldShowErrorState() {

		// Given
		paperProofIdentifierSpy.stubbedIdentifyResult = .unknown
		
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
		paperProofIdentifierSpy.stubbedIdentifyResult = .dutchDCC(dcc: code )
		
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
		paperProofIdentifierSpy.stubbedIdentifyResult = .foreignDCC(dcc: code )
		environmentSpies.couplingManagerSpy.stubbedConvertResult = EventFlow.EventResultWrapper(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			identity: EventFlow.Identity.fakeIdentity,
			status: .complete
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
		paperProofIdentifierSpy.stubbedIdentifyResult = .foreignDCC(dcc: code )
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

class PaperProofIdentifierSpy: PaperProofIdentifierProtocol {

	var invokedIdentify = false
	var invokedIdentifyCount = 0
	var invokedIdentifyParameters: (code: String, Void)?
	var invokedIdentifyParametersList = [(code: String, Void)]()
	var stubbedIdentifyResult: PaperProofType!

	func identify(_ code: String) -> PaperProofType {
		invokedIdentify = true
		invokedIdentifyCount += 1
		invokedIdentifyParameters = (code, ())
		invokedIdentifyParametersList.append((code, ()))
		return stubbedIdentifyResult
	}
}
