/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import CoreData
@testable import CTR
@testable import Transport
@testable import Shared
import Nimble
import Reachability

class HolderDashboardStrippenRefresherTests: XCTestCase {

	/// Subject under test
	var sut: DashboardStrippenRefresher!
	private var environmentSpies: EnvironmentSpies!
	var reachabilitySpy: ReachabilitySpy!

	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		reachabilitySpy = ReachabilitySpy()
	}

	// MARK: - Test calculations

	func test_expiring_calculates_state_expiring_and_loads() {

		// Arrange
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
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
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
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
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiredWithNoMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
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
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

		// Act
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.environmentSpies.walletManagerSpy.invokedStoreBlockedEvent) == false
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlertSetterCount) == 0
	}

	func test_loadingSuccess_persistsMatchingBlockedEvents() throws {
		
		// Arrange `expiring` starting state
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		
		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		let eventGroup = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		var greencardResponse = validGreenCardResponse
		greencardResponse.blobExpireDates = [RemoteGreenCards.BlobExpiry(
			identifier: eventGroup!.uniqueIdentifier,
			expirationDate: .distantPast,
			reason: "event_blocked"
		)]
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(greencardResponse), ())
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup!]
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()

		// Act
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.environmentSpies.walletManagerSpy.invokedStoreBlockedEventParameters?.eventDate) == DateFormatter.Event.iso8601.date(from: "2021-06-01")!
		expect(self.environmentSpies.walletManagerSpy.invokedStoreBlockedEventParameters?.type) == .vaccination
		expect(self.environmentSpies.walletManagerSpy.invokedStoreBlockedEventParameters?.reason) == "event_blocked"
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlert) == false // invoked with `false`
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlertSetterCount) == 1 // once
	}

	func test_loadingFailure_setsErrorFlags_canBeRecovered() {

		// Arrange `expiring` starting state
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToParsePrepareIssue), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .failed(error: .greencardLoaderError(error: .failedToParsePrepareIssue))
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 1

		sut.load()
		expect(self.sut.state.errorOccurenceCount) == 2

		// Fix network
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 2
	}

	func test_noInternet() {

		// Arrange `expiring` starting state
		let greencardLoaderError = GreenCardLoader.Error.preparingIssue(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection))
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(greencardLoaderError), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .noInternet
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 0

		// simulate reachability restoration

		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

		// Callback is set on `invokedWhenReachable`:
		reachabilitySpy.invokedWhenReachable?(try! Reachability()) // swiftlint:disable:this force_try
		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 0
	}

	func test_serverError_serverBusy() {

		// Arrange `expiring` starting state
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.preparingIssue(ServerError.error(statusCode: 429, response: nil, error: .serverBusy))), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
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
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 2
	}

	func test_serverResponseDidNotChangeExpiredOrExpiringState() {
		// Arrange
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		// Act
		sut.load()

		// Assert
		expect(self.sut.state.greencardsCredentialExpiryState) == .expired
		expect(self.sut.state.loadingState) == .serverResponseHasNoChanges
		expect(self.sut.state.isNonsilentlyLoading) == false
	}

	func test_serverError_shouldRetryIfAppReturnsFromBackgroundAfterTenMinutes() {

		// Arrange `expiring` starting state
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.preparingIssue(ServerError.error(statusCode: 429, response: nil, error: .serverBusy))), ())

		var fakeNow: Date = now
		Current.now = { fakeNow }

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		// Act & Assert
		sut.load()
		expect(self.environmentSpies.greenCardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentialsCount) == 1
		expect(self.sut.state.greencardsCredentialExpiryState) == .expired
		expect(self.sut.state.loadingState) == .failed(error: .networkError(error: .serverBusy, timestamp: now))

		// Simulate return from the background after five minutes:
		fakeNow = now.addingTimeInterval(5 * minutes * fromNow)
		NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

		// Should not have retried
		expect(self.environmentSpies.greenCardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentialsCount) == 1

		// Simulate return from the background after more than ten minutes:
		fakeNow = now.addingTimeInterval(11 * minutes * fromNow)
		NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
		expect(self.environmentSpies.greenCardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentialsCount) == 2
	}

	func test_serverError_invalidSignature() {

		// Arrange `expiring` starting state
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.preparingIssue(ServerError.error(statusCode: nil, response: nil, error: .invalidSignature))), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
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
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 2
	}

	func test_failedToSave() {

		// Arrange `expiring` starting state
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.failedToSaveGreenCards), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
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
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .completed
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 2
	}

	func test_serverError_noInternetConnection() {

		// Arrange `expiring` starting state
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
			(.failure(GreenCardLoader.Error.preparingIssue(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection))), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .noInternet
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 0

		// simulate reachability restoration

		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(validGreenCardResponse), ())
		environmentSpies.walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)

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
		environmentSpies.walletManagerSpy.loadDomesticEmptyCredentialsWithDistantFutureValidity(dataStoreManager: environmentSpies.dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
		expect(self.sut.state.hasLoadingEverFailed) == false
		expect(self.sut.state.errorOccurenceCount) == 0
		expect(self.environmentSpies.greenCardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentials) == false
	}

	// Test the jansen introduction where the greencard had zero credentials due to a 28 day waiting period.
	func test_greencard_withZeroInitialCredentials_shouldBeReloadedWhenInsideTheThreshold() {

		// Arrange with zero initial credentials
		environmentSpies.walletManagerSpy.loadDomesticEmptyCredentialsWithImminentFutureValidity(dataStoreManager: environmentSpies.dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		expect(self.environmentSpies.greenCardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentials) == false

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expired
		expect(self.sut.state.loadingState) == .loading(silently: false)
		expect(self.sut.state.hasLoadingEverFailed) == false
		expect(self.sut.state.errorOccurenceCount) == 0
		expect(self.environmentSpies.greenCardLoaderSpy.invokedSignTheEventsIntoGreenCardsAndCredentials) == true
	}

	// MARK: - International Paper Based
	
	func test_paperbased_withoutValidCredentail_calculates_state_noActionNeeded() {
		// Arrange
		environmentSpies.walletManagerSpy.loadInternationalPaperbasedxpiringIn24Days(dataStoreManager: environmentSpies.dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		// Act
		sut.load()

		// Assert
		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
	}
	
	func test_paperbased_withValidCredential_calculates_state_noActionNeeded() {
		// Arrange
		environmentSpies.walletManagerSpy.loadInternationalPaperbasedxpiringIn24DaysWithValidCredential(dataStoreManager: environmentSpies.dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			reachability: reachabilitySpy
		)

		// Act
		sut.load()

		// Assert
		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
	}
	
	// MARK: - helpers
	
	let validGreenCardResponse = RemoteGreenCards.Response(
		domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
			origins: [
				RemoteGreenCards.Origin(
					type: "vaccination",
					eventTime: Date(),
					expirationTime: Date().addingTimeInterval(60 * days * fromNow),
					validFrom: Date(),
					doseNumber: 1,
					hints: []
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
						doseNumber: nil,
						hints: []
					)
				],
				credential: "validGreenCardResponse"
			)
		],
		blobExpireDates: [],
		hints: []
	)
}
