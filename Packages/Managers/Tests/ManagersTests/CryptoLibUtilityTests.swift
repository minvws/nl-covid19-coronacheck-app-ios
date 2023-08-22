/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import TestingShared
import Reachability
@testable import Managers
@testable import Transport
@testable import Shared
@testable import Persistence

class CryptoLibUtilityTests: XCTestCase {
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (CryptoLibUtility, NetworkSpy, UserSettingsSpy, ReachabilitySpy, RemoteConfigManagingSpy) {

		let networkSpy = NetworkSpy()
		let userSettingsSpy = UserSettingsSpy()
		let reachabilitySpy = ReachabilitySpy()
		let fileStorageSpy = FileStorageSpy()
		let remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		remoteConfigManagerSpy.stubbedStoredConfiguration.configTTL = 3600
		remoteConfigManagerSpy.stubbedStoredConfiguration.configMinimumIntervalSeconds = 60
		
		let sut = CryptoLibUtility(
			now: { now },
			userSettings: userSettingsSpy,
			networkManager: networkSpy,
			remoteConfigManager: remoteConfigManagerSpy,
			reachability: reachabilitySpy,
			fileStorage: fileStorageSpy
		)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, networkSpy, userSettingsSpy, reachabilitySpy, remoteConfigManagerSpy)
	}

	/// Test the crypto lib utility  update call no result from the api
	func test_cryptoLibUtilityUpdate_errorFromApi() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			let (sut, networkSpy, _, _, _) = self.makeSUT()
			networkSpy.stubbedGetPublicKeysCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .invalidRequest)), ())

			// When
			sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
				//
			}, completion: { state in

				// Then
				expect(networkSpy.invokedGetPublicKeys) == true
				expect(state.isFailure) == true
				done()
			})
		}
	}

	/// Test the rcrypto lib utility  update call with succss
	func test_cryptoLibUtilityUpdate_success() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			let (sut, networkSpy, _, _, _) = self.makeSUT()
			networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())
			// When
			sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
				//
			}, completion: { state in

				// Then
				expect(networkSpy.invokedGetPublicKeys) == true
				expect(state.isSuccess) == true
				done()
			})
		}
	}

	func test_update_withinTTL_callsbackImmediately() {

		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, remoteConfigManagerSpy) = makeSUT()
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
		expect(networkSpy.invokedGetPublicKeys) == true
		expect(sut.isLoading) == false
	}

	func test_update_notWithinTTL_doesNotCallbackImmediately() {
	
		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _) = makeSUT()
		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())
		var didNotHitCallback = true

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(networkSpy.invokedGetPublicKeys) == true
		expect(sut.isLoading) == false
	}

	func test_update_neverFetchedBefore_doesNotCallbackImmediately() {
		
		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _) = makeSUT()
		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = nil
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())
		var didNotHitCallback = true

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(networkSpy.invokedGetPublicKeys) == true
		expect(sut.isLoading) == false
	}

	func test_update_withinTTL_butOutsideMinimumRefreshInterval_doesRefresh() {

		let (sut, networkSpy, userSettingsSpy, _, _) = makeSUT()
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
		newConfig.recommendedVersion = "2.0.0"

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
		expect(receivedResult).to(beSuccess())

		expect(sut.isLoading) == false
	}

	func test_update_withinTTL_withinMinimumRefreshInterval_doesNotRefresh() {

		let (sut, networkSpy, userSettingsSpy, _, _) = makeSUT()
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
		newConfig.recommendedVersion = "2.0.0"

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
		
		expect(receivedResult).to(beSuccess())
		expect(sut.isLoading) == false
	}

	func test_doesNotLoadWhenAlreadyLoading() {
		
		// Arrange
		let (sut, networkSpy, _, _, _) = makeSUT()
		
		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

		// Assert
		expect(networkSpy.invokedGetPublicKeysCount) == 1
	}

	func test_networkFailure_callsback_networkFailure() {

		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _) = makeSUT()
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
		expect(sut.isLoading) == false
	}

	func test_update_updatesConfigFetchedTimestamp() {

		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _) = makeSUT()
		userSettingsSpy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

		// Assert
		expect(userSettingsSpy.invokedIssuerKeysFetchedTimestamp) == now.timeIntervalSince1970
		expect(sut.isLoading) == false
	}

	func test_reachability() {

		// Arrange
		let (sut, networkSpy, _, reachabilitySpy, _) = makeSUT()
		expect(networkSpy.invokedGetPublicKeysCount) == 0
		sut.registerTriggers()

		// Act
		reachabilitySpy.invokedWhenReachable?(try! Reachability()) // swiftlint:disable:this force_try

		// Assert
		expect(networkSpy.invokedGetPublicKeysCount) == 1
	}
}
