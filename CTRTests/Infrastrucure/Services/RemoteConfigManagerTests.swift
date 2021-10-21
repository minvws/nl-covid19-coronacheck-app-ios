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
			self.sut.update(immediateCallbackIfWithinTTL: {
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
			self.sut.update(immediateCallbackIfWithinTTL: {
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
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, Data(), URLResponse())), ())
		var hitCallback = false

		// Act
		sut.update {
			hitCallback = true
		} completion: { _ in
			// should be true by the time this completion is called:
			expect(hitCallback) == true
		}

		// Assert
		expect(hitCallback) == true
		expect(self.networkSpy.invokedGetRemoteConfiguration) == true
	}

	func test_update_notWithinTTL_doesNotCallbackImmediately() {
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = now.addingTimeInterval(40 * days * ago).timeIntervalSince1970
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, Data(), URLResponse())), ())
		var didNotHitCallback = true

		// Act
		sut.update {
			didNotHitCallback = false
		} completion: { _ in }

		// Assert
		expect(didNotHitCallback) == true
		expect(self.networkSpy.invokedGetRemoteConfiguration) == true
	}

	func test_update_neverFetchedBefore_doesNotCallbackImmediately() {
		// Arrange
		userSettingsSpy.stubbedConfigFetchedTimestamp = nil
		networkSpy.stubbedGetRemoteConfigurationCompletionResult = (Result.success((RemoteConfiguration.default, Data(), URLResponse())), ())
		var didNotHitCallback = true

		// Act 
		sut.update {
			didNotHitCallback = false
		} completion: { _ in }

		// Assert
		expect(didNotHitCallback) == true
		expect(self.networkSpy.invokedGetRemoteConfiguration) == true
	}

	func test_doesNotLoadWhenAlreadyLoading() {
		// Arrange

		// Act
		sut.update {} completion: { _ in }
		sut.update {} completion: { _ in }

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

		sut.update { } completion: { result in
			receivedResult = result
		}

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
		sut.update { } completion: { _ in }

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

		sut.update { } completion: { result in
			receivedResult = result
		}

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

		sut.update { } completion: { result in
			receivedResult = result
		}

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
