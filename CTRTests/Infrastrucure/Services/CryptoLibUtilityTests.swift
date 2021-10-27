/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class CryptoLibUtilityTests: XCTestCase {

	private var sut: CryptoLibUtility!
	private var networkSpy: NetworkSpy!

	override func setUp() {

		super.setUp()
		networkSpy = NetworkSpy(configuration: .development)
		Services.use(networkSpy)
		sut = CryptoLibUtility()
	}

	/// Test the fetch issuers public keys
	func test_fetchIssuerPublicKeys() {

		// Given
		let data = Data()
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(data), ())

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
	}

	/// Test the fetch issuers public keys with no response
	func test_fetchIssuerPublicKeys_noResponse() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = nil

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
	}

	/// Test the fetch issuers public keys with an network error
	func test_fetchIssuerPublicKeys_withErrorResponse() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .cannotSerialize)), ())

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
	}

	/// Test the fetch issuers public keys with invalid keys error
	func test_fetchIssuerPublicKeys_withInvalidKeysError() {

		// Given
		let data = Data()
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(data), ())

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
	}
}
