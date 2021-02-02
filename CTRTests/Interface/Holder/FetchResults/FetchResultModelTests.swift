/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class FetchResultModelTests: XCTestCase {

	// MARK: Subject under test
	var sut: FetchResultViewModel?

	/// Spies
	var coordinatorSpy = HolderCoordinatorSpy()
	var openIdSpy = OpenClientSpy()
	var apiSpy = ApiSpy()
	var cryptoSpy = CryptoManagerSpy()

	// MARK: Test lifecycle
	override func setUp() {

		coordinatorSpy = HolderCoordinatorSpy()
		openIdSpy = OpenClientSpy()
		sut = FetchResultViewModel(
			coordinator: coordinatorSpy,
			openIdClient: openIdSpy,
			userIdentifier: nil)
		apiSpy = ApiSpy()
		sut?.apiClient = apiSpy
		cryptoSpy = CryptoManagerSpy()
		sut?.cryptoManager = cryptoSpy

		super.setUp()
	}

	// MARK: Test Doubles

	class HolderCoordinatorSpy: HolderCoordinatorDelegate {

		var navigateToFetchResultsCalled = false
		var navigateToHolderQRCalled = false
		var navigateToStartCalled = false
		var dismissCalled = false

		func navigateToFetchResults() {
			navigateToFetchResultsCalled = true
		}

		func navigateToHolderQR() {
			navigateToHolderQRCalled = true
		}

		func navigateToStart() {

			navigateToStartCalled = true
		}

		func dismiss() {

			dismissCalled = true
		}
	}

	class OpenClientSpy: OpenIdClientProtocol {

		var token: String?
		var shouldError: Bool = false
		var requestAccessTokenCalled = false

		func requestAccessToken(
			presenter: UIViewController,
			onCompletion: @escaping (String?) -> Void,
			onError: @escaping (Error?) -> Void) {

			requestAccessTokenCalled = true

			if shouldError {
				onError(NSError(domain: "TEST DOMAIN", code: 1000, userInfo: nil))
			} else {
				onCompletion(token)
			}
		}
	}

	class ApiSpy: ApiClientProtocol {

		var getNonceCalled = false
		var shouldReturnNonce = false
		var nonceEnvelope: NonceEnvelope?
		var getPublicKeysCalled = false
		var getTestResultsCalled = false
		var getTestResultsIdentifier: String?
		var getTestResultsWithISMCalled = false

		func getNonce(completionHandler: @escaping (NonceEnvelope?) -> Void) {

			getNonceCalled = true
			if shouldReturnNonce {
				completionHandler(nonceEnvelope)
			}
		}

		func getPublicKeys(completionHandler: @escaping ([Issuer]) -> Void) {

			getPublicKeysCalled = true
		}

		func getTestResults(identifier: String, completionHandler: @escaping (Data?) -> Void) {

			getTestResultsCalled = true
			getTestResultsIdentifier = identifier
		}

		func fetchTestResultsWithISM(dictionary: [String: AnyObject], completionHandler: @escaping (Data?) -> Void) {

			getTestResultsWithISMCalled = true
		}
	}

	class CryptoManagerSpy: CryptoManagerProtocol {

		var setNonceCalled = false
		var setStokenCalled = false
		var setProofsCalled = false
		var nonce: String?
		var stoken: String?
		var proofs: Data?

		required init() {
			 // Nothing for this spy class
		}

		func debug() {

		}

		func setNonce(_ nonce: String) {

			setNonceCalled = true
			self.nonce = nonce
		}

		func setStoken(_ stoken: String) {

			setStokenCalled = true
			self.stoken = stoken
		}

		func setProofs(_ proofs: Data?) {

			setProofsCalled = true
			self.proofs = proofs
		}

		func generateCommitmentMessage() -> String? {
			return nil
		}

		func generateQRmessage() -> String? {
			return nil
		}

		func getStoken() -> String? {
			return stoken
		}

		func verifyQRMessage(_ message: String) -> Bool {
			return false
		}
	}

	// MARK: Tests

	/// Test the secondary button tapped, api returns no nonce
	func testSecondaryButtonTappedNoNonce() {

		// Given
		apiSpy.shouldReturnNonce = false

		// When
		sut?.secondaryButtonTapped(UIViewController())

		// Then
		XCTAssertTrue(apiSpy.getNonceCalled, "Method should be called")
		XCTAssertFalse(openIdSpy.requestAccessTokenCalled, "Access token should not be requested without nonce")
	}

	/// Test the secondary button tapped, api returns with nonce
	func testSecondaryButtonTappedWithNonce() {

		// Given
		apiSpy.shouldReturnNonce = true
		apiSpy.nonceEnvelope = NonceEnvelope(nonce: "test", stoken: "test")

		// When
		sut?.secondaryButtonTapped(UIViewController())

		// Then
		XCTAssertTrue(apiSpy.getNonceCalled, "Method should be called")
		XCTAssertTrue(cryptoSpy.setNonceCalled, "Method should be called")
		XCTAssertTrue(cryptoSpy.setStokenCalled, "Method should be called")
		XCTAssertTrue(openIdSpy.requestAccessTokenCalled, "Access token should be requested")
	}
}
