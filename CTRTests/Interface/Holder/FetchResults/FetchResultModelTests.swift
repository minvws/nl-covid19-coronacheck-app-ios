/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class FetchResultModelTests: XCTestCase {

//	// MARK: Subject under test
//	var sut: FetchResultViewModel?
//
//	/// Spies
//	var coordinatorSpy = HolderCoordinatorSpy()
//	var openIdSpy = OpenClientSpy()
//	var networkManagerSpy = NetworkSpy(configuration: .test)
//	var cryptoSpy = CryptoManagerSpy()
//
//	// MARK: Test lifecycle
//	override func setUp() {
//
//		coordinatorSpy = HolderCoordinatorSpy()
//		openIdSpy = OpenClientSpy()
//		sut = FetchResultViewModel(
//			coordinator: coordinatorSpy,
//			openIdClient: openIdSpy,
//			userIdentifier: nil)
//		networkManagerSpy = NetworkSpy(configuration: .test)
//		sut?.networkManager = networkManagerSpy
//		cryptoSpy = CryptoManagerSpy()
//		sut?.cryptoManager = cryptoSpy
//
//		super.setUp()
//	}
//
//	// MARK: Test Doubles
//
//	class HolderCoordinatorSpy: HolderCoordinatorDelegate {
//		func navigateToChooseProvider() {
//			// Nothing yet
//		}
//
//		func navigateToListResults() {
//			// Nothing yet
//		}
//
//		func navigateToCreateProof() {
//			// Nothing yet
//		}
//
//		func navigateBackToStart() {
//			// Nothing yet
//		}
//
//		var navigateToAppointmentCalled = false
//		var navigateToFetchResultsCalled = false
//		var navigateToHolderQRCalled = false
//		var navigateToStartCalled = false
//		var dismissCalled = false
//
//		var dopenMenuItemCalled = false
//		var closeMenuCalled = false
//
//		func navigateToAppointment() {
//			navigateToAppointmentCalled = true
//		}
//
//		func navigateToFetchResults() {
//			navigateToFetchResultsCalled = true
//		}
//
//		func navigateToHolderQR() {
//			navigateToHolderQRCalled = true
//		}
//
//		func navigateToStart() {
//
//			navigateToStartCalled = true
//		}
//
//		func dismiss() {
//
//			dismissCalled = true
//		}
//
//		func openMenuItem(_ identifier: MenuIdentifier) {
//
//			dopenMenuItemCalled = true
//		}
//
//		func closeMenu() {
//
//			closeMenuCalled = true
//		}
//	}
//
//	class OpenClientSpy: OpenIdClientProtocol {
//
//		var token: String?
//		var shouldError: Bool = false
//		var requestAccessTokenCalled = false
//
//		func requestAccessToken(
//			presenter: UIViewController,
//			onCompletion: @escaping (String?) -> Void,
//			onError: @escaping (Error?) -> Void) {
//
//			requestAccessTokenCalled = true
//
//			if shouldError {
//				onError(NSError(domain: "TEST DOMAIN", code: 1000, userInfo: nil))
//			} else {
//				onCompletion(token)
//			}
//		}
//	}
//
//	// MARK: Tests
//
//	/// Test the primary button tapped, api returns no nonce
//	func testPrimaryButtonTappedNoNonce() {
//
//		// Given
//		networkManagerSpy.shouldReturnNonce = false
//
//		// When
//		sut?.primaryButtonTapped(UIViewController())
//
//		// Then
//		XCTAssertTrue(networkManagerSpy.getNonceCalled, "Method should be called")
//		XCTAssertFalse(openIdSpy.requestAccessTokenCalled, "Access token should not be requested without nonce")
//	}
//
//	/// Test the primary button tapped, api returns with nonce
//	func testPrimaryButtonTappedWithNonce() {
//
//		// Given
//		networkManagerSpy.shouldReturnNonce = true
//		networkManagerSpy.nonceEnvelope = NonceEnvelope(nonce: "test", stoken: "test")
//
//		// When
//		sut?.primaryButtonTapped(UIViewController())
//
//		// Then
//		XCTAssertTrue(networkManagerSpy.getNonceCalled, "Method should be called")
//		XCTAssertTrue(cryptoSpy.setNonceCalled, "Method should be called")
//		XCTAssertTrue(cryptoSpy.setStokenCalled, "Method should be called")
//		XCTAssertTrue(openIdSpy.requestAccessTokenCalled, "Access token should be requested")
//	}
}
