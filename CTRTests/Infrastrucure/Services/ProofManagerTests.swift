/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class ProofManagerTests: XCTestCase {

	var sut: ProofManager!
	var cryptoSpy: CryptoManagerSpy!

	override func setUp() {

		super.setUp()
		sut = ProofManager()
		cryptoSpy = CryptoManagerSpy()
		sut.cryptoManager = cryptoSpy
	}

	/// Test the fetch issuers public keys
	func testFetchIssuerPublicKeys() {

		// Given
		let networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut.networkManager = networkSpy
		networkSpy.shouldReturnPublicKeys = true

		// When
		sut.fetchIssuerPublicKeys {
			// Then
			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == true
		} onError: { _ in
			fail("There should be no error")
		}
	}

	/// Test the fetch issuers public keys with no response
	func testFetchIssuerPublicKeysNoResponse() {

		// Given
		let networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut.networkManager = networkSpy
		networkSpy.shouldReturnPublicKeys = false

		// When
		sut.fetchIssuerPublicKeys {
			// Then
			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == false
		} onError: { _ in
			fail("There should be no error")
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
		sut.fetchIssuerPublicKeys {
			// Then
			fail("There should be no success")
		} onError: { _ in
			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == false
		}
	}

	/// Test the fetch issuers public keys with invalid keys error
	func testFetchIssuerPublicKeysWithInvalidKeysError() {

		// Given
		let networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut.networkManager = networkSpy
		networkSpy.shouldReturnPublicKeys = true
		// Trigger invalid keys
		cryptoSpy.issuerPublicKeysAreValid = false

		// When
		sut.fetchIssuerPublicKeys {
			// Then
			fail("There should be no success")
		} onError: { _ in

			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == true
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
		sut.fetchIssuerPublicKeys {
			// Then
			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == false
		} onError: { _ in
			fail("There should be no error")
		}
	}

	func test_fetchTestProviders() {

		// Given

		// When

		// Then

	}
}
