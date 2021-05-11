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
	private var cryptoSpy: CryptoManagerSpy!
	private var networkSpy: NetworkSpy!

	override func setUp() {

		super.setUp()
		sut = ProofManager()
		cryptoSpy = CryptoManagerSpy()
		sut.cryptoManager = cryptoSpy
		networkSpy = NetworkSpy(configuration: .test, validator: CryptoUtilitySpy())
		sut.networkManager = networkSpy
	}

	/// Test the fetch issuers public keys
	func test_fetchIssuerPublicKeys() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success([]), ())

		// When
		sut.fetchIssuerPublicKeys {

			// Then
			expect(self.networkSpy.invokedGetPublicKeys) == true
			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == true
		} onError: { _ in
			fail("There should be no error")
		}
	}

	/// Test the fetch issuers public keys with no response
	func test_fetchIssuerPublicKeys_noResponse() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = nil

		// When
		sut.fetchIssuerPublicKeys {

			// Then
			expect(self.networkSpy.invokedGetPublicKeys) == true
			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == false
		} onError: { _ in
			fail("There should be no error")
		}
	}

	/// Test the fetch issuers public keys with an network error
	func test_fetchIssuerPublicKeys_withErrorResponse() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = (.failure(NetworkError.invalidRequest),(()))

		sut.keysFetchedTimestamp = nil

		// When
		sut.fetchIssuerPublicKeys {
			// Then
			fail("There should be no success")
		} onError: { _ in
			expect(self.networkSpy.invokedGetPublicKeys) == true
			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == false
		}
	}

	/// Test the fetch issuers public keys with invalid keys error
	func test_fetchIssuerPublicKeys_withInvalidKeysError() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success([]), ())
		// Trigger invalid keys
		cryptoSpy.issuerPublicKeysAreValid = false

		// When
		sut.fetchIssuerPublicKeys {

			// Then
			fail("There should be no success")
		} onError: { _ in

			expect(self.networkSpy.invokedGetPublicKeys) == true
			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == true
		}
	}

	/// Test the fetch issuers public keys with an network error
	func test_fetchIssuerPublicKeys_withError_withinTTL() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = (.failure(NetworkError.invalidRequest),(()))
		sut.keysFetchedTimestamp = Date()

		// When
		sut.fetchIssuerPublicKeys {

			// Then
			expect(self.networkSpy.invokedGetPublicKeys) == true
			expect(self.cryptoSpy.setIssuerPublicKeysCalled) == false
		} onError: { _ in
			fail("There should be no error")
		}
	}

	func test_fetchTestProviders() {

		// Given
		networkSpy.stubbedGetTestProvidersCompletionResult = (
			.success(
				[
					TestProvider(
						identifier: "test_fetchTestProviders",
						name: "test",
						resultURL: URL(string: "https://coronacheck.nl"),
						publicKey: "key",
						certificate: "certificate")
				]
			), ()
		)

		waitUntil(timeout: .seconds(10)) {done in
			// When
			self.sut.fetchCoronaTestProviders {
				// Then
				expect(self.networkSpy.invokedGetTestProviders) == true
				expect(self.sut.testProviders).to(haveCount(1))
				expect(self.sut.testProviders.first?.identifier) == "test_fetchTestProviders"
				done()
			} onError: { _ in
				fail("call should not error")
			}
		}
	}

	func test_fetchTestProviders_withError() {

		// Given
		networkSpy.stubbedGetTestProvidersCompletionResult = (.failure(NetworkError.invalidRequest),(()))

		waitUntil(timeout: .seconds(10)) {done in
			// When
			self.sut.fetchCoronaTestProviders {
				// Then
				fail("call should not success")

			} onError: { _ in
				expect(self.networkSpy.invokedGetTestProviders) == true
				expect(self.sut.testProviders).to(beEmpty())
				done()
			}
		}
	}
}
