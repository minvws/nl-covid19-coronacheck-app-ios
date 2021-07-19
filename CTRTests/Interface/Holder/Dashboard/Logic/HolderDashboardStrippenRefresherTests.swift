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

private let now = Date(timeIntervalSince1970: 1626361359)
private let ago: TimeInterval = -1
private let fromNow: TimeInterval = 1
private let seconds: TimeInterval = 1
private let minutes: TimeInterval = 60
private let hours: TimeInterval = 60 * minutes
private let days: TimeInterval = hours * 24

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
		greencardLoader.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(.serverBusy), ())

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
		expect(self.sut.state.loadingState) == .failed(error: .greencardLoaderError(error: .serverBusy))
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.serverErrorOccurenceCount) == 1

		sut.load()
		expect(self.sut.state.serverErrorOccurenceCount) == 2

		// Fix network
		greencardLoader.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(()), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		sut.load()

		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.serverErrorOccurenceCount) == 2
	}

	func test_noInternet() {

		// Arrange `expiring` starting state
		walletManagerSpy.loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		greencardLoader.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(.noInternetConnection), ())

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
		expect(self.sut.state.serverErrorOccurenceCount) == 0

		// simulate reachability restoration

		greencardLoader.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(()), ())
		walletManagerSpy.loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)

		// Callback is set on `invokedWhenReachable`:
		reachabilitySpy.invokedWhenReachable?(try! Reachability()) // swiftlint:disable:this force_try
		expect(self.sut.state.greencardsCredentialExpiryState) == .noActionNeeded
		expect(self.sut.state.loadingState) == .idle
		expect(self.sut.state.hasLoadingEverFailed) == true
		expect(self.sut.state.serverErrorOccurenceCount) == 0
	}
}

extension WalletManagerSpy {

	func loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.testDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.testDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.testDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticCredentialsExpiredWithNoMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.testDomesticCredentialsExpiredWithNoMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticCredentialsExpiringWithNoMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.testDomesticCredentialsExpiringWithNoMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}
}

extension GreenCard {

	static func testDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.test(eventTime: 8 * days * ago, expirationTime: 40 * days * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.test(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 1 * days * ago, expirationTime: 0 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 0 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 1 * days * fromNow, expirationTime: 2 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 2 * days * fromNow, expirationTime: 3 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 3 * days * fromNow, expirationTime: 4 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 4 * days * fromNow, expirationTime: 5 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 5 * days * fromNow, expirationTime: 6 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 6 * days * fromNow, expirationTime: 7 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 7 * days * fromNow, expirationTime: 8 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 8 * days * fromNow, expirationTime: 9 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 9 * days * fromNow, expirationTime: 10 * days * fromNow, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	static func testDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.test(eventTime: 8 * days * ago, expirationTime: 30 * days * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.test(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 1 * days * ago, expirationTime: 0 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 0 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 1 * days * fromNow, expirationTime: 2 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 2 * days * fromNow, expirationTime: 3 * days * fromNow, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	static func testDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.test(eventTime: 8 * days * ago, expirationTime: 30 * days * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.test(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	static func testDomesticCredentialsExpiringWithNoMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.test(eventTime: 8 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.test(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 1 * days * ago, expirationTime: 0 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 1 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	static func testDomesticCredentialsExpiredWithNoMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.test(eventTime: 8 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.test(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.test(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager)
		]
		return greencard
	}
}

extension Origin {
	static func test(eventTime: TimeInterval, expirationTime: TimeInterval, dataStoreManager: DataStoreManager) -> Origin {
		let origin = Origin(context: dataStoreManager.managedObjectContext())
		origin.type = OriginType.vaccination.rawValue
		origin.eventDate = now.addingTimeInterval(eventTime)
		origin.validFromDate = origin.eventDate
		origin.expirationTime = now.addingTimeInterval(expirationTime)
		return origin
	}
}

extension Credential {
	static func test(validFrom: TimeInterval, expirationTime: TimeInterval, dataStoreManager: DataStoreManager) -> Credential {
		let credential = Credential(context: dataStoreManager.managedObjectContext())
		credential.data = "".data(using: .utf8)
		credential.version = 1337
		credential.validFrom = now.addingTimeInterval(validFrom)
		credential.expirationTime = now.addingTimeInterval(expirationTime)
		return credential
	}
}
