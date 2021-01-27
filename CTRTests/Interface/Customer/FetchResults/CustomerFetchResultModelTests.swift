/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class CustomerFetchResultModelTests: XCTestCase {

	// MARK: Subject under test
	var sut: FetchResultViewModel?

	/// Spies
	var coordinatorSpy = CustomerCoordinatorSpy()
	var openIdSpy = OpenClientSpy()

	// MARK: Test lifecycle
	override func setUp() {

		coordinatorSpy = CustomerCoordinatorSpy()
		openIdSpy = OpenClientSpy()
		sut = FetchResultViewModel(
			coordinator: coordinatorSpy,
			openIdClient: openIdSpy,
			userIdentifier: nil)

		super.setUp()
	}

	// MARK: Test Doubles

	class CustomerCoordinatorSpy: CustomerCoordinatorDelegate {

		var navigateToFetchResultsCalled = false
		var navigateToVisitEventCalled = false
		var navigateToCustomerQRCalled = false
		var navigateToStartCalled = false
		var setTestResultEnvelopeCalled = false
		var setEventCalled = false
		var dismissCalled = false

		func navigateToFetchResults() {
			navigateToFetchResultsCalled = true
		}

		func navigateToVisitEvent() {
			navigateToVisitEventCalled = true
		}

		func navigateToCustomerQR() {
			navigateToCustomerQRCalled = true
		}

		func navigateToStart() {

			navigateToStartCalled = true
		}

		func setTestResultEnvelope(_ result: TestResultEnvelope?) {

			setTestResultEnvelopeCalled = true
		}

		func setEvent(_ event: EventEnvelope) {

			setEventCalled = true
		}

		func dismiss() {

			dismissCalled = true
		}
	}

	class OpenClientSpy: OpenIdClientProtocol {

		var token: String?
		var shouldError: Bool = false
		var requestAccessTokenCalled = false

		func requestAccessToken(presenter: UIViewController, onCompletion: @escaping (String?) -> Void, onError: @escaping (Error?) -> Void) {

			requestAccessTokenCalled = true

			if shouldError {
				onError(NSError(domain: "TEST DOMAIN", code: 1000, userInfo: nil))
			} else {
				onCompletion(token)
			}
		}
	}

	class ApiSpy: ApiClientProtocol {

		var getAgentEnvelopeCalled = false
		var getEventCalled = false
		var getPublicKeysCalled = false
		var getTestResultsCalled = false
		var postAuthorizationTokenCalled = false
		var postAuthorizationTokenToken: String?

		func getAgentEnvelope(identifier: String, completionHandler: @escaping (AgentEnvelope?) -> Void) {

			getAgentEnvelopeCalled = true
		}

		func getEvent(identifier: String, completionHandler: @escaping (EventEnvelope?) -> Void) {

			getEventCalled = true
		}

		func getPublicKeys(completionHandler: @escaping ([Issuer]) -> Void) {

			getPublicKeysCalled = true
		}

		func getTestResults(identifier: String, completionHandler: @escaping (TestResultEnvelope?) -> Void) {

			getTestResultsCalled = true
		}

		func postAuthorizationToken(_ token: String, completionHandler: @escaping (Bool) -> Void) {

			postAuthorizationTokenCalled = true
			postAuthorizationTokenToken = token
		}
	}

	// MARK: Tests

	/// Test the secondary button tapped, open id returns no token
	func testSecondaryButtonTappedNoToken() {

		// Given
		let apiSpy = ApiSpy()
		sut?.apiClient = apiSpy

		// When
		sut?.secondaryButtonTapped(UIViewController())

		// Then
		XCTAssertTrue(openIdSpy.requestAccessTokenCalled, "Method should be called")
		XCTAssertFalse(apiSpy.postAuthorizationTokenCalled, "Methos should NOT be called when there is no token")
	}

	/// Test the secondary button tapped, open id returns a token
	func testSecondaryButtonTappedWithToken() {

		// Given
		let apiSpy = ApiSpy()
		sut?.apiClient = apiSpy
		openIdSpy.token = "testSecondaryButtonTappedWithToken"

		// When
		sut?.secondaryButtonTapped(UIViewController())

		// Then
		XCTAssertTrue(openIdSpy.requestAccessTokenCalled, "Method should be called")
		XCTAssertTrue(apiSpy.postAuthorizationTokenCalled, "Methos should be called")
		XCTAssertEqual(apiSpy.postAuthorizationTokenToken, openIdSpy.token, "Token must match")
	}

	/// Test the secondary button tapped, open id returns an error
	func testSecondaryButtonTappedWithError() {

		// Given
		let apiSpy = ApiSpy()
		sut?.apiClient = apiSpy
		openIdSpy.shouldError = true

		// When
		sut?.secondaryButtonTapped(UIViewController())

		// Then
		XCTAssertTrue(openIdSpy.requestAccessTokenCalled, "Method should be called")
		XCTAssertFalse(apiSpy.postAuthorizationTokenCalled, "Methos should NOT be called when there is an error")
	}
}
