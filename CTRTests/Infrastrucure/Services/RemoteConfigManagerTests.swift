/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
import Nimble
import Reachability

class RemoteConfigManagerTests: XCTestCase {
	
	// MARK: - Setup
	private var sut: RemoteConfigManager!
	private var networkSpy: NetworkSpy!
	private var userSettingsSpy: UserSettingsSpy!
	private var reachabilitySpy: ReachabilitySpy!
	private var secureUserSettingsSpy: SecureUserSettingsSpy!
	private var appVersionSupplierSpy: AppVersionSupplierSpy!
	private var fileStorageSpy: FileStorageSpy!
	
	override func setUp() {

		networkSpy = NetworkSpy()
		userSettingsSpy = UserSettingsSpy()
		reachabilitySpy = ReachabilitySpy()
		secureUserSettingsSpy = SecureUserSettingsSpy()
		secureUserSettingsSpy.stubbedStoredConfiguration = .default
		appVersionSupplierSpy = AppVersionSupplierSpy(version: "1", build: "1")
		fileStorageSpy = FileStorageSpy()
		
		fileStorageSpy.stubbedReadResult = nil
		
		sut = RemoteConfigManager(
			now: { now },
			userSettings: userSettingsSpy,
			reachability: reachabilitySpy,
			networkManager: networkSpy,
			secureUserSettings: secureUserSettingsSpy,
			fileStorage: fileStorageSpy,
			appVersionSupplier: appVersionSupplierSpy
		)
		
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
			self.sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
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
			self.networkSpy.stubbedGetRemoteConfigurationCompletionResult = (.success((RemoteConfiguration.default, RemoteConfiguration.default.data, URLResponse())), ())
			// When
			self.sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
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
		expect(self.networkSpy.invokedGetRemoteConfiguration) == true
		expect(self.sut.storedConfiguration) == .default
		expect(self.sut.isLoading) == false
	}

