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
@testable import Transport
@testable import Shared
@testable import Persistence
@testable import Managers

// swiftlint:disable type_body_length
class RemoteConfigManagerTests: XCTestCase {
	
	// MARK: - Setup
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (RemoteConfigManager, NetworkSpy, UserSettingsSpy, ReachabilitySpy, SecureUserSettingsSpy, AppVersionSupplierSpy) {
			
		let networkSpy = NetworkSpy()
		let userSettingsSpy = UserSettingsSpy()
		let reachabilitySpy = ReachabilitySpy()
		let secureUserSettingsSpy = SecureUserSettingsSpy()
		secureUserSettingsSpy.stubbedStoredConfiguration = .default
		let appVersionSupplierSpy = AppVersionSupplierSpy(version: "1", build: "1")
		let fileStorageSpy = FileStorageSpy()
		
		fileStorageSpy.stubbedReadResult = nil
		
		let sut = RemoteConfigManager(
			now: { now },
			userSettings: userSettingsSpy,
			reachability: reachabilitySpy,
			networkManager: networkSpy,
			secureUserSettings: secureUserSettingsSpy,
			fileStorage: fileStorageSpy,
			appVersionSupplier: appVersionSupplierSpy
		)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, networkSpy, userSettingsSpy, reachabilitySpy, secureUserSettingsSpy, appVersionSupplierSpy)
	}

	// MARK: - Tests

	/// Test the remote config manager update call no result from the api
	func test_remoteConfigManagerUpdate_errorFromApi() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			let (sut, networkSpy, _, _, _, _) = self.makeSUT()
			networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .invalidRequest)), ())

			// When
			sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
				//
			}, completion: { state in

				// Then
				expect(networkSpy.invokedGetRemoteConfiguration) == true
				expect(state.isFailure) == true
				done()
			})
		}
	}

	/// Test the remote config manager update call with succss
	func test_remoteConfigManagerUpdate_success() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			let (sut, networkSpy, _, _, _, _) = self.makeSUT()
			networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((RemoteConfiguration.default, RemoteConfiguration.default.data, URLResponse())), ())
			// When
			sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
				//
			}, completion: { state in

				// Then
				expect(networkSpy.invokedGetRemoteConfiguration) == true
				expect(state.isSuccess) == true
				done()
			})
		}
	}

	func test_update_withinTTL_callsbackImmediately() {
		
		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _, _) = makeSUT()
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(10 * minutes * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, RemoteConfiguration.default.data, URLResponse())), ())
		var hitCallback = false

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			hitCallback = true
		}, completion: { _ in
			// should be true by the time this completion is called:
			expect(hitCallback) == true
		})

		// Assert
		expect(hitCallback) == true
		expect(networkSpy.invokedGetRemoteConfiguration) == true
		expect(sut.storedConfiguration) == .default
		expect(sut.isLoading) == false
	}

	func test_update_notWithinTTL_doesNotCallbackImmediately() {
		
		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _, _) = makeSUT()
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, RemoteConfiguration.default.data, URLResponse())), ())
		var didNotHitCallback = true

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(networkSpy.invokedGetRemoteConfiguration) == true
		expect(sut.storedConfiguration) == .default
		expect(sut.isLoading) == false
	}

	func test_update_neverFetchedBefore_doesNotCallbackImmediately() {
		
		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _, _) = makeSUT()
		userSettingsSpy.stubbedConfigFetchedTimestamp = nil
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, RemoteConfiguration.default.data, URLResponse())), ())
		var didNotHitCallback = true

		// Act 
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(networkSpy.invokedGetRemoteConfiguration) == true
		expect(sut.storedConfiguration) == .default
		expect(sut.isLoading) == false
	}

	func test_update_withinTTL_butOutsideMinimumRefreshInterval_doesRefresh() throws {

		// Arrange:
		let (sut, networkSpy, userSettingsSpy, _, secureUserSettingsSpy, _) = makeSUT()
		// Put in place a "previously loaded" config:
		let existingStoredConfig = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedHash = existingStoredConfig.hash
		secureUserSettingsSpy.stubbedStoredConfiguration = existingStoredConfig
		
		// Now perform a request to fetch a "new config":
		// within TTL but outside minimum interval, to fetch the `newConfig`:
		var newConfig = RemoteConfiguration.default
		newConfig.recommendedVersion = "2.0.0"

		// (within TTL (3600) but outside minimum interval (300)):
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(400 * seconds * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfig, newConfig.data, URLResponse())), ())

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?
		var didCallTTLCallback: Bool = false
		sut.update(
			isAppLaunching: false,
			immediateCallbackIfWithinTTL: { didCallTTLCallback = true },
			completion: { result in
			receivedResult = result
		})

		// Assert
		expect(didCallTTLCallback) == true
		expect(receivedResult).to(beSuccess {
			expect($0) == (true, newConfig)
		})
		
		expect(secureUserSettingsSpy.invokedStoredConfigurationList.last) == newConfig
		expect(sut.isLoading) == false
	}

	func test_update_withinTTL_withinMinimumRefreshInterval_doesNotRefresh() {

		// Arrange:
		let (sut, networkSpy, userSettingsSpy, _, secureUserSettingsSpy, _) = makeSUT()
		// Put in place a "previously loaded" config:
		let existingStoredConfig = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedHash = existingStoredConfig.hash
		secureUserSettingsSpy.stubbedStoredConfiguration = existingStoredConfig

		// Setup the real test:
		// within TTL but outside minimum interval
		var newConfig = RemoteConfiguration.default
		newConfig.recommendedVersion = "2.0.0"

		// (within TTL (3600) and minimum interval (300)):
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(5 * seconds * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfig, newConfig.data, URLResponse())), ())

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?
		var didCallTTLCallback: Bool = false
		sut.update(
			isAppLaunching: false,
			immediateCallbackIfWithinTTL: { didCallTTLCallback = true },
			completion: { result in
			receivedResult = result
		})

		// Assert
		expect(didCallTTLCallback) == true
		expect(receivedResult).to(beSuccess {
			expect($0) == (false, existingStoredConfig)
		})

		expect(secureUserSettingsSpy.invokedStoredConfigurationSetter) == false
		expect(sut.isLoading) == false
	}

	func test_update_withinTTL_withinMinimumRefreshInterval_onAppFirstLaunch_doesRefresh_withNewConfig() {

		// Arrange:
		let (sut, networkSpy, userSettingsSpy, _, secureUserSettingsSpy, _) = makeSUT()
		// Put in place a "previously loaded" config:
		let existingStoredConfig = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedHash = existingStoredConfig.hash
		secureUserSettingsSpy.stubbedStoredConfiguration = existingStoredConfig
		
		// Now perform a request to fetch a "new config":
		// within TTL but outside minimum interval, to fetch the `newConfig`:
		var newConfig = RemoteConfiguration.default
		newConfig.recommendedVersion = "2.0.0"

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(5 * seconds * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfig, newConfig.data, URLResponse())), ())

		// Add observer callbacks:
		var reloadObserverReceivedConfiguration: RemoteConfiguration?
		var updateObserverReceivedConfiguration: RemoteConfiguration?

		_ = sut.observatoryForReloads.append { result in
			reloadObserverReceivedConfiguration = result.successValue?.0
		}
		_ = sut.observatoryForUpdates.append { remoteConfiguration, _, _, _ in
			updateObserverReceivedConfiguration = remoteConfiguration
		}

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?
		var didCallTTLCallback: Bool = false
		sut.update(
			isAppLaunching: true,
			immediateCallbackIfWithinTTL: { didCallTTLCallback = true },
			completion: { result in
			receivedResult = result
		})

		// Assert
		expect(didCallTTLCallback) == true
		
		expect(receivedResult).to(beSuccess {
			expect($0) == (true, newConfig)
		})

		expect(secureUserSettingsSpy.invokedStoredConfiguration) == newConfig
		expect(sut.isLoading) == false

		expect(reloadObserverReceivedConfiguration) == newConfig
		expect(updateObserverReceivedConfiguration) == newConfig
	}

	func flaky_test_update_withinTTL_withinMinimumRefreshInterval_onAppFirstLaunch_doesRefresh_withUnchangedConfig() {

		// Arrange:
		let (sut, networkSpy, userSettingsSpy, _, secureUserSettingsSpy, appVersionSupplierSpy) = makeSUT()
		// Put in place a "previously loaded" config:
		let existingStoredConfig = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedHash = existingStoredConfig.hash! + appVersionSupplierSpy.getCurrentBuild() + appVersionSupplierSpy.getCurrentVersion()
		secureUserSettingsSpy.stubbedStoredConfiguration = existingStoredConfig
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((existingStoredConfig, existingStoredConfig.data, URLResponse())), ())
		
		// (within TTL (3600) and minimum interval (300)):
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(5 * seconds * ago).timeIntervalSince1970

		// Add observer callbacks:
		var reloadObserverReceivedConfiguration: RemoteConfiguration?
		var updateObserverReceivedConfiguration: RemoteConfiguration?

		_ = sut.observatoryForReloads.append { result in
			reloadObserverReceivedConfiguration = result.successValue?.0
		}
		_ = sut.observatoryForUpdates.append { remoteConfiguration, _, _, _ in
			updateObserverReceivedConfiguration = remoteConfiguration
		}

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?
		var didCallTTLCallback: Bool = false
		sut.update(
			isAppLaunching: true,
			immediateCallbackIfWithinTTL: { didCallTTLCallback = true },
			completion: { result in
			receivedResult = result
		})

		// Assert
		expect(didCallTTLCallback) == true

		guard (receivedResult?.successValue)! == (false, existingStoredConfig) else {
			fail("Didn't receive expected result \(String(describing: receivedResult))")
			return
		}

		expect(sut.storedConfiguration) == existingStoredConfig
		expect(sut.isLoading) == false

		expect(reloadObserverReceivedConfiguration) == existingStoredConfig
		expect(updateObserverReceivedConfiguration) == nil // no update so no callback expected here.
	}

	func test_doesNotLoadWhenAlreadyLoading() {

		// Arrange
		let (sut, networkSpy, _, _, _, _) = makeSUT()
		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

		// Assert
		expect(networkSpy.invokedGetRemoteConfigurationCount) == 1
	}

	func test_networkFailure_callsback_networkFailure() {

		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _, _) = makeSUT()
		let serverError = ServerError.error(statusCode: 500, response: nil, error: .invalidResponse)
		let result: Result<(RemoteConfiguration, Data, URLResponse), ServerError> = .failure(serverError)

		userSettingsSpy.stubbedConfigFetchedTimestamp = nil
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (result, ())

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?

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
		let (sut, networkSpy, userSettingsSpy, _, _, _) = makeSUT()
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, RemoteConfiguration.default.data, URLResponse())), ())

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

		// Assert
		expect(userSettingsSpy.invokedConfigFetchedTimestamp) == now.timeIntervalSince1970
		expect(sut.isLoading) == false
	}

	func flaky_test_update_unchangedConfig_returnsFalse_updatesObservers() {

		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _, appVersionSupplierSpy) = makeSUT()
		let configuration = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		userSettingsSpy.stubbedConfigFetchedHash = configuration.hash! + appVersionSupplierSpy.getCurrentBuild() + appVersionSupplierSpy.getCurrentVersion()
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((configuration, configuration.data, URLResponse())), ())

		var reloadObserverReceivedConfiguration: RemoteConfiguration?
		var updateObserverReceivedConfiguration: RemoteConfiguration?

		_ = sut.observatoryForReloads.append { result in
			reloadObserverReceivedConfiguration = result.successValue?.0
		}
		_ = sut.observatoryForUpdates.append { remoteConfiguration, _, _, _ in
			updateObserverReceivedConfiguration = remoteConfiguration
		}

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?

		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			receivedResult = result
		})

		guard (receivedResult?.successValue)! == (false, configuration) else {
			fail("Didn't receive expected result \(String(describing: receivedResult))")
			return
		}

		expect(reloadObserverReceivedConfiguration).toEventually(equal(configuration))
		expect(updateObserverReceivedConfiguration).toEventually(beNil())
		expect(sut.isLoading) == false
	}

	func test_update_changedConfig_returnsTrue_updatesObservers() {
	
		// Arrange
		let (sut, networkSpy, userSettingsSpy, _, _, _) = makeSUT()
		let newConfiguration: RemoteConfiguration = {
			var config = RemoteConfiguration.default
			config.recommendedVersion = "2.0.0"
			return config
		}()

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfiguration, newConfiguration.data, URLResponse())), ())

		var reloadObserverReceivedConfiguration: RemoteConfiguration?
		var updateObserverReceivedConfiguration: RemoteConfiguration?

		_ = sut.observatoryForReloads.append { result in
			reloadObserverReceivedConfiguration = result.successValue?.0
		}
		_ = sut.observatoryForUpdates.append { remoteConfiguration, _, _, _ in
			updateObserverReceivedConfiguration = remoteConfiguration
		}

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?

		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			receivedResult = result
		})
		expect(receivedResult).to(beSuccess {
			expect($0) == (true, newConfiguration)
		})
		expect(reloadObserverReceivedConfiguration).toEventually(equal(newConfiguration))
		expect(updateObserverReceivedConfiguration).toEventually(equal(newConfiguration))
		expect(sut.isLoading) == false
	}

	func test_reachability() {

		// Arrange
		let (sut, networkSpy, _, reachabilitySpy, _, _) = makeSUT()
		expect(networkSpy.invokedGetRemoteConfigurationCount) == 0
		sut.registerTriggers()

		// Act
		reachabilitySpy.invokedWhenReachable?(try! Reachability()) // swiftlint:disable:this force_try

		// Assert
		expect(networkSpy.invokedGetRemoteConfigurationCount) == 1
	}
}

// swiftlint:enable type_body_length

extension RemoteConfiguration {

	var data: Data {
		return try! JSONEncoder().encode(self) // swiftlint:disable:this force_try
	}

	var hash: String? {
		guard let string = String(data: data, encoding: .utf8) else { return nil }
		return string.sha256
	}
}
