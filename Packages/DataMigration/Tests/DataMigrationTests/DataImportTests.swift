/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import DataMigration
import Nimble

class DataImportTests: XCTestCase {
	
	private var sut: DataImporter!
	
	private var delegateSpy: DataImportDelegateSpy!
	
	override func setUp() {
		
		super.setUp()
		delegateSpy = DataImportDelegateSpy()
	}
	
	func test_import() throws {
		
		// Given
		sut = DataImporter(version: "TEST", delegate: delegateSpy)
		let data = try XCTUnwrap("This is a test".data(using: .utf8))
		
		// When
		try sut.importString("eyJpIjowLCJuIjoxLCJwIjoiSDRzSUFBQUFBQUFDRXd2SnlDeFdBS0pFaFpMVTRoSUFNcDk2d0E0QUFBQT0iLCJ2IjoiVEVTVCJ9")
		
		// Then
		expect(self.delegateSpy.invokedCompleted).toEventually(beTrue())
		expect(self.delegateSpy.invokedCompletedParameters?.value) == data
	}
	
	func test_import_notGzipped() {
		
		// Given
		sut = DataImporter(version: "TEST", delegate: delegateSpy)
		
		// When
		expect { try self.sut.importString("eyJpIjowLCJuIjoxLCJwIjoiVG05MElFZDZhWEJ3WldRPSIsInYiOiJURVNUIn0=") }
			.to(throwError(DataMigrationError.compressionError))
	}
}

class DataImportDelegateSpy: DataImportDelegate {

	var invokedCompleted = false
	var invokedCompletedCount = 0
	var invokedCompletedParameters: (value: Data, Void)?
	var invokedCompletedParametersList = [(value: Data, Void)]()

	func completed(_ value: Data) {
		invokedCompleted = true
		invokedCompletedCount += 1
		invokedCompletedParameters = (value, ())
		invokedCompletedParametersList.append((value, ()))
	}

	var invokedProgress = false
	var invokedProgressCount = 0
	var invokedProgressParameters: (percentage: Float, Void)?
	var invokedProgressParametersList = [(percentage: Float, Void)]()

	func progress(_ percentage: Float) {
		invokedProgress = true
		invokedProgressCount += 1
		invokedProgressParameters = (percentage, ())
		invokedProgressParametersList.append((percentage, ()))
	}
}
