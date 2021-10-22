/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class RemoteConfigManagerTests: XCTestCase {
	
	// MARK: - Setup
	private var sut: RemoteConfigManager!
	private var networkSpy: NetworkSpy!
	private var userSettingsSpy: UserSettingsSpy!

	override func setUp() {

		networkSpy = NetworkSpy(configuration: .development)
		userSettingsSpy = UserSettingsSpy()

		sut = RemoteConfigManager(now: { now }, userSettings: userSettingsSpy, networkManager: networkSpy)
		sut.reset()
		
		super.setUp()
	}
	
	override func tearDown() {
		
		super.tearDown()
	}

	// MARK: - Tests

	/// Test the remote config manager update call no result from the api
	func test_remoteConfigManagerUpdate_errorFromApi() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.failure(.error(statusCode: nil, response: nil, error: .invalidRequest)), ())

			// When
			self.sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {
				//
			}, completion: { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state.isFailure) == true
				done()
			})
		}
	}

	/// Test the remote config manager update call with succss
	func test_remoteConfigManagerUpdate_success() {

		// Given
		waitUntil(timeout: .seconds(10)) { done in
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((RemoteConfiguration.default, Data(), URLResponse())), ())
			// When
			self.sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {
				//
			}, completion: { state in

				// Then
				expect(self.networkSpy.invokedGetRemoteConfiguration) == true
				expect(state.isSuccess) == true
				done()
			})
		}
	}

	func test_update_withinTTL_callsbackImmediately() {
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(10 * minutes * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, Data(), URLResponse())), ())
		var hitCallback = false

		// Act
		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {
			hitCallback = true
		}, completion: { _ in
			// should be true by the time this completion is called:
			expect(hitCallback) == true
		})

		// Assert
		expect(hitCallback) == true
		expect(self.networkSpy.invokedGetRemoteConfiguration) == true
		expect(self.sut.storedConfiguration) == .default
	}

	func test_update_notWithinTTL_doesNotCallbackImmediately() {
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, Data(), URLResponse())), ())
		var didNotHitCallback = true

		// Act
		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(self.networkSpy.invokedGetRemoteConfiguration) == true
		expect(self.sut.storedConfiguration) == .default
	}

	func test_update_neverFetchedBefore_doesNotCallbackImmediately() {
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = nil
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, Data(), URLResponse())), ())
		var didNotHitCallback = true

		// Act 
		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(self.networkSpy.invokedGetRemoteConfiguration) == true
		expect(self.sut.storedConfiguration) == .default
	}

	func test_update_withinTTL_butOutsideMinimumRefreshInterval_doesRefresh() {

		// Load a new configuration into RemoteConfigurationManager to start with
		// (currently not an easy way to change it from using .default)
		var config = RemoteConfiguration.default
		config.configMinimumIntervalSeconds = 60
		config.configTTL = 3600

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((config, Data(), URLResponse())), ())

		var completedFirstLoad = false
		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			if case .success((true, _)) = result {
				completedFirstLoad = true
			}
		})
		expect(completedFirstLoad).toEventually(beTrue())

		// Setup the real test:
		// within TTL but outside minimum interval
		var newConfig = RemoteConfiguration.default
		newConfig.minimumVersionMessage = "This was changed"

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(100 * seconds * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfig, Data(), URLResponse())), ())

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?
		var didCallTTLCallback: Bool = false
		sut.update(
			isAppFirstLaunch: false,
			immediateCallbackIfWithinTTL: { didCallTTLCallback = true },
			completion: { result in
			receivedResult = result
		})

		// Assert
		expect(didCallTTLCallback) == true
		switch receivedResult {
			case .success((true, newConfig)): break
			default:
				assertionFailure("Didn't receive expected result")
		}

		expect(self.sut.storedConfiguration) == newConfig
	}

	func test_update_withinTTL_withinMinimumRefreshInterval_doesNotRefresh() {

		// Load a new configuration into RemoteConfigurationManager to start with
		// (currently not an easy way to change it from using .default)
		var firstConfig = RemoteConfiguration.default
		firstConfig.configMinimumIntervalSeconds = 60
		firstConfig.configTTL = 3600

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((firstConfig, Data(), URLResponse())), ())

		var completedFirstLoad = false
		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			if case .success((true, _)) = result {
				completedFirstLoad = true
			}
		})
		expect(completedFirstLoad).toEventually(beTrue())

		// Setup the real test:
		// within TTL but outside minimum interval
		var newConfig = RemoteConfiguration.default
		newConfig.minimumVersionMessage = "This was changed"

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(5 * seconds * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfig, Data(), URLResponse())), ())

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?
		var didCallTTLCallback: Bool = false
		sut.update(
			isAppFirstLaunch: false,
			immediateCallbackIfWithinTTL: { didCallTTLCallback = true },
			completion: { result in
			receivedResult = result
		})

		// Assert
		expect(didCallTTLCallback) == true

		switch receivedResult {
			case .success((false, firstConfig)): break
			default:
				assertionFailure("Didn't receive expected result")
		}

		expect(self.sut.storedConfiguration) == firstConfig
	}

	func test_update_withinTTL_withinMinimumRefreshInterval_onAppFirstLaunch_doesRefresh() {

		// Load a new configuration into RemoteConfigurationManager to start with
		// (currently not an easy way to change it from using .default)
		var firstConfig = RemoteConfiguration.default
		firstConfig.configMinimumIntervalSeconds = 60
		firstConfig.configTTL = 3600

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((firstConfig, Data(), URLResponse())), ())

		var completedFirstLoad = false
		sut.update(isAppFirstLaunch: true, immediateCallbackIfWithinTTL: {}, completion: { result in
			if case .success((true, _)) = result {
				completedFirstLoad = true
			}
		})
		expect(completedFirstLoad).toEventually(beTrue())

		// Setup the real test:
		// within TTL but outside minimum interval
		var newConfig = RemoteConfiguration.default
		newConfig.minimumVersionMessage = "This was changed"

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(5 * seconds * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfig, Data(), URLResponse())), ())

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?
		var didCallTTLCallback: Bool = false
		sut.update(
			isAppFirstLaunch: true,
			immediateCallbackIfWithinTTL: { didCallTTLCallback = true },
			completion: { result in
			receivedResult = result
		})

		// Assert
		expect(didCallTTLCallback) == true

		switch receivedResult {
			case .success((true, newConfig)): break
			default:
				assertionFailure("Didn't receive expected result")
		}

		expect(self.sut.storedConfiguration) == newConfig
	}

	func test_doesNotLoadWhenAlreadyLoading() {
		// Arrange

		// Act
		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })
		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

		// Assert
		expect(self.networkSpy.invokedGetRemoteConfigurationCount) == 1
	}

	func test_networkFailure_callsback_networkFailure() {

		// Arrange
		let serverError = ServerError.error(statusCode: 500, response: nil, error: .invalidResponse)
		let result: Result<(RemoteConfiguration, Data, URLResponse), ServerError> = .failure(serverError)

		userSettingsSpy.stubbedConfigFetchedTimestamp = nil
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (result, ())

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?

		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			receivedResult = result
		})

		// Assert
		switch receivedResult {
			case .failure(let error) where serverError == error: break
			default:
				assertionFailure("results didn't match")
		}
	}

	func test_update_updatesConfigFetchedTimestamp() {
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, Data(), URLResponse())), ())

		// Act
		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

		// Assert
		expect(self.userSettingsSpy.invokedConfigFetchedTimestamp) == now.timeIntervalSince1970
	}

	func test_update_unchangedConfig_returnsFalse_updatesObservers() {
		// Arrange
		let configuration = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((configuration, Data(), URLResponse())), ())

		var reloadObserverReceivedConfiguration: RemoteConfiguration?
		var updateObserverReceivedConfiguration: RemoteConfiguration?

		_ = sut.appendReloadObserver { remoteConfiguration, _, _ in
			reloadObserverReceivedConfiguration = remoteConfiguration
		}
		_ = sut.appendUpdateObserver { remoteConfiguration, _, _ in
			updateObserverReceivedConfiguration = remoteConfiguration
		}

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?

		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			receivedResult = result
		})

		switch receivedResult {
			case .success((false, let receivedConfiguration)) where receivedConfiguration == configuration:
				break
			default:
				assertionFailure("results didn't match")
		}

		expect(reloadObserverReceivedConfiguration).toEventually(equal(configuration))
		expect(updateObserverReceivedConfiguration).toEventually(beNil())
	}

	func test_update_changedConfig_returnsTrue_updatesObservers() {
		// Arrange
		let newConfiguration: RemoteConfiguration = {
			var config = RemoteConfiguration.default
			config.minimumVersionMessage = "this config has changed"
			return config
		}()

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfiguration, Data(), URLResponse())), ())

		var reloadObserverReceivedConfiguration: RemoteConfiguration?
		var updateObserverReceivedConfiguration: RemoteConfiguration?

		_ = sut.appendReloadObserver { remoteConfiguration, _, _ in
			reloadObserverReceivedConfiguration = remoteConfiguration
		}
		_ = sut.appendUpdateObserver { remoteConfiguration, _, _ in
			updateObserverReceivedConfiguration = remoteConfiguration
		}

		// Act
		var receivedResult: Result<(Bool, RemoteConfiguration), ServerError>?

		sut.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: {}, completion: { result in
			receivedResult = result
		})

		switch receivedResult {
			case .success((true, let receivedConfiguration)) where receivedConfiguration == newConfiguration:
				break
			default:
				assertionFailure("results didn't match")
		}

		expect(reloadObserverReceivedConfiguration).toEventually(equal(newConfiguration))
		expect(updateObserverReceivedConfiguration).toEventually(equal(newConfiguration))
	}

}
