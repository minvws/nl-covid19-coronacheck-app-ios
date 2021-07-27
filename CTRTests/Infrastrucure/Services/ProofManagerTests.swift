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

	private var sut: ProofManager!
	private var networkSpy: NetworkSpy!

	override func setUp() {

		super.setUp()
		sut = ProofManager()
		networkSpy = NetworkSpy(configuration: .test)
		sut.networkManager = networkSpy
	}

	/// Test the fetch issuers public keys
	func test_fetchIssuerPublicKeys() {

		// Given
		let data = Data()
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(data), ())

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
	}

	/// Test the fetch issuers public keys with no response
	func test_fetchIssuerPublicKeys_noResponse() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = nil

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
	}

	/// Test the fetch issuers public keys with an network error
	func test_fetchIssuerPublicKeys_withErrorResponse() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = (.failure(NetworkError.invalidRequest), ())
		sut.keysFetchedTimestamp = nil

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
	}

	/// Test the fetch issuers public keys with invalid keys error
	func test_fetchIssuerPublicKeys_withInvalidKeysError() {

		// Given
		let data = Data()
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(data), ())

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
	}

	/// Test the fetch issuers public keys with an network error
	func test_fetchIssuerPublicKeys_withError_withinTTL() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = (.failure(NetworkError.invalidRequest), ())
		sut.keysFetchedTimestamp = Date()

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
	}

	func test_fetchTestProviders() {

		// Given
		networkSpy.stubbedFetchTestProvidersCompletionResult = (
			.success(
				[
					TestProvider(
						identifier: "test_fetchTestProviders",
						name: "test",
						resultURLString: "https://coronacheck.nl",
						publicKey: "key",
						certificate: "certificate")
				]
			), ()
		)

		// When
		sut.fetchCoronaTestProviders(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedFetchTestProviders).toEventually(beTrue())
		expect(self.sut.testProviders).toEventually(haveCount(1))
		expect(self.sut.testProviders.first?.identifier).toEventually(equal("test_fetchTestProviders"))
	}

	func test_fetchTestProviders_withError() {

		// Given
		networkSpy.stubbedFetchTestProvidersCompletionResult = (.failure(NetworkError.invalidRequest), ())

		// When
		sut.fetchCoronaTestProviders(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedFetchTestProviders).toEventually(beTrue())
		expect(self.sut.testProviders).toEventually(beEmpty())
	}
}
