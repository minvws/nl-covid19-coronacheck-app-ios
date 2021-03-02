/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest

class ProofManagerTests: XCTestCase {

	var sut = ProofManager()

	override func setUp() {

		super.setUp()
		sut = ProofManager()
	}

	/// test the set birthdate with a date
	func testSetBirthdateWithDate() {

		// Given
		let date = Date()

		// When
		sut.setBirthDate(date)

		// Then
		XCTAssertEqual(date, sut.getBirthDate(), "Dates should match")
		XCTAssertNotNil(sut.getBirthDateChecksum(), "Checksum should not be nil")
	}

	/// test the set birthdate with a  date
	func testSetBirthdateWithoutDate() {

		// Given

		// When
		sut.setBirthDate(nil)

		// Then
		XCTAssertNil(sut.getBirthDate(), "Birthdate should be nil")
		XCTAssertNil(sut.getBirthDateChecksum(), "Checksum should be nil")
	}

	/// test the set birthdate with a date
	func testSetBirthdateWithMarch2nd() {

		// Given
		let date = Date(timeIntervalSince1970: 1614671701)

		// When
		sut.setBirthDate(date)

		// Then
		XCTAssertEqual(date, sut.getBirthDate(), "Dates should match")
		XCTAssertNotNil(sut.getBirthDateChecksum(), "Checksum should not be nil")
		XCTAssertEqual(sut.getBirthDateChecksum(), 61, "Checksum should match")
		// Timestamp is march 2nd, 2021. That is the (31 + 28 + 2) = 61st day of the year.
		// 61 mod 65 = 61.
	}

	/// test the set birthdate with a date
	func testSetBirthdateWithMarch10nd() {

		// Given
		let date = Date(timeIntervalSince1970: 1615362901)

		// When
		sut.setBirthDate(date)

		// Then
		XCTAssertEqual(date, sut.getBirthDate(), "Dates should match")
		XCTAssertNotNil(sut.getBirthDateChecksum(), "Checksum should not be nil")
		XCTAssertEqual(sut.getBirthDateChecksum(), 4, "Checksum should match")
		// Timestamp is march 7nd, 2021. That is the (31 + 28 + 10) = 69st day of the year.
		// 69 mod 65 = 1.
	}
}
