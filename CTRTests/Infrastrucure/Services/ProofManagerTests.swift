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
	var cryptoSpy = CryptoManagerSpy()

	override func setUp() {

		super.setUp()
		sut = ProofManager()
		cryptoSpy = CryptoManagerSpy()
		sut.cryptoManager = cryptoSpy
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

	/// Test the fetch issuers public keys
	func testFetchIssuerPublicKeys() {

		// Given
		let networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut.networkManager = networkSpy
		networkSpy.shouldReturnPublicKeys = true

		// When
		sut.fetchIssuerPublicKeys(ttl: 10) {
			// Then
			XCTAssertTrue(self.cryptoSpy.setIssuerPublicKeysCalled, "Method should be called")
		} onError: { _ in
			XCTFail("There should be no error")
		}
	}

	/// Test the fetch issuers public keys with no repsonse
	func testFetchIssuerPublicKeysNoResonse() {

		// Given
		let networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut.networkManager = networkSpy
		networkSpy.shouldReturnPublicKeys = false

		// When
		sut.fetchIssuerPublicKeys(ttl: 10) {
			// Then
			XCTAssertFalse(self.cryptoSpy.setIssuerPublicKeysCalled, "Method should be called")
		} onError: { _ in
			XCTFail("There should be no error")
		}
	}

	/// Test the fetch issuers public keys with an network error
	func testFetchIssuerPublicKeysWithError() {

		// Given
		let networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut.networkManager = networkSpy
		networkSpy.shouldReturnPublicKeys = false
		networkSpy.publicKeyError = NetworkError.invalidRequest
		sut.keysFetchedTimestamp = nil

		// When
		sut.fetchIssuerPublicKeys(ttl: 10) {
			// Then
			XCTFail("There should be no success")
		} onError: { _ in

			XCTAssertFalse(self.cryptoSpy.setIssuerPublicKeysCalled, "Method should be called")
		}
	}

	/// Test the fetch issuers public keys with an network error
	func testFetchIssuerPublicKeysWithErrorWithinTTL() {

		// Given
		let networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut.networkManager = networkSpy
		networkSpy.shouldReturnPublicKeys = false
		networkSpy.publicKeyError = NetworkError.invalidRequest
		sut.keysFetchedTimestamp = Date()

		// When
		sut.fetchIssuerPublicKeys(ttl: 10) {
			// Then
			XCTAssertFalse(self.cryptoSpy.setIssuerPublicKeysCalled, "Method should be called")
		} onError: { _ in
			XCTFail("There should be no error")
		}
	}
}
