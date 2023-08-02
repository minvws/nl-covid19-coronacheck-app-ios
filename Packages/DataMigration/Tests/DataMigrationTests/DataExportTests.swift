/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import DataMigration
import Nimble

class DataExportTests: XCTestCase {

	private var sut: DataExporter!
	
	func test_export() throws {
		
		// Given
		sut = DataExporter(maxPackageSize: 100, version: "TEST")
		let data = try XCTUnwrap("This is a test".data(using: .utf8))
		
		// When
		let packages = try sut.export(data)
		
		// Then
		expect(packages).to(haveCount(1))
	}
	
	func test_export_decoded() throws {
		
		// Given
		sut = DataExporter(maxPackageSize: 100, version: "TEST")
		let data = try XCTUnwrap("This is a test".data(using: .utf8))
		
		// When
		let packages = try sut.export(data)
		let package = try XCTUnwrap(packages.first?.base64Decoded())
		let decoded = try JSONDecoder().decode(MigrationParcel.self, from: package.data(using: .utf8)!)
		
		// Then
		expect(decoded.version) == "TEST"
		expect(decoded.index) == 0
		expect(decoded.numberOfPackages) == 1
		expect(decoded.payload.isGzipped) == true
		
		let unzipped = try decoded.payload.gunzipped()
		expect(unzipped) == data
	}
	
	func test_export_smallPackageSize() throws {
		
		// Given
		sut = DataExporter(maxPackageSize: 5, version: "TEST")
		let data = try XCTUnwrap("This is a test".data(using: .utf8))
		
		// When
		let packages = try sut.export(data)
		
		// Then
		expect(packages).to(haveCount(7))
	}
}
