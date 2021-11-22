/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import CoreData
@testable import CTR
import Nimble
import Reachability

class HolderDashboardStrippenRefresherTests: XCTestCase {

	/// Subject under test
	var sut: DashboardStrippenRefresher!

	var walletManagerSpy: WalletManagerSpy!
	var greencardLoaderSpy: GreenCardLoaderSpy!
	var dataStoreManager: DataStoreManager!
	var reachabilitySpy: ReachabilitySpy!

	override func setUp() {
		super.setUp()

		walletManagerSpy = WalletManagerSpy()
		greencardLoaderSpy = GreenCardLoaderSpy()
		dataStoreManager = DataStoreManager(.inMemory)
		reachabilitySpy = ReachabilitySpy()

		Services.use(greencardLoaderSpy)
		Services.use(walletManagerSpy)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	// MARK: - Test calculations

	func test_expiring_calculates_state_expiring_and_loads() {

		// Arrange
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act
		sut.load()

		// Assert
		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .loading(silently: true)
		expect(self.sut.state.isNonsilentlyLoading) == false
	}

	func test_expired_calculates_state_expired_and_loads() {
		// Arrange
		walletManagerSpy.loadDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act
		sut.load()

		// Assert
		expect(self.sut.state.greencardsCredentialExpiryState) == .expired
		expect(self.sut.state.loadingState) == .loading(silently: false)
		expect(self.sut.state.isNonsilentlyLoading) == true
	}

	func test_expiring_with_expiring_origin_calculates_state_noActionNeeded_and_doesnt_load() {
		// Arrange
		walletManagerSpy.loadDomesticCredentialsExpiredWithNoMoreToFetch(dataStoreManager: dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act
		sut.load()

		// Assert
		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
	}

	// MARK: - Test loading

	func test_loadingSuccess_setsNewState_becoming_noActionNeeded() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		// Act
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
	}

	func test_loadingFailure_setsErrorFlags_canBeRecovered() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(NetworkError.serverBusy), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .failed(error: .networkError(error: .serverBusy, timestamp: now))
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 1

		sut.load()
		expect(self.sut.state.errorOccurenceCount) == 2

		// Fix network
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 2
	}

	func test_noInternet() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(NetworkError.noInternetConnection), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .noInternet
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 0

		// simulate reachability restoration

		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		// Callback is set on `invokedWhenReachable`:
		reachabilitySpy.invokedWhenReachable?(try! Reachability()) // swiftlint:disable:this force_try
		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 0
	}

	func test_serverError_serverBusy() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.preparingIssue(ServerError.error(statusCode: 429, response: nil, error: .serverBusy))), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .failed(error: .networkError(error: .serverBusy, timestamp: now))
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 1

		sut.load()
		expect(self.sut.state.errorOccurenceCount) == 2

		// Fix network
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 2
	}

	func test_serverResponseDidNotChangeExpiredOrExpiringState() {
		// Arrange
		walletManagerSpy.loadDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act
		sut.load()

		// Assert
		expect(self.sut.state.greencardsCredentialExpiryState) == .expired
		expect(self.sut.state.loadingState) == .failed(error: .serverResponseDidNotChangeExpiredOrExpiringState)
		expect(self.sut.state.isNonsilentlyLoading) == false
	}

	func test_serverError_shouldRetryIfAppReturnsFromBackgroundAfterTenMinutes() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.preparingIssue(ServerError.error(statusCode: 429, response: nil, error: .serverBusy))), ())

		var fakeNow: Date = now

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { fakeNow }
		)

		// Act & Assert
		sut.load()
		expect(self.greencardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentialsCount) == 1
		expect(self.sut.state.greencardsCredentialExpiryState) == .expired
		expect(self.sut.state.loadingState) == .failed(error: .networkError(error: .serverBusy, timestamp: now))

		// Simulate return from the background after five minutes:
		fakeNow = now.addingTimeInterval(5 * minutes * fromNow)
		NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

		// Should not have retried
		expect(self.greencardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentialsCount) == 1

		// Simulate return from the background after more than ten minutes:
		fakeNow = now.addingTimeInterval(11 * minutes * fromNow)
		NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
		expect(self.greencardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentialsCount) == 2
	}

	func test_serverError_invalidSignature() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.preparingIssue(ServerError.error(statusCode: nil, response: nil, error: .invalidSignature))), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .failed(error: DashboardStrippenRefresher.Error.networkError(error: .invalidSignature, timestamp: now))
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 1

		sut.load()
		expect(self.sut.state.errorOccurenceCount) == 2

		// Fix network
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 2
	}

	func test_failedToSave() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.failedToSaveGreenCards), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState)
			== .failed(error: DashboardStrippenRefresher.Error.greencardLoaderError(error: .failedToSaveGreenCards))
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 1

		sut.load()
		expect(self.sut.state.errorOccurenceCount) == 2

		// Fix network
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 2
	}

	func test_serverError_noInternetConnection() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.preparingIssue(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection))), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .noInternet
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 0

		// simulate reachability restoration

		greencardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		// Callback is set on `invokedWhenReachable`:
		reachabilitySpy.invokedWhenReachable?(try! Reachability()) // swiftlint:disable:this force_try
		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 0
	}

	// MARK: Zero Credentials
	// Test the jansen introduction where the greencard had zero credentials due to a 28 day waiting period.

	func test_greencard_withZeroInitialCredentials_shouldNotBeReloadedWhenOutsideTheThreshold() {

		// Arrange with zero initial credentials
		walletManagerSpy.loadDomesticEmptyCredentialsWithDistantFutureValidity(dataStoreManager: dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
		expect(self.sut.state.hasLoadingEverFailed) == false
		expect(self.sut.state.errorOccurenceCount) == 0
		expect(self.greencardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentials) == false
	}

	// Test the jansen introduction where the greencard had zero credentials due to a 28 day waiting period.
	func test_greencard_withZeroInitialCredentials_shouldBeReloadedWhenInsideTheThreshold() {

		// Arrange with zero initial credentials
		walletManagerSpy.loadDomesticEmptyCredentialsWithImminentFutureValidity(dataStoreManager: dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy,
			now: { now }
		)

		expect(self.greencardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentials) == false

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expired
		expect(self.sut.state.loadingState) == .loading(silently: false)
		expect(self.sut.state.hasLoadingEverFailed) == false
		expect(self.sut.state.errorOccurenceCount) == 0
		expect(self.greencardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentials) == true
	}

	let validGreenCardResponse = RemoteGreenCards.Response(
		domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
			origins: [
				RemoteGreenCards.Origin(
					type: "vaccination",
					eventTime: Date(),
					expirationTime: Date().addingTimeInterval(60 * days * fromNow),
					validFrom: Date(),
					doseNumber: 1
				)
			],
			createCredentialMessages: "validGreenCardResponse"
		),
		euGreenCards: [
			RemoteGreenCards.EuGreenCard(
				origins: [
					RemoteGreenCards.Origin(
						type: "vaccination",
						eventTime: Date(),
						expirationTime: Date().addingTimeInterval(60 * days * fromNow),
						validFrom: Date(),
						doseNumber: nil
					)
				],
				credential: "validGreenCardResponse"
			)
		]
	)
}
