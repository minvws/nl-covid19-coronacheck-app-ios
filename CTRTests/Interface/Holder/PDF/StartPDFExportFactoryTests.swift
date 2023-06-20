/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Nimble
import XCTest
@testable import CTR
import Resources

final class StartPDFExportFactoryTests: XCTestCase {
	
	var sut: StartPDFExportFactory!
	
	func test_getExportInstructions() {
		
		// Given
		sut = StartPDFExportFactory()
		
		// When
		let pages = sut.getExportInstructions()
		
		// Then
		expect(pages).to(haveCount(1))
		expect(pages.first?.title) == L.holder_pdfExport_start_title()
		expect(pages.first?.content) == L.holder_pdfExport_start_message()
		expect(pages.first?.nextButtonTitle) == L.holder_pdfExport_start_buttonTitle()
	}
}
