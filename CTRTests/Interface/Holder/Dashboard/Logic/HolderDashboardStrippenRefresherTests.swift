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
	var greencardLoader: GreenCardLoaderSpy!
	var dataStoreManager: DataStoreManager!
	var reachabilitySpy: ReachabilitySpy!

	override func setUp() {
		super.setUp()

		walletManagerSpy = WalletManagerSpy()
		greencardLoader = GreenCardLoaderSpy()
		dataStoreManager = DataStoreManager(.inMemory)
		reachabilitySpy = ReachabilitySpy()
	}

	// MARK: - Test calculations

	func test_expiring_calculates_state_expiring_and_loads() {

		// Arrange
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			walletManager: walletManagerSpy,
			greencardLoader: greencardLoader,
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
			walletManager: walletManagerSpy,
			greencardLoader: greencardLoader,
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
			walletManager: walletManagerSpy,
			greencardLoader: greencardLoader,
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
		greencardLoader.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(()), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			walletManager: walletManagerSpy,
			greencardLoader: greencardLoader,
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
		greencardLoader.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(NetworkError.serverBusy), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			walletManager: walletManagerSpy,
			greencardLoader: greencardLoader,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expiring(deadline: now.addingTimeInterval(3 * days * fromNow))
		expect(self.sut.state.loadingState) == .failed(error: .networkError(error: .serverBusy))
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 1

		sut.load()
		expect(self.sut.state.errorOccurenceCount) == 2

		// Fix network
		greencardLoader.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(()), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.errorOccurenceCount) == 2
	}

	func test_noInternet() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoader.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(NetworkError.noInternetConnection), ())

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			walletManager: walletManagerSpy,
			greencardLoader: greencardLoader,
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

		greencardLoader.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(()), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		// Callback is set on `invokedWhenReachable`:
		reachabilitySpy.invokedWhenReachable?(try! Reachability()) // swiftlint:disable:this force_try
		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
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
			walletManager: walletManagerSpy,
			greencardLoader: greencardLoader,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
		expect(self.sut.state.hasLoadingEverFailed) == false
		expect(self.sut.state.errorOccurenceCount) == 0
	}

	// Test the jansen introduction where the greencard had zero credentials due to a 28 day waiting period.
	func test_greencard_withZeroInitialCredentials_shouldBeReloadedWhenInsideTheThreshold() {

		// Arrange with zero initial credentials
		walletManagerSpy.loadDomesticEmptyCredentialsWithImminentFutureValidity(dataStoreManager: dataStoreManager)

		sut = DashboardStrippenRefresher(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: 5,
			walletManager: walletManagerSpy,
			greencardLoader: greencardLoader,
			reachability: reachabilitySpy,
			now: { now }
		)

		// Act & Assert
		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .expired
		expect(self.sut.state.loadingState) == .loading(silently: false)
		expect(self.sut.state.hasLoadingEverFailed) == false
		expect(self.sut.state.errorOccurenceCount) == 0
	}
}
