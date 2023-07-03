/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
@testable import CTR
@testable import Transport
@testable import Shared
import TestingShared
import Persistence
@testable import Models
@testable import Managers
@testable import Resources
import WebKit

final class PDFExportViewModelTests: XCTestCase {
	
	private var sut: PDFExportViewModel!
	private var environmentSpies: EnvironmentSpies!
	private var coordinatorSpy: PDFExportCoordinatorSpy!
	
	override func setUp() {
		super.setUp()
		
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = PDFExportCoordinatorSpy()
		
		sut = PDFExportViewModel(coordinator: coordinatorSpy)
	}
	
	func test_openUrl() throws {
		
		// Given
		let url = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut.openUrl(url)
		
		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == url
	}
	
	func test_openPDF() {
		
		// Given
		expect(self.sut.previewURL.value) == nil
		
		// When
		sut.openPDF()

		// Then
		expect(self.sut.previewURL.value) != nil
	}

	func test_sharePDF() {
		
		// Given
		
		// When
		sut.sharePDF(sender: nil)
		
		// Then
		expect(self.coordinatorSpy.invokedUserWishesToShare) == true
	}

	func test_viewDidAppear() {
		
		// Given
		environmentSpies.contactInformationSpy.stubbedPhoneNumberLink = "PHONENUMBER"
		
		// When
		sut.viewDidAppear()
		
		// Then
		expect(self.coordinatorSpy.invokedDisplayError) == true
		expect(self.coordinatorSpy.invokedDisplayErrorParameters?.content.body) == L.holder_pdfExport_error_body("PHONENUMBER", "i 1510 000 121") // Can't load file (config)
		expect(self.sut.html.value) == nil
	}
	
	func test_viewDidAppear_withConfig() throws {
		
		// Given
		environmentSpies.contactInformationSpy.stubbedPhoneNumberLink = "PHONENUMBER"
		environmentSpies.cryptoLibUtilitySpy.stubbedReadResult = try XCTUnwrap( JSONEncoder().encode(environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration)
		)
		
		// When
		sut.viewDidAppear()
		
		// Then
		expect(self.coordinatorSpy.invokedDisplayError) == true
		expect(self.coordinatorSpy.invokedDisplayErrorParameters?.content.body) == L.holder_pdfExport_error_body("PHONENUMBER", "i 1510 000 124") // No DCC's
		expect(self.sut.html.value) == nil
	}
	
	func test_viewDidAppear_withConfig_withDCC() throws {
		
		// Given
		environmentSpies.contactInformationSpy.stubbedPhoneNumberLink = "PHONENUMBER"
		environmentSpies.cryptoLibUtilitySpy.stubbedReadResult = try XCTUnwrap( JSONEncoder().encode(environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration)
		)
		let greencards = GreenCard.sampleInternationalMultipleVaccineDCC(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.walletManagerSpy.stubbedListGreenCardsResult = greencards
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		sut.viewDidAppear()
		
		// Then
		expect(self.coordinatorSpy.invokedDisplayError) == false
		expect(self.sut.html.value) != nil
	}
}
