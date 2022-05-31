/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import ViewControllerPresentationSpy
@testable import CTR

class PaperProofScanViewControllerTests: XCTestCase {

	private var sut: PaperProofScanViewController!
	private var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	private var paperProofIdentifierSpy: PaperProofIdentifierSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		paperProofIdentifierSpy = PaperProofIdentifierSpy()
		sut = PaperProofScanViewController(
			viewModel: PaperProofScanViewModel(
				coordinator: coordinatorDelegateSpy,
				scanner: paperProofIdentifierSpy
			)
		)
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests
	
	func test_content() {
		
		// Given
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		sut.showPermissionError()
		
		// Then
		alertVerifier.verify(
			title: L.holder_scanner_permission_title(),
			message: L.holder_scanner_permission_message(),
			animated: true,
			actions: [
				.default(L.holder_scanner_permission_settings()),
				.cancel(L.general_cancel())
			]
		)
	}
	func test_parseQRMessage_whenQRisCTB_shouldShowErrorState() {

		// Given
		paperProofIdentifierSpy.stubbedIdentifyResult = .hasDomesticPrefix
		
		// When
		sut.found(code: "test")
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError) == true
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.title) == L.holder_scanner_error_title_ctb()
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.body) == L.holder_scanner_error_message_ctb()
	}

	func test_parseQRMessage_whenQRIsUnknown_shouldShowErrorState() {

		// Given
		paperProofIdentifierSpy.stubbedIdentifyResult = .unknown
		
		// When
		sut.found(code: "test")
		
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
		sut.found(code: code)
		
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
		sut.found(code: code)
		
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
		sut.found(code: code)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserDidScanDCC) == true
		expect(self.coordinatorDelegateSpy.invokedDisplayError) == true
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.title) == L.holderErrorstateTitle()
		expect(self.coordinatorDelegateSpy.invokedDisplayErrorParameters?.content.body) == L.holderErrorstateClientMessage("i 520 000 052")
	}
}
