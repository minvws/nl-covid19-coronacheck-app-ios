/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble
import Reachability

class CryptoLibUtilityTests: XCTestCase {

	private var sut: CryptoLibUtility!
	private var networkSpy: NetworkSpy!
	private var userSettingsSpy: UserSettingsSpy!
	private var reachabilitySpy: ReachabilitySpy!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!

	override func setUp() {

		super.setUp()
		networkSpy = NetworkSpy()
		userSettingsSpy = UserSettingsSpy()
		reachabilitySpy = ReachabilitySpy()
		remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		remoteConfigManagerSpy.stubbedStoredConfiguration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration.configMinimumIntervalSeconds = 60
		
		sut = CryptoLibUtility(
			now: { now },
			userSettings: userSettingsSpy,
			networkManager: networkSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			reachability: reachabilitySpy
		)
	}

	/// Test the crypto lib utility  update call no result from the api
	func test_cryptoLibUtilityUpdate_errorFromApi() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			self.networkSpy.stubbedGetPublicKeysCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .invalidRequest)), ())

			// When
			self.sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
				//
			}, completion: { state in

				// Then
				expect(self.networkSpy.invokedGetPublicKeys) == true
				expect(state.isFailure) == true
				done()
			})
		}
	}

	/// Test the rcrypto lib utility  update call with succss
	func test_cryptoLibUtilityUpdate_success() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			self.networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())
			// When
			self.sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
				//
			}, completion: { state in

				// Then
				expect(self.networkSpy.invokedGetPublicKeys) == true
				expect(state.isSuccess) == true
				done()
			})
		}
	}

	func test_update_withinTTL_callsbackImmediately() {

		// Arrange
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		remoteConfigManagerSpy.stubbedStoredConfiguration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration.configMinimumIntervalSeconds = 60

		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(10 * minutes * ago).timeIntervalSince1970
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())
		var hitCallback = false

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			hitCallback = true
		}, completion: { _ in
			// should be true by the time this completion is called:
			expect(hitCallback).toEventually(beTrue())
		})

		// Assert
		expect(hitCallback).toEventually(beTrue())
		expect(self.networkSpy.invokedGetPublicKeys) == true
		expect(self.sut.isLoading) == false
	}

	func test_update_notWithinTTL_doesNotCallbackImmediately() {
		// Arrange
		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())
		var didNotHitCallback = true

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(self.networkSpy.invokedGetPublicKeys) == true
		expect(self.sut.isLoading) == false
	}

	func test_update_neverFetchedBefore_doesNotCallbackImmediately() {
		// Arrange
		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = nil
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())
		var didNotHitCallback = true

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(self.networkSpy.invokedGetPublicKeys) == true
		expect(self.sut.isLoading) == false
	}

	func test_update_withinTTL_butOutsideMinimumRefreshInterval_doesRefresh() {

		// Load a new configuration into RemoteConfigurationManager to start with
		// (currently not an easy way to change it from using .default)
		var config = RemoteConfiguration.default
		config.configMinimumIntervalSeconds = 60
		config.configTTL = 3600

		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())

		var completedFirstLoad = false
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			if case .success(true) = result {
				completedFirstLoad = true
			}
		})
		expect(completedFirstLoad).toEventually(beTrue())

		// Setup the real test:
		// within TTL but outside minimum interval
		var newConfig = RemoteConfiguration.default
		newConfig.minimumVersionMessage = "This was changed"

		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(100 * seconds * ago).timeIntervalSince1970
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())

		// Act
		var receivedResult: Result<Bool, ServerError>?
		var didCallTTLCallback: Bool = false
		sut.update(
			isAppLaunching: false,
			immediateCallbackIfWithinTTL: { didCallTTLCallback = true },
			completion: { result in
				receivedResult = result
			})

		// Assert
		expect(didCallTTLCallback) == true
		switch receivedResult {
			case .success: break
			default:
				assertionFailure("Didn't receive expected result")
		}

		expect(self.sut.isLoading) == false
	}

	func test_update_withinTTL_withinMinimumRefreshInterval_doesNotRefresh() {

		// Load a new configuration into RemoteConfigurationManager to start with
		// (currently not an easy way to change it from using .default)
		var firstConfig = RemoteConfiguration.default
		firstConfig.configMinimumIntervalSeconds = 60
		firstConfig.configTTL = 3600

		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())

		var completedFirstLoad = false
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			if case .success(true) = result {
				completedFirstLoad = true
			}
		})
		expect(completedFirstLoad).toEventually(beTrue())

		// Setup the real test:
		// within TTL but outside minimum interval
		var newConfig = RemoteConfiguration.default
		newConfig.minimumVersionMessage = "This was changed"

		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(5 * seconds * ago).timeIntervalSince1970
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())

		// Act
		var receivedResult: Result<Bool, ServerError>?
		var didCallTTLCallback: Bool = false
		sut.update(
			isAppLaunching: false,
			immediateCallbackIfWithinTTL: { didCallTTLCallback = true },
			completion: { result in
				receivedResult = result
			})

		// Assert
		expect(didCallTTLCallback) == true

		switch receivedResult {
			case .success: break
			default:
				assertionFailure("Didn't receive expected result")
		}
		expect(self.sut.isLoading) == false
	}

	func test_doesNotLoadWhenAlreadyLoading() {
		// Arrange

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

		// Assert
		expect(self.networkSpy.invokedGetPublicKeysCount) == 1
	}

	func test_networkFailure_callsback_networkFailure() {

		// Arrange
		let serverError = ServerError.error(statusCode: 500, response: nil, error: .invalidResponse)
		let result: Result<Data, ServerError> = .failure(serverError)

		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = nil
		networkSpy.stubbedGetPublicKeysCompletionResult = (result, ())

		// Act
		var receivedResult: Result<Bool, ServerError>?

		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			receivedResult = result
		})

		// Assert
		switch receivedResult {
			case .failure(let error) where serverError == error: break
			default:
				assertionFailure("results didn't match")
		}
		expect(self.sut.isLoading) == false
	}

	func test_update_updatesConfigFetchedTimestamp() {
		// Arrange
		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

		// Assert
		expect(self.userSettingsSpy.invokedIssuerKeysFetchedTimestamp) == now.timeIntervalSince1970
		expect(self.sut.isLoading) == false
	}

	func test_reachability() {

		// Arrange
		expect(self.networkSpy.invokedGetPublicKeysCount) == 0
		sut.registerTriggers()
		
		// Act
		reachabilitySpy.invokedWhenReachable?(try! Reachability()) // swiftlint:disable:this force_try

		// Assert
		expect(self.networkSpy.invokedGetPublicKeysCount) == 1
	}
}
