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
	
	func test_import_invalidVersion() {
		
		// Given
		sut = DataImporter(version: "TEST", delegate: delegateSpy)
		
		// When
		expect { try self.sut.importString("eyJpIjowLCJuIjoxLCJwIjoiSDRzSUFBQUFBQUFDRXd2SnlDeFdBS0pFaFpMVTRoSUFNcDk2d0E0QUFBQT0iLCJ2IjoiV1JPTkcifQ===") }
			.to(throwError(DataMigrationError.invalidVersion))
	}
	
	func test_import_invalidNumberOfPackages() {
		
		// Given
		sut = DataImporter(version: "TEST", delegate: delegateSpy)
		
		// When
		expect { try self.sut.importString("eyJpIjoxLCJuIjoxLCJwIjoiSDRzSUFBQUFBQUFDRXd2SnlDeFdBS0pFaFpMVTRoSUFNcDk2d0E0QUFBQT0iLCJ2IjoiVEVTVCJ9") }
			.to(throwError(DataMigrationError.invalidNumberOfPackages))
	}
}
