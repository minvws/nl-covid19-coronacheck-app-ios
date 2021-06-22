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
		let publicKeys = IssuerPublicKeys(clKeys: [])
		let data = Data()
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success((publicKeys, data)), ())

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
		expect(self.cryptoSpy.invokedSetIssuerDomesticPublicKeys).toEventually(beTrue())
	}

	/// Test the fetch issuers public keys with no response
	func test_fetchIssuerPublicKeys_noResponse() {

		// Given
		networkSpy.stubbedGetPublicKeysCompletionResult = nil

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
		expect(self.cryptoSpy.invokedSetIssuerDomesticPublicKeys).toEventually(beFalse())
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
		expect(self.cryptoSpy.invokedSetIssuerDomesticPublicKeys).toEventually(beFalse())
	}

	/// Test the fetch issuers public keys with invalid keys error
	func test_fetchIssuerPublicKeys_withInvalidKeysError() {

		// Given
		let publicKeys = IssuerPublicKeys(clKeys: [])
		let data = Data()
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success((publicKeys, data)), ())
		// Trigger invalid keys
		cryptoSpy.stubbedSetIssuerDomesticPublicKeysResult = false

		// When
		sut.fetchIssuerPublicKeys(onCompletion: nil, onError: nil)

		// Then
		expect(self.networkSpy.invokedGetPublicKeys).toEventually(beTrue())
		expect(self.cryptoSpy.invokedSetIssuerDomesticPublicKeys).toEventually(beTrue())
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
		expect(self.cryptoSpy.invokedSetIssuerDomesticPublicKeys).toEventually(beFalse())
	}

	func test_fetchTestProviders() {

		// Given
		networkSpy.stubbedFetchTestProvidersCompletionResult = (
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

	func test_migrateExistingProof_noProof() {

		// Given
		let walletSpy = WalletManagerSpy(dataStoreManager: DataStoreManager(.inMemory))
		sut.walletManager = walletSpy
		sut.proofData.signedWrapper = nil
		sut.proofData.testWrapper = nil

		// When
		sut.migrateExistingProof()

		// Then
		expect(walletSpy.invokedStoreEventGroup).toEventually(beFalse())
		expect(self.cryptoSpy.invokedMigrateExistingCredential).toEventually(beFalse())
	}

	func test_migrateExistingProof() {

		// Given
		let walletSpy = WalletManagerSpy(dataStoreManager: DataStoreManager(.inMemory))
		sut.walletManager = walletSpy
		sut.proofData.signedWrapper = SignedResponse(payload: "test", signature: "test")
		sut.proofData.testWrapper = TestResultWrapper(
			providerIdentifier: "CC",
			protocolVersion: "2.0",
			result: TestResult(
				unique: "1234",
				sampleDate: "2021-06-21T16:33:26Z",
				testType: "pcr",
				negativeResult: true,
				holder: TestHolderIdentity(
					firstNameInitial: "R",
					lastNameInitial: "P",
					birthDay: "27",
					birthMonth: "5"
				)
			),
			status: .complete
		)

		// When
		sut.migrateExistingProof()

		// Then
		expect(walletSpy.invokedStoreEventGroup).toEventually(beTrue())
		expect(self.sut.getTestWrapper()).toEventually(beNil())
		expect(self.sut.getSignedWrapper()).toEventually(beNil())
		expect(self.cryptoSpy.invokedMigrateExistingCredential).toEventually(beTrue())
	}
}