	func test_update_notWithinTTL_doesNotCallbackImmediately() {
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, RemoteConfiguration.default.data, URLResponse())), ())
		var didNotHitCallback = true

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(self.networkSpy.invokedGetRemoteConfiguration) == true
		expect(self.sut.storedConfiguration) == .default
		expect(self.sut.isLoading) == false
	}

	func test_update_neverFetchedBefore_doesNotCallbackImmediately() {
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = nil
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, RemoteConfiguration.default.data, URLResponse())), ())
		var didNotHitCallback = true

		// Act 
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {
			didNotHitCallback = false
		}, completion: { _ in })

		// Assert
		expect(didNotHitCallback) == true
		expect(self.networkSpy.invokedGetRemoteConfiguration) == true
		expect(self.sut.storedConfiguration) == .default
		expect(self.sut.isLoading) == false
	}

	func test_update_withinTTL_butOutsideMinimumRefreshInterval_doesRefresh() throws {

		// Arrange:
		// Put in place a "previously loaded" config:
		let existingStoredConfig = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedHash = existingStoredConfig.hash
		secureUserSettingsSpy.stubbedStoredConfiguration = existingStoredConfig
		
		// Now perform a request to fetch a "new config":
		// within TTL but outside minimum interval, to fetch the `newConfig`:
		var newConfig = RemoteConfiguration.default
		newConfig.minimumVersionMessage = "This was changed"

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
		
		expect(self.secureUserSettingsSpy.invokedStoredConfigurationList.last) == newConfig
		expect(self.sut.isLoading) == false
	}

	func test_update_withinTTL_withinMinimumRefreshInterval_doesNotRefresh() {

		// Arrange:
		// Put in place a "previously loaded" config:
		let existingStoredConfig = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedHash = existingStoredConfig.hash
		secureUserSettingsSpy.stubbedStoredConfiguration = existingStoredConfig

		// Setup the real test:
		// within TTL but outside minimum interval
		var newConfig = RemoteConfiguration.default
		newConfig.minimumVersionMessage = "This was changed"

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

		expect(self.secureUserSettingsSpy.invokedStoredConfigurationSetter) == false
		expect(self.sut.isLoading) == false
	}

	func test_update_withinTTL_withinMinimumRefreshInterval_onAppFirstLaunch_doesRefresh_withNewConfig() {

		// Arrange:
		// Put in place a "previously loaded" config:
		let existingStoredConfig = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedHash = existingStoredConfig.hash
		secureUserSettingsSpy.stubbedStoredConfiguration = existingStoredConfig
		
		// Now perform a request to fetch a "new config":
		// within TTL but outside minimum interval, to fetch the `newConfig`:
		var newConfig = RemoteConfiguration.default
		newConfig.minimumVersionMessage = "This was changed"

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(5 * seconds * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfig, newConfig.data, URLResponse())), ())

		// Add observer callbacks:
		var reloadObserverReceivedConfiguration: RemoteConfiguration?
		var updateObserverReceivedConfiguration: RemoteConfiguration?

		_ = sut.observatoryForReloads.append { result in
			reloadObserverReceivedConfiguration = result.successValue?.0
		}
		_ = sut.observatoryForUpdates.append { remoteConfiguration, _, _ in
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

		expect(self.secureUserSettingsSpy.invokedStoredConfiguration) == newConfig
		expect(self.sut.isLoading) == false

		expect(reloadObserverReceivedConfiguration) == newConfig
		expect(updateObserverReceivedConfiguration) == newConfig
	}

	func test_update_withinTTL_withinMinimumRefreshInterval_onAppFirstLaunch_doesRefresh_withUnchangedConfig() {

		// Arrange:
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
		_ = sut.observatoryForUpdates.append { remoteConfiguration, _, _ in
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

		expect(self.sut.storedConfiguration) == existingStoredConfig
		expect(self.sut.isLoading) == false

		expect(reloadObserverReceivedConfiguration) == existingStoredConfig
		expect(updateObserverReceivedConfiguration) == nil // no update so no callback expected here.
	}

	func test_doesNotLoadWhenAlreadyLoading() {
		// Arrange

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

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
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, RemoteConfiguration.default.data, URLResponse())), ())

		// Act
		sut.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })

		// Assert
		expect(self.userSettingsSpy.invokedConfigFetchedTimestamp) == now.timeIntervalSince1970
		expect(self.sut.isLoading) == false
	}

	func test_update_unchangedConfig_returnsFalse_updatesObservers() {
		// Arrange
		
		let configuration = RemoteConfiguration.default
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		userSettingsSpy.stubbedConfigFetchedHash = configuration.hash! + appVersionSupplierSpy.getCurrentBuild() + appVersionSupplierSpy.getCurrentVersion()
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((configuration, configuration.data, URLResponse())), ())

		var reloadObserverReceivedConfiguration: RemoteConfiguration?
		var updateObserverReceivedConfiguration: RemoteConfiguration?

		_ = sut.observatoryForReloads.append { result in
			reloadObserverReceivedConfiguration = result.successValue?.0
		}
		_ = sut.observatoryForUpdates.append { remoteConfiguration, _, _ in
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
		expect(self.sut.isLoading) == false
	}

	func test_update_changedConfig_returnsTrue_updatesObservers() {
		// Arrange
		let newConfiguration: RemoteConfiguration = {
			var config = RemoteConfiguration.default
			config.minimumVersionMessage = "this config has changed"
			return config
		}()

		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(20 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((newConfiguration, newConfiguration.data, URLResponse())), ())

		var reloadObserverReceivedConfiguration: RemoteConfiguration?
		var updateObserverReceivedConfiguration: RemoteConfiguration?

		_ = sut.observatoryForReloads.append { result in
			reloadObserverReceivedConfiguration = result.successValue?.0
		}
		_ = sut.observatoryForUpdates.append { remoteConfiguration, _, _ in
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
		expect(self.sut.isLoading) == false
	}

	func test_reachability() {

		// Arrange
		expect(self.networkSpy.invokedGetRemoteConfigurationCount) == 0
		sut.registerTriggers()
		
		// Act
		reachabilitySpy.invokedWhenReachable?(try! Reachability()) // swiftlint:disable:this force_try

		// Assert
		expect(self.networkSpy.invokedGetRemoteConfigurationCount) == 1
	}
}

extension RemoteConfiguration {

	var data: Data {
		return try! JSONEncoder().encode(self) // swiftlint:disable:this force_try
	}

	var hash: String? {
		guard let string = String(data: data, encoding: .utf8) else { return nil }
		return string.sha256
	}
}
