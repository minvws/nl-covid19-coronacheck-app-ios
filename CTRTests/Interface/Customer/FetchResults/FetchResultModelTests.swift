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

	// MARK: Test lifecycle
	override func setUp() {

		coordinatorSpy = HolderCoordinatorSpy()
		openIdSpy = OpenClientSpy()
		sut = FetchResultViewModel(
			coordinator: coordinatorSpy,
			openIdClient: openIdSpy,
			userIdentifier: nil)

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

		func getTestResults(identifier: String, completionHandler: @escaping (TestProofs?) -> Void) {

			getTestResultsCalled = true
			getTestResultsIdentifier = identifier
		}

		func fetchTestResultsWithISM(dictionary: [String: AnyObject], completionHandler: @escaping (TestProofs?) -> Void) {

			getTestResultsWithISMCalled = true
		}
	}

	// MARK: Tests

	/// Test the secondary button tapped, api returns no nonce
	func testSecondaryButtonTappedNoNonce() {

		// Given
		let apiSpy = ApiSpy()
		apiSpy.shouldReturnNonce = false
		sut?.apiClient = apiSpy

		// When
		sut?.secondaryButtonTapped(UIViewController())

		// Then
		XCTAssertTrue(apiSpy.getNonceCalled, "Method should be called")
		XCTAssertFalse(openIdSpy.requestAccessTokenCalled, "Access token should not be requested without nonce")
	}

//	/// Test the secondary button tapped, api returns with nonce
//	func testSecondaryButtonTappedWithNonce() {
//
//		// Given
//		let apiSpy = ApiSpy()
//		apiSpy.shouldReturnNonce = false
//		apiSpy.nonceEnvelope = NonceEnvelope(nonce: "test", stoken: "test")
//		sut?.apiClient = apiSpy
//
//		// When
//		sut?.secondaryButtonTapped(UIViewController())
//
//		// Then
//		XCTAssertTrue(apiSpy.getNonceCalled, "Method should be called")
//		XCTAssertTrue(openIdSpy.requestAccessTokenCalled, "Access token should be requested")
//	}
}
